package handlers

import (
	_ "embed"
	"html/template"
	"net/http"
)

//go:embed templates/dashboard.html
var dashboardHTML string

type DashboardPageHandler struct {
	tpl *template.Template
}

func NewDashboardPageHandler() (*DashboardPageHandler, error) {
	tpl, err := template.New("dashboard").Parse(dashboardHTML)
	if err != nil {
		return nil, err
	}

	return &DashboardPageHandler{
		tpl: tpl,
	}, nil
}

func (h *DashboardPageHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch {
	case r.Method == http.MethodGet && r.URL.Path == "/analytics/admin/dashboard":
		h.handleDashboardPage(w, r)
		return
	default:
		http.NotFound(w, r)
		return
	}
}

func (h *DashboardPageHandler) handleDashboardPage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := h.tpl.Execute(w, nil); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}