defmodule MainWeb.TwilioView do
  use MainWeb, :view

  @error "Oh no! Something must have gone wrong, Sorry about that."

  @doc """
  Render the response back to the member in XML format
  """
  def render("response.xml", %{response: response}) do
    """
      <?xml version="1.0" encoding="UTF-8"?>
      <Response>
        <Message>#{response}</Message>
      </Response>
    """
  end

  @doc """
  Render a generic error message if there was a problem
  """
  def render("error.xml", _assigns) do
    """
      <?xml version="1.0" encoding="UTF-8"?>
        <Response>
        <Message>#{@error}</Message>
      </Response>
    """
  end
end
