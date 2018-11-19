defmodule MainWeb.AssignTeamMemberController do
  use MainWeb, :controller

  alias Data.{Conversations, ConversationMessages, TeamMember, Location}

  require Logger

  @assign_message "You have been assigned to a conversation. Please login to respond."
  @chatbot Application.get_env(:session, :chatbot, Chatbot)

  def assign(conn, %{"id" => id, "location_id" => location_id, "team_member_id" => team_member_id}) do

    location =
      Location.get(%{role: "admin"}, location_id)

    team_member =
      TeamMember.get(%{role: "admin"}, team_member_id)

    message = %{"conversation_id" => id,
                "phone_number" => team_member.user.phone_number,
                "message" => "ASSIGNED: #{team_member.user.last_name} was assigned to the conversation.",
                "sent_at" => DateTime.utc_now()}


    with {:ok, _pi} <- Conversations.update(%{"id" => id, "team_member_id" => team_member_id}),
         {:ok, _} <- ConversationMessages.create(message) do

      @chatbot.send(%{provider: :twilio,
                      from: location.phone_number,
                      to: team_member.user.phone_number,
                      body: @assign_message})

      render(conn, "ok.json")
    else
      {:error, _changeset} ->
        render(conn, "error.json")
    end
  end

end
