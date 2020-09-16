defmodule MainWeb.ConversationView do
  use MainWeb, :view

  import MainWeb.Helper.Formatters
  import MainWeb.Helper.MemberOptions

  def default_user do
    %{user: %{role: "system", first_name: "SMS Bot", last_name: "", avatar: "/images/unknown-profile.jpg"}}
  end
end
