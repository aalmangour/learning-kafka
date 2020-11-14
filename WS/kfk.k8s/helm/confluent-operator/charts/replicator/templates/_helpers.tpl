{{/*
Kafka configurations for Connect workers RBAC configurations
*/}}
{{- define "replicator.kafka-rbac-config" }}
{{- $_ := set $ "kafkaDependency" .Values.dependencies.kafka }}
{{- $protocol :=  (include "confluent-operator.kafka-external-advertise-protocol" .) | trim  }}
{{- $endpoint :=  (index (split ":" .Values.dependencies.kafka.bootstrapEndpoint) "_0") }}
{{- $bootstrap := printf "%s:9073" $endpoint }}
{{- if contains "SASL" $protocol }}
{{ printf "bootstrap.servers.admin=%s://%s" $protocol .Values.dependencies.kafka.bootstrapEndpoint }}
{{- else }}
{{- if contains "2WAYSSL" $protocol }}
{{ printf "bootstrap.servers.admin=SSL://%s" .Values.dependencies.kafka.bootstrapEndpoint }}
{{ else }}
{{ printf "bootstrap.servers.admin=%s://%s" $protocol .Values.dependencies.kafka.bootstrapEndpoint }}
{{- end }}
{{- end }}
{{- if and .Values.dependencies.kafka.tls.enabled  }}
{{ printf "bootstrap.servers=SASL_SSL://%s" $bootstrap }}
{{- else }}
{{ printf "bootstrap.servers=SASL_PLAINTEXT://%s" $bootstrap }}
{{- end }}
{{ include "confluent-operator.rbac-sasl-oauth-config" . | trim }}
{{- $_ := unset $ "kafkaDependency" }}
{{- end }}
{{/*
Kafka configurations for Replicator workers
*/}}
{{- define "replicator.kafka-config" }}
{{- if .Values.global.authorization.rbac.enabled }}
{{- include "replicator.kafka-rbac-config" . }}
{{- else }}
{{- $_ := set $ "kafkaDependency" .Values.dependencies.kafka }}
{{- $protocol :=  (include "confluent-operator.kafka-external-advertise-protocol" .) | trim  }}
{{- $bootstrap :=  .Values.dependencies.kafka.bootstrapEndpoint }}
{{- if contains "SASL" $protocol }}
{{ printf "bootstrap.servers=%s://%s" $protocol $bootstrap }}
{{- else }}
{{- if contains "2WAYSSL" $protocol }}
{{ printf "bootstrap.servers=SSL://%s" $bootstrap }}
{{ else }}
{{ printf "bootstrap.servers=%s://%s" $protocol $bootstrap }}
{{- end }}
{{- end }}
{{ include "confluent-operator.kafka-client-security" . | trim }}
{{- $_ := unset $ "kafkaDependency" }}
{{- end }}
{{- end }}

{{/*
Kafka Producer configurations
*/}}
{{- define "replicator.producer-config" }}
{{- $_ := set $ "kafkaDependency" .Values.dependencies.kafka }}
{{- if .Values.global.authorization.rbac.enabled }}
{{- $endpoint :=  (index (split ":" .Values.dependencies.kafka.bootstrapEndpoint) "_0") }}
{{ printf "producer.bootstrap.servers=%s:9073" $endpoint }}
{{- else }}
{{ printf "producer.bootstrap.servers=%s" .Values.dependencies.kafka.bootstrapEndpoint }}
{{- end }}
{{ include "confluent-operator.producer-security-config" . | trim }}
{{- $_ := unset $ "kafkaDependency" }}
{{- end }}

{{/*
Kafka Consumer configurations
*/}}
{{- define "replicator.consumer-config" }}
{{- $_ := set $ "kafkaDependency" .Values.dependencies.kafka }}
{{- if .Values.global.authorization.rbac.enabled }}
{{- $endpoint :=  (index (split ":" .Values.dependencies.kafka.bootstrapEndpoint) "_0") }}
{{ printf "consumer.bootstrap.servers=%s:9073" $endpoint }}
{{- else }}
{{ printf "consumer.bootstrap.servers=%s" .Values.dependencies.kafka.bootstrapEndpoint }}
{{- end }}
{{ include "confluent-operator.consumer-security-config" . | trim }}
{{- $_ := unset $ "kafkaDependency" }}
{{- end }}

{{/*
Kafka Producer-Interceptor configurations
*/}}
{{- define "replicator.producer-interceptor-config" }}
{{- if empty .Values.dependencies.interceptor.producer.bootstrapEndpoint }}
{{ printf "producer.confluent.monitoring.interceptor.bootstrap.servers=%s" .Values.dependencies.kafka.bootstrapEndpoint }}
{{- $_ := set $ "kafkaDependency" .Values.dependencies.kafka }}
{{- else }}
{{ printf "producer.confluent.monitoring.interceptor.bootstrap.servers=%s" .Values.dependencies.interceptor.producer.bootstrapEndpoint }}
{{- $_ := set $ "kafkaDependency" .Values.dependencies.interceptor.producer }}
{{- end }}
{{ include "confluent-operator.producer-interceptor-security-config" . | trim }}
{{ printf "producer.confluent.monitoring.interceptor.publishMs=%d" (.Values.dependencies.interceptor.publishMs | int64) }}
{{- $_ := unset $ "kafkaDependency" }}
{{- end }}


{{/*
Kafka Consumer-Interceptor configurations
*/}}
{{- define "replicator.consumer-interceptor-config" }}
{{- if empty .Values.dependencies.interceptor.consumer.bootstrapEndpoint }}
{{ printf "consumer.confluent.monitoring.interceptor.bootstrap.servers=%s" .Values.dependencies.kafka.bootstrapEndpoint }}
{{- $_ := set $ "kafkaDependency" .Values.dependencies.kafka }}
{{- else }}
{{ printf "consumer.confluent.monitoring.interceptor.bootstrap.servers=%s" .Values.dependencies.interceptor.consumer.bootstrapEndpoint }}
{{- $_ := set $ "kafkaDependency" .Values.dependencies.interceptor.consumer }}
{{- end }}
{{ include "confluent-operator.consumer-interceptor-security-config" . | trim }}
{{ printf "consumer.confluent.monitoring.interceptor.publishMs=%d" (.Values.dependencies.interceptor.publishMs | int64) }}
{{- $_ := unset $ "kafkaDependency" }}
{{- end }}
