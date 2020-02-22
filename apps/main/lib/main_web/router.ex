defmodule MainWeb.Router do
  use MainWeb, :router
  use Honeybadger.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
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

    get "/webchat/secret", PageController, :secret
    get "/webchat/:api_key", WebChatController, :index
    get "/tsi/:api_key", TsiController, :new
    post "/tsi/:api_key", TsiController, :create
  end

  scope "/admin", MainWeb do
    pipe_through [:browser, :auth]

    get "/", AdminController, :index

    delete "/logout/:id", SessionController, :delete

    resources "/teams", TeamController do
      resources "/dispositions", DispositionController
      resources "/members", MemberController
      resources "/team-members", TeamMemberController
      resources "/locations", LocationController do
        resources "/class-schedule", ClassScheduleController, only: [:new, :create]
        resources "/conversations", ConversationController do
          resources "/conversation-messages", ConversationMessageController
          put "/close", ConversationController, :close
          put "/open", ConversationController, :open
        end
        resources "/team-members", LocationTeamMemberController
        resources "/holiday-hours", HolidayHourController
        resources "/normal-hours", NormalHourController
        resources "/child-care-hours", ChildCareHourController
        resources "/wifi-network", WifiNetworkController
        resources "/pricing-plans", PricingPlanController
      end
    end

    resources "/users", UserController, only: [:edit, :update]

    # resources "/messages", MessageController, except: [:delete, :new, :create]
  end

  scope "/api", MainWeb do
    pipe_through :api

    post "/locations/:location_id/start_flow/:flow_name", FlowController, :flow

    post "/twilio/conversations", Api.ConversationController, :create
    post "/twilio/conversations/update", Api.ConversationController, :update
    post "/twilio/conversations/close", Api.ConversationController, :close

    get "/sms/inbound", TwilioController, :inbound
    get "/sms/inbound.json", TwilioJsonController, :inbound
    post "/sms/twilio", TwilioController, :inbound
    put "/remove-avatar", AvatarController, :remove_avatar
    put "/assign-team-member", AssignTeamMemberController, :assign
    put "/update-member", UpdateMemberController, :update
  end
end
