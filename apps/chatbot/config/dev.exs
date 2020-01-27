use Mix.Config

config :ex_twilio,
  account_sid: Map.fetch!(System.get_env(), "DEV_TWILIO_ACCOUNT_SID"),
  auth_token: Map.fetch!(System.get_env(), "DEV_TWILIO_AUTH_TOKEN"),
  authy_key: Map.fetch!(System.get_env(), "AUTHY_API_KEY"),
  flex_account_sid: Map.fetch!(System.get_env(), "FLEX_TWILIO_ACCOUNT_SID"),
  flex_auth_token: Map.fetch!(System.get_env(), "FLEX_TWILIO_AUTH_TOKEN"),
  flex_service_id: Map.fetch!(System.get_env(), "FLEX_SERVICE_ID")

config :logger, level: :debug
