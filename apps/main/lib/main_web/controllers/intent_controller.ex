defmodule MainWeb.IntentController do
  use MainWeb.SecuredContoller

  alias Data.{Intent, User, Location}

  def new(conn, %{"location_id" => location_id} = params) do

    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    intents = Intent.get_by_location_id(location_id)

    render(
      conn,
      "new.html",
      changeset: Intent.get_changeset(),
      location_id: location_id,
      intents: intents,
      location: location,
      teams: teams(conn),
      has_sidebar: true,
      errors: []
    )
  end

  def create(
        conn,
        %{"intent" => intent, "message" => message, "location_id" => location_id, "team_id" => team_id} = params
      ) do

    with {:ok, _} <- Intent.create(params) do
      conn
      |> put_flash(:success, "Intent created successfully.")
      |> redirect(to: team_location_intent_path(conn, :new, team_id, location_id))
    else

      {:error, changeset} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        intents = Intent.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "Intent failed to create")
        |> render(
             "new.html",
             changeset: Intent.get_changeset(),
             location_id: location_id,
             intents: intents,
             location: location,
             teams: teams(conn),
             has_sidebar: true,
             errors: changeset.errors
           )
    end
  end

  def update(
        conn,
        %{"id" => id, "intent" => intent, "message" => message, "location_id" => location_id, "team_id" => team_id} = params
      ) do
    with %Data.Schema.Intent{} = intent <- Intent.get(%{role: "admin"}, id),
         {:ok, _} <- Intent.update(intent, params) do
      conn
      |> put_flash(:success, "Intent updated successfully.")
      |> redirect(to: team_location_intent_path(conn, :new, team_id, location_id))
    else
      {:error, changeset} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        intents = Intent.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "Intent failed to update")
        |> render(
             "new.html",
             changeset: Intent.get_changeset(),
             location_id: location_id,
             intents: intents,
             location: location,
             teams: teams(conn),
             has_sidebar: true,
             errors: changeset.errors
           )
    end
  end
  def update(conn, %{"id" => id, "intent" => intent, "location_id" => location_id, "team_id" => team_id} = params) do
    with %Data.Schema.Intent{} = intent <- Intent.get(%{role: "admin"}, id),
         {:ok, _} <- Intent.update(intent, params) do
      conn
      |> put_flash(:success, "Intent updated successfully.")
      |> redirect(to: team_location_intent_path(conn, :new, team_id, location_id))
    else
      {:error, changeset} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        intents = Intent.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "Intent failed to update")
        |> render(
             "new.html",
             changeset: Intent.get_changeset(),
             location_id: location_id,
             intents: intents,
             location: location,
             teams: teams(conn),
             has_sidebar: true,
             errors: changeset.errors
           )
    end
  end
  def update(conn, %{"id" => id, "title" => title, "location_id" => location_id, "team_id" => team_id} = params) do
    with %Data.Schema.Intent{} = intent <- Intent.get(%{role: "admin"}, id),
         {:ok, _} <- Intent.update(intent, params) do
      conn
      |> put_flash(:success, "Intent updated successfully.")
      |> redirect(to: team_location_intent_path(conn, :new, team_id, location_id))
    else
      {:error, changeset} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        intents = Intent.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "Intent failed to update")
        |> render(
             "new.html",
             changeset: Intent.get_changeset(),
             location_id: location_id,
             intents: intents,
             location: location,
             teams: teams(conn),
             has_sidebar: true,
             errors: changeset.errors
           )
    end
  end

  def delete(conn, %{"id" => id, "location_id" => location_id, "team_id" => team_id}) do
    with %Data.Schema.Intent{} = intent <- Intent.get(%{role: "admin"}, id),
         {:ok, _} <- Intent.delete(intent) do
      conn
      |> put_flash(:success, "Intent deleted successfully.")
      |> redirect(to: team_location_intent_path(conn, :new, team_id, location_id))
    else
      {:error, :no_record_found} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        intents = Intent.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "failed to delete Intent")
        |> render(
             "new.html",
             changeset: Intent.get_changeset(),
             location_id: location_id,
             intents: intents,
             location: location,
             teams: teams(conn),
             has_sidebar: true,
             errors: []
           )
    end
  end
end
