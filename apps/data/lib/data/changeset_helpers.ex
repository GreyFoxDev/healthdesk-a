defmodule Data.ChangesetHelpers do
  @moduledoc """
  Here are helper functions for changeset validation.
  """

  import Ecto.Changeset

  @uuid_regexp ~r/^[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}$/

  def validate_uuid(%Ecto.Changeset{} = changeset, field) do
    validate_format(changeset, field, @uuid_regexp, message: "is not a valid UUID")
  end
end
