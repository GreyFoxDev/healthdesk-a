defmodule Data.Repo.Migrations.CreateFunctionResponseTimeDateFilter do
  use Ecto.Migration

  def up do
    execute "DROP FUNCTION IF EXISTS count_messages_by_location_id(location uuid);"
    execute """
    CREATE FUNCTION count_messages_by_location_id(location uuid)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
        select  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY diff) from
            (select case when u.phone_number!=m.original_number and u.conversation_id = lag(u.conversation_id) over (order by u.conversation_id) then
                             EXTRACT(epoch FROM (u.sent_at - lag(u.sent_at) over (order by u.sent_at)))   end as diff
             from conversation_messages u
                      inner join conversations m
                                 on   m.id = u.conversation_id
             where u.sent_at >= now()::date
               and m.location_id = location::uuid
             order by sent_at desc) subquery
        where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """
    execute "DROP FUNCTION IF EXISTS count_messages_by_team_id(team uuid);"
    execute """
    CREATE FUNCTION count_messages_by_team_id(team uuid)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
        select  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY diff) from
            (select case when u.phone_number!=m.original_number and u.conversation_id = lag(u.conversation_id) over (order by u.conversation_id) then
                             EXTRACT(epoch FROM (u.sent_at - lag(u.sent_at) over (order by u.sent_at)))   end as diff
             from conversation_messages u
                      inner join conversations m
                                 on   m.id = u.conversation_id
                      inner join locations l
                                 on m.location_id = l.id
                                     and l.team_id = team::uuid
             where u.sent_at >= now()::date
             order by sent_at desc) subquery
        where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """
    execute """
    CREATE FUNCTION count_messages_by_location_id(location uuid, to_data date)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
        select  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY diff) from
            (select case when u.phone_number!=m.original_number and u.conversation_id = lag(u.conversation_id) over (order by u.conversation_id) then
                             EXTRACT(epoch FROM (u.sent_at - lag(u.sent_at) over (order by u.sent_at)))   end as diff
             from conversation_messages u
                      inner join conversations m
                                 on   m.id = u.conversation_id
             where u.sent_at <= to_data::date
               and m.location_id = location::uuid
             order by sent_at desc) subquery
        where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """
  execute """
    CREATE FUNCTION count_messages_by_location_id(location uuid, to_data date, from_date date)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
        select  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY diff) from
            (select case when u.phone_number!=m.original_number and u.conversation_id = lag(u.conversation_id) over (order by u.conversation_id) then
                             EXTRACT(epoch FROM (u.sent_at - lag(u.sent_at) over (order by u.sent_at)))   end as diff
             from conversation_messages u
                      inner join conversations m
                                 on   m.id = u.conversation_id
             where u.sent_at >= from_date::date and u.sent_at <= to_data::date
               and m.location_id = location::uuid
             order by sent_at desc) subquery
        where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """
  execute """
    CREATE FUNCTION count_messages_by_location_id_from(location uuid, from_date date)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
        select  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY diff) from
            (select case when u.phone_number!=m.original_number and u.conversation_id = lag(u.conversation_id) over (order by u.conversation_id) then
                             EXTRACT(epoch FROM (u.sent_at - lag(u.sent_at) over (order by u.sent_at)))   end as diff
             from conversation_messages u
                      inner join conversations m
                                 on   m.id = u.conversation_id
            where u.sent_at >= from_date::date
               and m.location_id = location::uuid
             order by sent_at desc) subquery
        where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """



    execute """
    CREATE FUNCTION count_messages_by_team_id(team uuid,to_data date)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
        select  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY diff) from
            (select case when u.phone_number!=m.original_number and u.conversation_id = lag(u.conversation_id) over (order by u.conversation_id) then
                             EXTRACT(epoch FROM (u.sent_at - lag(u.sent_at) over (order by u.sent_at)))   end as diff
             from conversation_messages u
                      inner join conversations m
                                 on   m.id = u.conversation_id
                      inner join locations l
                                 on m.location_id = l.id
                                     and l.team_id = team::uuid
             where u.sent_at <= to_data::date
             order by sent_at desc) subquery
        where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """
    execute """
    CREATE FUNCTION count_messages_by_team_id(team uuid,to_data date,from_date date)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
        select  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY diff) from
            (select case when u.phone_number!=m.original_number and u.conversation_id = lag(u.conversation_id) over (order by u.conversation_id) then
                             EXTRACT(epoch FROM (u.sent_at - lag(u.sent_at) over (order by u.sent_at)))   end as diff
             from conversation_messages u
                      inner join conversations m
                                 on   m.id = u.conversation_id
                      inner join locations l
                                 on m.location_id = l.id
                                     and l.team_id = team::uuid
             where u.sent_at >= from_date::date and  u.sent_at <= to_data::date
             order by sent_at desc) subquery
        where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """
    execute """
    CREATE FUNCTION count_messages_by_team_id_from(team uuid, from_date date)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
        select  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY diff) from
            (select case when u.phone_number!=m.original_number and u.conversation_id = lag(u.conversation_id) over (order by u.conversation_id) then
                             EXTRACT(epoch FROM (u.sent_at - lag(u.sent_at) over (order by u.sent_at)))   end as diff
             from conversation_messages u
                      inner join conversations m
                                 on   m.id = u.conversation_id
                      inner join locations l
                                 on m.location_id = l.id
                                     and l.team_id = team::uuid
              where u.sent_at >= from_date::date
             order by sent_at desc) subquery
        where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """


  end
end
