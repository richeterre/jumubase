defmodule JumubaseWeb.Internal.AppearanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ParticipantView, only: [full_name: 1]
  alias Jumubase.Showtime.Appearance
  alias Jumubase.Showtime.{Instruments, Results}

  @doc """
  Returns the participant's full name and instrument name.
  """
  def appearance_info(%Appearance{participant: pt, instrument: i}) do
    "#{full_name(pt)}, #{instrument_name(i)}"
  end

  @doc """
  Returns a display name for the instrument.
  """
  def instrument_name(instrument) do
    Instruments.name(instrument)
  end

  def prize(%Appearance{points: points}, round) do
    Results.get_prize(points, round)
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
