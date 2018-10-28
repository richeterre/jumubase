defmodule JumubaseWeb.Email do
  use Bamboo.Phoenix, view: JumubaseWeb.EmailView

  import Jumubase.Gettext
  import JumubaseWeb.Router.Helpers
  alias Jumubase.Showtime
  alias Jumubase.Showtime.Performance
  alias JumubaseWeb.Email

  @doc """
  Sends a confirmation email after registering for a contest.
  """
  def registration_success(%Performance{} = performance) do
    %{
      contest_category: %{category: %{name: category_name}},
      edit_code: edit_code,
      appearances: appearances
    } = performance |> Showtime.load_contest_category

    subject = gettext("Jumu registration for category \"%{name}\"", name: category_name)

    email =
      base_email()
      |> subject(subject)
      |> assign(:category_name, category_name)
      |> assign(:edit_code, edit_code)
      |> assign(:edit_url, page_url(JumubaseWeb.Endpoint, :edit_registration))

    case appearances |> Enum.map(&(&1.participant)) do
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
end
