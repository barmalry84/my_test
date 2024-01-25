import { getApp } from './app'
import { config } from './utils/env'

const hasMessage = (error: unknown): error is { message: unknown } =>
  typeof error === 'object' && error !== null && 'message' in error

async function start() {
  const app = await getApp()

  try {
    await app.listen({
      host: "0.0.0.0",
      port: 3000,
    })
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (err: any) {
    app.log.error(hasMessage(err) ? err.message : err)
    process.exit(1)
  }
}

void start()
