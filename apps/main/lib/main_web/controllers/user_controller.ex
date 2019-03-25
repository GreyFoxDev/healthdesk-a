defmodule MainWeb.UserController do
  use MainWeb.SecuredContoller

  alias Data.{User, Location}

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
         {:ok, _pid} <- User.update(id, Map.merge(user, %{"avatar" => avatar})) do
      conn
      |> put_flash(:success, "Profile updated successfully.")
      |> redirect(to: "/admin/teams")
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
        conn
        |> put_flash(:success, "Profile updated successfully.")
        |> redirect(to: "/admin/teams")
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Profile failed to update")
        |> render("edit.html", changeset: changeset, errors: changeset.errors)
    end
  end
end
