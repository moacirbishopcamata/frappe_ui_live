import Config

# O mostruário é uma ferramenta de desenvolvimento; para publicá-lo, defina
# SECRET_KEY_BASE e PHX_HOST no ambiente.
config :showcase, ShowcaseWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT") || "4010")],
  url: [host: System.get_env("PHX_HOST") || "localhost", port: 443, scheme: "https"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  server: true
