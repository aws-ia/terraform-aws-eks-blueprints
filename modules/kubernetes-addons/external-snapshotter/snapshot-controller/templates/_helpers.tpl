{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "snapshot-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "snapshot-controller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "snapshot-controller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "snapshot-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "snapshot-controller.labels" -}}
helm.sh/chart: {{ include "snapshot-controller.chart" . }}
{{ include "snapshot-controller.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
role.sportradar.com/core: "1"
{{- end -}}
