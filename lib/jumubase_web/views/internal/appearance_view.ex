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

  def participant_names(appearances) when is_list(appearances) do
    appearances |> Enum.map(&full_name(&1.participant)) |> Enum.join(", ")
  end

  def prize(%Appearance{points: points}, round) do
    Results.get_prize(points, round)
  end

  def advancement_label(%Appearance{} = a) do
    if Results.advances?(a) do
      content_tag :span, "WL", class: "label label-success"
    end
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
