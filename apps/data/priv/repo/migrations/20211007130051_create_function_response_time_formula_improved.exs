defmodule Data.Repo.Migrations.CreateFunctionResponseTimeDateFilter do
  use Ecto.Migration

  def up do
    execute "DROP FUNCTION IF EXISTS count_messages_by_location_id(location uuid);"
    flush();
    execute """
    CREATE FUNCTION count_messages_by_location_id(location uuid)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (select PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diff)
    from (
         select case
                    when (phone_number != original_number and
                          conversation_id = lag(conversation_id) over (order by conversation_id)) then
                        EXTRACT(epoch FROM (sent_at - lag(sent_at) over (order by sent_at))) end as diff
         from (select *
               from (select *, lag(u.phone_number) over (order by u.sent_at) as next_phone_number
                     from conversation_messages u
                              inner join conversations m
                                         on m.id = u.conversation_id
                     where u.sent_at <= now()::timestamp
                       and m.location_id = location::uuid
                     order by u.sent_at desc
                    ) subquery
               where phone_number <> next_phone_number) subquery) subquery
    where diff is not null
    );
    END
    $$ LANGUAGE plpgsql;
    """
    flush();
    execute "DROP FUNCTION IF EXISTS count_messages_by_team_id(team uuid);"
    flush();
    execute """
    CREATE FUNCTION count_messages_by_team_id(team uuid)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
    select PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diff)
    from (
         select case
                    when (u_phone_number != original_number and
                          conversation_id = lag(conversation_id) over (order by conversation_id)) then
                        EXTRACT(epoch FROM (sent_at - lag(sent_at) over (order by sent_at))) end as diff
         from (select *
               from (select *,l.phone_number as l_phone_number, u.phone_number as u_phone_number, lag(u.phone_number) over (order by u.sent_at) as next_phone_number
                     from conversation_messages u
                              inner join conversations m
                                         on m.id = u.conversation_id
                     inner join locations l
                                 on m.location_id = l.id
                                     and l.team_id = team::uuid
             where u.sent_at <= now()::timestamp
                     order by u.sent_at desc
                    ) subquery
               where u_phone_number <> next_phone_number) subquery) subquery
    where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """
    flush();
    execute "DROP FUNCTION IF EXISTS count_messages_by_location_id(location uuid, to_data date);"
    flush();
    execute """
    CREATE FUNCTION count_messages_by_location_id(location uuid, to_data date)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
          select PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diff)
    from (
         select case
                    when (phone_number != original_number and
                          conversation_id = lag(conversation_id) over (order by conversation_id)) then
                        EXTRACT(epoch FROM (sent_at - lag(sent_at) over (order by sent_at))) end as diff
         from (select *
               from (select *, lag(u.phone_number) over (order by u.sent_at) as next_phone_number
                     from conversation_messages u
                              inner join conversations m
                                         on m.id = u.conversation_id
                     where u.sent_at <= to_data::date
                        and m.location_id = location::uuid
                     order by u.sent_at desc
                    ) subquery
               where phone_number <> next_phone_number) subquery) subquery
    where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """
    flush();
    execute "DROP FUNCTION IF EXISTS count_messages_by_location_id(location uuid, to_data date, from_date date);"
    flush();
    execute """
    CREATE FUNCTION count_messages_by_location_id(location uuid, to_data date, from_date date)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
        select PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diff)
  from (
       select case
                  when (phone_number != original_number and
                        conversation_id = lag(conversation_id) over (order by conversation_id)) then
                      EXTRACT(epoch FROM (sent_at - lag(sent_at) over (order by sent_at))) end as diff
       from (select *
             from (select *, lag(u.phone_number) over (order by u.sent_at) as next_phone_number
                   from conversation_messages u
                            inner join conversations m
                                       on m.id = u.conversation_id
                   where u.sent_at >= from_date::date and u.sent_at <= to_data::date
                   and m.location_id = location::uuid
                   order by u.sent_at desc
                  ) subquery
             where phone_number <> next_phone_number) subquery) subquery
  where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """
    flush();
    execute "DROP FUNCTION IF EXISTS count_messages_by_location_id_from(location uuid, from_date date);"
    flush();
    execute """
    CREATE FUNCTION count_messages_by_location_id_from(location uuid, from_date date)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
           select PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diff)
  from (
       select case
                  when (phone_number != original_number and
                        conversation_id = lag(conversation_id) over (order by conversation_id)) then
                      EXTRACT(epoch FROM (sent_at - lag(sent_at) over (order by sent_at))) end as diff
       from (select *
             from (select *, lag(u.phone_number) over (order by u.sent_at) as next_phone_number
                   from conversation_messages u
                            inner join conversations m
                                       on m.id = u.conversation_id
                   where u.sent_at >= from_date::date
                   and m.location_id = location::uuid
                   order by u.sent_at desc
                  ) subquery
             where phone_number <> next_phone_number) subquery) subquery
  where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """


    flush();
    execute "DROP FUNCTION IF EXISTS count_messages_by_team_id(team uuid,to_data date);"
    flush();
    execute """
    CREATE FUNCTION count_messages_by_team_id(team uuid,to_data date)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
          select PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diff)
    from (
         select case
                    when (u_phone_number != original_number and
                          conversation_id = lag(conversation_id) over (order by conversation_id)) then
                        EXTRACT(epoch FROM (sent_at - lag(sent_at) over (order by sent_at))) end as diff
         from (select *
               from (select *,l.phone_number as l_phone_number, u.phone_number as u_phone_number, lag(u.phone_number) over (order by u.sent_at) as next_phone_number
                     from conversation_messages u
                              inner join conversations m
                                         on m.id = u.conversation_id
                     inner join locations l
                                 on m.location_id = l.id
                                     and l.team_id = team::uuid
             where u.sent_at <= to_data::date
                     order by u.sent_at desc
                    ) subquery
               where u_phone_number <> next_phone_number) subquery) subquery
    where diff is not null
    );
    END
    $$ LANGUAGE plpgsql;
    """
    flush();
    execute "DROP FUNCTION IF EXISTS count_messages_by_team_id(team uuid,to_data date,from_date date);"
    flush();
    execute """
    CREATE FUNCTION count_messages_by_team_id(team uuid,to_data date,from_date date)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
    select PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diff)
    from (
         select case
                    when (u_phone_number != original_number and
                          conversation_id = lag(conversation_id) over (order by conversation_id)) then
                        EXTRACT(epoch FROM (sent_at - lag(sent_at) over (order by sent_at))) end as diff
         from (select *
               from (select *,l.phone_number as l_phone_number, u.phone_number as u_phone_number, lag(u.phone_number) over (order by u.sent_at) as next_phone_number
                     from conversation_messages u
                              inner join conversations m
                                         on m.id = u.conversation_id
                     inner join locations l
                                 on m.location_id = l.id
                                     and l.team_id = team::uuid
             where u.sent_at >= from_date::date and  u.sent_at <= to_data::date
                     order by u.sent_at desc
                    ) subquery
               where u_phone_number <> next_phone_number) subquery) subquery
    where diff is not null
    );
    END
    $$ LANGUAGE plpgsql;
    """

    flush();
    execute "DROP FUNCTION IF EXISTS count_messages_by_team_id_from(team uuid, from_date date);"
    flush();
    execute """
    CREATE FUNCTION count_messages_by_team_id_from(team uuid, from_date date)
    RETURNS integer AS
    $$
    BEGIN
    RETURN (
    select PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diff)
    from (
         select case
                    when (u_phone_number != original_number and
                          conversation_id = lag(conversation_id) over (order by conversation_id)) then
                        EXTRACT(epoch FROM (sent_at - lag(sent_at) over (order by sent_at))) end as diff
         from (select *
               from (select *,l.phone_number as l_phone_number, u.phone_number as u_phone_number, lag(u.phone_number) over (order by u.sent_at) as next_phone_number
                     from conversation_messages u
                              inner join conversations m
                                         on m.id = u.conversation_id
                     inner join locations l
                                 on m.location_id = l.id
                                     and l.team_id = team::uuid
              where u.sent_at >= from_date::date
                     order by u.sent_at desc
                    ) subquery
               where u_phone_number <> next_phone_number) subquery) subquery
    where diff is not null
    );
    END
    $$ LANGUAGE plpgsql;
    """


  end
end
