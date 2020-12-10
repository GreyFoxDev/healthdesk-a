defmodule Main.Email do
  import Bamboo.Email

  @from "info@healthdesk.ai"
  @from1 "info@theclub.healthdesk.ai"
  @default_subject "[Healthdesk] You have a new alert"

  def generate_email(to, message, subject \\ @default_subject) do
    new_email(
      to: to,
      from: @from,
      subject: subject,
      text_body: message
    )
  end
  def generate_reply_email(to, message, subject \\ @default_subject) do
    new_email(
      to: to,
      from: @from1,
      subject: "RE: "<> subject,
      text_body: message
    )
  end

end
