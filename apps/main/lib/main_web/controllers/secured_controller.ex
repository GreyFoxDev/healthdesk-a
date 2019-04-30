defmodule MainWeb.SecuredContoller do
  defmacro __using__(_opts) do
    quote do
      use MainWeb, :controller

      import MainWeb.Auth, only: [load_current_user: 2]

      alias Data.Team

      action_fallback MainWeb.FallbackController

      plug :load_current_user

      def current_user(conn) do
        MainWeb.Auth.Guardian.Plug.current_resource(conn) |> IO.inspect
      end

      def teams(conn) do
        conn
        |> current_user()
        |> Team.all()
      end
    end
  end
end
