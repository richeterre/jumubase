defmodule JumubaseWeb.PerformanceView do
  use JumubaseWeb, :view
  import JumubaseWeb.PageView, only: [contest_name: 1]
  alias Jumubase.JumuParams

  @doc """
  Renders JS that powers the signup form.
  """
  def render("scripts.new.html", _assigns) do
    ~E(<script src="/js/signup.js"></script>)
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
