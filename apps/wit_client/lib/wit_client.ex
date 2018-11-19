defmodule WitClient.Actions do
  @moduledoc false

  use Wit.Actions

  def say(session, context, message) do
    IO.inspect({session, context, message}, label: "RESPONSE @ say/3")
  end

  def merge(session, context, message) do
    IO.inspect({session, context, message}, label: "RESPONSE @ merge/3")
    context
  end

  def error(session, context, error) do
    IO.inspect({session, context, error}, label: "RESPONSE @ error/3")
  end

  defaction fetch_message(session, context, message) do
    IO.inspect({session, context, message}, label: "RESPONSE @ fetch_message/3")
    context
  end
end
