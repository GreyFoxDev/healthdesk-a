defmodule MainWeb.UpdateMemberView do
  use MainWeb, :view

  def render("ok.json", _) do
    %{success: true}
  end

  def render("error.json", _assigns) do
    %{success: false, message: "Member has not opted in so you can not update at this time." }
  end
end
