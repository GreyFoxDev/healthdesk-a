defmodule MainWeb.Presence do
  use Phoenix.Presence,
      otp_app: :main,
      pubsub_server: Main.PubSub
end