import type http from 'http'

import AWS from 'aws-sdk'
import fastify from 'fastify'
import type { FastifyInstance } from 'fastify'
import type { FastifyHealthcheckOptions } from 'fastify-healthcheck'
import healthcheck from 'fastify-healthcheck'
import metricsPlugin from 'fastify-metrics'
import fastifyNoIcon from 'fastify-no-icon'
import Redis from 'ioredis'
import type pino from 'pino'

import { config } from './utils/env'

const redis = new Redis({ host: config.REDIS_HOST, port: config.REDIS_PORT })

const DocumentClient = new AWS.DynamoDB.DocumentClient({
  endpoint: config.DYNAMODB_ENDPOINT,
  region: config.DYNAMODB_REGION,
})

export async function getApp(): Promise<
  FastifyInstance<http.Server, http.IncomingMessage, http.ServerResponse, pino.Logger>
> {
  const app = fastify<http.Server, http.IncomingMessage, http.ServerResponse, pino.Logger>()

  // Metrics endpoint
  await app.register(metricsPlugin, { endpoint: '/metrics' })

  await app.register(fastifyNoIcon)

  // Healthcheck endpoint

  const healthcheckOptions: FastifyHealthcheckOptions = {
    healthcheckUrl: '/status',
  }

  await app.register(healthcheck, healthcheckOptions)

  // DynamoDB Endpoint to Fetch Data
  app.get('/data', async (request, reply) => {
    try {
      const { person_surname } = request.query as { person_surname?: string }
      if (!person_surname) {
        return reply.status(400).send({ error: 'person_surname query parameter is required' })
      }

      // Check if data is in Redis
      const cachedData = await redis.get(`people_info:${person_surname}`)
      if (cachedData) {
        // If data is in Redis, return it
        return reply.send(JSON.parse(cachedData))
      }

      const params = {
        TableName: 'PeopleInfo',
        KeyConditionExpression: 'person_surname = :personSurname',
        ExpressionAttributeValues: {
          ':personSurname': person_surname,
        },
      }
      const data = await DocumentClient.query(params).promise()
      await redis.set(`people_info:${person_surname}`, JSON.stringify(data.Items))
      reply.send(data.Items)
    } catch (error) {
      reply.status(500).send({ error: 'Failed to fetch data from DynamoDB or Redis' })
    }
  })

  // DynamoDB Endpoint to Save Data
  app.post('/data', async (request, reply) => {
    try {
      const {
        person_name,
        person_surname,
        person_birthdate,
        person_address,
      }: Record<string, string> = request.body as Record<string, string>
      if (!person_name || !person_surname || !person_birthdate || !person_address) {
        return reply.status(400).send({ error: 'Missing required fields' })
      }
      const params = {
        TableName: 'PeopleInfo',
        Item: {
          person_name,
          person_surname,
          person_birthdate,
          person_address,
        },
      }

      await DocumentClient.put(params).promise()

      // Store data in Redis for future requests
      await redis.set(`people_info:${person_surname}`, JSON.stringify(request.body))

      reply.send(request.body)
      console.log('Response:', request.body)
    } catch (error) {
      console.log('Error:', error)
      reply.status(500).send({ error: 'Failed to insert data into DynamoDB' })
    }
  })

  // app.setErrorHandler(errorHandler)

  try {
    await app.ready()
  } catch (err) {
    app.log.error('Error while initializing app: ', err)
    throw err
  }

  return app
}
