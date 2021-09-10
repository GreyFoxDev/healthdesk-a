use Mix.Config

config :main, MainWeb.Endpoint,
       http: [port: 4000],
       https: [
         port: 4001,
         cipher_suite: :strong,
         certfile: "priv/cert/selfsigned.pem",
         keyfile: "priv/cert/selfsigned_key.pem"
       ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
    cd: Path.expand("../assets", __DIR__)]]

config :main, Main.Mailer,
  adapter: Bamboo.LocalAdapter

# Watch static and templates for browser reloading.
config :main, MainWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/main_web/views/.*(ex)$},
      ~r{lib/main_web/templates/.*(eex)$},
      ~r{lib/my_app_web/live/.*(ex)$}
    ]
  ]
config :logger, level: :debug
config :logger, :console, format: "[$level] $message\n $metadata \n", metadata: [:module, :function, :line]

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

config :bitly, access_token: System.get_env("BITLY_ACCESS_TOKEN")

config :main,
  super_admin: System.get_env("SUPER_ADMIN_PHONE"),
  endpoint: "http://b07ad92e.ngrok.io",
  mindbody_api_key: System.get_env("MINDBODY_API_KEY")

