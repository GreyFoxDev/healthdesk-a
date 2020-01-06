defmodule MainWeb.Plug.SaveMemberData do
  require Logger

  import Plug.Conn

  alias Data.{Member, Team, Location}

  @spec init(list()) :: list()
  def init(opts), do: opts

  def call(%{assigns: %{memberName: name, phoneNumber: phone, location: location}} = conn, _opts) when phone != nil do
    l = Location.get_by_phone(location)
    phone = format_phone(phone)
    [first_name, last_name] =
      name
      |> String.split(" ")
      |> format_name()

    with %Data.Schema.Member{} = member <- Member.get_by_phone_number(%{role: "admin"}, phone) do
      if last_name do
        Member.update(member.id, %{first_name: first_name, last_name: last_name})
      else
        Member.update(member.id, %{first_name: first_name})
      end
    else
      nil ->
      if last_name do
        Member.create(%{
              team_id: l.team_id,
              first_name: first_name,
              last_name: last_name,
              phone_number: phone})
      else
        Member.create(%{
              team_id: l.team_id,
              first_name: first_name,
              phone_number: phone})
      end
    end

    conn
  end

  def call(conn, _opts), do: conn

  def format_name([first, last] = name), do: name
  def format_name([first]), do: [first, nil]
  def format_name([first | rest]), do: [first, Enum.join(rest, " ")]

  def format_phone(<< "+1", number :: binary >> = phone),
    do: format_phone(number)

  def format_phone(phone) do
    "+1#{replace_non_digits(phone)}"
  end

  defp replace_non_digits(phone), do: String.replace(phone, ~r/[^\d]/, "")
end
