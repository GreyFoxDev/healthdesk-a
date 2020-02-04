defmodule MainWeb.SecuredContoller do
  defmacro __using__(_opts) do
    quote do
      use MainWeb, :controller

      import MainWeb.Auth, only: [load_current_user: 2]

      alias Data.Team

      action_fallback MainWeb.FallbackController

      plug :load_current_user

      def current_user(conn) do
        MainWeb.Auth.Guardian.Plug.current_resource(conn)
      end

      def teams(conn) do
        conn
        |> current_user()
        |> Team.all()
      end

      def teammate_locations(conn) do
        current_user = current_user(conn)

        current_user.team_member.team_member_locations
        |> Stream.map(&(&1.location))
        |> Stream.filter(&(&1.deleted_at == nil))
        |> Enum.to_list()
        |> Kernel.++([current_user.team_member.location])
        |> Enum.dedup_by(&(&1.id))
      end
    end
  end
end
