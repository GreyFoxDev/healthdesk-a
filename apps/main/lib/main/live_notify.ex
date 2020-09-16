defmodule Main.LiveUpdates do
  @topic inspect(__MODULE__)

  @doc "subscribe for all users"
  def subscribe_live_view do
    Phoenix.PubSub.subscribe(Main.PubSub, topic(), link: true)
  end

  @doc "subscribe for specific user"
  def subscribe_live_view(user_id) do
    Phoenix.PubSub.subscribe(Main.PubSub, topic(user_id), link: true)
  end

  @doc "notify for all users"
  def notify_live_view(message) do
    Phoenix.PubSub.broadcast(Main.PubSub, topic(), message)
  end

  @doc "notify for specific user"
  def notify_live_view(user_id, message) do
    Phoenix.PubSub.broadcast(Main.PubSub, topic(user_id), message)
  end

  defp topic, do: @topic
  defp topic(user_id), do: topic() <> to_string(user_id)
end