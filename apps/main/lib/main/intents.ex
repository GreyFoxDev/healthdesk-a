defmodule MainWeb.Intents do
  @moduledoc """
  This module receives the intent and args from Wit and then routes
  the information to the correct intent handler. To add a new intent
  add the module and implement the behaviour. Then add the atom and
  module to the @intents map.
  """

  @callback build_response(List.t, location :: binary) :: String.t
  @default_response "During normal business hours, someone from our staff will be with you shortly. If this is during off hours, we will reply the next business day."
  @default_greeting "Hello! How can I help you?"

  alias MainWeb.Intents.{
    Address,
    Hours,
    Wifi,
    DayPass,
    WeekPass,
    MonthPass,
    ChildCareHours,
    Generic,
    ClassSchedule,
    ClassCategory,
    ClassDescription,
    ClassNext,
    InstructorSchedule,
  }

  @intents %{
    getAddress: Address,
    getHours: Hours,
    getWifi: Wifi,
    getDayPass: DayPass,
    getWeekPass: WeekPass,
    getMonthPass: MonthPass,
    getChildCareHours: ChildCareHours,
    queryClassSchedule: ClassSchedule,
    queryClassCategory: ClassCategory,
    queryClassDescription: ClassDescription,
    queryClassNext: ClassNext,
    queryInstructorSchedule: InstructorSchedule,
    getMessageGeneric: Generic
  }

  @doc """
  Get the response from the intent module. If the intent hasn't been
  implemented then a default message is returned.
  """

  def get({:unknown, [{"greetings"=name, _}]} = intent, location) do

    location = Data.Location.get_by_phone(location)
    local_intent = Data.Intent.get_by(name, location.id)
    if local_intent != nil do
      local_intent.message
    else
      get_(intent, location)
    end
  end
  def get({name, _} = intent, location) when is_atom name do

    location = Data.Location.get_by_phone(location)
    local_intent = Data.Intent.get_by(to_string(name), location.id)

    if local_intent != nil do
      local_intent.message
    else
      get_(intent, location)
    end
  end
  def get({name, _} = intent, location) do

    location = Data.Location.get_by_phone(location)
    local_intent = Data.Intent.get_by(name, location.id)

    if local_intent != nil do
      local_intent.message
    else
      get_(intent, location)
    end
  end
  def get(:unknown_intent =name, location) do

    location = Data.Location.get_by_phone(location)
    local_intent = Data.Intent.get_by(to_string(name), location.id)

    if local_intent != nil do
      local_intent.message
    else
      get_(name, location)
    end
  end
  def get(:unknown =name, location) do

    location = Data.Location.get_by_phone(location)
    local_intent = Data.Intent.get_by(to_string(name), location.id)

    if local_intent != nil do
      local_intent.message
    else
      get_(name, location)
    end
  end
  def get(intent, location) do
      get_(intent, location)
  end

  def get_(:unknown_intent, location) do
    location = Data.Location.get_by_phone(location)
    if location.default_message != "" do
      location.default_message
    else
      @default_response
    end
  end

  def get_(:unknown, location) do
    location = Data.Location.get_by_phone(location)
    if location.default_message != "" do
      location.default_message
    else
      @default_response
    end
  end

  def get_({:unknown, [{"greetings", _}]}, _location),
    do: @default_greeting

  def get_({:unknown, _}, location) do
    location = Data.Location.get_by_phone(location)
    if location.default_message != "" do
      location.default_message
    else
      @default_response
    end
  end
  def get_({"salesQuestion", _}, location) do
    """
    We'd be happy to share information about our membership plans and pricing. When are you able to stop by for a tour? Or if you'd prefer, when's the best time to give you a call?
    """
  end
  def get_({"routeHousekeeping", _}, location) do
    """
    Thank you for your message. We apologize for any inconvenience and are notifying our front desk now. Would you like us to follow-up with you?
    """
  end

  def get_({"routeLostFound", _}, location) do
    """
    Thank you for your message. We are notifying our front desk now to check our Lost & Found. Would you like us to follow-up with you?
    """
  end

  def get_({"routeRetention", _}, location) do
    """
    Thank you for your message. May I ask, why are you looking to cancel today?
    """
  end

  def get_({"routeFrontDesk", _}, location) do
    """
    Thank you for your message. How can our front desk help you today?
    """
  end

  def get_({"routeSupport", _}, location) do
    """
    Thank you for your message. Can you please confirm your first and last name?
    """
  end
  def get_({"connectAgent", _}, location) do
    get({:unknown, %{}}, location)
  end
  def get_({"startOver", _}, location) do
    get({:unknown, %{}}, location)
  end

  def get_({intent, args}, location) do
    args = remove_intent(args)
    IO.inspect("###################")
    IO.inspect(args)
    IO.inspect("###################")

    with atom <- String.to_existing_atom(intent)do
      atom
      |> fetch_module()
      |> apply(:build_response, [args, location])
    else
      err ->     MainWeb.Intents |> apply(:build_response, [args, location])
    end
  end

  def build_response(_args, location) do
    location = Data.Location.get_by_phone(location)
    if location.default_message != "" do
      location.default_message
    else
      @default_response
    end
  end

  defp fetch_module(intent) when is_atom(intent),
    do: @intents[intent] || MainWeb.Intents

  defp remove_intent(args) when is_list(args),
    do: Enum.filter(args, fn({key, _}) -> key != :intent and key != :greetings end)

  defp remove_intent(args) when is_binary(args), do: args

end
