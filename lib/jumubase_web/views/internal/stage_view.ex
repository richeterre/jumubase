defmodule JumubaseWeb.Internal.StageView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.Internal.PerformanceView, only: [cc_filter_options: 1]

  def render("scripts.schedule.html", assigns) do
    options = render_html_safe_json %{
      csrfToken: Plug.CSRFProtection.get_csrf_token(),
      contestId: assigns.contest.id,
      stageId: assigns.stage.id,
    }

    ~E{
      <script src="/js/scheduler.js"></script>
      <script>scheduler(<%= raw(options) %>)</script>
    }
  end
end
