defmodule MainWeb.WifiNetworkController do
  use MainWeb.SecuredContoller

  alias Data.{WifiNetwork, Location}

  def index(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    networks =
      conn
      |> current_user()
      |> WifiNetwork.all(location_id)

    render conn, "index.html", location: location, networks: networks
  end

  def new(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    render(conn, "new.html",
      changeset: WifiNetwork.get_changeset(),
      location: location,
      errors: [])
  end

  def edit(conn, %{"id" => id, "location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- WifiNetwork.get_changeset(id, user) do

      render(conn, "edit.html",
        changeset: changeset,
        location: location,
        errors: [])
    end
  end

  def create(conn, %{"wifi_network" => network, "team_id" => team_id, "location_id" => location_id}) do
    network
    |> Map.put("location_id", location_id)
    |> WifiNetwork.create()
    |> case do
         {:ok, _network} ->
           conn
           |> put_flash(:success, "Wifi Network created successfully.")
           |> redirect(to: team_location_wifi_network_path(conn, :index, team_id, location_id))

         {:error, changeset} ->
           conn
           |> put_flash(:error, "Wifi Network failed to create")
           |> render_page("new.html", changeset, changeset.errors)
       end
  end

  def update(conn, %{"id" => id, "wifi_network" => network, "team_id" => team_id, "location_id" => location_id}) do
    network
    |> Map.merge(%{"id" => id, "location_id" => location_id})
    |> WifiNetwork.update()
    |> case do
         {:ok, _network} ->
           conn
           |> put_flash(:success, "Wifi Network updated successfully.")
           |> redirect(to: team_location_wifi_network_path(conn, :index, team_id, location_id))
         {:error, changeset} ->
           conn
           |> put_flash(:error, "Wifi Network failed to update")
           |> render_page("edit.html", changeset, changeset.errors)
       end
  end

  def delete(conn, %{"id" => id, "team_id" => team_id, "location_id" => location_id}) do
    %{"id" => id, "deleted_at" => DateTime.utc_now()}
    |> WifiNetwork.update()
    |> case do
         {:ok, _network} ->
           conn
           |> put_flash(:success, "Wifi Network deleted successfully.")
           |> redirect(to: team_location_wifi_network_path(conn, :index, team_id, location_id))

         {:error, _changeset} ->
           conn
           |> put_flash(:error, "Wifi Network failed to delete")
           |> render_page("index.html", team_id, location_id)
       end
  end

  defp render_page(conn, page, changeset, errors \\ []) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
