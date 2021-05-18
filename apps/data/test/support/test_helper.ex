defmodule Data.TestHelper do
  @moduledoc """
  Helper functions for that are shared in the test suite
  """

  defdelegate phone, to: Faker.Phone.EnUs

  def phone_number do
    "+#{String.replace(phone(), ~r/[()\s-.\/]/, "")}"
  end
end
