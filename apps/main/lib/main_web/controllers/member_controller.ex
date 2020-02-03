defmodule MainWeb.MemberController do
  use MainWeb.SecuredContoller

  alias Data.{Member, Team, Location}

  def index(conn, %{"team_id" => team_id}) do
    team =
      conn
      |> current_user()
      |> Team.get(team_id)

    members =
      conn
      |> current_user()
      |> Member.get_by_team_id(team_id)

    render conn, "index.html", location: nil, members: members, team: team, teams: teams(conn)
  end

  def new(conn, %{"team_id" => team_id}) do
    locations =
      conn
      |> current_user()
      |> Location.get_by_team_id(team_id)
      |> Enum.map(&{&1.location_name, &1.id})

    members =
      conn
      |> current_user()
      |> Member.get_by_team_id(team_id)

    render(conn, "new.html",
      changeset: Member.get_changeset(),
      location: nil,
      locations: locations,
      team_id: team_id,
      teams: teams(conn),
      members: members,
      has_sidebar: true,
      errors: [])
  end

  def edit(conn, %{"id" => id, "team_id" => team_id}) do
    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- Member.get_changeset(id, user) do

      locations =
        conn
        |> current_user()
        |> Location.get_by_team_id(team_id)
        |> Enum.map(&{&1.location_name, &1.id})

      members =
        conn
        |> current_user()
        |> Member.get_by_team_id(team_id)

      render(conn, "edit.html",
        changeset: changeset,
        location: nil,
        locations: locations,
        team_id: team_id,
        teams: teams(conn),
        members: members,
        has_sidebar: true,
        errors: [])
    end
  end

  def update(conn, %{"id" => id, "member" => member, "team_id" => team_id}) do
    member = Map.put(member, "team_id", team_id)

    case Member.update(id, member) do
      {:ok, _member} ->
        conn
        |> put_flash(:success, "Member updated successfully.")
        |> redirect(to: team_member_path(conn, :index, team_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Member failed to update")
        |> redirect(to: team_member_path(conn, :index, team_id))
    end
  end

  def delete(conn, %{"id" => id, "team_id" => team_id}) do
    case Member.update(id, %{"deleted_at" => DateTime.utc_now()}) do
      {:ok, _member} ->
        conn
        |> put_flash(:success, "Member deleted successfully.")
        |> redirect(to: team_member_path(conn, :index, team_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Member failed to delete")
        |> redirect(to: team_member_path(conn, :index, team_id))
    end
  end
end
