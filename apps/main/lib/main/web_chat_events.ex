defmodule Main.WebChat.Events do
  use GenServer, restart: :transient

  alias Data.Location

  @days_of_week ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]

  def start_link(assigns) do
    GenServer.start_link(__MODULE__, assigns)
  end

  def init(assigns) do
    {:ok, %{assigns: assigns, current_event: nil, current_location: nil}}
  end

  def handle_call(:current_event, _from, %{current_event: event} = state) do
    {:reply, event, state}
  end

  def handle_call(:current_location, _from, %{current_location: location} = state) do
    {:reply, location, state}
  end

  def handle_call("join", _from, %{assigns: %{location: location}} = state) do
    locations = location_stream(location.team_id)
    count = Enum.count(locations)

    response = if count > 1  do
      location_select(locations)
    else
      """
      Awesome!
      <br />
      #{which_plans(location)}
      """
    end

    {:reply, build_message(response, location, "outbound"), %{state | current_event: :join}}
  end

  def handle_call("join:yes", _from, %{assigns: %{location: location}, current_location: current_location} = state) do
    response = """
    We've got you covered..
    <br />
    Our Premium plan includes all of that plus 20% off all merchandise for just $27.95 per month. (plus joining and annual fees)
    <br />
    To join online now, please select your plan below.
    <br />
    #{select_plans(current_location)}
    """

    {:reply, build_message(response, location, "outbound"), state}
  end

  def handle_call("join:not-sure", _from, %{assigns: %{location: location}, current_location: current_location} = state) do
    response = """
    No worries...
    <br />
    Most of our members go with our Premium plan for just $27.95 per month. (plus join and annual fees)
    <br />
    It includes everything listed above plus 20% off all merchandise.
    <br />

    To join online now, please select a plan below.
    <br />
    #{select_plans(current_location)}
    """

    {:reply, build_message(response, location, "outbound"), state}
  end

  def handle_call("join:need-more-info", _from, %{assigns: %{location: location}} = state) do
    {:reply, build_message(text_box(), location, "outbound"), state}
  end

  def handle_call(<< "join:", plan :: binary >>, _from, %{assigns: %{location: location}, current_location: current_location} = state)
  when plan in ["basic", "premium", "level-10"] do

    location_name = case current_location.location_name do
                      "Downtown" ->
                        "downtown little rock"
                      "North Little Rock" ->
                        "nlr"
                      name ->
                        name
                    end

    link = "https://10fitness.com/#{Inflex.parameterize(location_name, "-")}-membership-plans/"

    response = """
    Great choice!
    <br />
    Go ahead and select your plan to continue and message us here if you have any questions.
    <br />
    <a href="#{link}" target="_top">Select Plan</a>
    <br>
    <div class="panel-footer">
      <div class="input-group">
        <form phx-submit="send">
        <textarea oninput="auto_grow(this)" class="form-control" name="message" placeholder="Type here..." style="width: 100%"></textarea>
        </form>
      </div>
    </div>
    """

    {:reply, build_message(response, location, "outbound"), state}
  end

  def handle_call("pricing", _from, %{assigns: %{location: location}} = state) do
    locations = location_stream(location.team_id)
    count = Enum.count(locations)

    response = if count > 1  do
      location_select(locations)
    else
      which_plans(location)
    end

    {:reply, build_message(response, location, "outbound"), %{state | current_event: :pricing}}
  end

  def handle_call(<< "location:", id :: binary >>, _from, %{assigns: %{location: location}} = state) do
    location_requested = Location.get(%{role: "admin"}, id)

    next = case state.current_event do
             :tour ->
               day_of_week()
             :other ->
               text_box()
             _ ->
               which_plans(location_requested)
           end

    response = """
    #{location_requested.location_name}<br />
    Got it...
    #{next}
    """

    {:reply, build_message(response, location, "outbound"), %{state | current_location: location_requested}}
  end

  def handle_call(<< "tour:", day :: binary >>, _from, %{assigns: %{location: location}} = state) when day in @days_of_week do
    {:reply, build_message(time_of_day(), location, "outbound"), %{state | current_event: :tour_time}}
  end

  def handle_call(<< "tour:", time_of_day :: binary >>, _from, %{current_event: :tour_time, assigns: %{location: location}} = state) do
    response = """
    Perfect. And can I please get your first and last name?
    <br>
    <div class="panel-footer">
      <div class="input-group">
        <form phx-submit="send">
          <textarea oninput="auto_grow(this)" class="form-control" name="message" placeholder="Type here..." style="width: 100%"></textarea>
        </form>
      </div>
    </div>

    """

    {:reply, build_message(response, location, "outbound"), %{state | current_event: :tour_name}}
  end

  def handle_call(:tour_name, _from, %{current_event: :tour_name, assigns: %{location: location}} = state) do
    response = """
    Thank you. Lastly, what is your 10-digit phone number?
    <br>
    <div class="panel-footer">
      <div class="input-group">
        <form phx-submit="send">
          <textarea oninput="auto_grow(this)" class="form-control" name="message" placeholder="Type here..." style="width: 100%"></textarea>
        </form>
      </div>
    </div>
    """

    {:reply, build_message(response, location, "outbound"), %{state | current_event: :tour_phone}}
  end

  def handle_call(:tour_phone, _from, %{current_event: :tour_phone, assigns: %{location: location}} = state) do
    response = """
    All set! Someone from our team will text you shortly to confirm your appointment. Thank you!
    """

    {:reply, build_message(response, location, "outbound"), %{state | current_event: :done}}
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
      user: get_web_handle(location),
      direction: "outbound",
      text: response
    }

    {:reply, build_message(response, location, "outbound"), %{state | current_event: :tour}}
  end

  def handle_call("other", _from, %{assigns: %{location: location}} = state) do
    locations = location_stream(location.team_id)
    count = Enum.count(locations)

    response = if count > 1  do
      location_select(locations)
    else
      text_box()
    end

    {:reply, build_message(response, location, "outbound"), %{state | current_event: :other}}
  end

  defp build_message(response, location, direction) do
    %{
      type: "message",
      user: get_web_handle(location),
      direction: direction,
      text: response
    }
  end

  defp location_stream(team_id) do
    %{role: "admin"}
    |> Location.get_by_team_id(team_id)
    |> Stream.reject(&(&1.web_chat))
    |> Stream.map(fn(location) ->
      """
      <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="location:#{location.id}">
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

  defp which_plans(location) do
      question = case location.location_name do
                   "Bryant" ->
                     "Would you like to be able to bring friends, tan, use massage chairs, or go to any of our 13 locations?"
                   "West Conway" ->
                     "Would you like to be able to bring friends or go to any of our 13 locations?"
                   "Springfield" ->
                     "Would you like to be able to bring friends, tan, use massage chairs, or go to any of our 13 locations?"
                   _ ->
                     "Would you like to be able to bring friends, attend group classes, tan, or use massage chairs?"
      end
      """
      We have a few plans to choose from..
      <br />
      #{question}
      <br />
      <br />
      <input type="button" class="btn btn-secondary" phx-click="link-click" phx-value="join:not-sure" value="Not Sure">
      <input type="button" class="btn btn-primary" style="background-color: #9B3426;" phx-click="link-click" phx-value="join:yes" value="Yes!">
      """
  end

  defp select_plans(location) do
    basic_plan = if location.location_name == "Downtown" do
      "$19.95"
    else
      "$12.95"
    end

    """
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="join:basic">
      <a href="#" style="color: white;">Basic #{basic_plan}/month</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="join:premium">
      <a href="#" style="color: white;">Premium $27.95/month</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="join:level-10">
      <a href="#" style="color: white;">Level 10 $39.95/month</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="join:need-more-info">
      <a href="#" style="color: white;">Need more info</a>
    </div>

    """
  end

  defp day_of_week() do
    """
    Got it. What day works best?
    <br>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="tour:monday">
      <a href="#" style="color: white;">Monday</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="tour:tuesday">
      <a href="#" style="color: white;">Tuesday</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="tour:wednesday">
      <a href="#" style="color: white;">Wednesday</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="tour:thursday">
      <a href="#" style="color: white;">Thursday</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="tour:friday">
      <a href="#" style="color: white;">Friday</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="tour:saturday">
      <a href="#" style="color: white;">Saturday</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="tour:sunday">
      <a href="#" style="color: white;">Sunday</a>
    </div>
    """
  end

  defp time_of_day() do
    """
    Got it. What time of day is best?
    <br>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="tour:morning">
      <a href="#" style="color: white;">Morning (8AM - 12PM)</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="tour:afternoon">
      <a href="#" style="color: white;">Afternoon (12PM - 4PM)</a>
    </div>
    <div style="width: 90%; padding: 5px; margin: 5px; background-color: #9B3426;border-radius: 5px;" phx-click="link-click" phx-value="tour:afternoon">
      <a href="#" style="color: white;">Evening (4PM - 7PM)</a>
    </div>
    """
  end

  defp text_box do
    """
    Please type away!
    <br>
    <div class="panel-footer">
      <div class="healthdesk-ai-group">
        <form phx-submit="send">
          <textarea oninput="auto_grow(this)" class="form-control" name="message" placeholder="Type here..." style="width: 100%"></textarea>
        </form>
      </div>
    </div>
    """
  end

  defp get_web_handle(%{web_handle: ""}), do: "Webbot"
  defp get_web_handle(%{web_handle: handle}), do: handle

end
