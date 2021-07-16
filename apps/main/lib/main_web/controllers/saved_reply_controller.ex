defmodule MainWeb.SavedReplyController do
  use MainWeb.SecuredContoller

  alias Data.{SavedReply, Location}

  def new(conn, %{"location_id" => location_id} = _params) do

    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    saved_replies = SavedReply.get_by_location_id(location_id)

    render(
      conn,
      "new.html",
      changeset: SavedReply.get_changeset(),
      location_id: location_id,
      saved_replies: saved_replies,
      location: location,
      teams: teams(conn),
      has_sidebar: true,
      errors: []
    )
  end

  def create(
        conn,
        %{"draft" => _draft, "title" => _title, "location_id" => location_id, "team_id" => team_id} = params
      ) do

    with {:ok, _} <- SavedReply.create(params) do
      conn
      |> put_flash(:success, "Saved Reply created successfully.")
      |> redirect(to: team_location_saved_reply_path(conn, :new, team_id, location_id))
    else

      {:error, changeset} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        saved_replies = SavedReply.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "Saved Reply failed to create")
        |> render(
             "new.html",
             changeset: SavedReply.get_changeset(),
             location_id: location_id,
             saved_replies: saved_replies,
             location: location,
             teams: teams(conn),
             has_sidebar: true,
             errors: changeset.errors
           )
    end
  end

  def update(
        conn,
        %{"id" => id, "draft" => _draft, "title" => _title, "location_id" => location_id, "team_id" => team_id} = params
      ) do
    with %Data.Schema.SavedReply{} = saved_reply <- SavedReply.get(%{role: "admin"}, id),
         {:ok, _} <- SavedReply.update(saved_reply, params) do
      conn
      |> put_flash(:success, "Saved Reply updated successfully.")
      |> redirect(to: team_location_saved_reply_path(conn, :new, team_id, location_id))
    else
      {:error, changeset} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        saved_replies = SavedReply.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "Saved Reply failed to update")
        |> render(
             "new.html",
             changeset: SavedReply.get_changeset(),
             location_id: location_id,
             saved_replies: saved_replies,
             location: location,
             teams: teams(conn),
             has_sidebar: true,
             errors: changeset.errors
           )
    end
  end
  def update(conn, %{"id" => id, "draft" => _draft, "location_id" => location_id, "team_id" => team_id} = params) do
    with %Data.Schema.SavedReply{} = saved_reply <- SavedReply.get(%{role: "admin"}, id),
         {:ok, _} <- SavedReply.update(saved_reply, params) do
      conn
      |> put_flash(:success, "Saved Reply updated successfully.")
      |> redirect(to: team_location_saved_reply_path(conn, :new, team_id, location_id))
    else
      {:error, changeset} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        saved_replies = SavedReply.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "Saved Reply failed to update")
        |> render(
             "new.html",
             changeset: SavedReply.get_changeset(),
             location_id: location_id,
             saved_replies: saved_replies,
             location: location,
             teams: teams(conn),
             has_sidebar: true,
             errors: changeset.errors
           )
    end
  end
  def update(conn, %{"id" => id, "title" => _title, "location_id" => location_id, "team_id" => team_id} = params) do
    with %Data.Schema.SavedReply{} = saved_reply <- SavedReply.get(%{role: "admin"}, id),
         {:ok, _} <- SavedReply.update(saved_reply, params) do
      conn
      |> put_flash(:success, "Saved Reply updated successfully.")
      |> redirect(to: team_location_saved_reply_path(conn, :new, team_id, location_id))
    else
      {:error, changeset} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        saved_replies = SavedReply.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "Saved Reply failed to update")
        |> render(
             "new.html",
             changeset: SavedReply.get_changeset(),
             location_id: location_id,
             saved_replies: saved_replies,
             location: location,
             teams: teams(conn),
             has_sidebar: true,
             errors: changeset.errors
           )
    end
  end

  def delete(conn, %{"id" => id, "location_id" => location_id, "team_id" => team_id}) do
    with %Data.Schema.SavedReply{} = saved_reply <- SavedReply.get(%{role: "admin"}, id),
         {:ok, _} <- SavedReply.delete(saved_reply) do
      conn
      |> put_flash(:success, "Saved Reply deleted successfully.")
      |> redirect(to: team_location_saved_reply_path(conn, :new, team_id, location_id))
    else
      {:error, :no_record_found} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        saved_replies = SavedReply.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "failed to delete Saved Reply")
        |> render(
             "new.html",
             changeset: SavedReply.get_changeset(),
             location_id: location_id,
             saved_replies: saved_replies,
             location: location,
             teams: teams(conn),
             has_sidebar: true,
             errors: []
           )
    end
  end
end
