defmodule MainWeb.Helper.LocationHelper do

  alias Data.Location

  def current_user(conn) do
    MainWeb.Auth.Guardian.Plug.current_resource(conn)
  end

  def teammate_locations(%Data.Schema.User{role: "admin"}=_current_user) do

    Location.all()
    |> Stream.filter(&(&1.deleted_at == nil))
    |> Enum.to_list()
    |> Enum.dedup_by(&(&1.id))
  end
  def teammate_locations(%Data.Schema.User{}=current_user) do

    current_user.team_member.team_member_locations
    |> Stream.map(&(&1.location))
    |> Stream.filter(&(&1.deleted_at == nil))
    |> Enum.to_list()
    |> Kernel.++([current_user.team_member.location])
    |> Enum.dedup_by(&(&1.id))
  end
  def teammate_locations(%Data.Schema.User{role: "admin"}=_current_user, true) do
    Location.all()
    |> Stream.filter(&(&1.deleted_at == nil))
    |> Stream.map(&(&1.id))
    |> Enum.to_list()
    |> Enum.dedup()
  end
  def teammate_locations(%Data.Schema.User{}=current_user, true) do
    current_user.team_member.team_member_locations
    |> Stream.map(&(&1.location))
    |> Stream.filter(&(&1.deleted_at == nil))
    |> Stream.map(&(&1.id))
    |> Enum.to_list()
    |> Kernel.++([current_user.team_member.location.id])
    |> Enum.dedup()
  end
  def teammate_locations(conn) do

    current_user = current_user(conn)

    current_user.team_member.team_member_locations
    |> Stream.map(&(&1.location))
    |> Stream.filter(&(&1.deleted_at == nil))
    |> Enum.to_list()
    |> Kernel.++([current_user.team_member.location])
    |> Enum.dedup_by(&(&1.id))
  end

end