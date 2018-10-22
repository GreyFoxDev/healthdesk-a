defmodule Data.Commands do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      alias Data.Query.WriteOnly.unquote(opts[:schema]), as: Write
      alias Data.Query.ReadOnly.unquote(opts[:schema]), as: Read

      alias Data.Commands.Supervisor, as: Command

      def all,
        do: Command.execute_task_with_results(fn -> Read.all() end)

      def get(id),
        do: Command.execute_task_with_results(fn -> Read.get(id) end)

      def write(params),
        do: Command.execute_task(fn -> Write.write(params) end)

      def write(orig_params, params),
        do: Command.execute_task(fn -> Write.write(orig_params, params) end)

      def delete(id),
        do: Command.execute_task(fn -> Write.delete(id) end)
    end
  end
end
