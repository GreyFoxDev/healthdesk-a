defmodule MainWeb.TeamMemberController do
  use MainWeb.SecuredContoller

  alias Data.{TeamMember, Team, User, Location}

  def index(conn, %{"team_id" => team_id} = params) do

    team =
      conn
      |> current_user()
      |> Team.get(team_id)

    team_members =
      conn
      |> current_user()
      |> TeamMember.get_by_team_id(team_id)

    render conn, "index.html", team_members: team_members, team: team
  end

  def new(conn, %{"team_id" => team_id}) do
    locations =
      conn
      |> current_user()
      |> Location.get_by_team_id(team_id)
      |> Enum.map(&{&1.location_name, &1.id})

    render(conn, "new.html",
      changeset: TeamMember.get_changeset(),
      locations: locations,
      team_id: team_id,
      errors: [])
  end

  def edit(conn, %{"id" => id, "team_id" => team_id}) do
    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- TeamMember.get_changeset(id, user) do

      locations =
        conn
        |> current_user()
        |> Location.get_by_team_id(team_id)
        |> Enum.map(&{&1.location_name, &1.id})

      data = 

      render(conn, "edit.html",
        changeset: changeset,
        locations: locations,
        team_id: team_id,
        errors: [])
    end
  end

  def create(conn, %{"team_member" => team_member, "team_id" => team_id} = params) do
    with {:ok, _pid} <- User.create(team_member["user"]),
         {:ok, %Data.Schema.User{} = user} <- User.get_by_phone(team_member["user"]["phone_number"]),
         {:ok, _pid} <- TeamMember.create(%{location_id: team_member["location_id"], user_id: user.id, team_id: team_id}) do
      conn
      |> put_flash(:success, "Team Member created successfully.")
      |> redirect(to: team_team_member_path(conn, :index, team_id))
    else
      {:error, changeset} ->

        locations =
          conn
          |> current_user()
          |> Location.get_by_team_id(team_id)
          |> Enum.map(&{&1.location_name, &1.id})

        conn
        |> put_flash(:error, "Team Member failed to create")
        |> render("new.html", changeset: changeset, locations: locations, team_id: team_id, errors: changeset.errors)
    end
  end

  def update(conn, %{"id" => id, "team_member" => team_member, "team_id" => team_id}) do
    with %Data.Schema.TeamMember{} = member <- TeamMember.get(current_user(conn), id),
         {:ok, _pid} <- TeamMember.update(id, %{location_id: team_member["location_id"]}),
         {:ok, _pid} <- User.update(member.user_id, team_member["user"]) do

      conn
      |> put_flash(:success, "Team Member deleted successfully.")
      |> redirect(to: team_team_member_path(conn, :index, team_id))
    else
      {:error, changeset} ->
        locations =
          conn
          |> current_user()
          |> Location.get_by_team_id(team_id)
          |> Enum.map(&{&1.location_name, &1.id})

        conn
        |> put_flash(:error, "Team Member failed to delete")
        |> render("edit.html", changeset: changeset, locations: locations, team_id: team_id, errors: changeset.errors)
    end
  end

  def delete(conn, %{"id" => id, "team_id" => team_id}) do
    with %Data.Schema.TeamMember{} = member <- TeamMember.get(current_user(conn), id),
         {:ok, _pi} <- User.update(member.user_id, %{"deleted_at" => DateTime.utc_now()}) do

      conn
      |> put_flash(:success, "Team Member deleted successfully.")
      |> redirect(to: team_team_member_path(conn, :index, team_id))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Team Member failed to delete")
        |> render("index.html", team_id)
    end
  end
end
