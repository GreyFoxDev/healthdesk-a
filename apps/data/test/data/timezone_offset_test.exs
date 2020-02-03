defmodule Data.TimezoneOffsetTest do
  use ExUnit.Case

  alias Data.TimezoneOffset, as: TO

  test "Pacific timezone returns seconds" do
    assert -28_800 == TO.calculate("PST8PDT")
  end

  test "Mountain timezone returns seconds" do
    assert -25_200 == TO.calculate("MST7MDT")
  end

  test "Central timezone returns seconds" do
    assert -21_600 == TO.calculate("CST6CDT")
  end

  test "Eastern timezone returns seconds" do
    assert -18_000 == TO.calculate("EST5EDT")
  end

  test "Any other timezone or value returns 0" do
    assert 0 == TO.calculate("SOM8THING")
  end
end
