defmodule JumubaseWeb.PerformanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  alias Jumubase.JumuParams
  alias Jumubase.Foundation.AgeGroups

  @doc """
  Renders JS that powers the registration form.
  """
  def render("scripts.new.html", assigns) do
    %{
      contest:  contest,
      changeset: changeset,
      contest_category_options: cc_options,
    } = assigns

    json = render_html_safe_json(
      %{
        changeset: changeset,
        contest_category_options: (
          for {label, value} <- cc_options, do: %{value: value, label: label}
        ),
        birthdate_year_options: birthdate_year_options(contest.season),
        birthdate_month_options: birthdate_month_options(),
        role_options: role_options(),
        instrument_options: instrument_options(),
      }
    )

    ~E{
      <script src="/js/registration.js"></script>
      <script>registrationForm(<%= raw(json) %>)</script>
    }
  end

  def birthdate_year_options(season) do
    AgeGroups.birthyear_range(season)
  end

  def birthdate_month_options() do
    Timex.Translator.current_locale
    |> Timex.Translator.get_months
    |> Map.to_list
    |> Enum.map(fn {ordinal, name} ->
      %{value: Integer.to_string(ordinal), label: name}
    end)
  end

  @doc """
  Returns a list of all participant roles in a form-friendly format.
  """
  def role_options do
    Enum.map(JumuParams.participant_roles, fn
      "soloist" -> %{id: "soloist", label: gettext("Soloist")}
      "accompanist" -> %{id: "accompanist", label: gettext("Accompanist")}
      "ensemblist" -> %{id: "ensemblist", label: gettext("Ensemblist")}
    end)
  end

  def instrument_options do
    Jumubase.Showtime.Instruments.all
    |> Enum.map(fn {value, label} -> %{value: value, label: label} end)
  end
end
