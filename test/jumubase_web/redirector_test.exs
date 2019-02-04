defmodule JumubaseWeb.RedirectorTest do
  use ExUnit.Case, async: true
  alias JumubaseWeb.Redirector

  defmodule Router do
    use Phoenix.Router

    get "/anmelden", Redirector, to: "/login"
    get "/exceptional", Redirector, []
  end

  test "an exception is raised when `to` isn't defined" do
    assert_raise Plug.Conn.WrapperError, ~R[Missing required to: option in redirect], fn ->
      call(Router, :get, "/exceptional")
    end
  end

  test "route redirected to internal route" do
    conn = call(Router, :get, "/anmelden")

    assert_redirected_to(conn, "/login")
  end

  test "route redirected to internal route with query string" do
    conn = call(Router, :get, "/anmelden?locale=en")

    assert_redirected_to(conn, "/login?locale=en")
  end

  # Private helpers

  defp call(router, verb, path) do
    verb
    |> Plug.Test.conn(path)
    |> router.call(router.init([]))
  end

  defp assert_redirected_to(conn, expected_url) do
    actual_uri =
      conn
      |> Plug.Conn.get_resp_header("location")
      |> List.first()
      |> URI.parse()

    expected_uri = URI.parse(expected_url)

    assert conn.status == 302
    assert actual_uri.scheme == expected_uri.scheme
    assert actual_uri.host == expected_uri.host
    assert actual_uri.path == expected_uri.path

    if actual_uri.query do
      assert Map.equal?(
               URI.decode_query(actual_uri.query),
               URI.decode_query(expected_uri.query)
             )
    end
  end
end
