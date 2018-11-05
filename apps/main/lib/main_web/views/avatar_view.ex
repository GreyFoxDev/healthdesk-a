defmodule MainWeb.AvatarView do
  use MainWeb, :view

  def render("ok.json", _) do
    %{success: true}
  end

  def render("error.json", _) do
    %{success: false}
  end
end
