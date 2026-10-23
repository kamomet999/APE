import { defineRouting } from 'next-intl/routing'
import { i18n } from '../../i18n.config'

// ロケールの定義は i18n.config.ts を単一の出典とする
export const routing = defineRouting({
  locales: i18n.locales,
  defaultLocale: i18n.defaultLocale,
  localePrefix: 'as-needed',
})
