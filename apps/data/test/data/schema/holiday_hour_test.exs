defmodule Data.Schema.HolidayHourTest do
  use ExUnit.Case

  alias Data.Schema.HolidayHour

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = HolidayHour.changeset(%HolidayHour{}, %{})

    assert errors == [
             location_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             HolidayHour.changeset(%HolidayHour{}, %{location_id: UUID.uuid4()})
  end

  describe "holiday date formating" do
    test "returns a valid changeset with a date" do
      assert %{valid?: true, changes: changes} =
               HolidayHour.changeset(%HolidayHour{}, %{
                 "location_id" => UUID.uuid4(),
                 "holiday_date" => "2020-12-25"
               })
    end

    test "returns an error for an invalid date format" do
      assert %{valid?: false, errors: errors} =
               HolidayHour.changeset(%HolidayHour{}, %{
                 "location_id" => UUID.uuid4(),
                 "holiday_date" => "12/12/2020"
               })

      assert errors == [
               holiday_date: {"is invalid", [type: :utc_datetime, validation: :cast]}
             ]
    end
  end
end
