use Mix.Config

config :data, Data.Repo,
  database: "healthdesk_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  migration_primary_key: [id: :uuid, type: :binary_id],
  migration_timestamps: [type: :utc_datetime]

# Print only warnings and errors during test
config :logger, level: :warn
