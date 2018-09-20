defmodule JumubaseWeb.PerformanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [contest_name: 1]
  import Phoenix.HTML
  alias Jumubase.JumuParams

  @doc """
  Renders JS that powers the registration form.
  """
  def render("scripts.new.html", assigns) do
    %{
      changeset: changeset,
      contest_category_options: contest_category_options
    } = assigns

    json = render_html_safe_json(
      %{
        changeset: changeset,
        contest_category_options: (for {name, id} <- contest_category_options,
                                   do: %{id: id, name: name})
      }
    )

    ~E{
      <script src="/js/registration.js"></script>
      <script>signupForm(<%= raw(json) %>)</script>
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
