use Mix.Config

config :data,
       Data.ReadOnly.Repo,
       database: "healthdesk_dev",
       migration_primary_key: [id: :uuid, type: :binary_id],
       migration_timestamps: [type: :utc_datetime]

config :data,
       Data.WriteOnly.Repo,
       database: "healthdesk_dev",
       migration_primary_key: [id: :uuid, type: :binary_id],
       migration_timestamps: [type: :utc_datetime]
