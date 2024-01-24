import { getApp } from './app'

describe('Fastify server', () => {
  let app: any

  beforeAll(async () => {
    app = await getApp()
  })

  afterAll(async () => {
    await app.close()
  })

  it('Returns health check information', async () => {
    const response = await app.inject().get('/status').end()

    expect(response.statusCode).toBe(200)
  })

  it('Returns Prometheus metrics', async () => {
    const response = await app.inject().get('/metrics').end()

    expect(response.statusCode).toBe(200)
  })
})
