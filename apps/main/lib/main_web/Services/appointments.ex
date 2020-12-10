defmodule Main.Service.Appointment do
  require Logger
  alias MainWeb.{Intents, Notify}
  alias Data.Location
  alias Data.Conversations, as: C
  alias Data.ConversationMessages, as: CM
  alias Data.Appointments, as: AP
  use Timex
  @default_response "During normal business hours, someone from our staff will be with you shortly. If this is during off hours, we will reply the next business day."

  def get_next_reply(id,intent,location)do
    IO.inspect("###################")
    IO.inspect(intent)

    location = Data.Location.get_by_phone(location)

    convo = C.get(id)
    step = convo.step
    appointment = convo.appointment
    IO.inspect("###################")
    IO.inspect(appointment)
    IO.inspect(location.google_token)
    IO.inspect("###################")

    if location.google_token do
      get_next_intent(id,step,intent,location,appointment)
    else
      case intent do
        {check,_} when check in ["bookAppointment", "startOver", "connectAgent"]  ->
          Intents.get(:unknown, location.phone_number)
        _ ->
          Intents.get(intent, location.phone_number)
      end
    end

  end
  defp get_next_intent(id,step,intent,location,appointment) when appointment == false do
    case intent do
      {check,_} when check in ["bookAppointment","salesQuestion"]  ->
        C.appointment_open(id)
        AP.create(%{conversation_id: id})
        get(intent, location.phone_number)
      {check,_} when check in [ "startOver", "connectAgent"]  ->
        Intents.get(:unknown, location.phone_number)
      _ ->
        Intents.get(intent, location.phone_number)
    end
  end
  defp get_next_intent(id,step,intent,location,appointment) do
    appointment = AP.get_by_conversation(id) |> List.first
    appointment =
      case appointment  do
        nil -> AP.create(%{conversation_id: id})
        appointment ->appointment
      end
    {res, step_next} = case intent do
      {check,_} when check in ["bookAppointment","salesQuestion"]  ->
        C.appointment_open(id)
        {Intents.get(intent, location.phone_number),1}
      {check,_} when check in ["startOver"]  ->
        C.appointment_open(id)
        {Intents.get({"bookAppointment",[]}, location.phone_number),1}
      {"connectAgent",_}  ->
        C.appointment_close(id)
        Intents.get(:unknown, location.phone_number)
      {:unknown,[number: [%{"value" => value}]]} ->
        {res,step}=  get_next_step(appointment,step,value,location)
        C.appointment_step(id,step)
        {res,step}
      {:unknown,[datetime: date]} ->
        {:ok, dt} = Timex.parse(date, "{ISO:Extended}")
        {res,step}=  get_next_step(appointment,step,dt,location)
        C.appointment_step(id,step)
        {res,step}
      {:unknown,[datetime: date, greetings: _ ]} ->
        {:ok, dt} = Timex.parse(date, "{ISO:Extended}")
        {res,step}=  get_next_step(appointment,step,dt,location)
        C.appointment_step(id,step)
        {res,step}
      {:unknown,[contact: [%{"value" => value}]]} ->
        {res,step}=  get_next_step(appointment,step,value,location)
        C.appointment_step(id,step)
        {res,step}
      {:unknown,[phone_number: [%{"value" => value}]]} ->
        {res,step}=  get_next_step(appointment,step,value,location)
        C.appointment_step(id,step)
        {res,step}
      {:unknown,[response: [%{"value" => value}]]} ->
        value = String.to_integer value
        {res,step}=  get_next_step(appointment,step,value,location)
        C.appointment_step(id,step)
        {res,step}
      {:unknown,[email: [%{"value" => value}]]} ->
        {res,step_next}=  get_next_step(appointment,step,value,location)
        {res,step_next}
      {:unknown,_} ->
        {res,step}=  get_next_step(appointment,step,:unknown,location)
        C.appointment_step(id,step)
        {res,step}
      _ -> {Intents.get(intent, location.phone_number),35}
    end
    cond do
      step_next in [13] && step in [1,11,12] ->
        C.appointment_close(id)
      step_next in [15] && step in [2,13,14] ->
        C.appointment_close(id)
      step_next in [17] && step in [3,15,16] ->
        C.appointment_close(id)
      step_next in [19] && step in [4,17,18] ->
        C.appointment_close(id)
      step_next in [23] && step in [5,21,22] ->
        C.appointment_close(id)
      step_next in [21] && step in [6,19,20] ->
        C.appointment_close(id)
      step_next in [8] ->
        C.appointment_close(id)
      step_next in [35] ->
        C.appointment_close(id)
      true ->
        C.appointment_step(id,step_next)
    end
    res

  end


  defp get_next_step(appointment,step,value,location) when value in [1,2] and step in [1,11,12] do
    AP.update(%{"id" => appointment.id,"type" => type(value)})
    dates = get_dates()
    res =  """
    What day works for you? You can also ask for a specific day if you don't see a date that works:

    1. #{dates.a}
    2. #{dates.b}
    3. #{dates.c}
    4. #{dates.d}
    5. #{dates.e}
    6. Show full calendar
    """
    {res,2}
  end
  defp get_next_step(appointment,step,value,location) when value in [1,2,3,4,5] and step in [2,13,14] do
    date = get_dates(value)
    IO.inspect("######ddddd#############")
    IO.inspect(date)
    IO.inspect("###################")

    AP.update(%{"id" => appointment.id,"date" => date})
    res =
      """
      Here's our schedule on Friday, December 4. What time would you like to stop by?

      1. 11am
      2. 12:15pm
      3. 1pm
      4. 2pm
      5. 3:30pm
      6. 6pm
      7. Pick different day
      8. Show full calendar
      """
    {res,3}
  end
  defp get_next_step(appointment,step, %DateTime{} = dt,location) when step in [2,13,14] do
    AP.update(%{"id" => appointment.id,"date" => format_date(dt)})
    res =
      """
      Here's our schedule on #{format_date(dt)}. What time would you like to stop by?

      1. 11am
      2. 12:15pm
      3. 1pm
      4. 2pm
      5. 3:30pm
      6. 6pm
      7. Pick different day
      8. Show full calendar
      """
    {res,3}
  end
  defp get_next_step(appointment,step,value,location) when value in [6] and step in [2,13,14] do
    {get_calendar(location),3}
  end
  defp get_next_step(appointment,step,value,location) when value in [1,2,3,4,5,6] and step in [3,15,16] do
    AP.update(%{"id" => appointment.id,"time" => get_time(value)})
    res =
      """
      Great, I'll just need a few more pieces of information. What's your full name?
      """
    {res,4}
  end
  defp get_next_step(appointment,step,%DateTime{} = dt,location) when step in [3,15,16] do
    AP.update(%{"id" => appointment.id,"time" => format_time(dt)})
    res =
      """
      Great, I'll just need a few more pieces of information. What's your full name?
      """
    {res,4}
  end
  defp get_next_step(appointment,step,value,location) when value in [7] and step in [3,15,16] do
    dates = get_dates()
    res =  """
    What day works for you? You can also ask for a specific day if you don't see a date that works:

    1. #{dates.a}
    2. #{dates.b}
    3. #{dates.c}
    4. #{dates.d}
    5. #{dates.e}
    6. Show full calendar
    """
    {res,2}
  end
  defp get_next_step(appointment,step,value,location) when value in [8] and step in [3,15,16] do
    {get_calendar(location),4}
  end
  defp get_next_step(appointment,step,value,location) when is_binary(value) and step in [4,17,18] do
    AP.update(%{"id" => appointment.id,"name" => value})
    name = value |> String.split |> Enum.map(&String.capitalize/1)|>Enum.join(" ")
    res = """
    Thanks #{name}. Can I please get your 10-digit phone number?
    """
    {res,5}
  end
  defp get_next_step(appointment,step,value,location) when is_binary(value) and step in [5,21,22] do
    AP.update(%{"id" => appointment.id,"phone" => value})

    res = """
    Where do you want me to email the calendar invite?
    """
    {res,6}
  end
  defp get_next_step(appointment,step,value,location) when is_binary(value) and step in [6,19,20] do
    {:ok, appointment} = AP.update(%{"id" => appointment.id,"email" => value})

    name = appointment.name |> String.split |> Enum.map(&String.capitalize/1)|>Enum.join(" ")

    res = """
    Before I schedule your free Fitness Assessment, does everything look right?

    1. Yes
    2. No

    ...

    #{appointment.type} with #{name}
    #{appointment.phone}
    #{appointment.email}
    #{appointment.date} @ #{appointment.time}
    #{location.address_1} #{location.city} #{location.state} #{location.postal_code}
    """
    {res,7}
  end
  defp get_next_step(appointment,step,value,location) when value in [1] and step in [7] do
    IO.inspect("###################")
    IO.inspect(location)
    IO.inspect("###################")

    url = if location.google_token do
      event(appointment,location)
    else
      ""
    end
    AP.update(%{"id" => appointment.id,"confirmed" => true, "link" => url})

    res = """
    You're all set. Please check your email for the calendar invite. We'll call you then!

    #{url}

    To make the most of our appointment, please fill out this form prior to your visit: https://forms.gle/MiJxNwmZb5hcHiwW7

    """
    {res,step+1}
  end
  defp get_next_step(appointment,step,value,location) when value in [2] and step in [7] do
    res = """
    Could you please rephrase that? (I'm a bot) Would you like to book?

    1. Yes
    2. No

    (If you need help, you can always say 'agent' to chat with a person. You can also text 'start over' anytime.)
    """
    {res,step}
  end
  defp get_next_step(appointment,step,_,location) when step in [1,2,3,11,12,13,14,15,16] do
    res= case step do
      1 -> 11
      2 -> 13
      3 -> 15
      s -> s+1
    end
    {fallback_intent(res,location),res}
  end
  defp get_next_step(appointment,step,_,location) when step in [4,5,6,17,18,19,20,21,22] do
    res= case step do
      1 -> 11
      2 -> 13
      3 -> 15
      s -> s+1
    end
    {fallback_intent(res,location),res}
  end
  defp get_next_step(appointment,step,value,location) when value in [:unknown] and step in [17,18] do
    res = """
    Please enter a valid name.
    """
    {res,step+1}
  end
  defp get_next_step(appointment,step,value,location) when value in [:unknown] and step in [19,20] do
    res = """
    Please enter a valid email address.
    """
    {res,step+1}
  end
  defp get_next_step(appointment,step,value,location) when value in [:unknown] and step in [21,22] do
    res = """
    Please enter a valid 10-digit phone number. No spaces, dashes, or special characters.
    """
    {res,step+1}
  end
  defp get_dates() do
    today = Timex.today
    %{
      a: format_date(today),
      b: format_date(Timex.shift(today, days: 1)),
      c: format_date(Timex.shift(today, days: 2)),
      d: format_date(Timex.shift(today, days: 3)),
      e: format_date(Timex.shift(today, days: 4))
    }
  end
  defp get_dates(num) do
    today = Timex.today
    Timex.shift(today, days: num-1) |> format_date
  end
  defp get_time(num) do
    today = Timex.today |> Timex.to_datetime
    val = case num do
      1 -> Timex.set today, [hour: 11]
      2 -> Timex.set today, [hour: 12, minute: 30]
      3 -> Timex.set today, [hour: 13]
      4 -> Timex.set today, [hour: 14]
      5 -> Timex.set today, [hour: 15, minute: 30]
      6 -> Timex.set today, [hour: 18]
    end

    format_time(val)
  end
  defp format_date(date) do
    {:ok,val}=Timex.format(date, "{WDshort}, {Mshort} {D}")
    val
  end
  defp format_time(date) do
    #    Timex.parse( "{h12}:{m} {am}")
    {:ok,val}=Timex.format(date, "{h12}:{m} {am}")
    val
  end
  defp fallback_intent(s,_) when s in [11,13,15] do
    """
    Not sure I understood that (I'm a bot). Which option did you mean?

    (If you need help, you can always say 'agent' to chat with a person. You can also text 'start over' anytime.)
    """
  end
  defp fallback_intent(s,_) when s in [12,14,16]do
    """
    Sorry, I'm not understanding. Which option did you mean? Please send the corresponding number.

    (If you need help, you can always say 'agent' to chat with a person. You can also text 'start over' anytime.)
    """
  end
  defp fallback_intent(_,location)do
    """
    Sorry, I'm not understanding. I'll connect you with a person from our team now.

    """ <>
    (if location.default_message != "" do
       location.default_message
     else
       @default_response
     end)
  end
  defp get_calendar(location) do
    url = if location.google_token != nil do
      connection = get_connection(location)
      {:ok, calendar}=GoogleApi.Calendar.V3.Api.Calendars.calendar_calendars_get(connection, location.calender.id)
      "https://calendar.google.com/"

    else
      "https://calendar.google.com/"
    end
    #    case GoogleApi.Calendar.V3.Api.CalendarList.calendar_calendar_list_get c , id do
    #       ->
    #    end
    """
    Here's the calendar! Feel free to book the time that works best for you. If you're stuck, just say 'agent' to chat with a person. #{url}
    """
  end
  defp get_connection(location)do
    client = OAuth2.Client.new([
      strategy: OAuth2.Strategy.Refresh, # default strategy is AuthCode
      client_id: System.get_env("GOOGLE_CLIENT_ID"),
      client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
      site: "https://oauth2.googleapis.com",
      redirect_uri: "https://example.com/auth/callback",
      token_url: "/token",
      token: %OAuth2.AccessToken{refresh_token:  location.google_refresh_token}
    ])
    {:ok,
      %OAuth2.Client{token: %OAuth2.AccessToken{
        access_token: token}}} =  OAuth2.Client.refresh_token client
    %{"access_token" => token} = Jason.decode! token
    GoogleApi.Calendar.V3.Connection.new token

  end
  defp event(appointment,location)do
    connection = get_connection(location)
    time = Timex.parse!(appointment.time, "{h12}:{m} {am}")
    date = Timex.parse!(appointment.date, "{WDshort}, {Mshort} {D}")
    today = Timex.to_datetime Timex.today
    date = if date.month<today.month do
      Timex.set(date,[year: today.year+1])
      else
      Timex.set(date,[year: today.year])
    end
    dt = Timex.set(date,[hour: time.hour, minute: time.minute]) |> Timex.to_datetime |> Timex.Timezone.convert(location.timezone)
    dts = %GoogleApi.Calendar.V3.Model.EventDateTime{dateTime: dt}
    dte = %GoogleApi.Calendar.V3.Model.EventDateTime{dateTime: Timex.shift(dt,minutes: 30)}
    name = appointment.name |> String.split |> Enum.map(&String.capitalize/1)|>Enum.join(" ")
