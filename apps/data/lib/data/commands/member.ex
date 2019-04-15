defmodule Data.Commands.Member do
  @moduledoc false

  use Data.Commands, schema: Member

  alias Data.Schema.{Member, Location}
  alias Data.Commands.Location, as: L

  def all(team_id),
    do: Command.execute_task_with_results(fn -> Read.all(team_id) end)

  @doc """
  Finds a opt in by member's phone number
  """
  @spec get_by_phone(phone_number :: binary) :: Member.t()
  def get_by_phone(phone_number),
    do: {:ok, Read.get_by_phone(phone_number)}

  @doc """
  Enables Opt In for a member
  """
  @spec disable_opt_in(phone_number :: binary, location :: binary) :: {:ok, Member.t()}
  def enable_opt_in(phone_number, location),
    do: insert_or_update!(phone_number, true, location)

  @doc """
  Disables Opt In for a member
  """
  @spec disable_opt_in(phone_number :: binary, location :: binary) :: {:ok, Member.t()}
  def disable_opt_in(phone_number, location),
    do: insert_or_update!(phone_number, false, location)

  defp insert_or_update!(phone_number, consent, location) do
    %Location{team_id: team_id} = L.get_by_phone(location)

    with {:ok, %Member{id: id} = opt_in} <- get_by_phone(phone_number) do
      {:ok, write(opt_in, %{"consent" => consent})}
    else
      {:ok, _} ->
        {:ok, write(%{"phone_number" => phone_number, "team_id" => team_id, "consent" => consent})}
    end
  end
end
