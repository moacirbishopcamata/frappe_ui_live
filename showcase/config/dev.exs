import Config

config :showcase, ShowcaseWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4010],
  check_origin: false,
  debug_errors: true,
  # Somente desenvolvimento: este app é um mostruário local e não guarda dados.
  secret_key_base:
    "showcase-dev-only-secret-key-base-0123456789-0123456789-0123456789-0123456789",
  server: true

config :phoenix, :stacktrace_depth, 20
config :phoenix_live_view, enable_expensive_runtime_checks: true
