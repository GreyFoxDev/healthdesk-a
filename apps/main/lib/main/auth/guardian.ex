defmodule MainWeb.Auth.Guardian do
  @moduledoc false

  use Guardian, otp_app: :main

  alias Data.User

  def subject_for_token(user, _claims),
    do: {:ok, to_string(user.id)}

  def resource_from_claims(claims),
    do: {:ok, User.get(%{role: "system"}, claims["sub"])}
end
