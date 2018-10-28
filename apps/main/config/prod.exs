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
