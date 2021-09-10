defmodule MainWeb.Router do
  use MainWeb, :router
  use Honeybadger.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :live_root do
    plug :put_root_layout, {MainWeb.LayoutView, "root_live.html"}
  end
  pipeline :not_live do
    plug :put_root_layout, {MainWeb.LayoutView, :root}
  end

  pipeline :auth,
    do: plug MainWeb.Auth.AuthAccessPipeline

  scope "/", MainWeb do
    pipe_through [:browser, :not_live]

    get "/", SessionController, :new
    get "/login", SessionController, :new
    post "/login", SessionController, :create

    get "/webchat/secret", PageController, :secret
    get "/webchat/:api_key", WebChatController, :index
    resources "/tsi/:api_key", TsiController, except: [:delete, :index, :show]
  end

  scope "/admin", MainWeb do
    pipe_through [:browser, :auth, :live_root]

    live "/conversations/:id" , Live.ConversationsView, only: [:index]
    live "/conversations/:id/:tab" , Live.ConversationsView, only: [:index]
    live "/campaigns" , Live.CampaignsView
    live "/tickets" , Live.TicketsView
    live "/tickets/:id" , Live.TicketsView

  end
  scope "/auth" do
    pipe_through [:browser]

  end
  scope "/admin", MainWeb do
    pipe_through [:browser, :auth, :not_live]

    post "/", AdminController, :index
    get "/", AdminController, :index
    get "/export/campaign-recipients/:campaign_id", CampaignController, :export
    delete "/campaign/:campaign_id", CampaignController, :delete

    delete "/logout/:id", SessionController, :delete

    resources "/teams", TeamController do
      resources "/dispositions", DispositionController
      resources "/members", MemberController
      resources "/team-members", TeamMemberController
      resources "/locations", LocationController do
        get "/edit/:provider", LocationController, :edit
        get "/remove", LocationController, :remove_config
        get "/:provider/callback", LocationController, :callback
        post "/:provider/callback", LocationController, :callback
        resources "/class-schedule", ClassScheduleController, only: [:new, :create]
        live "/conversations" , Live.ConversationsView, only: [:index]
        resources "/conversations", ConversationController, except: [:index] do
          resources "/conversation-messages", ConversationMessageController
          put "/close", ConversationController, :close
          put "/open", ConversationController, :open
        end
        resources "/team-members", LocationTeamMemberController
        resources "/holiday-hours", HolidayHourController
        resources "/normal-hours", NormalHourController
        live "/normal-hours/form" , Live.NormalHourForm, :form
        resources "/child-care-hours", ChildCareHourController
        resources "/wifi-network", WifiNetworkController
        resources "/pricing-plans", PricingPlanController
        resources "/saved-replies", SavedReplyController
        resources "/intent", IntentController
        resources "/automations", AutomationController
      end
    end
    live "/admin/teams/:location_team_id/locations/:location_id/normal-hours/" , Live.NormalHourForm, :index

    resources "/users", UserController, only: [:edit, :update]

    # resources "/messages", MessageController, except: [:delete, :new, :create]
  end
  scope "/admin", MainWeb do
    pipe_through [:api, :not_live]
    get "/facebook/hook", FacebookController, :hook
    post "/facebook/hook", FacebookController, :event
    get "/instagram/hook", InstagramController, :hook
    post "/instagram/hook", InstagramController, :event
  end
  scope "/api", MainWeb do
    pipe_through :api

    post "/locations/:location_id/start_flow/:flow_name", FlowController, :flow

    post "/twilio/conversations", Api.ConversationController, :create_
    post "/twilio/conversations/update", Api.ConversationController, :update
    post "/twilio/conversations/close", Api.ConversationController, :close

    get "/sms/inbound", TwilioController, :inbound
    get "/sms/inbound.json", TwilioJsonController, :inbound
    post "/sms/twilio", TwilioController, :inbound
    put "/remove-avatar", AvatarController, :remove_avatar
    put "/assign-team-member", AssignTeamMemberController, :assign
    put "/update-member", UpdateMemberController, :update

    get "/healthcheck", HealthCheckController, :status
  end
end
