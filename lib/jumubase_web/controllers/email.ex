defmodule JumubaseWeb.Email do
  use Bamboo.Phoenix, view: JumubaseWeb.EmailView
  import Jumubase.Gettext
  import JumubaseWeb.Internal.ContestView, only: [city: 1, round_name_and_year: 1]
  alias Jumubase.Foundation.{Category, Contest}
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance
  alias JumubaseWeb.Endpoint
  alias JumubaseWeb.Email
  alias JumubaseWeb.Router.Helpers, as: Routes

  def contact_message(%{name: name, email: email, message: message}) do
    contact_email = Application.get_env(:jumubase, Email)[:contact_email]
    admin_email = Application.get_env(:jumubase, Email)[:admin_email]

    email =
      new_email()
      |> from({name, email})
      |> to(contact_email)
      |> subject(gettext("New message via jumu-nordost.eu"))
      |> text_body(message)

    # Include admin as CC if different from contact email
    if admin_email != contact_email, do: cc(email, admin_email), else: email
  end

  @doc """
  Sends a confirmation email after registering for a contest.
  """
  def registration_success(%Performance{} = performance) do
    %{
      contest_category: %{category: category},
      edit_code: edit_code,
      appearances: appearances
    } = performance |> Showtime.load_contest_category()

    participants = appearances |> Enum.map(& &1.participant)

    email =
      base_email()
      |> subject(registration_success_subject(category, length(participants)))
      |> assign(:genre, category.genre)
      |> assign(:category_name, category.name)
      |> assign(:edit_code, edit_code)
      |> assign(:edit_url, Routes.page_url(Endpoint, :edit_registration))

    case participants do
      [participant] ->
        email
        |> to(participant.email)
        |> assign(:participant, participant)
        |> render("registration_success_one.html")

      participants ->
        email
        |> to(participants |> get_unique_emails)
        |> assign(:participants, participants)
        |> render("registration_success_many.html")
    end
  end

  @doc """
  Sends welcome emails to participants who advanced to an LW contest.
  """
  def welcome_advanced(%Contest{round: 2} = contest) do
    Showtime.list_performances(contest)
    |> Enum.map(fn p ->
      %{edit_code: edit_code, appearances: appearances} = p
      participants = appearances |> Enum.map(& &1.participant)

      email =
        base_email()
        |> subject(welcome_advanced_subject(contest, length(participants)))
        |> assign(:contest, contest)
        |> assign(:edit_code, edit_code)
        |> assign(:edit_url, Routes.page_url(Endpoint, :edit_registration))
        |> assign(:rules_url, Routes.page_path(Endpoint, :rules))

      case participants do
        [participant] ->
          email
          |> to(participant.email)
          |> assign(:participant, participant)
          |> render("welcome_advanced_one.html")

        participants ->
          email
          |> to(participants |> get_unique_emails)
          |> assign(:participants, participants)
          |> render("welcome_advanced_many.html")
      end
    end)
  end

  # Private helpers

  defp base_email do
    sender = Application.get_env(:jumubase, Email)[:default_sender]

    new_email() |> from(sender)
  end

  defp registration_success_subject(%Category{genre: "kimu"}, participant_count) do
    ngettext(
      "KIMU_REGISTRATION_SUCCESS_SUBJECT_ONE",
      "KIMU_REGISTRATION_SUCCESS_SUBJECT_MANY",
      participant_count
    )
  end

  defp registration_success_subject(%Category{name: cat_name}, participant_count) do
    ngettext(
      "JUMU_REGISTRATION_SUCCESS_SUBJECT_ONE(%{name})",
      "JUMU_REGISTRATION_SUCCESS_SUBJECT_MANY(%{name})",
      participant_count,
      name: cat_name
    )
  end

  defp welcome_advanced_subject(%Contest{} = c, participant_count) do
    ngettext(
      "JUMU_WELCOME_ADVANCED_SUBJECT_ONE(%{contest}, %{city})",
      "JUMU_WELCOME_ADVANCED_SUBJECT_MANY(%{contest}, %{city})",
      participant_count,
      contest: round_name_and_year(c),
      city: city(c)
    )
  end

  defp get_unique_emails(participants) do
    participants |> Enum.map(& &1.email) |> Enum.uniq()
  end
end
