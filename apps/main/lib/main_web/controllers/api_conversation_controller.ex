defmodule MainWeb.Api.ConversationController do
  use MainWeb, :controller

  alias Data.Commands.Conversations, as: C
  alias Data.Commands.ConversationMessages, as: CM

  def create(conn, %{"location" => location, "member" => member, "message" => message} = params) do
    with {:ok, convo} <- C.find_or_start_conversation({member, location}) do
      CM.write_new_message(convo.id, location, message)

      conn
      |> put_status(200)
      |> put_resp_content_type("application/json")
      |> json(%{conversation_id: convo.id})
    end
  end

  def update(conn, %{"conversation_id" => id, "from" => from, "message" => message} = params) do
    CM.write_new_message(id, from, message)
    conn
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{conversation_id: id, updated: true})
  end

  def close(conn, %{"conversation_id" => id, "from" => from, "message" => message}) do
    CM.write_new_message(id, from, message)
    C.close(id)

    conn
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{conversation_id: id})
  end
end
