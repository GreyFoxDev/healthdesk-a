use Mix.Config

config :data,
       Data.ReadOnly.Repo,
       database: "healthdesk_dev",
       migration_primary_key: [id: :uuid, type: :binary_id],
       migration_timestamps: [type: :utc_datetime],
       username: "postgres",
       password: "postgres"


config :data,
       Data.WriteOnly.Repo,
       database: "healthdesk_dev",
       migration_primary_key: [id: :uuid, type: :binary_id],
       migration_timestamps: [type: :utc_datetime],
       username: "postgres",
       password: "postgres"
