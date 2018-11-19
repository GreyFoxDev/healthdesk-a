defmodule MainWeb.Router do
  use MainWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api,
    do: plug :accepts, ["json"]

  pipeline :auth,
    do: plug MainWeb.Auth.AuthAccessPipeline

  scope "/", MainWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/login", SessionController, :new
    post "/login", SessionController, :create
  end

  scope "/admin", MainWeb do
    pipe_through [:browser, :auth]

    get "/", AdminController, :index

    delete "/logout/:id", SessionController, :delete

    resources "/teams", TeamController do
      resources "/locations", LocationController do
        resources "/conversations", ConversationController do
          resources "/conversation-messages", ConversationMessageController
          put "/close", ConversationController, :close
          put "/open", ConversationController, :open
        end
        resources "/holiday-hours", HolidayHourController
        resources "/normal-hours", NormalHourController
        resources "/child-care-hours", ChildCareHourController
        resources "/wifi-network", WifiNetworkController
        resources "/pricing-plans", PricingPlanController
      end
      resources "/team-members", TeamMemberController
    end

    resources "/users", UserController

    resources "/messages", MessageController, except: [:delete, :new, :create]
  end

  scope "/api", MainWeb do
    pipe_through :api

    post "/sms/twilio", TwilioController, :create
    put "/remove-avatar", AvatarController, :remove_avatar
    put "/assign-team-member", AssignTeamMemberController, :assign
  end
end
