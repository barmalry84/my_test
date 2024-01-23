import { getStringEnvVar, getNumberEnvVar } from './env.utils'

export const config = {
  ENV: getStringEnvVar('ENV'),
  HOST: getStringEnvVar('HOST'),
  PORT: getNumberEnvVar('PORT')
}
