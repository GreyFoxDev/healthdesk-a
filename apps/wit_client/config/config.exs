use Mix.Config

config :wit_client,
  access_token: Map.fetch!(System.get_env(), "WIT_ACCESS_TOKEN")
