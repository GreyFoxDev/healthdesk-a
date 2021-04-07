defmodule Data.Repo.Migrations.CreateMetricsView do
  use Ecto.Migration

  def up do
    # Teammates count by team
    execute """
    CREATE OR REPLACE VIEW metrics_teammates AS (
      SELECT count(*) AS teammates, t.team_id
      FROM team_members AS t INNER JOIN users AS u
      ON t.user_id = u.id
      WHERE u.deleted_at IS NULL
      GROUP BY t.team_id
    );
    """

    execute """
    CREATE OR REPLACE VIEW metrics_location_admins AS (
      SELECT count(*) AS location_admins, t.team_id
      FROM team_members AS t INNER JOIN users AS u
      ON t.user_id = u.id
      WHERE u.deleted_at IS NULL
      AND u.role = 'location-admin'
      GROUP BY t.team_id
    );
    """

    execute """
    CREATE OR REPLACE VIEW metrics_locations AS (
      SELECT count(*) AS locations, l.team_id
      FROM locations AS l
      WHERE l.deleted_at IS NULL
      GROUP BY l.team_id
    );
    """

    execute """
    CREATE OR REPLACE VIEW metrics_bounce_rates AS (
      WITH number_of_members AS (
        SELECT count(*) AS members, team_id
        FROM members
        WHERE deleted_at IS NULL
        GROUP BY team_id
      ),
      number_of_bounced_members AS (
        SELECT count(*) AS bounces, team_id
        FROM members
        WHERE deleted_at IS NULL
        AND consent IS NULL
        OR consent = false
        GROUP BY team_id
      )
      SELECT m.team_id, ROUND(COALESCE(b.bounces, 0) / m.members) AS bounce_rate
      FROM number_of_members AS m
      LEFT JOIN number_of_bounced_members AS b ON m.team_id = b.team_id
    );
    """

    execute """
    CREATE OR REPLACE VIEW metrics_teams AS (
      SELECT t.team_id, teammates, location_admins, locations, bounce_rate
      FROM metrics_teammates AS t
      INNER JOIN metrics_locations AS l ON t.team_id = l.team_id
      INNER JOIN metrics_location_admins AS la ON t.team_id = la.team_id
      INNER JOIN metrics_bounce_rates AS b ON t.team_id = b.team_id
    );

    """
  end

  def down do
    execute "DROP VIEW IF EXISTS metrics_teams;"
    execute "DROP VIEW IF EXISTS metrics_teammates;"
    execute "DROP VIEW IF EXISTS metrics_location_admins;"
    execute "DROP VIEW IF EXISTS metrics_locations;"
    execute "DROP VIEW IF EXISTS metrics_bounce_rates;"
  end
end
