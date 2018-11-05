defmodule MainWeb.AvatarController do
  use MainWeb, :controller

  alias Data.TeamMember

  def remove_avatar(conn, %{"id" => id}) do
    with {:ok, _pid} <- TeamMember.update(id, %{avatar: ""}) do
      render(conn, "ok.json")
    else
      {:error, _message} ->
        render(conn, "error.json")
    end
  end
end
