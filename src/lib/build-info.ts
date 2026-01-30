/* Vite define injects __BUILD_TIMESTAMP__ and __BUILD_FINGERPRINT__ at build time */
declare const __BUILD_TIMESTAMP__: string | undefined
declare const __BUILD_FINGERPRINT__: string | undefined

export const buildInfo = {
  version: (import.meta.env.VITE_APP_VERSION as string | undefined) || 'dev',
  buildCommit: (import.meta.env.VITE_BUILD_COMMIT as string | undefined) || null,
  timestamp: typeof __BUILD_TIMESTAMP__ !== 'undefined' ? __BUILD_TIMESTAMP__ : null,
  fingerprint: typeof __BUILD_FINGERPRINT__ !== 'undefined' ? __BUILD_FINGERPRINT__ : 'dev',
}
