defmodule JumubaseWeb.Email do
  use Bamboo.Phoenix, view: JumubaseWeb.EmailView

  import Jumubase.Gettext
  import JumubaseWeb.Router.Helpers
  alias Jumubase.Foundation.Category
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance
  alias JumubaseWeb.Email

  @doc """
  Sends a confirmation email after registering for a contest.
  """
  def registration_success(%Performance{} = performance) do
    %{
      contest_category: %{category: category},
      edit_code: edit_code,
      appearances: appearances
    } = performance |> Showtime.load_contest_category

    participants = appearances |> Enum.map(&(&1.participant))

    email =
      base_email()
      |> subject(get_subject(category, length(participants)))
      |> assign(:genre, category.genre)
      |> assign(:category_name, category.name)
      |> assign(:edit_code, edit_code)
      |> assign(:edit_url, page_url(JumubaseWeb.Endpoint, :edit_registration))

    case participants do
      [participant] ->
        email
        |> to(participant.email)
        |> assign(:participant, participant)
        |> render("registration_success_one.html")
      participants ->
        email
        |> to(participants |> Enum.map(&(&1.email)))
        |> assign(:participants, participants)
        |> render("registration_success_many.html")
    end
  end

  # Private helpers

  defp base_email do
    sender = Application.get_env(:jumubase, Email)[:default_sender]

    new_email() |> from(sender)
  end

  defp get_subject(%Category{genre: "kimu"}, participant_count) do
    ngettext(
      "KIMU_REGISTRATION_SUCCESS_SUBJECT_ONE",
      "KIMU_REGISTRATION_SUCCESS_SUBJECT_MANY",
      participant_count
    )
  end
  defp get_subject(%Category{name: cat_name}, participant_count) do
    ngettext(
      "JUMU_REGISTRATION_SUCCESS_SUBJECT_ONE: \"%{name}\"",
      "JUMU_REGISTRATION_SUCCESS_SUBJECT_MANY: \"%{name}\"",
      participant_count,
      name: cat_name
    )
  end
end
