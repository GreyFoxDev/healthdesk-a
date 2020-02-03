defmodule MainWeb.UserController do
  use MainWeb.SecuredContoller

  alias Data.User

  def edit(conn, %{"id" => id}) do
    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- User.get_changeset(id, user) do

      render(conn, "edit.html",
        changeset: changeset,
        teams: teams(conn),
        location: nil,
        user: user,
        errors: [])
    end
  end

  def update(conn, %{"id" => id, "user" => %{"image" => [image]} = user}) do
    with {:ok, avatar} <- Uploader.upload_image(image.path),
         {:ok, user} <- User.update(id, Map.merge(user, %{"avatar" => avatar})) do
      conn = put_flash(conn, :success, "Profile updated successfully.")
      case user.role do
        "admin" ->
          redirect(conn, to: "/admin/teams")
        _ ->
          path = team_location_conversation_path(conn, :index, user.team_member.team_id, user.team_member.location_id)
          redirect(conn, to: path)
      end
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Profile failed to update")
        |> render("edit.html", changeset: changeset, errors: changeset.errors)
    end
  end

  def update(conn, %{"id" => id, "user" => user}) do
    case User.update(id, user) do
      {:ok, %Data.Schema.User{} = user} ->
        conn = put_flash(conn, :success, "Profile updated successfully.")
        case user.role do
          "admin" ->
            redirect(conn, to: "/admin/teams")
          _ ->
            path = team_location_conversation_path(conn, :index, user.team_member.team_id, user.team_member.location_id)
            redirect(conn, to: path)
        end
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Profile failed to update")
        |> render("edit.html", changeset: changeset, errors: changeset.errors)
    end
  end
end
