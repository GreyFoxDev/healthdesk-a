defmodule MainWeb.Intents.ClassDescription do
  @moduledoc """
  This handles class schedule responses
  """

  alias Data.Commands.{
    ClassSchedule,
    Location
  }

  @behaviour MainWeb.Intents

  @classes "[class_type]:\n[description]"
  @default_response "I'm checking with a teammate for assistance. One moment please..."
  @no_classes "It doesn't look like we have a class type by that name. (Please ensure correct spelling)"

  @impl MainWeb.Intents
  def build_response([class_type: [%{"value" => class_type}]], location) do
    location = Location.get_by_phone(location)

    class =
      location.id
      |> ClassSchedule.all()
      |> Enum.find(&find_classes(&1, class_type))

    if class do
      @classes
      |> String.replace("[class_type]", class.class_type)
      |> String.replace("[description]", class.class_description)
    else
      @no_classes
    end
  end

  def build_response(_args, _location),
    do: @default_response

  defp find_classes(class, class_type) do
    with class_type <- String.downcase(class.class_type()),
         true <- String.contains?(class_type, String.downcase(class_type)) do
      true
    end
  end
end
