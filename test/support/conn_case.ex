defmodule JumubaseWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import Jumubase.Factory
      import Jumubase.TestHelpers
      import JumubaseWeb.AuthTestHelpers
      import JumubaseWeb.DateHelpers
      alias JumubaseWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint JumubaseWeb.Endpoint

      def login_if_needed(%{conn: conn} = context) do
        # Add user session if role is given in context
        case context[:login_as] do
          nil ->
            {:ok, context}

          user_role ->
            {:ok, Map.merge(context, create_and_log_in_user(context, user_role))}
        end
      end

      defp create_and_log_in_user(%{conn: conn}, role) do
        user = insert(:user, role: role)
        %{conn: log_in_user(conn, user), user: user}
      end

      defp log_in_user(conn, user) do
        token = Jumubase.Accounts.generate_user_session_token(user)

        conn
        |> init_test_session(%{})
        |> put_session(:user_token, token)
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Jumubase.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Jumubase.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
