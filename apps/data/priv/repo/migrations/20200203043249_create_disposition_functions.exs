defmodule Data.Repo.Migrations.CreateDispositionFunctions do
  use Ecto.Migration

  def down do
    execute "DROP FUNCTION IF EXISTS average_dispositions_per_day();"
    execute "DROP FUNCTION IF EXISTS average_dispositions_per_day_by_team();"
    execute "DROP FUNCTION IF EXISTS average_dispositions_per_day_by_location();"
  end

  def up do
    execute "DROP FUNCTION IF EXISTS average_dispositions_per_day();"
    execute """
    CREATE FUNCTION average_dispositions_per_day()
    RETURNS integer AS
    $$
    BEGIN
      RETURN (
      SELECT AVG(count)::integer AS sessions_per_day
      FROM (
        SELECT COUNT(*)
        FROM conversation_dispositions
        GROUP BY date_trunc('day', inserted_at)
      ) s);
    END
    $$ LANGUAGE plpgsql;
    """

    execute "DROP FUNCTION IF EXISTS average_dispositions_per_day_by_team();"
    execute """
    CREATE FUNCTION average_dispositions_per_day_by_team()
    RETURNS TABLE (
      sessions_per_day integer,
      team_id varchar(36)
    ) AS
    $average_dispositions_per_day_by_team$
    BEGIN
      RETURN QUERY
      SELECT AVG(count)::integer AS sessions_per_day, s.team_id::varchar(36) AS team_id
      FROM (
        SELECT COUNT(*), d.team_id
        FROM conversation_dispositions cd
        INNER JOIN dispositions d ON cd.disposition_id = d.id
        GROUP BY d.team_id, date_trunc('day', cd.inserted_at)
      ) s GROUP BY s.team_id;
    END
    $average_dispositions_per_day_by_team$ LANGUAGE plpgsql;
    """

    execute "DROP FUNCTION IF EXISTS average_dispositions_per_day_by_location();"
    execute """
    CREATE FUNCTION average_dispositions_per_day_by_location()
    RETURNS TABLE (
      sessions_per_day integer,
      location_id varchar(36)
    ) AS
    $average_dispositions_per_day_by_location$
    BEGIN
      RETURN QUERY
      SELECT AVG(count)::integer AS sessions_per_day, s.location_id::varchar(36) AS location_id
      FROM (
        SELECT COUNT(*), c.location_id
        FROM conversation_dispositions cd
        INNER JOIN conversations c ON cd.conversation_id = c.id
        GROUP BY c.location_id, date_trunc('day', cd.inserted_at)
      ) s GROUP BY s.location_id;
    END
    $average_dispositions_per_day_by_location$ LANGUAGE plpgsql;
    """

  end
end
