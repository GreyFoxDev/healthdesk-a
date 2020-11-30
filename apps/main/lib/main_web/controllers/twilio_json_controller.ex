defmodule MainWeb.TwilioJsonController do
  @moduledoc """
  This controller is the communication pipeline for the bot.
  """
  use MainWeb, :controller

  alias MainWeb.Plug, as: P

  require Logger

  plug P.AssignParams
  plug P.SaveMemberData
  plug P.OpenConversation
  plug P.CacheQuestion
  plug P.AskWit
  plug P.BuildAnswer
  plug P.CloseConversation
  plug P.Broadcast

  @spec inbound(Plug.Conn.t(), Map.t()) :: Plug.Conn.t()
  def inbound(conn, params)

  @doc """
  This catches an explicit error that was raied in the pipeling
  """
  def inbound(%Plug.Conn{assigns: %{error: true}} = conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(500)
    |> json(%{message: "Service Error"})
  end

  def inbound(%Plug.Conn{assigns: %{status: "pending", convo: id}} = conn, _params) do
    pending_message_count = (ConCache.get(:session_cache, id) || 0)
    conn
    |> put_resp_content_type("application/json")
    |> put_status(200)
    |> json(%{message: conn.assigns[:response], pending: pending_message_count})
  end
  def inbound(%Plug.Conn{assigns: %{status: "open", convo: id}} = conn, _params) do
    pending_message_count = (ConCache.get(:session_cache, id) || 0)
    conn
    |> put_resp_content_type("application/json")
    |> put_status(200)
    |> json(%{message: conn.assigns[:response], pending: pending_message_count})
  end

  @doc """
  Handle a successful communication with a member
  """
  def inbound(%Plug.Conn{assigns: %{response: response}} = conn, _params)
      when is_binary(response) do
    conn
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{message: response, pending: 0})
  end

  @doc """
  Handle an error back to member. This is a catch all function
  """
  def inbound(conn, _params) do

    conn
    |> put_resp_content_type("application/json")
    |> put_status(500)
    |> json(%{message: "Service Error"})
  end
end
