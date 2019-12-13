defmodule WitClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :wit_client,
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

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {WitClient.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:inflex, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:elixir_wit, "~> 2.0.0"}
    ]
  end
end
