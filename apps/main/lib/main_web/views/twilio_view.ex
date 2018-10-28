defmodule MainWeb.TwilioView do
  use MainWeb, :view

  def render("index.xml", _assigns) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <Response>
      <Hangup />
    </Response>
    """
  end
end
