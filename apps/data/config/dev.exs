use Mix.Config

config :data,
       Data.ReadOnly.Repo,
       username: "postgres",
       password: "postgres",
       database: "healthdesk_dev",
       migration_primary_key: [id: :uuid, type: :binary_id],
       migration_timestamps: [type: :utc_datetime]

config :data,
       Data.WriteOnly.Repo,
       username: "postgres",
       password: "postgres",
       database: "healthdesk_dev",
       migration_primary_key: [id: :uuid, type: :binary_id],
       migration_timestamps: [type: :utc_datetime]
