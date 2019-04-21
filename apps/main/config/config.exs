# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :main,
  namespace: Main

config :phoenix, :json_library, Jason

# Configures the endpoint
config :main, MainWeb.Endpoint,
  url: [scheme: "http", host: "localhost", port: 4000],
  secret_key_base: "z0HlXKVQRJoAEUI1h6E/u5b0uuQOQucLm2gG7PdJGQbQW4UO/B3eaaTu3OsW+Bpp",
  render_errors: [view: MainWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Main.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
