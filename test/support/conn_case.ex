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

      def login_if_needed(%{conn: conn} = config) do
        conn =
          conn
          |> bypass_through(JumubaseWeb.Router, [:browser])
          |> get("/")

        # Add user session if role given in config
        case config[:login_as] do
          nil ->
            {:ok, config}

          user_role ->
            {:ok, Map.merge(config, login_user(conn, user_role))}
        end
      end

      def add_phauxth_session(conn, user) do
        session_id = Phauxth.Login.gen_session_id("F")
        Jumubase.Accounts.add_session(user, session_id, System.system_time(:second))
        Phauxth.Login.add_session(conn, session_id, user.id)
      end

      defp login_user(conn, role) do
        user = add_user(role: role)

        conn =
          conn
          |> add_phauxth_session(user)
          |> send_resp(:ok, "/")

        %{conn: conn, user: user}
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
