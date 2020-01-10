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
    do: "During normal business hours, someone from our staff will be with you shortly. If this is during off hours, we will reply the next business day."

end
