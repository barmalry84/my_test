# People Info API

## Intro

The People Info API is a small API based on Fastify and Typescript. API allows to receive data and posts it to DynamoDB. It also uses Redis cluster as cache layer between application and database.

## Prerequisites

- Node.js 20+
- DynamoDB already created and runs in AWS (**app_iac** stack)
- Redis cluster already created and runs in AWS (**app_iac** stack)

Note that current code implementation has DynamoDb and Redis as hard requirements. Application will fail to start without them.

## Running locally

```sh
npm install
cp .env.example .env
npm run start
```
Visit `localhost:3000/status` in browser

or

```sh
docker build -t people-info-api .
docker run -p 3000:3000 people-info-api
```

Note: 
1. If application runs locally, it will have issues with connecting to Redis cluster as it is running in AWS VPC. There are ways to workaround this:
- mock redis cluster while running locally 
- create IP forwarding via AWS NATs to Redis
- use VPN connection to VPC to access its internals.
- just comment Redis code part before running application locally.
In a scope of the task, it's proposed to use last option.
2. For running DynamoDb locally, it's possible to use [DynamoDB Local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html). But in a scope of the task it was not done.

## Running in AWS (proposed way to test)

## How to use app



