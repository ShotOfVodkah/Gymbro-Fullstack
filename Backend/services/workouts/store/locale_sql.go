package store

import "github.com/alexandra-gritsaenko/gymbro-workouts/types"

// exerciseDisplayNameExpr returns a SQL fragment for the localized display name column.
// tableAlias must be a simple identifier (e.g. "e", "d").
func exerciseDisplayNameExpr(tableAlias string, locale string) string {
	if locale == types.LocaleRU {
		return tableAlias + ".name"
	}
	return "COALESCE(" + tableAlias + ".name_en, " + tableAlias + ".name)"
}
