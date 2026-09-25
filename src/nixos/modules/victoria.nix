{config, lib, ...}: let
  self = config.jaidCustomModules.victoria.self;

  remote = {
    VICTORIA_LOGS_QUERY_ENDPOINT = "https://logs.nas.lan/api/query";
    VICTORIA_TRACES_QUERY_ENDPOINT = "https://traces.nas.lan/select/logsql/query";
    VICTORIA_METRICS_QUERY_ENDPOINT = "https://vmui.metrics.nas.lan/api/v1/query";
    VICTORIA_METRICS_QUERY_RANGE_ENDPOINT = "https://vmui.metrics.nas.lan/api/v1/query_range";
    VICTORIA_LOGS_INGESTION_ENDPOINT = "https://vmui.logs.nas.lan/insert/jsonline";
    VICTORIA_TRACES_INGESTION_ENDPOINT = "https://traces.nas.lan/insert/opentelemetry/v1/traces";
    VICTORIA_METRICS_INGESTION_ENDPOINT = "https://vmui.metrics.nas.lan/api/v1/import";
    OTEL_EXPORTER_OTLP_PROTOCOL = "http/protobuf";
    OTEL_EXPORTER_OTLP_LOGS_ENDPOINT = "https://vmui.logs.nas.lan/insert/opentelemetry/v1/logs";
    OTEL_EXPORTER_OTLP_TRACES_ENDPOINT = "https://traces.nas.lan/insert/opentelemetry/v1/traces";
    OTEL_EXPORTER_OTLP_METRICS_ENDPOINT = "https://vmui.metrics.nas.lan/opentelemetry/v1/metrics";
  };

  local = remote // {
    VICTORIA_LOGS_QUERY_ENDPOINT = "http://127.0.0.1:3301/select/logsql/query";
    VICTORIA_TRACES_QUERY_ENDPOINT = "http://127.0.0.1:3303/select/logsql/query";
    VICTORIA_METRICS_QUERY_ENDPOINT = "http://127.0.0.1:3304/api/v1/query";
    VICTORIA_METRICS_QUERY_RANGE_ENDPOINT = "http://127.0.0.1:3304/api/v1/query_range";
    VICTORIA_LOGS_INGESTION_ENDPOINT = "http://127.0.0.1:3301/insert/jsonline";
    VICTORIA_TRACES_INGESTION_ENDPOINT = "http://127.0.0.1:3303/insert/opentelemetry/v1/traces";
    VICTORIA_METRICS_INGESTION_ENDPOINT = "http://127.0.0.1:3304/api/v1/import";
    OTEL_EXPORTER_OTLP_LOGS_ENDPOINT = "http://127.0.0.1:3301/insert/opentelemetry/v1/logs";
    OTEL_EXPORTER_OTLP_TRACES_ENDPOINT = "http://127.0.0.1:3303/insert/opentelemetry/v1/traces";
    OTEL_EXPORTER_OTLP_METRICS_ENDPOINT = "http://127.0.0.1:3304/opentelemetry/v1/metrics";
  };
in {
  options.jaidCustomModules.victoria.self = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Use local Victoria endpoints on the Victoria host";
  };

  config.environment.sessionVariables =
    if self
    then local
    else remote;
}
