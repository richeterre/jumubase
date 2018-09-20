defmodule JumubaseWeb.PerformanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  alias Jumubase.JumuParams

  @doc """
  Renders JS that powers the registration form.
  """
  def render("scripts.new.html", assigns) do
    %{
      changeset: changeset,
      contest_category_options: cc_options
    } = assigns

    json = render_html_safe_json(
      %{
        changeset: changeset,
        contest_category_options: (
          for {name, id} <- cc_options, do: %{id: id, name: name}
        )
      }
    )

    ~E{
      <script src="/js/registration.js"></script>
      <script>registrationForm(<%= raw(json) %>)</script>
    }
  end

  def role_options do
    Enum.map(JumuParams.participant_roles, fn
      "soloist" -> {gettext("Soloist"), "soloist"}
      "accompanist" -> {gettext("Accompanist"), "accompanist"}
      "ensemblist" -> {gettext("Ensemblist"), "ensemblist"}
    end)
  end

  def instrument_options do
    [
      {gettext("Vocals"), "VOCALS"},
      {gettext("Piano"), "PIANO"},
    ]
  end
end
