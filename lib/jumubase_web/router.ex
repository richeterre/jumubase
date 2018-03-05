defmodule JumubaseWeb.Router do
  use JumubaseWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", JumubaseWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
  end

  scope "/internal", JumubaseWeb.Internal, as: :internal do
    pipe_through(:browser)

    resources("/users", UserController, except: [:show])
  end
end
