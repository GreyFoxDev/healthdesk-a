defmodule Data.Repo.Migrations.AddDefaultsToClassSchedules do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")

    alter table(:class_schedules) do

      modify(:id, :uuid, default: fragment("uuid_generate_v4()"))
      modify(:class_description, :text)
      modify(:updated_at, :utc_datetime, default: fragment("now()"))
      modify(:inserted_at, :utc_datetime, default: fragment("now()"))

    end

  end

  def down do

    alter table(:class_schedules) do

      modify(:id, :uuid, default: fragment("uuid_generate_v4()"))
      modify(:class_description, :text)
      modify(:updated_at, :utc_datetime, default: fragment("now()"))
      modify(:inserted_at, :utc_datetime, default: fragment("now()"))

    end

  end
end
