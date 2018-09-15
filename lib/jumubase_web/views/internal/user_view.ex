defmodule JumubaseWeb.Internal.UserView do
  use JumubaseWeb, :view
  alias Jumubase.JumuParams

  @doc """
  Returns the given user's full name.
  """
  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  @doc """
  Returns the user's associated hosts as Emoji flags.
  """
  def host_flags(user) do
    user.hosts
    |> Enum.map(fn(host) -> emoji_flag(host.country_code) end)
  end

  @doc """
  Returns the names of the user's associated hosts.
  """
  def host_names(user) do
    user.hosts
    |> Enum.map(&(&1.name))
    |> Enum.join(", ")
  end

  @doc """
  Returns a textual tag describing the user's role.
  """
  def role_tag(role) do
    case role do
      "rw-organizer" ->
        nil
      _ ->
        text = role_name(role)
        content_tag(:span, text, class: "label label-#{label_class(role)}")
    end
  end

  @doc """
  Returns a list of possible `role` values suitable for forms.
  """
  def form_roles do
    Enum.map(JumuParams.roles(), &{role_name(&1), &1})
  end

  # Maps internal roles to user-facing role names.
  defp role_name(role) do
    case role do
      "admin" -> gettext("Admin")
      "inspector" -> gettext("Inspector")
      "lw-organizer" -> gettext("LW Organizer")
      "rw-organizer" -> gettext("RW Organizer")
    end
  end

  # Maps roles to classes that determine label style.
  defp label_class(role) do
    case role do
      "admin" -> "danger"
      "inspector" -> "info"
      "lw-organizer" -> "warning"
      _ -> "default"
    end
  end
end
