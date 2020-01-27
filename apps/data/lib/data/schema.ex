defmodule Data.Schema do
  @moduledoc """
  Imports all functionality for an ecto schema

  ### Usage

  ```
  defmodule Data.Schema.MySchema do
    use Data.Schema

    schema "my_schemas" do
      # Fields
    end
  end
  ```
  """
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
      import Data.ChangesetHelper

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :utc_datetime]
    end
  end
end
