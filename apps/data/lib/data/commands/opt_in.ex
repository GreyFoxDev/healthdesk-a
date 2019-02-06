defmodule Data.Commands.OptIn do
  @moduledoc false

  use Data.Commands, schema: OptIn

  alias Data.Schema.OptIn

  @doc """
  Finds a opt in by member's phone number
  """
  @spec get_by_phone(phone_number :: binary) :: OptIn.t()
  def get_by_phone(phone_number),
    do: {:ok, Read.get_by_phone(phone_number)}

  @doc """
  Enables Opt In for a member
  """
  @spec disable_opt_in(phone_number :: binary) :: {:ok, OptIn.t()}
  def enable_opt_in(phone_number), do: insert_or_update!(phone_number, "yes")

  @doc """
  Disables Opt In for a member
  """
  @spec disable_opt_in(phone_number :: binary) :: {:ok, OptIn.t()}
  def disable_opt_in(phone_number), do: insert_or_update!(phone_number, "no")

  defp insert_or_update!(phone_number, status) do
    with {:ok, %OptIn{id: id} = opt_in} <- get_by_phone(phone_number) do
      {:ok, write(opt_in, %{"status" => status})}
    else
      {:ok, _} ->
        {:ok, write(%{"phone_number" => phone_number, "status" => status})}
    end
  end
end
