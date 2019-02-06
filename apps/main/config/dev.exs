use Mix.Config

config :main, MainWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../assets", __DIR__)]]


# Watch static and templates for browser reloading.
config :main, MainWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/main_web/views/.*(ex)$},
      ~r{lib/main_web/templates/.*(eex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :main, MainWeb.Auth.Guardian,
  issuer: "MainWeb",
  ttl: {1, :days},
  secret_key: "sdqPGAptdPcv7NyjXyIe5QE/MBHb8DnCxM4uW5eW/urij1mZaV4BY94ofqfhWUBv"

config :main, MainWeb.Auth.AuthAccessPipeline,
  module: MainWeb.Auth.Guardian,
  error_handler: MainWeb.Auth.AuthErrorHandler

config :ex_aws,
  access_key_id: System.get_env("HD_AWS_ACCESS_KEY"),
  secret_access_key: System.get_env("HD_AWS_SECRET_ACCESS_KEY"),
  bucket: System.get_env("HD_AWS_BUCKET")
