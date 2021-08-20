defmodule Jumubase.SentryEventFilter do
  @moduledoc """
  Allows filtering of events before submitting them to Sentry,
  e.g. for certain exceptions that should not be reported.
  """

  @behaviour Sentry.EventFilter

  # Ignore Phoenix "route not found" exception
  def exclude_exception?(%x{}, :plug) when x in [Phoenix.Router.NoRouteError], do: true

  def exclude_exception?(%Ecto.NoResultsError{}, :plug), do: true
  def exclude_exception?(%Ecto.NoResultsError{}, :endpoint), do: true
  def exclude_exception?(_exception, _source), do: false
end
