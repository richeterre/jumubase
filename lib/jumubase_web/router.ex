defmodule JumubaseWeb.Router do
  use JumubaseWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
    plug Phauxth.Remember
  end

  pipeline :html_only do
    plug :accepts, ["html"]
  end

  pipeline :json_only do
    plug :accepts, ["json"]
  end

  pipeline :pdf_only do
    plug :accepts, ["pdf"]
  end

  scope "/api/v1", JumubaseWeb.Api do
    pipe_through :json_only

    resources "/contests", ContestController, only: [:index]
  end

  scope "/", JumubaseWeb do
    pipe_through [:browser, :html_only]

    get "/", PageController, :home
    get "/regeln", PageController, :rules
    get "/faq", PageController, :faq
    get "/datenschutz", PageController, :privacy

    # Contact
    get "/kontakt", PageController, :contact
    post "/contact", ContactController, :send_message

    # Registration
    get "/anmeldung", PageController, :registration
    get "/anmeldung-bearbeiten", PageController, :edit_registration
    post "/lookup-registration", PageController, :lookup_registration
    resources "/contests/:contest_id/performances", PerformanceController,
      only: [:new, :create, :edit, :update]

    # Auth
    get "/login", SessionController, :new
    resources "/sessions", SessionController, only: [:create, :delete]
    resources "/password-resets", PasswordResetController, only: [:new, :create]
    get "/password-resets/edit", PasswordResetController, :edit
    put "/password-resets/update", PasswordResetController, :update

    # Redirections for legacy paths
    get "/vorspiel-bearbeiten", Redirector, to: "/anmeldung-bearbeiten"
    get "/anmelden", Redirector, to: "/login"
    get "/jmd", Redirector, to: "/internal"
  end

  scope "/internal", JumubaseWeb.Internal, as: :internal do
    pipe_through [:browser, :json_only]

    patch "/contests/:contest_id/performances/reschedule",
      PerformanceController, :reschedule, as: :contest_performance
  end

  scope "/internal", JumubaseWeb.Internal, as: :internal do
    pipe_through [:browser, :pdf_only]

    get "/contests/:contest_id/performances/print-jury-sheets",
      PerformanceController, :print_jury_sheets, as: :contest_performance
    get "/contests/:contest_id/performances/print-jury-table",
      PerformanceController, :print_jury_table, as: :contest_performance
  end

  scope "/internal", JumubaseWeb.Internal, as: :internal do
    pipe_through [:browser, :html_only]

    get "/", PageController, :home

    resources "/categories", CategoryController, except: [:show, :delete]
    resources "/contests", ContestController, only: [:index, :show, :edit, :update] do
      get "/performances/jury-material", PerformanceController, :jury_material, as: :jury_material
      resources "/contest_categories", ContestCategoryController, only: [:index]
      resources "/participants", ParticipantController, only: [:index, :show]
      resources "/performances", PerformanceController
      resources "/stages", StageController, only: [:index] do
        get "/schedule", StageController, :schedule, as: :schedule
      end
    end
    resources "/hosts", HostController, only: [:index, :new, :create]
    resources "/users", UserController, except: [:show]
  end

  if Mix.env == :dev do
    scope "/dev" do
      forward "/sent_emails", Bamboo.SentEmailViewerPlug
    end
  end
end
