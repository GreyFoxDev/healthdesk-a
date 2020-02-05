defmodule MainWeb.AssignTeamMemberController do
  use MainWeb, :controller

  alias MainWeb.Notify
  alias Data.{Conversations, ConversationMessages, TeamMember, Location}

  require Logger

  @assign_message "Message From: [phone_number]\n[message]"

  def assign(conn, %{"id" => id, "location_id" => location_id, "team_member_id" => team_member_id}) do

    location =
      Location.get(%{role: "admin"}, location_id)

    team_member =
      TeamMember.get(%{role: "admin"}, team_member_id)

    [original_message] = ConversationMessages.all(%{role: "admin"}, id) |> Enum.take(-1)

    message = %{"conversation_id" => id,
                "phone_number" => team_member.user.phone_number,
                "message" => "ASSIGNED: #{team_member.user.first_name} #{team_member.user.last_name} was assigned to the conversation.",
                "sent_at" => DateTime.utc_now()}


    with {:ok, _pi} <- Conversations.update(%{"id" => id, "team_member_id" => team_member_id}),
         {:ok, _} <- ConversationMessages.create(message) do

      message =
        @assign_message
        |> String.replace("[phone_number]", original_message.phone_number)
        |> String.replace("[message]", original_message.message)

      Notify.send_to_teammate(id, message, location.phone_number, team_member)

      render(conn, "ok.json")
    else
      {:error, _changeset} ->
        render(conn, "error.json")
    end
  end

end
