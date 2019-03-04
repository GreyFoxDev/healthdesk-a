defmodule MainWeb.ClassScheduleController do
  use MainWeb.SecuredContoller

  alias Data.{Location, Commands.ClassSchedule}

  NimbleCSV.define(MyParser, [])

  def new(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    render(conn, "new.html",
      location: location,
      upload_info: nil,
      teams: teams(conn))
  end

  def create(conn, %{"location_id" => location_id, "csv" => upload} = params) do
    IO.inspect params
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    count = upload.path
    |> File.stream!
    |> MyParser.parse_stream
    |> Stream.map(fn [date, start_time, end_time, name, instructor, category, description] ->
      %{
        "date" => date,
        "start_time" => start_time,
        "end_time" => end_time,
        "instructor" => instructor,
        "class_category" => category,
        "class_description" => description,
        "location_id" => location.id}
    end)
    |> Stream.map(fn(row) -> ClassSchedule.create(row) end)
    |> Enum.count()

    render(conn, "new.html",
      location: location,
      upload_info: %{count: count},
      teams: teams(conn))
  end
end
