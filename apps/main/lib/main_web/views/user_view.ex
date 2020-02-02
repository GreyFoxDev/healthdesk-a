defmodule MainWeb.UserView do
  use MainWeb, :view

  def available_times do
    [
      {"12:00 AM", "00:00"},
      {"12:30 AM", "00:30"},
      {"1:00 AM", "01:00"},
      {"1:30 AM", "01:30"},
      {"2:00 AM", "02:00"},
      {"2:30 AM", "02:30"},
      {"3:00 AM", "03:00"},
      {"3:30 AM", "03:30"},
      {"4:00 AM", "04:00"},
      {"4:30 AM", "04:30"},
      {"5:00 AM", "05:00"},
      {"5:30 AM", "05:30"},
      {"6:00 AM", "06:00"},
      {"6:30 AM", "06:30"},
      {"7:00 AM", "07:00"},
      {"7:30 AM", "07:30"},
      {"8:00 AM", "08:00"},
      {"8:30 AM", "08:30"},
      {"9:00 AM", "09:00"},
      {"9:30 AM", "09:30"},
      {"10:00 AM", "10:00"},
      {"10:30 AM", "10:30"},
      {"11:00 AM", "11:00"},
      {"11:30 AM", "11:30"},
      {"12:00 PM", "12:00"},
      {"12:30 PM", "12:30"},
      {"1:00 PM", "13:00"},
      {"1:30 PM", "13:30"},
      {"2:00 PM", "14:00"},
      {"2:30 PM", "14:30"},
      {"3:00 PM", "15:00"},
      {"3:30 PM", "15:30"},
      {"4:00 PM", "16:00"},
      {"4:30 PM", "16:30"},
      {"5:00 PM", "17:00"},
      {"5:30 PM", "17:30"},
      {"6:00 PM", "18:00"},
      {"6:30 PM", "18:30"},
      {"7:00 PM", "19:00"},
      {"7:30 PM", "19:30"},
      {"8:00 PM", "20:00"},
      {"8:30 PM", "20:30"},
      {"9:00 PM", "21:00"},
      {"9:30 PM", "21:30"},
      {"10:00 AM", "22:00"},
      {"10:30 AM", "22:30"},
      {"11:00 AM", "23:00"},
      {"11:30 AM", "23:30"}
    ]
  end
end
