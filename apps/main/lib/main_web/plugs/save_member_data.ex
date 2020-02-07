defmodule MainWeb.Plug.SaveMemberData do
  require Logger

  import Plug.Conn

  alias Data.{Member, MemberChannel, Team, Location}

  @role %{role: "admin"}

  @spec init(list()) :: list()
  def init(opts), do: opts

  def call(%{assigns: %{memberName: name, phoneNumber: phone, location: location} = assigns} = conn, _opts) when phone != nil do
    l = Location.get_by_phone(location)
    phone = format_phone(phone)
    [first_name, last_name] =
      name
      |> String.split(" ")
      |> format_name()

    {:ok, member} =
      with %Data.Schema.Member{} = member <- Member.get_by_phone_number(@role, phone) do
        update_member_data(member.id, first_name, last_name)
      else
        nil ->
          create_member_data(l.team_id, first_name, last_name, phone)
      end

    if MemberChannel.get_by_channel_id(assigns.member) == [] do
      MemberChannel.create(%{member_id: member.id, channel_id: assigns.member})
    end

    conn
  end

  def call(%{assigns: %{member: phone, location: location}} = conn, _opts) when phone != nil do
    l = Location.get_by_phone(location)
    {:ok, member} =
      with nil <- Member.get_by_phone_number(@role, phone) do
        create_member_data(l.team_id, "", "", phone)
      else
        %Data.Schema.Member{} = member ->
          {:ok, member}

      end
    conn
  end

  def call(conn, _opts), do: conn

  defp create_member_data(team_id, first_name, nil, phone) do
    Member.create(%{
          team_id: team_id,
          first_name: first_name,
          phone_number: phone})
  end

  defp create_member_data(team_id, first_name, last_name, phone) do
    Member.create(%{
          team_id: team_id,
          first_name: first_name,
          last_name: last_name,
          phone_number: phone})
  end

  defp update_member_data(member_id, first_name, nil) do
    Member.update(member_id, %{first_name: first_name})
  end

  defp update_member_data(member_id, first_name, last_name) do
    Member.update(member_id, %{first_name: first_name, last_name: last_name})
  end

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
