defmodule MainWeb.TsiController do
  use MainWeb, :controller

  plug :put_layout, {MainWeb.LayoutView, :tsi}
  plug MainWeb.Plug.AllowFrom
  plug MainWeb.Plug.ValidateApiKey

  alias Data.Conversations, as: C
  alias Data.ConversationMessages, as: CM
  alias Data.Schema.Conversation, as: CSchema
  alias Data.Schema.Location, as: LSchema

  alias Data.{Location, Conversation}

  def new(conn, %{"phone-number" => phone_number} = params) do
    render(conn, "new.html", api_key: params["api_key"], phone_number: phone_number)
  end

  def new(conn, _params) do
    Plug.Conn.send_resp(conn, 400, "Bad request")
  end

  def create(conn, %{"phone_number" => phone_number} = params) do
    with %LSchema{} = location <- Location.get_by_api_key(params["api_key"]),
         {:ok, %CSchema{} = convo} <- C.find_or_start_conversation({phone_number, location.phone_number}) do

      CM.create(%{
            "conversation_id" => convo.id,
            "phone_number" => phone_number,
            "message" => Enum.join([params["comment"], ":\n", params["detail"]], ""),
            "sent_at" => DateTime.utc_now()})

      render(conn, "new.html", api_key: params["api_key"], phone_number: params["phone-number"])
    end
  end

  def create(conn, _params) do
    Plug.Conn.send_resp(conn, 400, "Bad request")
  end
end
