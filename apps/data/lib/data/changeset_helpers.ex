defmodule Data.ChangesetHelper do
  @moduledoc """
  Here are helper functions for changeset validation.
  """

  import Ecto.Changeset

  @uuid_regexp ~r/[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}/

  @spec validate_uuid(changeset :: Ecto.Changeset.t(), field :: Atom.t()) :: Ecto.Changeset.t()
  def validate_uuid(%Ecto.Changeset{} = changeset, field) do
    validate_format(changeset, field, @uuid_regexp, message: "is not a valid UUID")
  end
end
