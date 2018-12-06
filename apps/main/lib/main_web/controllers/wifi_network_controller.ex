defmodule MainWeb.WifiNetworkController do
  use MainWeb.SecuredContoller

  alias Data.{WifiNetwork, Location}

  def index(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    with %Data.Schema.User{} = user <- current_user(conn),
         [network|_] <- WifiNetwork.all(user, location_id),
         {:ok, changeset} <- WifiNetwork.get_changeset(network.id, user) do

      render conn, "index.html", location: location, changeset: changeset, errors: [], teams: teams(conn)
    else
      [] ->

        render(conn, "index.html",
          changeset: WifiNetwork.get_changeset(),
          location: location,
          teams: teams(conn),
          errors: [])
    end
  end

  def create(conn, %{"wifi_network" => network, "team_id" => team_id, "location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

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
           |> render("index.html", location: location, changeset: changeset, errors: changeset.errors, teams: teams(conn))
       end
  end

  def update(conn, %{"id" => id, "wifi_network" => network, "team_id" => team_id, "location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

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
           |> render("index.html", location: location, changeset: changeset, errors: changeset.errors, teams: teams(conn))
       end
  end
end
