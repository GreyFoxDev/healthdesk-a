use Mix.Config

config :main, MainWeb.Endpoint,
  load_from_system_env: true,
  url: [scheme: "https", host: "healthdesk-ai.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")

config :logger, level: :info

config :main, MainWeb.Auth.Guardian,
  issuer: "MainWeb",
  ttl: {1, :days},
  secret_key:  Map.fetch!(System.get_env(), "SECRET_KEY_BASE")

config :main, MainWeb.Auth.AuthAccessPipeline,
  module: MainWeb.Auth.Guardian,
  error_handler: MainWeb.Auth.AuthErrorHandler

config :ex_aws,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  bucket: System.get_env("AWS_BUCKET")
