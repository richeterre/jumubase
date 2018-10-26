defmodule JumubaseWeb.Internal.AppearanceView do
  use JumubaseWeb, :view
  alias Jumubase.Showtime.Appearance

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
    Enum.filter(appearances, &Appearance.is_accompanist/1)
  end

  @doc """
  Returns only the soloist and ensemblist appearances from the list.
  """
  def non_acc(appearances) do
    Enum.filter(appearances, &!Appearance.is_accompanist(&1))
  end

  @doc """
  Creates an age group badge for an appearance.
  """
  def age_group_badge(%Appearance{age_group: ag}), do: badge(ag)

  @doc """
  Creates a badge for an age group.
  """
  def badge(nil), do: nil
  def badge(age_group) do
    content_tag :span, age_group, class: "badge"
  end
end
