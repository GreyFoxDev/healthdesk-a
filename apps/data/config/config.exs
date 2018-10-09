use Mix.Config

config :data,
  ecto_repos: [Data.ReadOnly.Repo, Data.WriteOnly.Repo]

import_config "#{Mix.env()}.exs"
