defmodule JumubaseWeb.Router do
  use JumubaseWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
    plug Phauxth.Remember
  end

  pipeline :api_auth do
    plug JumubaseWeb.ApiAuth
  end

  pipeline :html_only do
    plug :accepts, ["html"]
    plug :put_root_layout, {JumubaseWeb.LayoutView, :root}
  end

  pipeline :json_only do
    plug :accepts, ["json"]
  end

  pipeline :pdf_only do
    plug :accepts, ["pdf"]
  end

  scope "/graphql" do
    if Mix.env() == :prod do
      pipe_through :api_auth
    end

    forward "/", Absinthe.Plug, schema: JumubaseWeb.Schema
  end

  scope "/", JumubaseWeb do
    pipe_through [:browser, :html_only]

    get "/", PageController, :home
    get "/regeln", PageController, :rules
    get "/faq", PageController, :faq
    get "/datenschutz", PageController, :privacy
    get "/app/datenschutz", PageController, :app_privacy

    # Contact
    get "/kontakt", PageController, :contact
    post "/contact", ContactController, :send_message

    # Registration
    get "/anmeldung", PageController, :registration
    get "/anmeldung-bearbeiten", PageController, :edit_registration
    post "/lookup-registration", PageController, :lookup_registration

    resources "/contests/:contest_id/performances", PerformanceController, only: [:new, :edit]

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

    patch "/contests/:contest_id/performances/reschedule", PerformanceController, :reschedule,
      as: :contest_performance
  end

  scope "/internal", JumubaseWeb.Internal, as: :internal do
    pipe_through [:browser, :pdf_only]

    get "/contests/:contest_id/performances/print-jury-sheets",
        PerformanceController,
        :print_jury_sheets,
        as: :contest_performance

    get "/contests/:contest_id/performances/print-jury-table",
        PerformanceController,
        :print_jury_table,
        as: :contest_performance

    get "/contests/:contest_id/performances/print-certificates",
        PerformanceController,
        :print_certificates,
        as: :contest_performance
  end

  scope "/internal", JumubaseWeb.Internal, as: :internal do
    pipe_through [:browser, :html_only]

    get "/", PageController, :home
    get "/jury-work", PageController, :jury_work
    get "/literature-guidance", PageController, :literature_guidance
    get "/meeting-minutes", PageController, :meeting_minutes

    get "/maintenance", MaintenanceController, :index

    delete "/maintenance/participants/orphaned",
           MaintenanceController,
           :delete_orphaned_participants

    resources "/categories", CategoryController, except: [:show, :delete]

    resources "/contests", ContestController, except: [:create] do
      get "/performances/jury-material", PerformanceController, :jury_material, as: :performances
      get "/performances/edit-results", PerformanceController, :edit_results, as: :results
      patch "/performances/update-results", PerformanceController, :update_results, as: :results
      get "/performances/publish-results", PerformanceController, :publish_results, as: :results

      patch "/performances/update-results-public", PerformanceController, :update_results_public,
        as: :results

      get "/performances/certificates", PerformanceController, :certificates, as: :performances
      get "/performances/advancing", PerformanceController, :advancing, as: :performances
      get "/performances/advancing.xml", PerformanceController, :advancing_xml, as: :performances

      post "/performances/migrate-advancing", PerformanceController, :migrate_advancing,
        as: :performances

      get "/participants/duplicates", ParticipantController, :duplicates
      get "/participants/compare/:source_id/:target_id", ParticipantController, :compare
      patch "/participants/merge/:source_id/:target_id", ParticipantController, :merge

      get "/participants/export-csv", ParticipantController, :export_csv
      post "/participants/send-welcome-emails", ParticipantController, :send_welcome_emails

      resources "/contest_categories", ContestCategoryController, only: [:index]
      resources "/participants", ParticipantController, only: [:index, :show, :edit, :update]

      resources "/performances", PerformanceController,
        only: [:index, :show, :new, :edit, :delete]

      resources "/stages", StageController, only: [:index] do
        get "/schedule", StageController, :schedule, as: :schedule
        get "/timetable", StageController, :timetable, as: :timetable
      end
    end

    resources "/hosts", HostController, except: [:show, :delete]
    resources "/users", UserController, except: [:show]
  end

  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser
      live_dashboard "/dashboard"
    end

    scope "/dev" do
      forward "/sent_emails", Bamboo.SentEmailViewerPlug

      forward "/graphql-playground", Absinthe.Plug.GraphiQL,
        schema: JumubaseWeb.Schema,
        interface: :playground
    end
  end
end
