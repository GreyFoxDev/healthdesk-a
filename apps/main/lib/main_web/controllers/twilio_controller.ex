defmodule MainWeb.TwilioController do
  @moduledoc """
  This controller is the communication pipeline for the bot.
  """
  use MainWeb, :controller

  alias MainWeb.Plug, as: P

  require Logger

  plug P.AssignParams
  plug P.OpenConversation
  plug P.OptIn
  plug P.CacheQuestion
  plug P.AskWit
  plug P.BuildAnswer
  plug P.CloseConversation

  @spec inbound(Plug.Conn.t(), Map.t()) :: Plug.Conn.t()
  def inbound(conn, params)

  @doc """
  This catches an explicit error that was raied in the pipeling
  """
  def inbound(%Plug.Conn{assigns: %{error: true}} = conn, _params) do
    Logger.info("SENDING ERROR: #{inspect conn}")

    conn
    |> put_resp_content_type("text/xml")
    |> render("error.xml")
  end

  @doc """
  Handle a successful communication with a member
  """
  def inbound(%Plug.Conn{assigns: %{response: response}} = conn, _params)
  when is_binary(response) do
    Logger.info("SENDING: #{response}")

    conn
    |> put_resp_content_type("text/xml")
    |> render("response.xml")
  end

  @doc """
  Handle an error back to member. This is a catch all function
  """
  def inbound(conn, _params) do
    Logger.info("SENDING ERROR: #{inspect conn}")

    conn
    |> put_resp_content_type("text/xml")
    |> render("error.xml")
  end
end
