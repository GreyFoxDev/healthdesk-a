defmodule MainWeb.Helper.MemberOptions do

  @status [
    {"Not Selected", ""},
    {"Lead", "Lead"},
    {"Prospect", "Prospect"},
    {"Member", "Member"},
    {"At Risk Member", "At-Risk"},
    {"Alumni", "Alumni"},
    {"Non-Member", "Non-Member"}
  ]

  def member_status, do: @status

  def get_status(key) do
    with [{value, _}] <-Enum.filter(@status, fn({_, k}) -> k == key end) do
      value
    else
      _ -> ""
    end
  end

  def member_consent do
    [
      {"Not Subscribed", ""},
      {"Subscribed", true},
      {"Unsubscribed", false}
    ]
  end

end
