package types

const LocaleRU = "ru"
const LocaleEN = "en"

func NormalizeLocale(s string) string {
	if s == LocaleRU {
		return LocaleRU
	}
	return LocaleEN
}
