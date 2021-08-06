defmodule Data.Repo.Migrations.CreateFunctionTimeChecker do
  use Ecto.Migration

  def down do
    execute "DROP FUNCTION IF EXISTS find_available_team_members(varchar, varchar)"
  end

  def up do
    execute "DROP FUNCTION IF EXISTS find_available_team_members(varchar, varchar)"

    execute """
    CREATE FUNCTION find_available_team_members(location varchar, c_time varchar)
    RETURNS TABLE (
      email varchar,
      phone_number varchar,
      role varchar,
      use_email boolean,
      use_sms boolean

    ) AS
    $find_available_team_members$
    DECLARE
      c_timestamp timestamp;
      c_today date;
      c_start_date date;
      c_end_date date;
    BEGIN

      SELECT DATE('today') INTO c_today;
      SELECT TO_TIMESTAMP(c_today::varchar || ' ' || c_time, 'YYYY-MM-DD HH24:MI:SS') INTO c_timestamp;

      IF c_time < '12:00' THEN
        SELECT DATE('yesterday') INTO c_start_date;
        SELECT DATE('today') INTO c_end_date;
      ELSE
        SELECT DATE('today') INTO c_start_date;
        SELECT DATE('tomorrow') INTO c_end_date;
      END IF;

      RETURN QUERY
        SELECT u.email, u.phone_number, u.role, u.use_email, u.use_sms
        FROM users u
        INNER JOIN team_members t ON t.user_id = u.id
        LEFT JOIN team_member_locations tl ON tl.team_member_id = t.id
        WHERE t.location_id = location::uuid or tl.location_id = location::uuid
        AND u.deleted_at IS NULL
        AND (u.use_do_not_disturb = false
          OR c_timestamp
            NOT BETWEEN
                TO_TIMESTAMP(c_start_date::varchar || ' ' || COALESCE(u.start_do_not_disturb, '00:00:00'), 'YYYY-MM-DD HH24:MI:SS')
            AND TO_TIMESTAMP(c_end_date::varchar || ' ' || COALESCE(u.end_do_not_disturb, '23:59:59'), 'YYYY-MM-DD HH24:MI:SS')
            );
    END
    $find_available_team_members$ LANGUAGE plpgsql;
    """
  end
end
