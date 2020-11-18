defmodule Main.Mixfile do
  use Mix.Project

  def project do
    [
      app: :main,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Main.Application, []},
      extra_applications: [:logger, :runtime_tools, :con_cache, :data, :chatbot, :nimble_csv, :honeybadger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bamboo, "~> 1.4"},
      {:bitly, "~> 0.1"},
      {:phoenix, "~> 1.4.9"},
      {:cors_plug, "~> 2.0"},
      {:csv, "~> 2.3"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_ecto, "~> 4.1"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:calendar, "~> 0.17.4"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_live_view, "~> 0.14.0"},
      {:honeybadger, "~> 0.13.1"},
      {:gettext, "~> 0.11"},
      {:guardian, "~> 1.0"},
      {:con_cache, "~> 0.13.0"},
      {:data, in_umbrella: true},
      {:chatbot, in_umbrella: true},
      {:wit_client, in_umbrella: true},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.16"},
      {:sweet_xml, "~> 0.6"},
      {:elixir_uuid, "~> 1.2"},
      {:nimble_csv, "~> 0.5.0"},
      {:jason, "~> 1.0"},
      {:tesla, "~> 1.3.0"},
      {:quantum, "~> 3.0"},
      {:eximap, "~> 0.1.2-dev"}
    ]
  end
end
