defmodule JumubaseWeb.Internal.AppearanceView do
  use JumubaseWeb, :view

  @doc """
  Returns a display name for the instrument.
  """
  def instrument_name(instrument) do
    Jumubase.Showtime.Instruments.name(instrument)
  end

  @doc """
  Returns only the accompanist appearances from the list.
  """
  def acc(appearances) do
    Enum.filter(appearances, fn %{participant_role: role} ->
      role == "accompanist"
    end)
  end

  @doc """
  Returns only the soloist and ensemblist appearances from the list.
  """
  def non_acc(appearances), do: appearances -- acc(appearances)
end
