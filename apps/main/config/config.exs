# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :main,
  namespace: Main

config :main, Main.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_API_KEY")

config :phoenix, :json_library, Jason

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Configures the endpoint
config :main, MainWeb.Endpoint,
  url: [scheme: "http", host: "localhost", port: 4000],
  check_origin: false,
  secret_key_base: "z0HlXKVQRJoAEUI1h6E/u5b0uuQOQucLm2gG7PdJGQbQW4UO/B3eaaTu3OsW+Bpp",
  render_errors: [view: MainWeb.ErrorView, accepts: ~w(html json)],
  live_view: [
    signing_salt: "e2coiRnvsrcguHHbgcQDoK4pOKj1x3Il92sTetEUUMjSS1gTu+DNLH0rlWOCdjox"
  ],
  pubsub: [name: Main.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :tesla, adapter: Tesla.Adapter.Hackney

config :ueberauth, Ueberauth,
       providers: [
         google: {Ueberauth.Strategy.Google, [request_path: "/admin/teams/:team_id/locations/:location_id/:provider",
           callback_path: "/admin/teams/:team_id/locations/:location_id/:provider/callback"] }
       ]
config :ueberauth, Ueberauth.Strategy.Google.OAuth,
       client_id: System.get_env("GOOGLE_CLIENT_ID"),
       client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :honeybadger,
  api_key: System.get_env("HONEYBADGER_API_KEY")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
