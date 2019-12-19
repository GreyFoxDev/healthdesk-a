defmodule Chatbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :chatbot,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :ex_twilio],
      mod: {Chatbot.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_twilio, git: "https://github.com/HealthdeskAI/ex_twilio.git"}
      # {:ex_twilio, "~> 0.8.1"}
    ]
  end
end
