defmodule Main.Integrations.Mindbody do

  @base_url "https://api.mindbodyonline.com/public/v6"

  @urls %{
    activation: "#{@base_url}/site/activationcode",
    classes: "#{@base_url}/class/classes",
    class_descriptions: "#{@base_url}/class/classdescriptions",
    class_schedules: "#{@base_url}/class/classschedules",
    clients: "#{@base_url}/client/clients",
    locations: "#{@base_url}/site/locations",
    staff: "#{@base_url}/staff/staff",
    user_token: "#{@base_url}/usertoken/issue"
  }

  @api_key Application.get_env(:main, :mindbody_api_key)

  def activation(site_id) do
    headers = [
      {"Api-key", @api_key},
      {"SiteId", site_id}
    ]

    {:ok, response} = Tesla.get(@urls.activation, headers: headers)

    Jason.decode!(response.body)
  end

  @doc """

  """
  def get_auth_token(username \\ "Siteowner", password \\ "apitest1234") do
    body = Jason.encode!(%{Username: username, Password: password})

    {:ok, response} =
      Tesla.post @urls.user_token, body, headers: @headers ++ [{"Content-Type", "application/json"}]

    body = Jason.decode!(response.body)

    if body["AccessToken"] do
      {:ok, Jason.decode!(response.body)["AccessToken"]}
    else
      {:error, Jason.decode!(response.body)["Error"]["Message"]}
    end
  end

  @doc """
  Requires an auth token
  """
  def get_member_by_phone(location, phone_number, token) do
    headers = [
      {"Api-key", @api_key},
      {"SiteId", location.team.mindbody_site_id},
      {"Authorization", token},
      {"Content-Type", "application/json"}
    ]

    {:ok, response} =
      [@urls.clients, "?SearchText=#{phone_number}"]
      |> Enum.join()
      |> Tesla.get(headers: headers)

    Jason.decode!(response.body)
  end

  def get_staff(location) do
    headers = [
      {"Api-key", @api_key},
      {"SiteId", location.team.mindbody_site_id}
    ]

    {:ok, response} =
      Tesla.get @urls.staff, headers: headers

    Jason.decode!(response.body)
  end

  def get_classes(location, start_date, end_date) do
    headers = [
      {"Api-key", @api_key},
      {"SiteId", location.team.mindbody_site_id}
    ]

    {:ok, response} =
      Tesla.get @urls.classes, query: [
        StartDateTime: "#{start_date}",
        EndDateTime: "#{end_date}",
        LocationIds: location.mindbody_location_id,
        Limit: 200
      ], headers: headers

    Jason.decode!(response.body)["Classes"]
    |> Stream.dedup()
    |> Stream.map(fn class ->
      <<year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2), "T", start_time::binary>> = class["StartDateTime"]
      <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), "T", end_time::binary>> = class["EndDateTime"]

      << hour::binary-size(2), ":", minute::binary-size(2), ":", seconds::binary-size(2), _rest::binary>> = start_time
      {:ok, start_time} = Time.new(String.to_integer(hour), String.to_integer(minute), String.to_integer(seconds))

      << hour::binary-size(2), ":", minute::binary-size(2), ":", seconds::binary-size(2), _rest::binary>> = end_time
      {:ok, end_time} = Time.new(String.to_integer(hour), String.to_integer(minute), String.to_integer(seconds))

      %{
        location_id: location.id,
        class_type: class["ClassDescription"]["Name"],
        class_description: String.replace(class["ClassDescription"]["Description"], ~r/<[a-z]*>|<\/[a-z]*>/, ""),
        class_category: class["ClassDescription"]["Category"],
        instructor: "#{class["Staff"]["FirstName"]} #{String.first(class["Staff"]["LastName"])}.",
        date: Date.from_erl!({String.to_integer(year), String.to_integer(month), String.to_integer(day)}),
        start_time: start_time,
        end_time: end_time
       }

    end)
    |> Enum.to_list()
  end

  def get_locations(location) do
    headers = [
      {"Api-key", @api_key},
      {"SiteId", location.team.mindbody_site_id}
    ]

    {:ok, response} =
      Tesla.get @urls.locations, headers: headers

    Jason.decode!(response.body)["Locations"]
  end

  def get_class_descriptions_by_location(location) do
    headers = [
      {"Api-key", @api_key},
      {"SiteId", location.team.mindbody_site_id}
    ]

    {:ok, response} =
      Tesla.get @urls.class_descriptions, query: [LocationId: location.mindbody_location_id, Limit: 200], headers: headers

    Jason.decode!(response.body)["ClassDescriptions"]
    |> Stream.dedup()
    |> Stream.map(fn class ->
      %{
        location_id: location.id,
        class_type: class["Name"],
        class_description: String.replace(class["Description"], ~r/<[a-z]*>|<\/[a-z]*>/, ""),
        class_category: class["Category"]
       }
    end)
    |> Enum.to_list()
  end
end
