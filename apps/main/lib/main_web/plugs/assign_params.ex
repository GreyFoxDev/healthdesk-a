defmodule MainWeb.Plug.AssignParams do
  @moduledoc """
  This plug is used to standardize the params coming in from the SMS
  service.
  """

  import Plug.Conn

  alias Data.Location

  @spec init(list()) :: list()
  def init(opts), do: opts

  @doc """
  Takes the params and moves them to the the conn's assigns. This
  makes it easier to access in the pipeline.
  """
  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t()
  def call(%{params: %{"Body" => body, "From" => member, "To" => location} = params} = conn, _opts) do
    if String.starts_with?(location, "messenger:") do
      conn
      |> assign(:message, body)
      |> assign(:member, member)
      |> assign(:location, "+13105893019")
    else
      conn
      |> assign(:message, body)
      |> assign(:member, member)
      |> assign(:location, location)
    end
  end

  def call(%{params: %{"flow_name" => flow} = params} = conn, _opts) do

    location = Location.get(%{role: "admin"}, params["location_id"])

    conn
    |> assign(:flow_name, flow)
    |> assign(:member, params["phone"])
    |> assign(:location, location.phone_number)
    |> assign(:location_name, location.location_name)
    |> assign(:first_name, params["fName"])
    |> assign(:last_name, params["lName"])
    |> assign(:barcode, params["barcode"])
    |> assign(:home_club, params["home_club"]) # optional
    |> assign(:new_club, params["new_club"]) # optional
    |> assign(:message, params["msg"])
  end

end
