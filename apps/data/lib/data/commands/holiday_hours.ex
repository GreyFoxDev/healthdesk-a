defmodule Data.Commands.HolidayHours do
  # @moduledoc false

  # use Data.Commands, schema: HolidayHours

  # def all(location_id),
  #   do: Command.execute_task_with_results(fn -> Read.all(location_id) end)

  # def find(location_id, erl_date) do
  #   location_id
  #   |> all()
  #   |> Enum.filter(fn d ->
  #     match_date?(d.holiday_date, erl_date)
  #   end)
  # end

  # defp match_date?(nil, _), do: false

  # defp match_date?(date, erl_date) do
  #   Date.to_erl(date) == erl_date
  # end
end
