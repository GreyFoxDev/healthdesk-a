defmodule MainWeb.Intents do
  @moduledoc """
  This module receives the intent and args from Wit and then routes
  the information to the correct intent handler. To add a new intent
  add the module and implement the behaviour. Then add the atom and
  module to the @intents map.
  """

  @callback build_response(List.t, location :: binary) :: String.t
  @default_response "During normal business hours, a team member will be with you shortly."
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
  def get(:unknown_intent, _location),
    do: @default_response

  def get(:unknown, _location),
    do: @default_response

  def get({:unknown, [{"greetings", _}]}, _location),
    do: @default_greeting

  def get({:unknown, _}, _location),
    do: @default_response

  def get({"getMembershipPricing", _}, location) do
    """
    We offer 3 membership plans. Here's a link to our Join Online page:
    https://10fitness.com/location-select/
    """
  end

  def get({intent, args}, location) do
    args = remove_intent(args)

    intent
    |> String.to_existing_atom()
    |> fetch_module()
    |> apply(:build_response, [args, location])
  end

  def build_response(_args, _location),
    do: @default_response

  defp fetch_module(intent) when is_atom(intent),
    do: @intents[intent] || MainWeb.Intents

  defp remove_intent(args) when is_list(args),
    do: Enum.filter(args, fn({key, _}) -> key != :intent and key != :greetings end)

  defp remove_intent(args) when is_binary(args), do: args

end
