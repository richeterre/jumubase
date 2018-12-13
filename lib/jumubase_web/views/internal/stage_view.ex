defmodule JumubaseWeb.Internal.StageView do
  use JumubaseWeb, :view
  import JumubaseWeb.Internal.ContestView, only: [name_with_flag: 1]
  import JumubaseWeb.Internal.PerformanceView, only: [cc_filter_options: 1]

  def render("scripts.schedule.html", %{conn: conn, contest: c, stage: s}) do
    options = render_html_safe_json %{
      csrfToken: Plug.CSRFProtection.get_csrf_token(),
      stageId: s.id,
      submitPath: Routes.internal_contest_performance_path(conn, :reschedule, c),
    }

    ~E{
      <script src="/js/scheduler.js"></script>
      <script>scheduler(<%= raw(options) %>)</script>
    }
  end
end
