defmodule MainWeb.Live.ConversationsView do
  use Phoenix.LiveView, layout: {MainWeb.LayoutView, "live.html"}


  alias Data.{Location, Conversations,Ticket, TeamMember, ConversationMessages, SavedReply, MemberChannel, Notes, Notifications}
  alias Data.Schema.MemberChannel, as: Channel
  alias MainWeb.Helper.Formatters
  import MainWeb.Helper.LocationHelper

  @chatbot Application.get_env(:session, :chatbot, Chatbot)

  require Logger
  @limit 25
  @offset 0
  def render(assigns), do: MainWeb.ConversationView.render("index.html", assigns)


  def mount(%{"id" => "active"},session, socket) do

    {:ok, user, claims} = MainWeb.Auth.Guardian.resource_from_token(session["guardian_default_token"])

    location_ids = user |> teammate_locations(true)
    locations = user |> teammate_locations()
    Main.LiveUpdates.subscribe_live_view()
    send(self(), {:fetch_c, %{user: user, locations: location_ids, type: "active"}})

    teams = user
            |> Data.Team.all()

    socket =
      socket
      |> assign(:locations, locations)
      |> assign(:location_ids, location_ids)
      |> assign(:conversations, [])
      |> assign(:my_conversations, [])
      |> assign(:teams, teams)
      |> assign(:dispositions, [])
      |> assign(:team_members, [])
      |> assign(:team_members_all, [])
      |> assign(:saved_replies, [])
      |> assign(:user, user)
      |> assign(:current_user, user)
      |> assign(:count, 0)
      |> assign(:loading, true)
      |> assign(:tab, "active")
      |> assign(:tab1, "details")
      |> assign(:search_string, "")
      |> assign(:changeset, Conversations.get_changeset())
      |> assign(:mchangeset, ConversationMessages.get_changeset())
      |> assign(:tchangeset, Ticket.get_changeset())


    {:ok, socket}
  end
  def mount(%{"id" => "assigned"},session, socket) do

    {:ok, user, claims} = MainWeb.Auth.Guardian.resource_from_token(session["guardian_default_token"])
    location_ids = user |> teammate_locations(true)
    locations = user |> teammate_locations()
    Main.LiveUpdates.subscribe_live_view()
    send(self(), {:fetch_c, %{user: user, locations: location_ids, type: "assigned"}})

    teams = user
            |> Data.Team.all()


    socket =
      socket
      |> assign(:locations, locations)
      |> assign(:location_ids, location_ids)
      |> assign(:conversations, [])
      |> assign(:my_conversations, [])
      |> assign(:teams, teams)
      |> assign(:dispositions, [])
      |> assign(:team_members, [])
      |> assign(:team_members_all, [])
      |> assign(:saved_replies, [])
      |> assign(:user, user)
      |> assign(:current_user, user)
      |> assign(:count, 0)
      |> assign(:loading, true)
      |> assign(:tab, "assigned")
      |> assign(:tab1, "details")
      |> assign(:search_string, "")
      |> assign(:tchangeset, Ticket.get_changeset())
      |> assign(:changeset, Conversations.get_changeset())
      |> assign(:mchangeset, ConversationMessages.get_changeset())



    {:ok, socket}
  end
  def mount(%{"id" => "closed"},session, socket) do

    {:ok, user, claims} = MainWeb.Auth.Guardian.resource_from_token(session["guardian_default_token"])
    location_ids = user |> teammate_locations(true)
    locations = user |> teammate_locations()
    Main.LiveUpdates.subscribe_live_view()
    send(self(), {:fetch_c, %{user: user, locations: location_ids, type: "closed"}})

    teams = user
            |> Data.Team.all()

    socket =
      socket
      |> assign(:locations, locations)
      |> assign(:location_ids, location_ids)
      |> assign(:conversations, [])
      |> assign(:my_conversations, [])
      |> assign(:teams, teams)
      |> assign(:dispositions, [])
      |> assign(:team_members, [])
      |> assign(:team_members_all, [])
      |> assign(:saved_replies, [])
      |> assign(:user, user)
      |> assign(:current_user, user)
      |> assign(:count, 0)
      |> assign(:loading, true)
      |> assign(:tab, "closed")
      |> assign(:tab1, "details")
      |> assign(:search_string, "")
      |> assign(:changeset, Conversations.get_changeset())
      |> assign(:mchangeset, ConversationMessages.get_changeset())
      |> assign(:tchangeset, Ticket.get_changeset())



    {:ok, socket}
  end
  def mount(%{"id" => conversation_id},session, socket) do


    {:ok, user, claims} = MainWeb.Auth.Guardian.resource_from_token(session["guardian_default_token"])

    location_ids = user |> teammate_locations(true)
    locations = user |> teammate_locations()
    convo =
      user
      |> Conversations.get(conversation_id)
      |> fetch_member()

    Main.LiveUpdates.subscribe_live_view()
    send(self(), {:fetch_c, %{user: user, locations: location_ids, convo: convo}})

    teams = user
            |> Data.Team.all()

    socket =
      socket
      |> assign(:locations, locations)
      |> assign(:location_ids, location_ids)
      |> assign(:conversations, [])
      |> assign(:my_conversations, [])
      |> assign(:teams, teams)
      |> assign(:dispositions, [])
      |> assign(:team_members, [])
      |> assign(:team_members_all, [])
      |> assign(:saved_replies, [])
      |> assign(:user, user)
      |> assign(:current_user, user)
      |> assign(:count, 0)
      |> assign(:loading, true)
      |> assign(:tab, "active")
      |> assign(:tab1, "details")
      |> assign(:search_string, "")
      |> assign(:changeset, Conversations.get_changeset())
      |> assign(:mchangeset, ConversationMessages.get_changeset())
      |> assign(:tchangeset, Ticket.get_changeset())


    {:ok, socket}
  end
  def mount(_,_,socket)do
    {:ok, redirect(socket, to: "/login")}
  end
  def handle_info({:fetch_c, %{user: user, locations: locations, type: "active"}}, socket) do

    conversations = user
                    |> Conversations.all(locations,["open", "pending"]) |> Enum.filter(fn (c) -> (!c.team_member)||(c.team_member && c.team_member.user_id == user.id) end)
    open_conversation = conversations |> List.first() |>fetch_member()

    socket = socket
             |> assign(:team_members, [])
             |> assign(:team_members_all, [])
             |> assign(:notes, [])
             |> assign(:saved_replies, [])
             |> assign(:dispositions, [])
             |> assign(:loading, false)
             |> assign(:conversations, conversations)
             |> assign(:open_conversation, open_conversation)
    if connected?(socket), do: Process.send_after(self(), :init_convo, 3000)
    send(self(), {:fetch_d, %{user: user, locations: locations, convo: open_conversation}})

    socket
    |> assign(:open_conversation, open_conversation)
    {:noreply, socket}
  end
  def handle_info({:fetch_c, %{user: user, locations: locations, type: "assigned"}}, socket) do

    conversations = user
                    |> Conversations.all(locations,["open", "pending"]) |> Enum.filter(fn (c) ->(c.team_member && c.team_member.user_id != user.id) end)
    open_conversation = conversations |> List.first() |>fetch_member()

    socket = socket
             |> assign(:team_members, [])
             |> assign(:team_members_all, [])
             |> assign(:notes, [])
             |> assign(:saved_replies, [])
             |> assign(:dispositions, [])
             |> assign(:loading, false)
             |> assign(:conversations, conversations)
             |> assign(:open_conversation, open_conversation)
    if connected?(socket), do: Process.send_after(self(), :init_convo, 3000)
    send(self(), {:fetch_d, %{user: user, locations: locations, convo: open_conversation}})

    socket
    |> assign(:open_conversation, open_conversation)
    {:noreply, socket}
  end
  def handle_info({:fetch_c, %{user: user, locations: locations, type: "closed"}}, socket) do

    conversations = user
                    |> Conversations.all(locations,["closed"])
    open_conversation= conversations |> List.first() |>fetch_member()

    socket = socket
             |> assign(:team_members, [])
             |> assign(:team_members_all, [])
             |> assign(:notes, [])
             |> assign(:saved_replies, [])
             |> assign(:dispositions, [])
             |> assign(:loading, false)
             |> assign(:conversations, conversations)
             |> assign(:open_conversation, open_conversation)
    if connected?(socket), do: Process.send_after(self(), :init_convo, 3000)
    send(self(), {:fetch_d, %{user: user, locations: locations, convo: open_conversation}})

    socket
    |> assign(:open_conversation, open_conversation)
    {:noreply, socket}
  end
  def handle_info({:fetch_c, %{user: user, locations: locations, convo: open_conversation}}, socket) do

    conversations = case open_conversation.status do
      "closed" -> user
                  |> Conversations.all(locations,["closed"])
      _ ->
        if open_conversation.team_member == nil || open_conversation.team_member.user_id == user.id do
          user
          |> Conversations.all(locations,["open", "pending"]) |> Enum.filter(fn (c) -> (!c.team_member)||(c.team_member && c.team_member.user_id == user.id) end)
        else
          conversations = user
                          |> Conversations.all(locations,["open", "pending"]) |> Enum.filter(fn (c) ->(c.team_member && c.team_member.user_id != user.id) end)
        end
    end
    tab = case open_conversation.status do
      "closed" -> "closed"
      _ ->
        if open_conversation.team_member == nil || open_conversation.team_member.user_id == user.id do
          "active"
        else
          "assigned"
        end
    end
    socket = socket
             |> assign(:team_members, [])
             |> assign(:tab, tab)
             |> assign(:team_members_all, [])
             |> assign(:notes, [])
             |> assign(:saved_replies, [])
             |> assign(:dispositions, [])
             |> assign(:loading, false)
             |> assign(:conversations, conversations)
             |> assign(:open_conversation, open_conversation)
    if connected?(socket), do: Process.send_after(self(), :init_convo, 3000)
    send(self(), {:fetch_d, %{user: user, locations: locations, convo: open_conversation}})

    socket
    |> assign(:open_conversation, open_conversation)
    {:noreply, socket}
  end
  def handle_info({:fetch_d, %{user: user, locations: locations, convo: nil}},socket)do
    {:noreply, socket}
  end
  def handle_info({:fetch_d, %{user: user, locations: locations, convo: open_conversation}},socket)do

    dispositions =
      user
      |> Data.Disposition.get_by_team_id(open_conversation.location.team_id)
      |> Stream.reject(&(&1.disposition_name in ["Automated", "Call deflected"]))
      |> Stream.map(&({&1.disposition_name, &1.id}))
      |> Enum.to_list()
    team_members =
      user
      |> TeamMember.all(open_conversation.location.id)
    team_members_all = Enum.map(team_members, fn x -> {x.user.first_name <> " " <> x.user.last_name, x.id} end)
    notes= Notes.get_by_conversation(open_conversation.id)
    saved_replies = SavedReply.get_by_location_id(open_conversation.location.id)
    socket = socket
             |> assign(:team_members, team_members)
             |> assign(:team_members_all, team_members_all)
             |> assign(:notes, notes)
             |> assign(:saved_replies, saved_replies)
             |> assign(:dispositions, dispositions)
             |> assign(:loading, false)
    if connected?(socket), do: Process.send_after(self(), :reload_convo, 1000)

    {:noreply, socket}
  end
  def fetch_member(%{original_number: <<"CH", _rest :: binary>> = channel} = conversation) do
    with [%Channel{} = channel] <- MemberChannel.get_by_channel_id(channel) do
      Map.put(conversation, :member, channel.member)
    end
  end
  def fetch_member(conversation), do: conversation

  def handle_event("openconvo", %{"cid" => conversation_id} = params, socket) do
    user = socket.assigns.user
    convo =
      user
      |> Conversations.get(conversation_id)
      |> fetch_member()

    socket = socket
             |> assign(:team_members, [])
             |> assign(:team_members_all, [])
             |> assign(:notes, [])
             |> assign(:saved_replies, [])
             |> assign(:dispositions, [])
             |> assign(:loading, false)
             |> assign(:open_conversation, convo)
             |> assign(:online, false)
             |> assign(:typing, false)


    send(self(), {:fetch_d, %{user: user, locations: socket.assigns.location_ids, convo: convo}})

    {:noreply, socket}
  end
  def handle_info(:reload_convo, socket) do

    {:noreply, push_event(socket, "reload_convo", %{})}

  end
  def handle_info(:init_convo, socket) do
    {:noreply, push_event(socket, "init_convo", %{})}
  end
  def handle_info(:menu_fix, socket) do
    {:noreply, push_event(socket, "menu_fix", %{})}
  end
  def handle_info(:scroll_chat, socket) do
    {:noreply, push_event(socket, "scroll_chat", %{})}
  end

  def handle_event("save", %{"conversation_message" => c_params} = params, socket) do
    location = socket.assigns.open_conversation.location
    user = socket.assigns.user
    conversation = socket.assigns.open_conversation


    send_message(conversation, params, location, user)
    conversation =
      user
      |> Conversations.get(conversation.id)
      |> fetch_member()

    messages =
      user
      |> ConversationMessages.all(conversation.id) |>Enum.reverse()
    socket =
      socket
      |> assign(:open_conversation, Map.merge(conversation,%{conversation_messages: messages}))
      |> assign(:child_id, (List.first(messages)).id)
      |> assign(:changeset, Conversations.get_changeset())
    if connected?(socket), do: Process.send_after(self(), :scroll_chat, 200)
    if connected?(socket), do: Process.send_after(self(), :menu_fix, 200)
    {:noreply, socket}
  end
  defp send_message(%{original_number: <<"+1", _ :: binary>>} = conversation, params, location, user) do

    params["conversation_message"]
    |> Map.merge(
         %{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()}
       )
    |> ConversationMessages.create()
    |> case do
         {:ok, message_} ->
           message = %{
             provider: :twilio,
             from: location.phone_number,
             to: conversation.original_number,
             body: params["conversation_message"]["message"]
           }
           @chatbot.send(message)

           Main.LiveUpdates.notify_live_view(conversation.id, {__MODULE__, {:new_msg, message_}})

         {:error, _changeset} ->
           nil
       end
  end
  defp send_message(%{original_number: <<"messenger:", _ :: binary>>} = conversation, params, location, user) do

    params["conversation_message"]
    |> Map.merge(
         %{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()}
       )
    |> ConversationMessages.create()
    |> case do
         {:ok, _message} ->
           message = %Chatbot.Params{
             provider: :twilio,
             from: "messenger:#{location.messenger_id}",
             to: conversation.original_number,
             body: params["conversation_message"]["message"]
           }
           Chatbot.Client.Twilio.call(message)
         {:error, _changeset} ->
           nil
       end
  end
  defp send_message(%{original_number: <<"CH", _ :: binary>>} = conversation, params, location, user) do


    from_name = if conversation.team_member do
      Enum.join(
        [conversation.team_member.user.first_name, "#{String.first(conversation.team_member.user.last_name)}."],
        " "
      )
    else
      location.location_name
    end

    params["conversation_message"]
    |> Map.merge(
         %{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()}
       )
    |> ConversationMessages.create()
    |> case do
         {:ok, _message} ->
           from = if conversation.team_member && conversation.team_member.user.first_name, do: conversation.team_member.user.first_name, else: location.location_name

           message = %Chatbot.Params{
             provider: :twilio,
             from: from,
             to: conversation.original_number,
             body: params["conversation_message"]["message"]
           }
           Chatbot.Client.Twilio.channel(message)
         {:error, _changeset} -> nil
       end
  end
  defp send_message(%{original_number: <<"APP", _ :: binary>>} = conversation, params, location, user) do

    from = if conversation.team_member do
      Enum.join(
        [conversation.team_member.user.first_name, "#{String.first(conversation.team_member.user.last_name)}."],
        " "
      )
    else
      location.location_name
    end

    params["conversation_message"]
    |> Map.merge(
         %{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()}
       )
    |> ConversationMessages.create()
    |> case do
         {:ok, message_} ->

           Main.LiveUpdates.notify_live_view(conversation.id, {__MODULE__, {:new_msg, message_}})
         _ -> nil
       end

  end

  def handle_event("assign", %{"foo" => params}, socket)do
    user = socket.assigns.user
    conversation_id = socket.assigns.open_conversation.id
    conversation =
      user
      |> Conversations.get(conversation_id)
      |> fetch_member()
    location = conversation.location
    if params["team_member_id"] != "" do
      case MainWeb.AssignTeamMemberController.assign(
             Map.merge(params, %{"id" => conversation.id, "location_id" => location.id})
           ) do
        {:ok, _} ->
          if socket.assigns.tab == "active" do
            conversation =
              user
              |> Conversations.get(conversation.id)
              |> fetch_member()
            locations = socket.assigns.location_ids
            conversations = user
                            |> Conversations.all(locations,["open", "pending"]) |> Enum.filter(fn (c) -> (!c.team_member)||(c.team_member && c.team_member.user_id == user.id) end)

            socket =
              socket
              |> assign(:open_conversation, conversations |> List.first()|>fetch_member())
              |> assign(:conversations, conversations)
              |> assign(:changeset, Conversations.get_changeset())

            {:noreply, socket}
          else
            {:noreply, redirect(socket, to: "/admin/conversations/active")}
          end
        _ ->
          {:noreply, socket}
      end

    end

  end
  def handle_event("assign", %{"cid" => conversation_id} = params, socket)do
    user = socket.assigns.user
    conversation =

      user
      |> Conversations.get(conversation_id)
      |> fetch_member()
    location = conversation.location

    case MainWeb.AssignTeamMemberController.assign(
           %{"id" => conversation.id, "location_id" => location.id, "team_member_id" => user.team_member.id}
         ) do
      {:ok, _} ->
        if socket.assigns.tab == "active" do
          conversation =
            user
            |> Conversations.get(conversation.id)
            |> fetch_member()
          locations = socket.assigns.location_ids
          conversations = user
                          |> Conversations.all(locations,["open", "pending"]) |> Enum.filter(fn (c) -> (!c.team_member)||(c.team_member && c.team_member.user_id == user.id) end)

          socket =
            socket
            |> assign(:open_conversation, conversation|>fetch_member())
            |> assign(:conversations, conversations)
            |> assign(:changeset, Conversations.get_changeset())
          if connected?(socket), do: Process.send_after(self(), :reload_convo, 500)

          {:noreply, socket}
        else
          {:noreply, redirect(socket, to: "/admin/conversations/active")}
        end
      _ ->
        {:noreply, socket}
    end


  end
  def handle_event("close", %{"did" => disposition_id} = params, socket)do


    user = socket.assigns.user
    conversation = socket.assigns.open_conversation
    location = socket.assigns.location_ids

    if conversation.status != "closed" do
      user_info = Formatters.format_team_member(user)
      _ = ConCache.delete(:session_cache, conversation.id)
      Data.ConversationDisposition.create(%{"conversation_id" => conversation.id, "disposition_id" => disposition_id})

      disposition =
        user
        |> Data.Disposition.get(disposition_id)

      message = %{
        "conversation_id" => conversation.id,
        "phone_number" => user.phone_number,
        "message" => "CLOSED: Closed by #{user_info} with disposition #{disposition.disposition_name}",
        "sent_at" => DateTime.utc_now()
      }

      Conversations.update(%{"id" => conversation.id, "status" => "closed", "team_member_id" => nil})
      Main.LiveUpdates.notify_live_view( {conversation.location.id, :updated_open})
      ConversationMessages.create(message)
      conversations = user
                      |> Conversations.all(socket.assigns.location_ids,["open", "pending"]) |> Enum.filter(fn (c) -> (!c.team_member)||(c.team_member && c.team_member.user_id == user.id) end)
      convo= conversations |> List.first()
      socket = case convo do
        nil ->
          if connected?(socket), do: Process.send_after(self(), :menu_fix, 1000)
          socket
          |> assign(:team_members, [])
          |> assign(:team_members_all, [])
          |> assign(:notes, [])
          |> assign(:saved_replies, [])
          |> assign(:dispositions, [])
          |> assign(:conversations, conversations)
          |> assign(:open_conversation, nil)
          |> assign(:loading, false)

        open_conversation ->
          dispositions =
            user
            |> Data.Disposition.get_by_team_id(open_conversation.location.team_id)
            |> Stream.reject(&(&1.disposition_name in ["Automated", "Call deflected"]))
            |> Stream.map(&({&1.disposition_name, &1.id}))
            |> Enum.to_list()
          team_members =
            user
            |> TeamMember.all(open_conversation.location.id)
          team_members_all = Enum.map(team_members, fn x -> {x.user.first_name <> " " <> x.user.last_name, x.id} end)
          notes= Notes.get_by_conversation(open_conversation.id)
          saved_replies = SavedReply.get_by_location_id(open_conversation.location.id)
          if connected?(socket), do: Process.send_after(self(), :menu_fix, 1000)
          socket
          |> assign(:team_members, team_members)
          |> assign(:team_members_all, team_members_all)
          |> assign(:notes, notes)
          |> assign(:saved_replies, saved_replies)
          |> assign(:dispositions, dispositions)
          |> assign(:conversations, conversations)
          |> assign(:open_conversation, open_conversation)
          |> assign(:loading, false)

      end
      {:noreply, socket}
    else
      {:noreply, socket}

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
      team_members_all = Enum.map(team_members, fn x -> {x.user.first_name <> " " <> x.user.last_name, x.id} end)
      conversation =
        user
        |> Conversations.get(id)
        |> fetch_member()


      messages =
        user
        |> ConversationMessages.all(id)
      saved_replies = SavedReply.get_by_location_id(location.id)

      Main.LiveUpdates.notify_live_view( {location.id, :updated_open})
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
        |> assign(:changeset, Conversations.get_changeset())
      {:noreply, socket}
    else
      {:noreply, socket}
    end

  end
  def handle_event("tab1", %{"tab" => tab}, socket)do

    socket =
      socket
      |> assign(:tab1, tab)
    {:noreply, socket}

  end
  def handle_event("new_msg", %{"conversation" => c_params, "location_id" => location_id} = params, socket)do

    user = socket.assigns.user
    location = user
               |> Location.get(location_id)

    MainWeb.ConversationController.create_convo(params, location, user)
    socket = %{
      socket |
      assigns: Map.delete(Map.delete(Map.delete(socket.assigns, :conversation_id), :conversation), :new),
      changed: Map.put_new(socket.changed, :key, true)
    }

    send(self(), {:fetch_c, %{user: user, locations: socket.assigns.location_ids, type: socket.assigns.tab}})

    {:noreply, socket}
  end
  def handle_event("new_ticket",%{"ticket" => params}, socket)do
    {:ok, res}=Ticket.create(params)
    IO.inspect("###################")
    IO.inspect(res)
    IO.inspect("###################")
    tm = TeamMember.get(%{role: "admin"}, res.team_member_id)
    notify(%{user_id: tm.user.id, from: res.user_id, ticket_id: res.id, text: " has assigned you a ticket"})
    Process.send_after(self(), :close_new, 10)
    {:noreply, socket}
  end
  def handle_info(:close_new, socket) do
    {:noreply, push_event(socket, "close_new", %{})}
  end
  def handle_info({convo_id, :online}, socket) do
    if socket.assigns.open_conversation && convo_id == socket.assigns.open_conversation.id do
      if connected?(socket), do: Process.send_after(self(), :menu_fix, 1000)
      {:noreply, assign(socket, %{online: true})}
    else
      {:noreply, socket}
    end
  end
  def handle_info({convo_id, :offline}, socket) do
    if socket.assigns.open_conversation && convo_id == socket.assigns.open_conversation.id do
      if connected?(socket), do: Process.send_after(self(), :menu_fix, 1000)

      {:noreply, assign(socket, %{online: false})}
    else
      {:noreply, socket}
    end
  end
  def handle_info({convo_id, :user_typing_start}, socket) do

    if  socket.assigns.open_conversation && convo_id == socket.assigns.open_conversation.id do
      if connected?(socket), do: Process.send_after(self(), :menu_fix, 1000)

      {:noreply, assign(socket, %{typing: true})}
    else
      {:noreply, socket}
    end
  end
  def handle_info({convo_id, :user_typing_stop}, socket) do
    if  socket.assigns.open_conversation && convo_id == socket.assigns.open_conversation.id do
      if connected?(socket), do: Process.send_after(self(), :menu_fix, 1000)

      {:noreply, assign(socket, %{typing: false})}
    else
      {:noreply, socket}
    end
  end
  def handle_info({convo_id, %Data.Schema.ConversationMessage{}=msg}, socket) do
    if  socket.assigns.open_conversation && convo_id == socket.assigns.open_conversation.id do
      user = socket.assigns.user
      conversation = socket.assigns.open_conversation
      messages =
        user
        |> ConversationMessages.all(conversation.id) |> Enum.reverse()
      socket =
        socket
        |> assign(:open_conversation, Map.merge(conversation,%{conversation_messages: messages}))
        |> assign(:child_id, (List.first(messages)).id)
        |> assign(:changeset, Conversations.get_changeset())
      if connected?(socket), do: Process.send_after(self(), :scroll_chat, 200)
      IO.inspect("###################")
      IO.inspect("this is 2")
      IO.inspect("###################")
      {:noreply,socket}
    else
      {:noreply,socket}
    end
  end
  def handle_info({location_id, :updated_open}, socket) do
    IO.inspect("###################")
    IO.inspect(:updated_open)
    IO.inspect("###################")

    if socket.assigns.tab == "active" && Enum.any?(socket.assigns.location_ids, fn x -> x == location_id end) do
      send(self(), {:fetch_c, %{user: socket.assigns.user, locations: socket.assigns.location_ids, type: "active"}})
    end
    {:noreply, socket}

  end
  def handle_event("new_note",%{"foo" => params},socket)do
    user = socket.assigns.user
    conversation_id = socket.assigns.open_conversation.id
    conversation =
      user
      |> Conversations.get(conversation_id)
      |> fetch_member()
    location = conversation.location
    team_members = socket.assigns.team_members
    text= params["text"]
    {text_,notifications} = if text|>String.contains?("@") do
      Enum.reduce(team_members,
        {text,[]}, fn m, {t,n} ->
        if String.contains?(t,"@" <> m.user.first_name <> " " <> m.user.last_name) do
          {
            String.replace(
              t,
              "@" <> m.user.first_name <> " " <> m.user.last_name,
              "<span class='user-tag'>" <> m.user.first_name <> " " <> m.user.last_name <> "</span>"
            ),
            n++[m]
          }
        else
          {t,n}
        end

      end)
    else
      {text,[]}
    end

    Enum.each(notifications,fn n ->
      notify(%{user_id: n.user.id, from: user.id, conversation_id: conversation_id, text: " has mention you in a conversation"},n,location,user)
    end)

    params = %{"conversation_id" => conversation_id,"user_id" => user.id,"text" => text_}
    case Notes.create(params) do
      {:ok, _ } ->
        notes = Notes.get_by_conversation(conversation_id)
        {:noreply , assign(socket,:notes,notes)}
      {:error , _ } ->
        {:noreply , socket}

    end
  end
  def handle_event("focused", _, socket)do
    convo_id = socket.assigns.open_conversation.id
    Main.LiveUpdates.notify_live_view(convo_id, {__MODULE__, :agent_typing_start})
    {:noreply, socket}

  end
  def handle_event("blured", _, socket)do
    convo_id = socket.assigns.open_conversation.id
    Main.LiveUpdates.notify_live_view(convo_id, {__MODULE__, :agent_typing_stop})
    {:noreply, socket}
  end
  def handle_event("filter_convo", query, socket) do
    search_string = query["value"]
    conversations = socket.assigns[:o_conversations] || socket.assigns.conversations


    socket =  socket
              |> assign(:conversations, filter_conversations(conversations, search_string))
              |> assign(:o_conversations, conversations)
    if connected?(socket), do: Process.send_after(self(), :reload_convo, 1000)

    {:noreply, socket}

  end
  defp filter_conversations(conversations, search_string) when is_list(conversations) do

    case search_string do
      "" -> conversations
      search_string ->
        res = Enum.filter(conversations, fn c -> filter_conversations(c, search_string) end)
        res
    end
  end
  defp filter_conversations(c, search_string) when is_map(c) do
    c= fetch_member (c)

    filter_conversations(c.original_number, search_string) ||
      filter_conversations(c.channel_type, search_string) ||
      filter_conversations(c.location.location_name, search_string) ||
      ( c.team_member != nil && filter_conversations(((c.team_member.user.first_name||"") <> " " <> (c.team_member.user.last_name||"")), search_string) )||
      ( c.team_member != nil &&   filter_conversations(c.team_member.user.phone_number, search_string)) ||
      ( c.member != nil && (c.member.first_name != nil && filter_conversations((c.member.first_name <> " " <> (c.member.last_name||"")), search_string))) ||
      ( c.member != nil && (c.member.phone_number != nil &&  filter_conversations(c.member.phone_number, search_string)))
  end
  defp filter_conversations(nil, s) do
    false
  end
  defp filter_conversations(c, s) when is_binary(c) do
    String.downcase(c) =~ String.downcase(s)
  end
  def terminate(reason, socket) do
    if(socket.assigns[:conversation_id]) do
      convo_id = socket.assigns.conversation_id
      Main.LiveUpdates.notify_live_view(convo_id, {__MODULE__, :agent_typing_stop})
    end

  end
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  def handle_event(_,params, socket) do
    {:noreply, socket}
  end
  defp notify(params)do
    case Notifications.create(params) do
      {:ok, notif} ->
        Main.LiveUpdates.notify_live_view(params.user_id,{__MODULE__, :new_notif})
      _ -> nil
    end

  end
  defp notify(params,team_member, location,user)do
    case Notifications.create(params) do
      {:ok, notif} ->
        Main.LiveUpdates.notify_live_view(params.user_id,{__MODULE__, :new_notif})
        MainWeb.Notify.send_to_teammate(params.conversation_id, params.text, location, team_member,user)
      _ -> nil
    end

  end
  defp merge(left, right), do: Map.merge(to_map(left), to_map(right), &resolve_conflict/3) |> Map.values
  defp to_map(list), do: (for item <- list, into: %{}, do: {item.id, item})
  defp resolve_conflict(_key, %{read: read1} = map1, %{read: read2}), do: %{map1 | read: read1||read2}

end
