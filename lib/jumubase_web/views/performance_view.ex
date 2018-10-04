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
      contest: contest,
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
        epoch_options: epoch_options(),
      }
    )

    ~E{
      <script src="/js/registration.js"></script>
      <script>registrationForm(<%= raw(json) %>)</script>
    }
  end

  # Private helpers

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

  defp role_options do
    Enum.map(JumuParams.participant_roles, fn
      role -> %{id: role, label: role_name(role)}
    end)
  end

  defp role_name(role) do
    case role do
      "soloist" -> gettext("Soloist")
      "accompanist" -> gettext("Accompanist")
      "ensemblist" -> gettext("Ensemblist")
    end
  end

  defp instrument_options do
    Jumubase.Showtime.Instruments.all
    |> Enum.map(fn {value, label} -> %{value: value, label: label} end)
  end

  defp epoch_options do
    Enum.map(JumuParams.epochs, fn
      epoch -> %{id: epoch, label: "#{epoch}) #{epoch_name(epoch)}"}
    end)
  end

  defp epoch_name(epoch) do
    case epoch do
      "a" -> gettext("Renaissance, Early Baroque")
      "b" -> gettext("Baroque")
      "c" -> gettext("Early Classical, Classical")
      "d" -> gettext("Romantic, Impressionist")
      "e" -> gettext("Modern Classical, Jazz, Pop")
      "f" -> gettext("Neue Musik")
    end
  end
end
