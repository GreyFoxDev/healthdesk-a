defmodule Main.Email do
  import Bamboo.Email

  @from "info@healthdesk.ai"

  def generate_email(to, message) do
    new_email(
      to: to,
      from: @from,
      subject: "[Healthdesk] You have a new alert",
      text_body: message
    )
  end

end
