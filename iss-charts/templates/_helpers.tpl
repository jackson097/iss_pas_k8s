{{/*
Expand the name of the chart.
*/}}
{{- define "iss-charts.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "iss-charts.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "iss-charts.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "iss-charts.labels" -}}
helm.sh/chart: {{ include "iss-charts.chart" . }}
{{ include "iss-charts.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "iss-charts.selectorLabels" -}}
app.kubernetes.io/name: {{ include "iss-charts.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "iss-charts.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "iss-charts.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Join a list of strings into a quoted array
*/}}
{{- define "quoted.array" -}}
{{- $local := dict "first" true -}}
{{- range . -}}{{- if not $local.first -}},{{- end -}}{{- . | quote -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}

{{/*
Converts a list of objects (e.g. from env) of the form

- name: namevalue
  value: actualvalue

to a ports listing suitable for container def.
*/}}
{{- define "ports.from.env" -}}
{{- $brokerPort := (include "value.by.name" (dict "values" .values "searchterm" "DB_BROKER_PORT") | int) -}}
{{- $minPort := (include "value.by.name" (dict "values" .values "searchterm" "DB_MINPORT") | int) -}}
{{- $maxPort := (include "value.by.name" (dict "values" .values "searchterm" "DB_MAXPORT") | int) -}}
{{- $dbName := .name -}}
{{- $protocol := .protocol -}}
{{- $portRange := (add (sub $maxPort $minPort) 1) | int -}}
- containerPort: {{ $brokerPort }}
  name: {{ $dbName }}
  protocol: {{ $protocol }}
{{- range $i := until $portRange }}
- containerPort: {{ add $minPort $i }}
  name: {{ $dbName }}{{ $i }}
  protocol: {{ $protocol }}
{{- end }}
{{- end -}}

{{/* 
Retrieves the value of an environment variable key
*/}}
{{- define "value.by.name" -}}
{{- $key := .searchterm -}}
{{- range .values }}
{{- if eq $key .name }}
{{- .value -}}
{{- end -}}
{{- end }}
{{- end -}}