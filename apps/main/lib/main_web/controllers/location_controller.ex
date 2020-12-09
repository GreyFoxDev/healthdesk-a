defmodule MainWeb.LocationController do
  use MainWeb.SecuredContoller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers
  alias Data.{Location, Team}

  def index(conn, %{"team_id" => team_id}) do
    current_user = current_user(conn)
    team = Team.get(current_user, team_id)
    locations = if current_user.role in ["admin", "team-admin"] do
      team.locations
    else
      teammate_locations(conn)
    end
    render conn, "index.html",
           location: nil,
           locations: locations,
           team: team,
           teams: teams(conn)
  end

  def show(conn, %{"id" => id}) do
    location =
      conn
      |> current_user()
      |> Location.get(id)

    render conn, "show.json", data: location
  end

  def request(conn, %{"location_id" => id, "team_id" => team_id, "provider" => provider}=params) do
    # Present an authentication challenge to the user
    provider_config = {Ueberauth.Strategy.Google, [default_scope: "https://www.googleapis.com/auth/calendar.events",request_path: "/admin/teams/#{team_id}/locations/#{id}/edit/:provider",
      callback_path: "/admin/teams/#{team_id}/locations/#{id}/#{provider}/callback",callback_methods: ["POST"]] }
    conn
    |> Ueberauth.run_request(provider, provider_config)
  end
  def callback(conn, %{"location_id" => id, "team_id" => team_id, "provider" => provider,"code" => code}=params) do
    res = Ueberauth.Strategy.Google.OAuth.get_access_token [code: code,redirect_uri: "https://staging.healthdesk.ai/admin/teams/#{team_id}/locations/#{id}/#{provider}/callback", prompt: "consent",access_type: "offline" ]
    IO.inspect("###################")
    IO.inspect(res)
    IO.inspect("###################")

    case res do
             {:ok,
             %OAuth2.AccessToken{access_token: token, refresh_token: rtoken}} ->
                 location_params = %{google_token: token, google_refresh_token:  rtoken}
                 case Location.update(id, location_params) do
                   {:ok, %Data.Schema.Location{}} ->
                     with %Data.Schema.User{} = user <- current_user(conn),
                          {:ok, changeset} <- Location.get_changeset(id, user) do

                       team = Team.get(user, team_id)

                       render(conn, "edit.html",
                         changeset: changeset,
                         team_id: team_id,
                         teams: teams(conn),
                         team: team,
                         callback_url: Helpers.callback_url(conn),
                         location: changeset.data,
                         errors: [])
                     end
                 end
             _ ->
                 conn
                 |> redirect(to: team_location_path(conn, :edit, team_id, id))
    end

  end

  def new(conn, %{"team_id" => team_id}) do
    current_user = current_user(conn)
    team = Team.get(current_user, team_id)

    render(conn, "new.html",
      changeset: Location.get_changeset(),
      team_id: team_id,
      team: team,
      location: nil,
      teams: teams(conn),
      errors: [])
  end

  def edit(conn, %{"location_id" => id, "team_id" => team_id, "provider" => provider}=params) do
    provider_config = {Ueberauth.Strategy.Google, [default_scope: "https://www.googleapis.com/auth/calendar",request_path: "/admin/teams/#{team_id}/locations/#{id}/edit/:provider",
      callback_path: "/admin/teams/#{team_id}/locations/#{id}/#{provider}/callback",prompt: "consent", access_type: "offline"] }
    conn
    |> Ueberauth.run_request(provider, provider_config)

  end
  def edit(conn, %{"id" => id, "team_id" => team_id}=params) do

    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- Location.get_changeset(id, user) do

      team = Team.get(user, team_id)

      render(conn, "edit.html",
        changeset: changeset,
        team_id: team_id,
        teams: teams(conn),
        team: team,
        callback_url: Helpers.callback_url(conn),
        location: changeset.data,
        errors: [])
    end
  end

  def create(conn, %{"location" => location, "team_id" => team_id}) do
    location
    |> Map.put("team_id", team_id)
    |> Location.create()
    |> case do
         {:ok, %Data.Schema.Location{}} ->
           conn
           |> put_flash(:success, "Location created successfully.")
           |> redirect(to: team_location_path(conn, :index, team_id))
         {:error, changeset} ->
           conn
           |> put_flash(:error, "Location failed to create")
           |> render_page("new.html", changeset, changeset.errors)
       end
  end

  def update(conn, %{"id" => id, "location" => location, "team_id" => team_id}) do
    location = Map.put(location, "team_id", team_id)

    case Location.update(id, location) do
      {:ok, %Data.Schema.Location{}} ->
        conn
        |> put_flash(:success, "Location updated successfully.")
        |> redirect(to: team_location_path(conn, :index, team_id))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Location failed to update")
        |> render_page("edit.html", changeset, changeset.errors)
    end
  end

  def delete(conn, %{"id" => id, "team_id" => team_id}) do
    case Location.update(id, %{"deleted_at" => DateTime.utc_now()}) do
      {:ok, _location} ->
        conn
        |> put_flash(:success, "Location deleted successfully.")
        |> redirect(to: team_location_path(conn, :index, team_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Location failed to delete")
        |> render("index.html", team_id)
    end
  end

  defp render_page(conn, page, changeset, errors) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
