defmodule MainWeb.Live.ConversationsView do
  use Phoenix.LiveView

  alias Data.{Location, Conversations, TeamMember, ConversationMessages, SavedReply, MemberChannel}
  alias Data.Schema.MemberChannel, as: Channel
  alias MainWeb.Helper.Formatters

  @chatbot Application.get_env(:session, :chatbot, Chatbot)

  require Logger

  def render(assigns), do: MainWeb.ConversationView.render("index.html", assigns)

  def mount(_params, %{"location_id" => location_id,"conversation_id" => conversation_id, "user" => user}, socket) do
    location = user
               |> Location.get(location_id)
    Main.LiveUpdates.subscribe_live_view()
    conversations =
      user
      |> Conversations.all(location_id)

    my_conversations =
      Enum.filter(conversations, fn (c) -> c.team_member && c.team_member.user_id == user.id end)
    count = open_convos(location_id)
    dispositions =
      user
      |> Data.Disposition.get_by_team_id(location.team_id)
      |> Stream.reject(&(&1.disposition_name in ["Automated", "Call deflected"]))
      |> Stream.map(&({&1.disposition_name, &1.id}))
      |> Enum.to_list()

    teams= user |> Data.Team.all()
    team_members =
      user
      |> TeamMember.all(location_id)
    team_members_all= Enum.map(team_members, fn x -> {x.user.first_name<>" "<>x.user.last_name, x.id} end)
    conversation =
      user
      |> Conversations.get(conversation_id)
      |> fetch_member()

    messages =
      user
      |> ConversationMessages.all(conversation_id)
    saved_replies = SavedReply.get_by_location_id(location_id)

    socket =
      socket
      |> assign(:conversation_id, conversation_id)
      |> assign(:conversation, conversation)
      |> assign(:saved_replies, saved_replies)
      |> assign(:team_members, team_members)
      |> assign(:team_members_all, team_members_all)
      |> assign(:messages, messages)
      |> assign(:has_sidebar, True)
      |> assign(:changeset, ConversationMessages.get_changeset())
      |> assign(:location, location)
      |> assign(:conversations, conversations)
      |> assign(:my_conversations, my_conversations)
      |> assign(:teams, teams)
      |> assign(:dispositions, dispositions)
      |> assign(:user, user)
      |> assign(:count, count)
      |> assign(:tab, "open")
      

    {:ok, socket}
  end
  def mount(_params, %{"location_id" => location_id, "user" => user}, socket) do
    location = user
               |> Location.get(location_id)
    Main.LiveUpdates.subscribe_live_view()
    conversations =
      user
      |> Conversations.all(location_id)

    my_conversations =
      Enum.filter(conversations, fn (c) -> c.team_member && c.team_member.user_id == user.id end)
    count = open_convos(location_id)
    dispositions =
      user
      |> Data.Disposition.get_by_team_id(location.team_id)
      |> Stream.reject(&(&1.disposition_name in ["Automated", "Call deflected"]))
      |> Stream.map(&({&1.disposition_name, &1.id}))
      |> Enum.to_list()

    teams= user |> Data.Team.all()

    socket =
      socket
      |> assign(:location, location)
      |> assign(:conversations, conversations)
      |> assign(:my_conversations, my_conversations)
      |> assign(:teams, teams)
      |> assign(:dispositions, dispositions)
      |> assign(:user, user)
      |> assign(:count, count)
      |> assign(:tab, "me")


    {:ok, socket}
  end

  def fetch_member(%{original_number: << "CH", _rest :: binary >> = channel} = conversation) do
    with [%Channel{} = channel] <- MemberChannel.get_by_channel_id(channel) do
      Map.put(conversation, :member, channel.member)
    end
  end
  def fetch_member(conversation), do: conversation

  def handle_event("openconvo", %{ "cid" => conversation_id,"lid"=>location_id,"tid" => team_id}=params, socket) do
    user= socket.assigns.user
    team_members =
      user
      |> TeamMember.all(location_id)
    team_members_all= Enum.map(team_members, fn x -> {x.user.first_name<>" "<>x.user.last_name, x.id} end)
    conversation =
      user
      |> Conversations.get(conversation_id)
      |> fetch_member()


    messages =
      user
      |> ConversationMessages.all(conversation_id)
    saved_replies = SavedReply.get_by_location_id(location_id)

    socket =
      socket
      |> assign(:conversation_id, conversation_id)
      |> assign(:conversation, conversation)
      |> assign(:saved_replies, saved_replies)
      |> assign(:team_members, team_members)
      |> assign(:team_members_all, team_members_all)
      |> assign(:messages, messages)
      |> assign(:has_sidebar, True)
      |> assign(:changeset, ConversationMessages.get_changeset())

    {:noreply, socket}

  end
  def handle_event("back", _, socket) do

    location = socket.assigns.location
    user = socket.assigns.user
    socket= %{socket |
      assigns: Map.delete(Map.delete(Map.delete(socket.assigns,:conversation_id),:conversation),:new),changed: Map.put_new(socket.changed, :key, true)}
    conversations =
      user
      |> Conversations.all(location.id)

    my_conversations =
      Enum.filter(conversations, fn (c) -> c.team_member && c.team_member.user_id == user.id end)
    socket =
      socket
      |> assign(:location, location)
      |> assign(:conversations, conversations)
      |> assign(:my_conversations, my_conversations)
      
    {:noreply, socket}
  end

  def handle_event("tab", %{ "tab" => tab}, socket) do

    {:noreply, socket |> assign(:tab, tab)}
  end

  def handle_event("save", %{"conversation_message" => params}, socket) do
    location = socket.assigns.location
    user = socket.assigns.user
    conversation = socket.assigns.conversation

    send_message(conversation, params, location,user)
    conversation =
      user
      |> Conversations.get(conversation.id)
      |> fetch_member()

    messages =
      user
      |> ConversationMessages.all(conversation.id)
    socket =
      socket
      |> assign(:conversation, conversation)
      |> assign(:messages, messages)
      |> assign(:changeset, ConversationMessages.get_changeset())
    {:noreply, socket}
  end
  defp send_message(%{original_number: << "+1", _ :: binary >>} = conversation, params, location,user) do

    params
    |> Map.merge(%{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()})
    |> ConversationMessages.create()
    |> case do
         {:ok, _message} ->
           message = %{provider: :twilio, from: location.phone_number, to: conversation.original_number, body: params["conversation_message"]["message"]}
           @chatbot.send(message)
         {:error, _changeset} ->
           nil
       end
  end
  defp send_message(%{original_number: << "messenger:", _ :: binary>>} = conversation, params, location,user) do
    params
    |> Map.merge(%{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()})
    |> ConversationMessages.create()
    |> case do
         {:ok, _message} ->
           message = %Chatbot.Params{provider: :twilio, from: "messenger:#{location.messenger_id}", to: conversation.original_number, body: params["conversation_message"]["message"]}
           Chatbot.Client.Twilio.call(message)
         {:error, _changeset} ->
           nil
       end
  end
  defp send_message(%{original_number: << "CH", _ :: binary >>} = conversation, params, location,user) do


    from_name = if conversation.team_member do
      Enum.join([conversation.team_member.user.first_name, "#{String.first(conversation.team_member.user.last_name)}."], " ")
    else
      location.location_name
    end

    params
    |> Map.merge(%{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()})
    |> ConversationMessages.create()
    |> case do
         {:ok, _message} ->
           message = %Chatbot.Params{provider: :twilio, from: location.phone_number, to: conversation.original_number, body: params["conversation_message"]["message"]}
           Chatbot.Client.Twilio.channel(message)
         {:error, _changeset} -> nil
       end
  end
  defp send_message(%{original_number: << "APP", _ :: binary >>} = conversation, params, location,user) do

    from = if conversation.team_member do
      Enum.join([conversation.team_member.user.first_name, "#{String.first(conversation.team_member.user.last_name)}."], " ")
    else
      location.location_name
    end

    params
    |> Map.merge(%{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()})
    |> ConversationMessages.create()
  end

  def handle_event("assign", %{"foo" => params}, socket)do
    location = socket.assigns.location
    user = socket.assigns.user
    conversation = socket.assigns.conversation
    if params["team_member_id"] != "" do
      case MainWeb.AssignTeamMemberController.assign(Map.merge(params,%{"id" => conversation.id, "location_id" => location.id})) do
        {:ok, _} ->
          conversation =
            user
            |> Conversations.get(conversation.id)
            |> fetch_member()

          messages =
            user
            |> ConversationMessages.all(conversation.id)
          socket =
            socket
            |> assign(:conversation, conversation)
            |> assign(:messages, messages)
            |> assign(:changeset, ConversationMessages.get_changeset())
          {:noreply,socket}
        _ ->
          {:noreply,socket}
      end

    end

  end

  def handle_event("close", %{"did" => disposition_id}=params, socket)do

    location = socket.assigns.location
    user = socket.assigns.user
    conversation = case socket.assigns[:conversation] do
      nil ->  conversation = Conversations.get(params["cid"])
      c -> c
    end

    if conversation.status != "closed" do
      user_info = Formatters.format_team_member(user)
      _ = ConCache.delete(:session_cache, conversation.id)
      Data.ConversationDisposition.create(%{"conversation_id" => conversation.id, "disposition_id" => disposition_id})

      disposition =
        user
        |> Data.Disposition.get(disposition_id)

      message=   %{
        "conversation_id" => conversation.id,
        "phone_number" => user.phone_number,
        "message" => "CLOSED: Closed by #{user_info} with disposition #{disposition.disposition_name}",
        "sent_at" => DateTime.utc_now()
      }

      Conversations.update(%{"id" => conversation.id, "status" => "closed", "team_member_id" => nil})
      ConversationMessages.create(message)
      socket= %{socket |
        assigns: Map.delete(socket.assigns,:conversation_id),changed: Map.put_new(socket.changed, :key, true)}

      conversations =
        user
        |> Conversations.all(location.id)

      my_conversations =
        Enum.filter(conversations, fn (c) -> c.team_member && c.team_member.user_id == user.id end)

      dispositions =
        user
        |> Data.Disposition.get_by_team_id(location.team_id)
        |> Stream.reject(&(&1.disposition_name in ["Automated", "Call deflected"]))
        |> Stream.map(&({&1.disposition_name, &1.id}))
        |> Enum.to_list()
      Main.LiveUpdates.notify_live_view({__MODULE__, :updated_open})

      socket =
        socket
        |> assign(:location, location)
        |> assign(:conversations, conversations)
        |> assign(:my_conversations, my_conversations)
        |> assign(:dispositions, dispositions)
        |> assign(:user, user)
        
      {:noreply,socket}
      else
      {:noreply,socket}

    end
  end
  def handle_event("close", %{"cid" => conversation_id}, socket)do
    location = socket.assigns.location
    user = socket.assigns.user
    conversation = Conversations.get(conversation_id)

    if conversation.status != "closed" do
      user_info = Formatters.format_team_member(user)
      _ = ConCache.delete(:session_cache, conversation_id)
      message=   %{
        "conversation_id" => conversation_id,
        "phone_number" => user.phone_number,
        "message" => "CLOSED: Closed by #{user_info}",
        "sent_at" => DateTime.utc_now()
      }

      Conversations.update(%{"id" => conversation.id, "status" => "closed", "team_member_id" => nil})
      ConversationMessages.create(message)
      socket= %{socket |
        assigns: Map.delete(socket.assigns,:conversation_id),changed: Map.put_new(socket.changed, :key, true)}

      conversations =
        user
        |> Conversations.all(location.id)

      my_conversations =
        Enum.filter(conversations, fn (c) -> c.team_member && c.team_member.user_id == user.id end)

      dispositions =
        user
        |> Data.Disposition.get_by_team_id(location.team_id)
        |> Stream.reject(&(&1.disposition_name in ["Automated", "Call deflected"]))
        |> Stream.map(&({&1.disposition_name, &1.id}))
        |> Enum.to_list()
      Main.LiveUpdates.notify_live_view({__MODULE__, :updated_open})

      socket =
        socket
        |> assign(:location, location)
        |> assign(:conversations, conversations)
        |> assign(:my_conversations, my_conversations)
        |> assign(:dispositions, dispositions)
        |> assign(:user, user)

      {:noreply,socket}
      else
      {:noreply,socket}
    end
  end
  def handle_event("open", %{"cid" => id}, socket)do

    conversation = Conversations.get(id)
    location = socket.assigns.location
    user = socket.assigns.user

    if conversation.status == "closed" do

      user_info = Formatters.format_team_member(user)

      message = %{
        "conversation_id" => id,
        "phone_number" => user.phone_number,
        "message" => "OPENED: Opened by #{user_info}",
        "sent_at" => DateTime.utc_now()
      }


      Conversations.update(%{"id" => id, "status" => "pending"})
      ConversationMessages.create(message)


      pending_message_count = (ConCache.get(:session_cache, id) || 0)
      :ok = ConCache.put(:session_cache, id, pending_message_count + 1)
      team_members =
        user
        |> TeamMember.all(location.id)
      team_members_all= Enum.map(team_members, fn x -> {x.user.first_name<>" "<>x.user.last_name, x.id} end)
      conversation =
        user
        |> Conversations.get(id)
        |> fetch_member()


      messages =
        user
        |> ConversationMessages.all(id)
      saved_replies = SavedReply.get_by_location_id(location.id)
      Main.LiveUpdates.notify_live_view({__MODULE__, :updated_open})
      socket =
        socket
        |> assign(:conversation_id, id)
        |> assign(:conversation, conversation)
        |> assign(:saved_replies, saved_replies)
        |> assign(:team_members, team_members)
        |> assign(:team_members_all, team_members_all)
        |> assign(:messages, messages)
        |> assign(:has_sidebar, True)
        |> assign(:tab, "open")
        |> assign(:changeset, ConversationMessages.get_changeset())
      {:noreply, socket}
    else
      {:noreply,socket}
    end

  end

  def handle_event("new",_,socket)do
    socket = socket
    |> assign(:new, "new")
    |> assign( changeset: Conversations.get_changeset(),)

    {:noreply, socket}
  end
  def handle_event("new_msg",params,socket)do
    IO.inspect("###################")
    IO.inspect(params)
    IO.inspect("###################")

    location = socket.assigns.location
    user = socket.assigns.user
    MainWeb.ConversationController.create_convo(Map.merge(params,%{"location_id" => location.id}),location,user)
    socket= %{socket |
      assigns: Map.delete(Map.delete(Map.delete(socket.assigns,:conversation_id),:conversation),:new),changed: Map.put_new(socket.changed, :key, true)}
    conversations =
      user
      |> Conversations.all(location.id)

    my_conversations =
      Enum.filter(conversations, fn (c) -> c.team_member && c.team_member.user_id == user.id end)
    socket =
      socket
      |> assign(:location, location)
      |> assign(:conversations, conversations)
      |> assign(:my_conversations, my_conversations)
      |> assign(:tab, "open")

    {:noreply, socket}
  end

  def handle_info({_requesting_module, :updated_open}, socket) do
    count = open_convos(socket.assigns.location.id)
    {:noreply, assign(socket, %{count: count})}
  end
  defp open_convos(location_id) do
    %{role: "admin"}
    |> Conversations.all(location_id)
    |> Enum.count(&(&1.status in ["open", "pending"]))
  end
end
