use Mix.Config

config :ex_twilio,
  account_sid: Map.fetch!(System.get_env(), "TWILIO_ACCOUNT_SID"),
  auth_token: Map.fetch!(System.get_env(), "TWILIO_AUTH_TOKEN"),
  authy_key: Map.fetch!(System.get_env(), "AUTHY_API_KEY")

# Do not print debug messages in production
config :logger, level: :info
