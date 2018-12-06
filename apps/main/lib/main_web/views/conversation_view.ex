defmodule MainWeb.ConversationView do
  use MainWeb, :view

  import MainWeb.Helper.Formatters

  def default_user do
    %{avatar: "/images/unknown-profile.jpg", user: %{role: "system", first_name: "Bot", last_name: ""}}
  end
end

