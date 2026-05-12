package store

import "github.com/alexandra-gritsaenko/gymbro-workouts/types"

func exerciseDisplayNameExpr(tableAlias string, locale string) string {
	if locale == types.LocaleRU {
		return tableAlias + ".name"
	}
	return "COALESCE(" + tableAlias + ".name_en, " + tableAlias + ".name)"
}
