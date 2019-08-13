defmodule JumubaseWeb.Plugs.Grouping do
  @moduledoc """
  This stores the user's grouping preference as selected on the website,
  and assigns it to the conn for easy access from within templates.
  """

  import Plug.Conn
  alias Jumubase.JumuParams

  def init(_opts), do: nil

  def call(conn, _opts) do
    grouping = retrieve_grouping(conn) |> validate_grouping()

    conn
    |> persist_grouping(grouping)
    |> assign(:active_grouping, grouping)
  end

  # Private helpers

  defp retrieve_grouping(conn) do
    grouping_from_params(conn) || grouping_from_session(conn)
  end

  defp grouping_from_params(conn) do
    conn.params["grouping"]
  end

  defp grouping_from_session(conn) do
    get_session(conn, :active_grouping)
  end

  defp validate_grouping(grouping) do
    if grouping in JumuParams.groupings(), do: grouping, else: nil
  end

  defp persist_grouping(conn, grouping) do
    put_session(conn, :active_grouping, grouping)
  end
end
