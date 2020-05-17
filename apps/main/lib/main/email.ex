defmodule Main.Email do
  import Bamboo.Email

  @from "info@healthdesk.ai"
  @default_subject "[Healthdesk] You have a new alert"

  def generate_email(to, message, subject \\ @default_subject) do
    new_email(
      to: to,
      from: @from,
      subject: subject,
      text_body: message
    )
  end

end
