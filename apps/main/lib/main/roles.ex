defmodule MainWeb.Roles do

  def all(%{role: role}) when role in ["admin", "team-admin"] do
    [
      {"Team Admin", "team-admin"},
      {"Location Admin", "location-admin"},
      {"Teammate", "teammate"}
    ]
  end

  def all(%{role: role}) when role in ["location-admin"] do
    [
      {"Location Admin", "location-admin"},
      {"Teammate", "teammate"}
    ]
  end

  def all(_), do: []
end