address = "#{location.address_1} #{location.city} #{location.state} #{location.postal_code}"
    description = """
    #{appointment.type} with #{name}
    #{appointment.phone}
    #{appointment.email}
    #{appointment.date} @ #{appointment.time}
    #{address}
    """
    event = [sendUpdates: "all", body: %GoogleApi.Calendar.V3.Model.Event{
      end: dte,
      start: dts,
      status: "confirmed",
      attendees: [%GoogleApi.Calendar.V3.Model.EventAttendee{
        email: appointment.email,
        displayName: appointment.name,
      }],
    location: address,
      summary: appointment.type,
      description: description

    }]
    {:ok,
    %GoogleApi.Calendar.V3.Model.Event{htmlLink: link}}= GoogleApi.Calendar.V3.Api.Events.calendar_events_insert(connection,location.calender_id,event)
    link
  end
  defp type(v)  do
    case v do
      1 -> "Club Tour"
      2 -> "Fitness Assessment"
    end
  end
  defp get({"salesQuestion", _}, location) do
    """
    We'd be happy to share information about our membership plans and pricing. What can I get booked for you? (I'm a bot) Please send the corresponding number.

    1. Club Tour
    2. Fitness Assessment
    """
  end
  defp get({"bookAppointment", _}, location) do
    """
    Sure, what can I get booked for you? (I'm a bot) Please send the corresponding number.

    1. Club Tour
    2. Fitness Assessment
    """
  end
end