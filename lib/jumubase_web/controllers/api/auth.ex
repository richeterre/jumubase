defmodule JumubaseWeb.Api.Auth do
  @moduledoc """
  A plug to restrict API access for mobile apps and other clients.
  """

  import Plug.Conn

  def init(options), do: options

  @doc """
  Checks that the API key is present in the request headers.
  """
  def call(conn, _opts) do
    api_key = Application.get_env(:jumubase, __MODULE__)[:api_key]

    case get_req_header(conn, "x-api-key") do
      [^api_key] -> conn
      _ -> send_resp(conn, 401, "Incorrect or missing API key")
    end
  end
end
