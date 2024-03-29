defmodule JumubaseWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use JumubaseWeb, :controller
      use JumubaseWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: JumubaseWeb
      import Plug.Conn
      import Phoenix.LiveView.Controller
      import Jumubase.Gettext
      import JumubaseWeb.Breadcrumbs
      import JumubaseWeb.Authorize
      alias JumubaseWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/jumubase_web/templates",
        namespace: JumubaseWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1, view_template: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Phoenix.LiveView.Helpers
      import Jumubase.Gettext
      import Jumubase.Utils
      import JumubaseWeb.AuthHelpers
      import JumubaseWeb.DateHelpers
      import JumubaseWeb.ErrorHelpers
      import JumubaseWeb.FormHelpers
      import JumubaseWeb.IconHelpers
      alias JumubaseWeb.Router.Helpers, as: Routes
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {JumubaseWeb.LayoutView, "live.html"}

      import Jumubase.Gettext
      import JumubaseWeb.Breadcrumbs
      alias JumubaseWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import Jumubase.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
