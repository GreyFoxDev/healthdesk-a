defmodule Data.Repo.Migrations.CreateFunctionsForConversationAnalytics do
  use Ecto.Migration

  def down do
    execute "DROP FUNCTION IF EXISTS count_location_dispositions_by_channel_type(varchar, varchar)"
    execute "DROP FUNCTION IF EXISTS count_team_dispositions_by_channel_type(varchar, varchar)"
    execute "DROP FUNCTION IF EXISTS count_dispositions_by_channel_type(varchar);"
  end

  def up do
    execute "DROP FUNCTION IF EXISTS count_dispositions_by_channel_type(varchar);"
    execute """
    CREATE FUNCTION count_dispositions_by_channel_type(channel varchar)
    RETURNS TABLE(
      disposition_count integer,
      disposition_date date,
      channel_type citext
    )  AS
    $count_dispositions_by_channel_type$
    BEGIN
      RETURN QUERY
        SELECT
        COUNT(*)::integer AS "count",
        DATE(cd.inserted_at),
        c.channel_type
        FROM conversations c
        INNER JOIN conversation_dispositions cd ON c.id = cd.conversation_id
        INNER JOIN dispositions d ON cd.disposition_id = d.id
        WHERE c.channel_type = channel
        GROUP BY c.channel_type, "date";
    END
    $count_dispositions_by_channel_type$ LANGUAGE plpgsql;
    """

    execute "DROP FUNCTION IF EXISTS count_team_dispositions_by_channel_type(varchar, varchar);"
    execute """
    CREATE FUNCTION count_team_dispositions_by_channel_type(team varchar, channel varchar)
    RETURNS TABLE(
      disposition_count integer,
      disposition_date date,
      channel_type citext
    )  AS
    $count_team_dispositions_by_channel_type$
    BEGIN
    RETURN QUERY
      SELECT
        COUNT(*)::integer AS "count",
        DATE(cd.inserted_at),
        c.channel_type
      FROM conversations c
      INNER JOIN conversation_dispositions cd ON c.id = cd.conversation_id
      INNER JOIN dispositions d ON cd.disposition_id = d.id
      WHERE d.team_id = team::uuid
      AND c.channel_type = channel
      GROUP BY c.channel_type, "date";
    END
    $count_team_dispositions_by_channel_type$ LANGUAGE plpgsql;
    """

    execute "DROP FUNCTION IF EXISTS count_location_dispositions_by_channel_type(varchar, varchar);"
    execute """
    CREATE FUNCTION count_location_dispositions_by_channel_type(location varchar, channel varchar)
    RETURNS TABLE(
      disposition_count integer,
      disposition_date date,
      channel_type citext
    )  AS
    $count_location_dispositions_by_channel_type$
    BEGIN
      RETURN QUERY
        SELECT
          COUNT(*)::integer AS "count",
          DATE(cd.inserted_at),
          c.channel_type
        FROM conversations c
        INNER JOIN conversation_dispositions cd ON c.id = cd.conversation_id
        INNER JOIN dispositions d ON cd.disposition_id = d.id
        WHERE c.location_id = location::uuid
        AND c.channel_type = channel
        GROUP BY c.channel_type, "date";
    END
    $count_location_dispositions_by_channel_type$ LANGUAGE plpgsql;
    """
  end
end
