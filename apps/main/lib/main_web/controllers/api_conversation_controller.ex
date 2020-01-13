defmodule MainWeb.Api.ConversationController do
  use MainWeb, :controller

  alias Data.Commands.Conversations, as: C
  alias Data.Commands.ConversationMessages, as: CM
  alias Data.Commands.Location

  def create(conn, %{"location" => << "messenger:", location :: binary>>, "member" => << "messenger:", member :: binary>>}) do
    location = Location.get_by_messanger_id(location)

    with {:ok, convo} <- C.find_or_start_conversation({member, location.phone_number}) do
      conn
      |> put_status(200)
      |> put_resp_content_type("application/json")
      |> json(%{conversation_id: convo.id})
    end
  end

  def create(conn, %{"location" => location, "member" => member} = params) do
    with {:ok, convo} <- C.find_or_start_conversation({member, location}) do
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

  def update(conn, params) do

    conn
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{success: false})
  end

  def close(conn, %{"conversation_id" => id, "from" => from, "message" => message} = params) do
    if message == "Sent to Slack" do
      CM.write_new_message(id, from, params["slack_message"])

      :ok = MainWeb.Notify.send_to_admin(id, params["slack_message"], from)
    else
      CM.write_new_message(id, from, message)

      :ok = MainWeb.Notify.send_to_admin(id, message, from)
    end

    C.close(id)
    conn
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{conversation_id: id})
  end
end
