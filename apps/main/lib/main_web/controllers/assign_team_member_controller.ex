defmodule MainWeb.AssignTeamMemberController do
  use MainWeb, :controller

  alias MainWeb.Notify
  alias Data.{Conversations, ConversationMessages, TeamMember, Location}

  require Logger

  @assign_message "Message From: [phone_number]"
#  @assign_message "Message From: [phone_number]\n[message]"

  def assign(conn, %{"id" => _id, "location_id" => _location_id, "team_member_id" => _team_member_id}=params) do
    with {:ok, _} <- assign(params) do
      render(conn, "ok.json")
    else
      {:error, _changeset} ->
        render(conn, "error.json")
    end


  end
  def assign(%{"id" => id, "location_id" => location_id, "team_member_id" => team_member_id}) do
    location =
      Location.get(%{role: "admin"}, location_id)

    team_member =
      TeamMember.get(%{role: "admin"}, team_member_id)

    original_message =
      %{role: "admin"}
      |> ConversationMessages.all(id)
      |> Enum.reject(&(reject_location_messages(&1, location, team_member)))
      |> List.first()

    message = %{conversation_id: id,
      phone_number: team_member.user.phone_number,
      message: "ASSIGNED: #{team_member.user.first_name} was assigned to the conversation.",
      sent_at: DateTime.utc_now()}


    with {:ok, _pi} <- Conversations.update(%{"id" => id, "team_member_id" => team_member_id, "status" => "open"}),
         {:ok, _} <- ConversationMessages.create(message) do
      if original_message != nil do
        message =
          @assign_message
          |> String.replace("[phone_number]", original_message.phone_number)
#          |> String.replace("[message]", original_message.message)

        Notify.send_to_teammate(id, message, location.phone_number, team_member)

      end
      Main.LiveUpdates.notify_live_view(id, {__MODULE__, {:new_msg, message}})
      {:ok,%{}}
    else
      {:error, changeset} ->
        {:error,changeset}
    end
  end

  defp reject_location_messages(original_message, location, team_member) do
    if original_message.phone_number == location.phone_number or original_message.phone_number == team_member.user.phone_number, do: true, else: false
  end

end