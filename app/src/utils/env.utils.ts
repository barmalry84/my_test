export function getStringEnvVar(key: string, defaultValue?: string): string {
  const environment = process.env.ENV || 'qa'

  if (key === 'ENV') {
    return environment
  }

  if (process.env[key]) {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    return process.env[key]!
  }

  if (defaultValue !== undefined) {
    return defaultValue
  }

  throw new Error(`Could not resolve environment variable ${key}. Tried ${key} in .env file.`)
}

export function getBooleanEnvVar(key: string, defaultValue?: boolean): boolean {
  const value = getStringEnvVar(key, defaultValue?.toString())

  return value === 'true'
}

export function getNumberEnvVar(key: string, defaultValue?: number): number {
  const value = getStringEnvVar(key, defaultValue?.toString())

  return Number(value)
}
