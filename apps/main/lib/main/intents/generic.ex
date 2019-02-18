defmodule MainWeb.Intents.Generic do
  @moduledoc """
  This handles generic message responses
  """

  @behaviour MainWeb.Intents

  @impl MainWeb.Intents
  def build_response("thanks", _location) do
    "No sweat!"
  end

  def build_response(_args, _location),
    do: "Not sure about that. Give me a minute..."

end
