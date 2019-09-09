defmodule Main.WebChat.Events do
  use GenServer, restart: :transient

  alias Data.Location

  @days_of_week ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]

  def start_link(assigns) do
    GenServer.start_link(__MODULE__, assigns)
  end

  def init(assigns) do
    {:ok, %{assigns: assigns, current_event: nil}}
  end

  def handle_call(:current_event, _from, %{current_event: event} = state) do
    {:reply, event, state}
  end

  def handle_call("join", _from, %{assigns: %{location: location}} = state) do
    locations = location_stream(location.team_id)
    count = Enum.count(locations) |> IO.inspect(label: "COUNT")

    response = if count > 1  do
      location_select(locations)
    else
      """
      Awesome!
      <br />
      #{which_plans()}

      """
    end

    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: response
    }

    {:reply, message, %{state | current_event: :join}}
  end

  def handle_call("join:yes", _from, state) do
    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: """
      We've got you covered..
      <br />
      Our Premium plan includes all of that plus 20% off all merchandise for just $27.95 per month. (cancel anytime)
      <br />
      To join online now, please select your plan below.
      <br />
      #{select_plans()}
      """}

    {:reply, message, state}
  end

  def handle_call("join:not-sure", _from, state) do
    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: """
      No worries...
      <br />
      Most of our members go with our Premium plan for just $27.95 per month. (cancel anytime)
      <br />
      It includes everything listed above plus 20% off all merchandise.
      <br />

      To join online now, please select a plan below.
      <br />
      #{select_plans()}
      """
    }

    {:reply, message, state}
  end

  def handle_call("join:need-more-info", _from, state) do
    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: """
      Please, type away!
      """
    }

    {:reply, message, state}
  end

  def handle_call(<< "join:", plan :: binary >>, _from, state)
  when plan in ["basic", "premium", "level-10"] do
    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: """
      Great choice!
      <br />
      All set! Someone from our team will text you shortly to get you set up. Thank you!
      """
    }

    {:reply, message, state}
  end

  def handle_call("pricing", _from, %{assigns: %{location: location}} = state) do
    locations = location_stream(location.team_id)
    count = Enum.count(locations)

    response = if count > 1  do
      location_select(locations)
    else
      which_plans()
    end

    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: response
    }

    {:reply, message, %{state | current_event: :pricing}}
  end

  def handle_call(<< "location:", id :: binary >>, _from, state) do
    location = Location.get(%{role: "admin"}, id)

    next = if state.current_event == :tour do
      day_of_week()
    else
      which_plans()
    end

    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: """
      #{location.location_name}<br />
      Got it...
      #{next}
      """
    }

    {:reply, message, %{state | current_event: :pricing}}
  end

  def handle_call(<< "tour:", day :: binary >>, _from, state) when day in @days_of_week do
    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: time_of_day()
    }

    {:reply, message, %{state | current_event: :tour_time}}
  end

  def handle_call(<< "tour:", time_of_day :: binary >>, _from, %{current_event: :tour_time} = state) do
    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: """
      Perfect. And can I please get your first and last name?
      """
    }

    {:reply, message, %{state | current_event: :tour_name}}
  end

  def handle_call(:tour_name, _from, %{current_event: :tour_name} = state) do
    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: """
      Thank you. Lastly, what is your 10-digit phone number?
      """
    }

    {:reply, message, %{state | current_event: :tour_phone}}
  end

  def handle_call(:tour_phone, _from, %{current_event: :tour_phone} = state) do
    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: """
      All set! Someone from our team will text you shortly to confirm your appointment. Thank you!
      """
    }

    {:reply, message, %{state | current_event: :done}}
  end

  def handle_call("tour", _from, %{assigns: %{location: location}} = state) do
    locations = location_stream(location.team_id)
    count = Enum.count(locations)

    response = if count > 1  do
      location_select(locations)
    else
      day_of_week()
    end

    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: response
    }

    {:reply, message, %{state | current_event: :tour}}
  end

  def handle_call("other", _from, state) do
    message = %{
      type: "message",
      user: "Webbot",
      direction: "outbound",
      text: "Please type away!"
    }

    {:reply, message, %{state | current_event: :other}}
  end

  defp location_stream(team_id) do
    %{role: "admin"}
    |> Location.get_by_team_id(team_id)
    |> Stream.filter(&(&1.location_name != "Webbot"))
    |> Stream.map(fn(location) ->
      """
      <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="location:#{location.id}">
      <a href="#" style="color: white;">#{location.location_name}</a>
      </div>
      """ end)
  end

  defp location_select(locations) do
      """
      Awesome!
      <br />
      Which of our #{Enum.count(locations)} locations are you interested in?
      <br />
      #{Enum.join(locations)}


      """
  end

  defp which_plans do
      """
      We have a few plans to choose from..
      <br />
      Would you like to be able to bring friends, attend group classes, tan, use massage chairs?
      <br />
      <br />
      <input type="button" class="btn btn-secondary" phx-click="link-click" phx-value="join:not-sure" value="Not Sure">
      <input type="button" class="btn btn-primary" phx-click="link-click" phx-value="join:yes" value="Yes!">
      """
  end

  defp select_plans do
    """
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="join:basic">
      <a href="#" style="color: white;">Basic $12.95/month</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="join:premium">
      <a href="#" style="color: white;">Premium $27.95/month</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="join:level-10">
      <a href="#" style="color: white;">Level 10 $39.95/month</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="join:need-more-info">
      <a href="#" style="color: white;">Need more info</a>
    </div>

    """
  end

  defp day_of_week() do
    """
    Got it. What day works best?
    <br>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="tour:monday">
      <a href="#" style="color: white;">Monday</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="tour:tuesday">
      <a href="#" style="color: white;">Tuesday</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="tour:wednesday">
      <a href="#" style="color: white;">Wednesday</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="tour:thursday">
      <a href="#" style="color: white;">Thursday</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="tour:friday">
      <a href="#" style="color: white;">Friday</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="tour:saturday">
      <a href="#" style="color: white;">Saturday</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="tour:sunday">
      <a href="#" style="color: white;">Sunday</a>
    </div>
    """
  end

  defp time_of_day() do
    """
    Got it. What time of day is best?
    <br>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="tour:morning">
      <a href="#" style="color: white;">Morning</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="tour:afternoon">
      <a href="#" style="color: white;">Afternoon</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #DB4437;border-radius: 5px;" phx-click="link-click" phx-value="tour:afternoon">
      <a href="#" style="color: white;">Evening</a>
    </div>
    """
  end

end
