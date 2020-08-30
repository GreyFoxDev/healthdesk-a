defmodule MainWeb.ClassScheduleController do
  use MainWeb.SecuredContoller

  alias Data.{Location, ClassSchedule}

  NimbleCSV.define(ScheduleParser, [])

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

  def create(conn, %{"location_id" => location_id, "csv" => upload}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    # Clear out location schedules
    location_id
    |> ClassSchedule.get_by_location_id()
    |> Enum.each(&ClassSchedule.delete/1)

    count = upload.path
    |> File.stream!
    |> ScheduleParser.parse_stream
    |> Stream.map(fn [date, start_time, end_time, name, instructor, category, description] ->
      %{
        "date" => date,
        "start_time" => start_time,
        "end_time" => end_time,
        "class_type" => name,
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
