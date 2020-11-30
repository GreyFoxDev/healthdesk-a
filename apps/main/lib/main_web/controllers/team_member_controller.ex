defmodule MainWeb.TeamMemberController do
  use MainWeb.SecuredContoller

  alias Data.{TeamMember, Team, User, Location}

  def index(conn, %{"team_id" => team_id}) do
    team =
      conn
      |> current_user()
      |> Team.get(team_id)

    team_members =
      conn
      |> current_user()
      |> TeamMember.get_by_team_id(team_id)
      |> Enum.uniq_by(& &1.id)

    render conn, "index.html", location: nil, team_members: team_members, team: team, teams: teams(conn)
  end

  def new(conn, %{"team_id" => team_id}) do
    locations =
      conn
      |> current_user()
      |> Location.get_by_team_id(team_id)
      |> Enum.map(&{&1.location_name, &1.id})

    team_members =
      conn
      |> current_user()
      |> TeamMember.get_by_team_id(team_id)

    render(conn, "new.html",
      changeset: TeamMember.get_changeset(),
      location: nil,
      locations: locations,
      team_id: team_id,
      teams: teams(conn),
      team_members: team_members,
      has_sidebar: true,
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

      team_members =
        conn
        |> current_user()
        |> TeamMember.get_by_team_id(team_id)

      render(conn, "edit.html",
        changeset: changeset,
        location: nil,
        locations: locations,
        team_id: team_id,
        teams: teams(conn),
        team_members: team_members,
        has_sidebar: true,
        errors: [])
    end
  end

  def create(conn, %{"team_member" => %{"user" => %{"image" => [image]}} = team_member, "team_id" => team_id}) do
    with {:ok, avatar} <- Uploader.upload_image(image.path),
         user_params <- Map.merge(team_member["user"], %{"avatar" => avatar}),
         nil <- User.get_by_phone(team_member["user"]["phone_number"]),
         {:ok, %Data.Schema.User{} = user} <- User.create(user_params),
         {:ok, _pid} <- TeamMember.create(%{location_id: team_member["location_id"], locations: team_member["team_member_locations"], user_id: user.id, team_id: team_id, avatar: avatar}) do
      conn
      |> put_flash(:success, "Team Member created successfully.")
      |> redirect(to: team_team_member_path(conn, :index, team_id))
    else
      {:ok, %Data.Schema.User{}} ->
        conn
        |> put_flash(:error, "Error: Phone number already in the system")
        |> redirect(to: team_team_member_path(conn, :index, team_id))
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

  def create(conn, %{"team_member" => team_member, "team_id" => team_id}) do
    with nil <- User.get_by_phone(team_member["user"]["phone_number"]),
         {:ok, %Data.Schema.User{} = user} <- User.create(team_member["user"]),
         {:ok, _pid} <- TeamMember.create(%{location_id: team_member["location_id"], locations: team_member["team_member_locations"], user_id: user.id, team_id: team_id}) do
      conn
      |> put_flash(:success, "Team Member created successfully.")
      |> redirect(to: team_team_member_path(conn, :index, team_id))
    else
      %Data.Schema.User{} ->
        conn
        |> put_flash(:error, "Error: Phone number already in the system")
        |> redirect(to: team_team_member_path(conn, :index, team_id))
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

  def update(conn, %{"id" => id, "team_member" => %{"user" => %{"image" => [image]}} = team_member, "team_id" => team_id}) do
    with %Data.Schema.TeamMember{} = member <- TeamMember.get(current_user(conn), id),
         {:ok, avatar} <- Uploader.upload_image(image.path),
         {:ok, _pid} <- TeamMember.update(id, %{location_id: team_member["location_id"], locations: team_member["team_member_locations"]}),
         {:ok, _pid} <- User.update(member.user_id, Map.merge(team_member["user"], %{"avatar" => avatar})) do

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

  def update(conn, %{"id" => id, "team_member" => %{"location_id" => location_id}=team_member, "team_id" => team_id}) do
    locations = (team_member["team_member_locations"] || [])
    with %Data.Schema.TeamMember{} = member <- TeamMember.get(current_user(conn), id),
         {:ok, _pid} <- TeamMember.update(id, %{location_id: location_id, locations: locations}),
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

  def update(conn, %{"id" => id, "team_member" => team_member, "team_id" => team_id}) do
    with %Data.Schema.TeamMember{} = member <- TeamMember.get(current_user(conn), id),
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
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Team Member failed to delete")
        |> render("index.html", team_id)
    end
  end
end
