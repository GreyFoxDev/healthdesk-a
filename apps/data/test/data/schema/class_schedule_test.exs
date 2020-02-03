defmodule Data.Schema.ClassScheduleTest do
  use ExUnit.Case

  alias Data.Schema.ClassSchedule

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = ClassSchedule.changeset(%ClassSchedule{}, %{})

    assert errors == [
             location_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             ClassSchedule.changeset(%ClassSchedule{}, %{location_id: UUID.uuid4()})
  end

  describe "clean_date/1" do
    setup do
      {:ok, location_id: UUID.uuid4()}
    end

    test "returns 4/20/2019 as a formated date", %{location_id: location_id} do
      changeset =
        ClassSchedule.changeset(%ClassSchedule{}, %{
          "location_id" => location_id,
          "date" => "4/20/2019"
        })

      assert %{valid?: true, changes: changes} = changeset
      assert changes == %{date: ~D[2019-04-20], location_id: location_id}
    end

    test "returns 04/20/2019 as a formated date", %{location_id: location_id} do
      changeset =
        ClassSchedule.changeset(%ClassSchedule{}, %{
          "location_id" => location_id,
          "date" => "04/20/2019"
        })

      assert %{valid?: true, changes: changes} = changeset
      assert changes == %{date: ~D[2019-04-20], location_id: location_id}
    end

    test "returns 04/02/2019 as a formated date", %{location_id: location_id} do
      changeset =
        ClassSchedule.changeset(%ClassSchedule{}, %{
          "location_id" => location_id,
          "date" => "04/02/2019"
        })

      assert %{valid?: true, changes: changes} = changeset
      assert changes == %{date: ~D[2019-04-02], location_id: location_id}
    end

    test "returns 4/2/2019 as a formated date", %{location_id: location_id} do
      changeset =
        ClassSchedule.changeset(%ClassSchedule{}, %{
          "location_id" => location_id,
          "date" => "4/2/2019"
        })

      assert %{valid?: true, changes: changes} = changeset
      assert changes == %{date: ~D[2019-04-02], location_id: location_id}
    end

    test "returns 12/2/2019 as a formated date", %{location_id: location_id} do
      changeset =
        ClassSchedule.changeset(%ClassSchedule{}, %{
          "location_id" => location_id,
          "date" => "12/2/2019"
        })

      assert %{valid?: true, changes: changes} = changeset
      assert changes == %{date: ~D[2019-12-02], location_id: location_id}
    end

    test "returns an error for invalid date", %{location_id: location_id} do
      changeset =
        ClassSchedule.changeset(%ClassSchedule{}, %{
          "location_id" => location_id,
          "date" => "04-02-1019"
        })

      assert %{valid?: false, errors: errors} = changeset

      assert errors == [
               date: {"is invalid", [type: :date, validation: :cast]}
             ]
    end
  end

  describe "clean_time/1" do
    setup do
      {:ok, location_id: UUID.uuid4()}
    end

    test "returns formatted start and end times AM", %{location_id: location_id} do
      changeset =
        ClassSchedule.changeset(%ClassSchedule{}, %{
          "location_id" => location_id,
          "start_time" => "05:15 AM",
          "end_time" => "06:15 AM"
        })

      assert %{valid?: true, changes: changes} = changeset

      assert changes == %{
               start_time: ~T[05:15:00],
               end_time: ~T[06:15:00],
               location_id: location_id
             }
    end

    test "returns formatted start and end times PM", %{location_id: location_id} do
      changeset =
        ClassSchedule.changeset(%ClassSchedule{}, %{
          "location_id" => location_id,
          "start_time" => "10:15 PM",
          "end_time" => "11:15 PM"
        })

      assert %{valid?: true, changes: changes} = changeset

      assert changes == %{
               start_time: ~T[22:15:00],
               end_time: ~T[23:15:00],
               location_id: location_id
             }
    end

    test "returns formatted start and end times PM with mixed hr", %{location_id: location_id} do
      # This should not happen but just in case we'll make an assumption
      changeset =
        ClassSchedule.changeset(%ClassSchedule{}, %{
          "location_id" => location_id,
          "start_time" => "14:15 PM",
          "end_time" => "15:15 PM"
        })

      assert %{valid?: true, changes: changes} = changeset

      assert changes == %{
               start_time: ~T[02:15:00],
               end_time: ~T[03:15:00],
               location_id: location_id
             }
    end
  end
end
