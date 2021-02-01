defmodule JumubaseWeb.EmailView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [round_name_and_year: 1]
  alias Jumubase.Showtime.Participant

  @doc """
  Returns a greeting to start a message to the given participants.
  """
  def greeting(%Participant{given_name: name}) do
    "#{gettext("Hello")} #{name}"
  end

  def greeting(participants) when is_list(participants) do
    [last | other] =
      participants
      |> Enum.map(fn pt -> pt.given_name end)
      |> Enum.reverse()

    part1 = other |> Enum.reverse() |> Enum.join(", ")
    part2 = "#{gettext("and")} #{last}"

    "#{gettext("Hello")} #{part1} #{part2}"
  end
end
