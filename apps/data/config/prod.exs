use Mix.Config

config :data,
       Data.Repo,
       url: System.get_env("DATABASE_URL"),
       pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
       migration_primary_key: [id: :uuid, type: :binary_id],
       migration_timestamps: [type: :utc_datetime],
       ssl: true
