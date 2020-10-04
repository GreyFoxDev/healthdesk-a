defmodule MainWeb.Live.ConversationsView do
  use Phoenix.LiveView, layout: {MainWeb.LayoutView, "live.html"}


  alias Data.{Location, Conversations, TeamMember, ConversationMessages, SavedReply, MemberChannel, Notes, Notifications}
  alias Data.Schema.MemberChannel, as: Channel
  alias MainWeb.Helper.Formatters

  @chatbot Application.get_env(:session, :chatbot, Chatbot)

  require Logger
  @limit 25
  @offset 0
  def render(assigns), do: MainWeb.ConversationView.render("index.html", assigns)

  def mount(_params, %{"location_id" => location_id, "conversation_id" => conversation_id, "user" => user}, socket) do
    location = user
               |> Location.get(location_id)
    Main.LiveUpdates.subscribe_live_view(location_id)
    Main.LiveUpdates.subscribe_live_view(conversation_id)
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

    teams = user
            |> Data.Team.all()
    team_members =
      user
      |> TeamMember.all(location_id)
    team_members_all = Enum.map(team_members, fn x -> {x.user.first_name <> " " <> x.user.last_name, x.id} end)
    conversation =
      user
      |> Conversations.get(conversation_id)
      |> fetch_member()

    messages =
      user
      |> ConversationMessages.all(conversation_id)
    saved_replies = SavedReply.get_by_location_id(location_id)
    notes= Notes.get_by_conversation(conversation_id)


    socket =
      socket
      |> assign(:conversation_id, conversation_id)
      |> assign(:conversation, conversation)
      |> assign(:saved_replies, saved_replies)
      |> assign(:team_members, team_members)
      |> assign(:team_members_all, team_members_all)
      |> assign(:messages, messages)
      |> assign(:notes, notes)
      |> assign(:tab1, "notes")
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
      |> assign(:search_string, "")
      |> assign(:current_user, user)


    {:ok, socket}
  end
  def mount( %{"location_id" => location_id, "team_id" => team_id},session, socket) do
    {:ok, user, claims} = MainWeb.Auth.Guardian.resource_from_token(session["guardian_default_token"])

    location = user
               |> Location.get(location_id)


     send(self(), {:fetch_c, %{user: user, location: location}})
     send(self(), {:fetch_d, %{user: user, location: location}})


    teams = user
            |> Data.Team.all()
    Main.LiveUpdates.subscribe_live_view(location_id)

    socket =
      socket
      |> assign(:location, location)
      |> assign(:conversations, [])
      |> assign(:my_conversations, [])
      |> assign(:teams, teams)
      |> assign(:dispositions, [])
      |> assign(:user, user)
      |> assign(:current_user, user)
      |> assign(:count, 0)
      |> assign(:loading, false)
      |> assign(:tab, "me")
      |> assign(:search_string, "")

    {:ok, socket}
  end

  def handle_info({:fetch_c, %{user: user, location: location}}, socket) do

    conversations = user
          |> Conversations.all(location.id)
    my_conversations =
      Enum.filter(conversations, fn (c) -> c.team_member && c.team_member.user_id == user.id end)
    count = open_convos(location.id)

    socket =
      socket
      |> assign(:conversations, conversations)
      |> assign(:my_conversations, my_conversations)
      |> assign(:count, count)

    {:noreply, socket}
  end
  def handle_info({:fetch_d, %{user: user, location: location}}, socket) do
    dispositions =
      user
      |> Data.Disposition.get_by_team_id(location.team_id)
      |> Stream.reject(&(&1.disposition_name in ["Automated", "Call deflected"]))
      |> Stream.map(&({&1.disposition_name, &1.id}))
      |> Enum.to_list()
    socket =
      socket
      |> assign(:dispositions, dispositions)

    {:noreply, socket}
  end

  def fetch_member(%{original_number: <<"CH", _rest :: binary>> = channel} = conversation) do
    with [%Channel{} = channel] <- MemberChannel.get_by_channel_id(channel) do
      Map.put(conversation, :member, channel.member)
    end
  end
  def fetch_member(conversation), do: conversation

  def handle_event("openconvo", %{"cid" => conversation_id, "lid" => location_id, "tid" => team_id} = params, socket) do
    user = socket.assigns.user
    team_members =
      user
      |> TeamMember.all(location_id)
    team_members_all = Enum.map(team_members, fn x -> {x.user.first_name <> " " <> x.user.last_name, x.id} end)
    conversation =
      user
      |> Conversations.get(conversation_id)
      |> fetch_member()
    Main.LiveUpdates.subscribe_live_view(conversation_id)
    messages =
      user
      |> ConversationMessages.all(conversation_id)
    saved_replies = SavedReply.get_by_location_id(location_id)

    notes= Notes.get_by_conversation(conversation_id)

    socket =
      socket
      |> assign(:conversation_id, conversation_id)
      |> assign(:conversation, conversation)
      |> assign(:saved_replies, saved_replies)
      |> assign(:team_members, team_members)
      |> assign(:team_members_all, team_members_all)
      |> assign(:messages, messages)
      |> assign(:has_sidebar, True)
      |> assign(:notes, notes)
      |> assign(:tab1, "notes")
      |> assign(:changeset, ConversationMessages.get_changeset())

    {:noreply, socket}

  end
  def handle_event("back", _, socket) do

    location = socket.assigns.location
    user = socket.assigns.user
    convo_id = socket.assigns.conversation_id
    Main.LiveUpdates.notify_live_view(convo_id, {__MODULE__, :agent_typing_stop})
    socket = %{
      socket |
      assigns: Map.delete(Map.delete(Map.delete(socket.assigns, :conversation_id), :conversation), :new),
      changed: Map.put_new(socket.changed, :key, true)
    }
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

  def handle_event("tab", %{"tab" => tab}, socket) do

    {
      :noreply,
      socket
      |> assign(:tab, tab)
      |> assign(:search_string, "")
    }
  end
  def handle_event("tab1", %{"tab" => tab}, socket) do

    {
      :noreply,
      socket
      |> assign(:tab1, tab)
    }
  end

  def handle_event("save", %{"conversation_message" => c_params} = params, socket) do
    location = socket.assigns.location
    user = socket.assigns.user
    conversation = socket.assigns.conversation

    send_message(conversation, params, location, user)
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
      |> assign(:child_id, length(messages))
      |> assign(:changeset, ConversationMessages.get_changeset())
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
           message = %Chatbot.Params{
             provider: :twilio,
             from: location.phone_number,
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
    location = socket.assigns.location
    user = socket.assigns.user
    conversation = socket.assigns.conversation
    if params["team_member_id"] != "" do
      case MainWeb.AssignTeamMemberController.assign(
             Map.merge(params, %{"id" => conversation.id, "location_id" => location.id})
           ) do
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
          {:noreply, socket}
        _ ->
          {:noreply, socket}
      end

    end

  end

  def handle_event("close", %{"did" => disposition_id} = params, socket)do

    location = socket.assigns.location
    user = socket.assigns.user
    conversation = case socket.assigns[:conversation] do
      nil -> conversation = Conversations.get(params["cid"])
      c -> c
    end

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
      ConversationMessages.create(message)
      socket = %{
        socket |
        assigns: Map.delete(socket.assigns, :conversation_id),
        changed: Map.put_new(socket.changed, :key, true)
      }

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
      Main.LiveUpdates.notify_live_view(location.id, {__MODULE__, :updated_open})

      socket =
        socket
        |> assign(:location, location)
        |> assign(:conversations, conversations)
        |> assign(:my_conversations, my_conversations)
        |> assign(:dispositions, dispositions)
        |> assign(:user, user)

      {:noreply, socket}
    else
      {:noreply, socket}

    end
  end
  def handle_event("close", %{"cid" => conversation_id}, socket)do
    location = socket.assigns.location
    user = socket.assigns.user
    conversation = Conversations.get(conversation_id)

    if conversation.status != "closed" do
      user_info = Formatters.format_team_member(user)
      _ = ConCache.delete(:session_cache, conversation_id)
      message = %{
        "conversation_id" => conversation_id,
        "phone_number" => user.phone_number,
        "message" => "CLOSED: Closed by #{user_info}",
        "sent_at" => DateTime.utc_now()
      }

      Conversations.update(%{"id" => conversation.id, "status" => "closed", "team_member_id" => nil})
      ConversationMessages.create(message)
      socket = %{
        socket |
        assigns: Map.delete(socket.assigns, :conversation_id),
        changed: Map.put_new(socket.changed, :key, true)
      }

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
      Main.LiveUpdates.notify_live_view(location.id, {__MODULE__, :updated_open})

      socket =
        socket
        |> assign(:location, location)
        |> assign(:conversations, conversations)
        |> assign(:my_conversations, my_conversations)
        |> assign(:dispositions, dispositions)
        |> assign(:user, user)

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

      Main.LiveUpdates.notify_live_view(location.id, {__MODULE__, :updated_open})
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
      {:noreply, socket}
    end

  end

  def handle_event("new", _, socket)do
    socket = socket
             |> assign(:new, "new")
             |> assign(changeset: Conversations.get_changeset(), )

    {:noreply, socket}
  end
  def handle_event("new_msg", params, socket)do

    location = socket.assigns.location
    user = socket.assigns.user
    MainWeb.ConversationController.create_convo(Map.merge(params, %{"location_id" => location.id}), location, user)
    socket = %{
      socket |
      assigns: Map.delete(Map.delete(Map.delete(socket.assigns, :conversation_id), :conversation), :new),
      changed: Map.put_new(socket.changed, :key, true)
    }
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
  def handle_info({_requesting_module, :online}, socket) do
    {:noreply, assign(socket, %{online: true})}
  end
  def handle_info({_requesting_module, :offline}, socket) do
    {:noreply, assign(socket, %{online: false})}
  end
  def handle_info({_requesting_module, :user_typing_start}, socket) do
    {:noreply, assign(socket, %{typing: true})}
  end
  def handle_info({_requesting_module, :user_typing_stop}, socket) do
    {:noreply, assign(socket, %{typing: false})}
  end
  def handle_info({_requesting_module, %Data.Schema.ConversationMessage{}=msg}, socket) do

    msgs_=merge(socket.assigns.messages,[msg])|>Enum.sort_by( &(&1.sent_at), {:asc, DateTime})
    {:noreply,assign(socket,:messages,msgs_)}
  end

  def handle_event("new_note",%{"foo" => params},socket)do
    conversation_id = socket.assigns.conversation_id
    team_members = socket.assigns.team_members
    location = socket.assigns.location
    user = socket.assigns.user
    text= params["text"]
    IO.inspect("###################")
    IO.inspect(text)
    IO.inspect(text|>String.contains?("@"))
    IO.inspect("###################")
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
      text
    end

    IO.inspect("###################")
    IO.inspect(text_)
    IO.inspect(notifications)
    IO.inspect("###################")

    Enum.each(notifications,fn n ->
      notify(%{user_id: n.user.id, from: user.id, conversation_id: conversation_id, text: " has mention you in a conversation"},n,location,user)
    end)

    params = %{"conversation_id" => conversation_id,"user_id" => user.id,"text" => text_}
    case Notes.create(params) do
      {:ok, _ } ->
        notes= Notes.get_by_conversation(conversation_id)
        {:noreply,assign(socket,:notes,notes)}
      {:error, _ } ->
        {:noreply,socket}

    end
  end

  def handle_event("focused", _, socket)do
    convo_id = socket.assigns.conversation_id
    team_members = socket.assigns.team_members
    Main.LiveUpdates.notify_live_view(convo_id, {__MODULE__, :agent_typing_start})
    {:noreply, socket}

  end
  def handle_event("blured", _, socket)do
    convo_id = socket.assigns.conversation_id
    Main.LiveUpdates.notify_live_view(convo_id, {__MODULE__, :agent_typing_stop})
    {:noreply, socket}
  end

  def handle_event("filter_convo", query, socket) do
    IO.inspect(query)
    search_string = query["value"]
    conversations = socket.assigns[:o_conversations] || socket.assigns.conversations
    my_conversations = socket.assigns[:o_my_conversations] || socket.assigns.my_conversations
    tab = socket.assigns.tab
    socket = case tab do
      "me" ->
        socket
        |> assign(:my_conversations, filter_conversations(my_conversations, search_string))
        |> assign(:o_my_conversations, my_conversations)
      _ ->
        socket
        |> assign(:conversations, filter_conversations(conversations, search_string))
        |> assign(:o_conversations, conversations)

    end
    {:noreply, socket}

  end
  defp filter_conversations(conversations, search_string) when is_list(conversations) do

    case search_string do
      "" -> conversations
      search_string ->
        Enum.filter(conversations, fn c -> filter_conversations(c, search_string) end)
    end
  end
  defp filter_conversations(c, search_string) when is_map(c) do
    if filter_conversations(c.original_number, search_string) do
      true
    else
      if filter_conversations(c.channel_type, search_string) do
        true
      else
        if c.team_member != nil do
          filter_conversations(
            (c.team_member.user.first_name <> " " <> c.team_member.user.last_name),
            search_string
          ) || filter_conversations(c.team_member.user.phone_number, search_string)
        else
          if c.member != nil do
            if c.member.first_name != nil do
              filter_conversations((c.member.first_name <> " " <> c.member.last_name), search_string)
            else
              filter_conversations(c.member.phone_number, search_string)
            end
          else
            false
          end
        end
      end
    end
  end
  defp filter_conversations(c, s) when is_binary(c) do
    String.downcase(c) =~ String.downcase(s)
  end

  defp open_convos(location_id) do
    %{role: "admin"}
    |> Conversations.all(location_id)
    |> Enum.count(&(&1.status in ["open", "pending"]))
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
  defp notify(params,team_member, location,user)do
    case Notifications.create(params) do
      {:ok, notif} ->
        Main.LiveUpdates.notify_live_view(params.user_id,{__MODULE__, :new_notif})
        MainWeb.Notify.send_to_teammate(params.conversation_id, params.text, location, team_member,user)
      _ -> nil
    end

  end

  defp merge(left, right), do: Map.merge(to_map(left), to_map(right), &resolve_conflict/3) |> Map.values
  defp to_map(list), do: for item <- list, into: %{}, do: {item.id, item}
  defp resolve_conflict(_key, %{read: read1} = map1, %{read: read2}),
       do: %{map1 | read: read1||read2}

end
