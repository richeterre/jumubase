defmodule JumubaseWeb.Router do
  use JumubaseWeb, :router

  import JumubaseWeb.UserAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
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

    # Redirections for legacy paths
    get "/vorspiel-bearbeiten", Redirector, to: "/anmeldung-bearbeiten"
    get "/anmelden", Redirector, to: "/login"
    get "/jmd", Redirector, to: "/internal"
  end

  # Authentication routes

  scope "/", JumubaseWeb do
    pipe_through [:browser, :html_only, :redirect_if_user_is_authenticated]

    get "/login", UserSessionController, :new
    post "/login", UserSessionController, :create
    get "/reset-password", UserResetPasswordController, :new
    post "/reset-password", UserResetPasswordController, :create
    get "/reset-password/:token", UserResetPasswordController, :edit
    put "/reset-password/:token", UserResetPasswordController, :update
  end

  scope "/", JumubaseWeb do
    pipe_through [:browser, :html_only]

    delete "/logout", UserSessionController, :delete
  end

  scope "/internal", JumubaseWeb.Internal, as: :internal do
    pipe_through [:browser, :json_only, :require_authenticated_user]

    patch "/contests/:contest_id/performances/reschedule", PerformanceController, :reschedule,
      as: :contest_performance
  end

  scope "/internal", JumubaseWeb.Internal, as: :internal do
    pipe_through [:browser, :html_only, :require_authenticated_user]

    get "/", PageController, :home
    get "/jury-work", PageController, :jury_work
    get "/literature-guidance", PageController, :literature_guidance
    get "/meeting-minutes", PageController, :meeting_minutes

    get "/maintenance", MaintenanceController, :index

    delete "/maintenance/participants/orphaned",
           MaintenanceController,
           :delete_orphaned_participants

    resources "/categories", CategoryController, except: [:show, :delete]

    live "/contests", ContestLive.Index

    resources "/contests", ContestController, except: [:index, :create] do
      get "/performances/jury-material", PerformanceController, :jury_material, as: :performances

      get "/performances/print-jury-sheets", PerformanceController, :print_jury_sheets,
        as: :performances

      get "/performances/print-jury-table", PerformanceController, :print_jury_table,
        as: :performances

      get "/performances/edit-results", PerformanceController, :edit_results, as: :results
      patch "/performances/update-results", PerformanceController, :update_results, as: :results
      get "/performances/publish-results", PerformanceController, :publish_results, as: :results

      patch "/performances/update-results-public", PerformanceController, :update_results_public,
        as: :results

      get "/performances/certificates", PerformanceController, :certificates, as: :performances

      get "/performances/print-certificates", PerformanceController, :print_certificates,
        as: :performances

      get "/performances/advancing", PerformanceController, :advancing, as: :performances
      get "/performances/advancing.xml", PerformanceController, :advancing_xml, as: :performances

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

    resources "/users", UserController, except: [:show] do
      get "/impersonate", UserController, :impersonate, as: :impersonate
    end
  end

  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser
      live_dashboard "/dashboard"
    end

    scope "/dev" do
      forward "/mailbox", Plug.Swoosh.MailboxPreview

      forward "/graphql-playground", Absinthe.Plug.GraphiQL,
        schema: JumubaseWeb.Schema,
        interface: :playground
    end
  end
end
