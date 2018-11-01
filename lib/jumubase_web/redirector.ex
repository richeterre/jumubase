defmodule JumubaseWeb.Redirector do
  import Phoenix.Controller, only: [redirect: 2]

  @spec init(Keyword.t) :: Keyword.t
  def init([to: _] = opts), do: opts
  def init(_default), do: raise("Missing required to: option in redirect")

  @spec call(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
  def call(conn, [to: to]) do
    redirect(conn, to: append_query_string(conn, to))
  end

  @spec append_query_string(Plug.Conn.t, String.t) :: String.t
  defp append_query_string(%Plug.Conn{query_string: ""}, path), do: path
  defp append_query_string(%Plug.Conn{query_string: query}, path), do: "#{path}?#{query}"
end
