import createNextIntlPlugin from 'next-intl/plugin'
import type { NextConfig } from 'next'

const withNextIntl = createNextIntlPlugin()

// PWA は public/manifest.json と public/sw.js を直接配置して提供している。
// (以前ここに experimental.pwa を指定していたが、Next.js にそのオプションは
//  存在せず next-pwa も未導入のため、何も行われていなかった)
const config: NextConfig = {
  reactStrictMode: true,
  transpilePackages: ['@ape/shared'],
}

export default withNextIntl(config)
