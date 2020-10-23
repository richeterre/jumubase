defmodule JumubaseWeb.Internal.ParticipantView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  alias Jumubase.Foundation.AgeGroups
  alias Jumubase.Showtime.{Participant, Performance}
  alias JumubaseWeb.Internal.PerformanceView

  @doc """
  Returns the participant's full name.
  """
  def full_name(%Participant{given_name: given_name, family_name: family_name}) do
    "#{given_name} #{family_name}"
  end

  @doc """
  Returns all years to be shown in birthdate pickers for the given season.
  """
  def birthdate_year_options(season) do
    AgeGroups.birthyear_range(season)
  end

  @doc """
  Returns an email link with all unique participant emails in BCC.
  """
  def group_email_link(participants) do
    emails =
      participants
      |> Enum.map(& &1.email)
      |> Enum.uniq()
      |> Enum.join(",")

    "mailto:?bcc=#{emails}"
  end

  @doc """
  Returns the performance's category and predecessor info.
  """
  def performance_info(%Performance{} = p) do
    "#{PerformanceView.category_name(p)} #{PerformanceView.predecessor_info(p, :short)}"
  end
end
