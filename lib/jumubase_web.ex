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
      import Jumubase.Gettext
      import JumubaseWeb.Router.Helpers
      import JumubaseWeb.Breadcrumbs
      import JumubaseWeb.Authorize
      alias Jumubase.Foundation

      def get_contest!(conn, module) do
        contest = Foundation.get_contest!(conn.params["contest_id"])
        args = [conn, conn.params, contest]
        apply(module, action_name(conn), args)
      end
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/jumubase_web/templates",
        namespace: JumubaseWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Jumubase.Gettext
      import Jumubase.Utils
      import JumubaseWeb.Router.Helpers
      import JumubaseWeb.AuthHelpers
      import JumubaseWeb.ErrorHelpers
      import JumubaseWeb.IconHelpers
      import JumubaseWeb.JsonHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
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
