use Mix.Config

config :main, MainWeb.Endpoint,
  load_from_system_env: true,
  url: [scheme: "https", host: "healthdesk-ai.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")

config :logger, level: :info
