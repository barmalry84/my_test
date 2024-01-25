import { getStringEnvVar, getNumberEnvVar } from './env.utils'

const prefix = getStringEnvVar('ENV') === 'aws' ? 'AWS' : 'LOCAL'

export const config = {
  ENV: getStringEnvVar('ENV'),
  DYNAMODB_REGION: getStringEnvVar(`${prefix}_DYNAMODB_REGION`),
  DYNAMODB_ENDPOINT: getStringEnvVar(`${prefix}_DYNAMODB_ENDPOINT`),
  REDIS_HOST: getStringEnvVar(`${prefix}_REDIS_HOST`),
  REDIS_PORT: getNumberEnvVar(`${prefix}_REDIS_PORT`),
}
