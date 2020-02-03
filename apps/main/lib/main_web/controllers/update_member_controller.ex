defmodule MainWeb.UpdateMemberController do
  use MainWeb, :controller

  alias Data.Member

  def update(conn, %{"id" => id, "member" => member}) do
    case Member.update(id, member) do
      {:ok, _member} ->
        render(conn, "ok.json")
      {:error, _changeset} ->
        render(conn, "error.json")
    end
  end

  def update(conn, %{"member" => member}) do
    phone = format_phone(member["phone_number"])

    if phone do
      with %Data.Schema.Member{} = member <- Member.get_by_phone_number(%{role: "admin"}, phone) do
        Member.update(member.id, member)
      else
        nil ->
          Member.create(member)
      end

      render(conn, "ok.json")
    else
      conn
      |> put_status(422)
      |> render("error.json")
    end
  end

  def format_phone("N/A"), do: nil

  def format_phone(<< "+1", number :: binary >>),
    do: format_phone(number)

  def format_phone(phone) do
    "+1#{replace_non_digits(phone)}"
  end

  defp replace_non_digits(phone), do: String.replace(phone, ~r/[^\d]/, "")
end
