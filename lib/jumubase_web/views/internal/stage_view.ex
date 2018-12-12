defmodule JumubaseWeb.Internal.StageView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.Internal.PerformanceView, only: [cc_filter_options: 1]

  def render("scripts.schedule.html", _assigns) do
    ~E(<script src="/js/scheduler.js"></script>)
  end
end
