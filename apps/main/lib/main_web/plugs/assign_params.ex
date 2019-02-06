defmodule MainWeb.Plug.AssignParams do
  @moduledoc """
  This plug is used to standardize the params coming in from the SMS
  service.
  """

  import Plug.Conn

  @spec init(list()) :: list()
  def init(opts), do: opts

  @doc """
  Takes the params and moves them to the the conn's assigns. This
  makes it easier to access in the pipeline.
  """
  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t()
  def call(%{params: params} = conn, _opts) do
    conn
    |> assign(:message, params["Body"])
    |> assign(:member, params["From"])
    |> assign(:location, params["To"])
  end
end
