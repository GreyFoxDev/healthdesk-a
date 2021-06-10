defmodule Data.Repo.Migrations.CreateCitext do
    use Ecto.Migration

    def up do
#      execute "CREATE EXTENSION citext"
      execute "DROP VIEW IF EXISTS conversations_list;"

      alter table(:conversations) do
        modify(:channel_type,:citext)
      end
      alter table(:locations) do
        modify(:location_name,:citext)
      end
      alter table(:members) do
        modify(:first_name,:citext)
        modify(:last_name,:citext)
      end
      execute """
      CREATE VIEW conversations_list AS(
      SELECT c0.id, c0.original_number, c0.status, c0.started_at, c0.channel_type,
         c0.subject, c0.appointment, c0.step, c0.fallback, c0.location_id,
         c0.team_member_id , c1.sent_at,t1.user_id,l1.location_name,
         m2.id as member_id, m2.first_name, m2.last_name,m2.team_id
      FROM conversations AS c0
      INNER JOIN (select distinct on (conversation_id) *
              from conversation_messages
              order by conversation_id,sent_at desc)AS c1 ON c1.conversation_id = c0.id
      LEFT OUTER JOIN members AS m2 ON c0.original_number = m2.phone_number
      LEFT OUTER JOIN team_members AS t1 ON c0.team_member_id = t1.id
      LEFT OUTER JOIN locations AS l1 ON c0.location_id = l1.id
      order by c1.sent_at desc
      );
      """
    end

    def down do
      execute "DROP EXTENSION citext"
    end
  end