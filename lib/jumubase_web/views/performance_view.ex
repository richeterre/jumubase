defmodule JumubaseWeb.PerformanceView do
  use JumubaseWeb, :view

  @doc """
  Renders JS that powers the signup form.
  """
  def render("scripts.new.html", _assigns) do
    ~E(<script src="/js/signup.js"></script>)
  end
end
