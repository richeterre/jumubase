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
      use Phoenix.ConnTest
      import JumubaseWeb.Router.Helpers
      import JumubaseWeb.AuthTestHelpers

      # The default endpoint for testing
      @endpoint JumubaseWeb.Endpoint

      def login_if_needed(%{conn: conn} = config) do
        conn = conn
        |> bypass_through(JumubaseWeb.Router, [:browser])
        |> get("/")

        # Add user session if role given in config
        conn = case config[:login_as] do
          nil -> conn
          user_role -> login_user(conn, user_role)
        end

        {:ok, Map.put(config, :conn, conn)}
      end

      def add_phauxth_session(conn, user) do
        session_id = Phauxth.Login.gen_session_id("F")
        Jumubase.Accounts.add_session(user, session_id, System.system_time(:second))
        Phauxth.Login.add_session(conn, session_id, user.id)
      end

      def assert_unauthorized_user(conn) do
        assert redirected_to(conn) == internal_page_path(conn, :home)
        assert conn.halted
      end

      def assert_unauthorized_guest(conn) do
        assert redirected_to(conn) == session_path(conn, :new)
        assert conn.halted
      end

      defp login_user(conn, role) do
        user = add_user(role: role)
        conn
        |> add_phauxth_session(user)
        |> send_resp(:ok, "/")
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
