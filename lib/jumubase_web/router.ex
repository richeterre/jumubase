defmodule JumubaseWeb.Router do
  use JumubaseWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
    plug Phauxth.Remember
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", JumubaseWeb do
    pipe_through :browser

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
    pipe_through :browser

    get "/", PageController, :home

    resources "/categories", CategoryController, only: [:index, :new, :create]
    resources "/contests", ContestController, only: [:index, :show] do
      resources "/contest_categories", ContestCategoryController, only: [:index]
      resources "/performances", PerformanceController, only: [:index, :show]
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
