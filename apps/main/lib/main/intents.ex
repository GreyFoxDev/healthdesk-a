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
  def get(:unknown_intent, location) do
    location = Data.Location.get_by_phone(location)
    if location.default_message != "" do
      location.default_message
    else
      @default_response
    end
  end

  def get(:unknown, location) do
    location = Data.Location.get_by_phone(location)
    if location.default_message != "" do
      location.default_message
    else
      @default_response
    end
  end

  def get({:unknown, [{"greetings", _}]}, _location),
    do: @default_greeting

  def get({:unknown, _}, location) do
    location = Data.Location.get_by_phone(location)
    if location.default_message != "" do
      location.default_message
    else
      @default_response
    end
  end

  def get({"routeNewSales", _}, location) do
    """
    We'd be happy to share information about our membership plans and pricing. When are you able to stop by for a tour? Or if you'd prefer, when's the best time to give you a call?
    """
  end

  def get({"routeHousekeeping", _}, location) do
    """
    Thank you for your message. We apologize for any inconvenience and are notifying our front desk now. Would you like us to follow-up with you?
    """
  end

  def get({"routeLostFound", _}, location) do
    """
    Thank you for your message. We are notifying our front desk now to check our Lost & Found. Would you like us to follow-up with you?
    """
  end

  def get({"routeRetention", _}, location) do
    """
    Thank you for your message. May I ask, why are you looking to cancel today?
    """
  end

  def get({"routeFrontDesk", _}, location) do
    """
    Thank you for your message. How can our front desk help you today?
    """
  end

  def get({"routeSupport", _}, location) do
    """
    Thank you for your message. Can you please confirm your first and last name?
    """
  end

  def get({intent, args}, location) do
    args = remove_intent(args)

    intent
    |> String.to_existing_atom()
    |> fetch_module()
    |> apply(:build_response, [args, location])
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
