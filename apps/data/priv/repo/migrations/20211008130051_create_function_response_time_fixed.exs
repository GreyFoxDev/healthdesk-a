defmodule Data.Repo.Migrations.CreateFunctionResponseTimeDateFilter do
  use Ecto.Migration

  def up do
    execute "DROP FUNCTION IF EXISTS count_messages_by_location_id(location uuid[]);"
    flush();
    execute """
    CREATE FUNCTION count_messages_by_location_id(location uuid[])
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
                       and m.location_id = any(location::uuid[])
                     order by u.sent_at desc
                    ) subquery
               where phone_number <> next_phone_number) subquery) subquery
    where diff is not null
    );
    END
    $$ LANGUAGE plpgsql;
    """

    flush();

    execute "DROP FUNCTION IF EXISTS count_messages_by_location_id(location uuid[], to_data date);"
    flush();

    execute """
    CREATE FUNCTION count_messages_by_location_id(location uuid[], to_data date)
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
                        and m.location_id = any(location::uuid[])
                     order by u.sent_at desc
                    ) subquery
               where phone_number <> next_phone_number) subquery) subquery
    where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """
    flush();

    execute "DROP FUNCTION IF EXISTS count_messages_by_location_id(location uuid[], to_data date, from_date date);"
    flush();

    execute """
    CREATE FUNCTION count_messages_by_location_id(location uuid[], to_data date, from_date date)
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
                   and m.location_id = any(location::uuid[])
                   order by u.sent_at desc
                  ) subquery
             where phone_number <> next_phone_number) subquery) subquery
  where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """
    flush();

    execute "DROP FUNCTION IF EXISTS count_messages_by_location_id_from(location uuid[], from_date date);"
    flush();

    execute """
    CREATE FUNCTION count_messages_by_location_id_from(location uuid[], from_date date)
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
                   and m.location_id = any(location::uuid[])
                   order by u.sent_at desc
                  ) subquery
             where phone_number <> next_phone_number) subquery) subquery
  where diff is not null);
    END
    $$ LANGUAGE plpgsql;
    """

  end
end
