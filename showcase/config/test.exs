import Config

config :showcase, ShowcaseWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4011],
  secret_key_base:
    "showcase-test-only-secret-key-base-0123456789-0123456789-0123456789-0123456789",
  server: false

config :logger, level: :warning
config :phoenix_live_view, enable_expensive_runtime_checks: true
