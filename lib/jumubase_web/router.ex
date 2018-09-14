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

    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/password-resets", PasswordResetController, only: [:new, :create]
    get "/password-resets/edit", PasswordResetController, :edit
    put "/password-resets/update", PasswordResetController, :update
  end

  scope "/internal", JumubaseWeb.Internal, as: :internal do
    pipe_through :browser

    get "/", PageController, :home
    resources "/users", UserController, except: [:show]
  end
end
