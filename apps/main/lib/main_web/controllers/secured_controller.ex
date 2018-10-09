defmodule MainWeb.SecuredContoller do
  defmacro __using__(_opts) do
    quote do
      use MainWeb, :controller

      import MainWeb.Auth, only: [load_current_user: 2]

      action_fallback MainWeb.FallbackController

      plug :load_current_user

      def current_user(conn) do
        MainWeb.Auth.Guardian.Plug.current_resource(conn)
      end
    end
  end
end
