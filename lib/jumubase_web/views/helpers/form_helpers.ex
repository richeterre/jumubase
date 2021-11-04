defmodule JumubaseWeb.FormHelpers do
  import Phoenix.HTML.Form
  import Phoenix.LiveView.Helpers
  import JumubaseWeb.DateHelpers, only: [localized_months: 0]

  def inline_date_select(form, field, opts \\ []) do
    builder = fn b ->
      assigns = %{}

      ~H"""
      <div class="form-inline">
        <%= b.(:day, class: "form-control") %>
        <%= b.(:month, class: "form-control") %>
        <%= b.(:year, class: "form-control") %>
      </div>
      """
    end

    # Localize month names
    month_options = Enum.map(localized_months(), fn {ordinal, name} -> {name, ordinal} end)

    month_opts =
      case Keyword.get(opts, :month) do
        nil -> [options: month_options]
        existing -> Keyword.put_new(existing, :options, month_options)
      end

    opts = Keyword.put(opts, :month, month_opts)
    date_select(form, field, [builder: builder] ++ opts)
  end
end
