defmodule MainWeb.Intents.ClassDescription do
  @moduledoc """
  This handles class schedule responses
  """

  alias Main.Integrations.Mindbody
  alias Data.{
    ClassSchedule,
    Location
  }

  @behaviour MainWeb.Intents

  @classes "[class_type]:\n[description]"
  @no_classes "It doesn't look like we have a class type by that name. (Please ensure correct spelling)"

  @impl MainWeb.Intents
  def build_response(args, location) when is_binary(location),
    do: build_response(args, Location.get_by_phone(location))

  def build_response([class_type: [%{"value" => class_type}]], %{mindbody_location_id: mb_id} = location) when mb_id not in [nil, ""] do
    class =
      location
      |> Mindbody.get_class_descriptions_by_location()
      |> Enum.find(&find_classes(&1, class_type))

    if class do
      @classes
      |> String.replace("[class_type]", class.class_type)
      |> String.replace("[description]", class.class_description)
    else
      @no_classes
    end
  end

  def build_response([class_type: [%{"value" => class_type}]], location) do
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

  def build_response(_, location),
    do: location.default_message

  defp find_classes(class, class_type) do
    with type <- String.downcase(class.class_type()),
         true <- String.contains?(type, String.downcase(class_type)) do
      true
    end
  end
end
