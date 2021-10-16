defmodule MainWeb.LocationController do
  use MainWeb.SecuredContoller
  plug Ueberauth
  alias Data.{Location, Team}
  alias Ueberauth.Strategy.Helpers

  @app_id System.get_env("FACEBOOK_CLIENT_ID")
  @app_secret System.get_env("FACEBOOK_CLIENT_SECRET")
  def index(conn, %{"team_id" => team_id}) do
    current_user = current_user(conn)
    team = Team.get(current_user, team_id)
    locations = if current_user.role in ["admin", "team-admin"] do
      team.locations
    else
      Location.get_by_team_id(%{role: current_user.role},team_id)
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

  def request(conn, %{"location_id" => id, "team_id" => team_id, "provider" => provider} = _params) when provider == "google" do
    # Present an authentication challenge to the user
    provider_config = {Ueberauth.Strategy.Google, [default_scope: "https://www.googleapis.com/auth/calendar.events",request_path: "/admin/teams/#{team_id}/locations/#{id}/edit/:provider",
      callback_path: "/admin/teams/#{team_id}/locations/#{id}/#{provider}/callback",callback_methods: ["POST"]] }
    conn
    |> Ueberauth.run_request(provider, provider_config)
  end
  def request(conn, %{"location_id" => id, "team_id" => team_id, "provider" => provider} = _params) when provider == "facebook" do
    # Present an authentication challenge to the user
    provider_config = {Ueberauth.Strategy.Facebook, [
      default_scope: "https://graph.facebook.com/auth",
      request_path: "/admin/teams/#{team_id}/locations/#{id}/edit/:provider",
      callback_path: "/admin/teams/#{team_id}/locations/#{id}/#{provider}/callback",callback_methods: ["POST"]] }
    conn
    |> Ueberauth.run_request(provider, provider_config)
  end

  def callback(conn, %{"location_id" => id, "team_id" => team_id, "provider" => provider,"code" => code}=_params) when provider == "google"   do
    res = Ueberauth.Strategy.Google.OAuth.get_access_token [code: code,redirect_uri: "https://staging.healthdesk.ai/admin/teams/#{team_id}/locations/#{id}/#{provider}/callback", prompt: "consent",access_type: "offline" ]

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
  def callback(conn, %{"location_id" => id, "team_id" => team_id, "provider" => provider, "code" => code} = _params) when provider == "facebook" do
    location = Location.get(id)
    res = Ueberauth.Strategy.Facebook.OAuth.get_token! [code: code, redirect_uri: "https://staging.healthdesk.ai/admin/teams/#{team_id}/locations/#{id}/#{provider}/callback"]
    case res do
      %OAuth2.Client{token: token} ->
        case get_long_token(token.access_token) do
          :error -> conn
          %{"access_token" => access_token} = _res ->
            case get_user_pages(access_token,location.facebook_page_id) do
              :error -> conn
              %{"access_token" => access_token} = _res ->
                    location_params = %{facebook_token: access_token}
                    case Location.update(id, location_params) do
                      {:ok, %Data.Schema.Location{}} ->
                        with %Data.Schema.User{} = user <- current_user(conn),
                             {:ok, changeset} <- Location.get_changeset(id, user) do

                          team = Team.get(user, team_id)

                          render(
                            conn,
                            "edit.html",
                            changeset: changeset,
                            team_id: team_id,
                            teams: teams(conn),
                            team: team,
                            callback_url: Helpers.callback_url(conn),
                            location: changeset.data,
                            errors: []
                          )
                        end
                end
            end
        end
      _ -> conn
    end
  end
  def callback(conn, params) do
    conn
  end

  def new(conn, %{"team_id" => team_id}) do
    current_user = current_user(conn)
    team = Team.get(current_user, team_id)
    phone_number=team.phone_number
    render(conn, "new.html",
      changeset: Location.get_changeset(),
      team_id: team_id,
      team: team,
      location: nil,
      phone_number: phone_number,
      teams: teams(conn),
      errors: [])
  end

  def edit(conn, %{"location_id" => id, "team_id" => team_id, "provider" => provider} = _params) when provider == "google" do
    provider_config = {Ueberauth.Strategy.Google, [default_scope: "https://www.googleapis.com/auth/calendar",request_path: "/admin/teams/#{team_id}/locations/#{id}/edit/:provider",
      callback_path: "/admin/teams/#{team_id}/locations/#{id}/#{provider}/callback",prompt: "consent", access_type: "offline"] }
    conn
    |> Ueberauth.run_request(provider, provider_config)

  end
  def edit(conn, %{"location_id" => id, "team_id" => team_id, "provider" => provider} = _params) when provider == "facebook" do
    provider_config = {Ueberauth.Strategy.Facebook, [
      default_scope: "email,public_profile",
      request_path: "/admin/teams/#{team_id}/locations/#{id}/edit/:provider",
      callback_path: "/admin/teams/#{team_id}/locations/#{id}/#{provider}/callback"
    ]}
    conn
    |> Ueberauth.run_request(provider, provider_config)
  end

  def edit(conn, %{"id" => id, "team_id" => team_id} = _params) do

    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- Location.get_changeset(id, user) do

      team = Team.get(user, team_id)

      render(conn, "edit.html",
        changeset: changeset,
        team_id: team_id,
        teams: teams(conn),
        team: team,
        phone_number: team.phone_number,
        callback_url: Helpers.callback_url(conn),
        location: changeset.data,
        errors: [])
    end
  end

  def create(conn, %{"location" => location, "team_id" => team_id}) do
    current_user = current_user(conn)
    team = Team.get(current_user, team_id)
    location
    |> Map.put("team_id", team_id)
    |> Map.put("phone_number", team.phone_number)
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

  def update(conn, %{"id" => id, "location" => location, "team_id" => team_id} = _params) do
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

  def remove_config(conn, %{"location_id" => location_id, "team_id" => team_id} = _params) do
    _location = Location.get(location_id)

    case Location.update(location_id, _location = %{
      form_url: nil,
      calender_url: nil,
      calender_id: nil,
      google_refresh_token: nil,
      google_token: nil,
      facebook_page_id: nil,
      facebook_token: nil,
      whatsapp_token: nil,
      whatsapp_login: false
    }) do

      {:ok, %Data.Schema.Location{}} ->
        current_user = current_user(conn)
        case Location.get_changeset(location_id, current_user) do

          {:ok, changeset} ->
            team = Team.get(current_user, team_id)
            render(
              conn,
              "edit.html",
              changeset: changeset,
              team_id: team_id,
              teams: teams(conn),
              team: team,
              callback_url: Helpers.callback_url(conn),
              location: changeset.data,
              errors: []
            )

            _ ->
              {:error, "failed"}
        end

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Location failed to update")
        |> render_page("edit.html", changeset, changeset.errors)
    end
  end

  defp get_long_token(access_token)do
    url = "https://graph.facebook.com/oauth/access_token?grant_type=fb_exchange_token&client_id=#{@app_id}&client_secret=#{@app_secret}&fb_exchange_token=#{access_token}"
    case HTTPoison.get(url) do
      {:ok, res} -> Poison.decode!(res.body)
      _ -> :error
    end
  end

  defp get_user_pages( access_token,page_id)do
    url = "https://graph.facebook.com/#{page_id}?fields=access_token&access_token=#{access_token}"
    case HTTPoison.get(url) do
      {:ok, res} -> Poison.decode!(res.body)
      _ -> :error
    end
  end

  defp render_page(conn, page, changeset, errors) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
