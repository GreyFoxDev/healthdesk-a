use Mix.Config

config :data,
       Data.Repo,
       database: "healthdesk_dev",
       migration_primary_key: [id: :uuid, type: :binary_id],
       migration_timestamps: [type: :utc_datetime],
       username: "postgres",
       password: "postgres"

# use Mix.Config
#
# config :data,
#       Data.ReadOnly.Repo,
#       url: "postgres://clnnsaxdlunhmp:f72aa8697637c46dbf9196f3405fbca95a51454591c296bcf381655cf7b3985a@ec2-3-211-250-230.compute-1.amazonaws.com:5432/d5r4nq28sov5fh",
#       pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
#       migration_primary_key: [id: :uuid, type: :binary_id],
#       migration_timestamps: [type: :utc_datetime],
#       ssl: true
#
# config :data,
#       Data.WriteOnly.Repo,
#       url: "postgres://clnnsaxdlunhmp:f72aa8697637c46dbf9196f3405fbca95a51454591c296bcf381655cf7b3985a@ec2-3-211-250-230.compute-1.amazonaws.com:5432/d5r4nq28sov5fh",
#       pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
#       migration_primary_key: [id: :uuid, type: :binary_id],
#       migration_timestamps: [type: :utc_datetime],
#       ssl: true
