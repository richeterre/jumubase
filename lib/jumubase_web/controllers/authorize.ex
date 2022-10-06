defmodule JumubaseWeb.Authorize do
  import Plug.Conn
  import Phoenix.Controller
  import Jumubase.Gettext
  import Jumubase.Foundation.Contest, only: [deadline_passed?: 2]
  alias Plug.Conn
  alias Jumubase.Foundation
  alias JumubaseWeb.Router.Helpers, as: Routes
  alias JumubaseWeb.Internal.Permit

  # Plug to allow only admins to access the resource.
  def admin_check(%Conn{} = conn, opts) do
    role_check(conn, opts ++ [roles: ["admin"]])
  end

  # Plug to prevent observers from accessing the resource.
  def non_observer_check(%Conn{} = conn, opts) do
    role_check(conn, opts ++ [roles: ["admin", "global-organizer", "local-organizer"]])
  end

  # Plug to authorize access to a contest route.
  def contest_user_check(%Conn{assigns: %{current_user: user}, params: params} = conn, _opts) do
    contest_id = params["id"] || params["contest_id"]
    authorize_contest(conn, user, contest_id, fn {:ok, _} -> conn end)
  end

  # Action override to ensure contest deadline hasn't passed before passing it to action
  def contest_deadline_check_action(
        %Conn{params: %{"contest_id" => id} = params} = conn,
        module
      ) do
    check_contest_deadline(conn, id, fn {:ok, contest} ->
      apply(module, action_name(conn), [conn, params, contest])
    end)
  end

  # Action override to ensure contest accepts new registrations before passing it to action
  def contest_openness_check_action(
        %Conn{params: %{"contest_id" => id} = params} = conn,
        module
      ) do
    check_contest_openness(conn, id, fn {:ok, contest} ->
      apply(module, action_name(conn), [conn, params, contest])
    end)
  end

  # Action override to authorize contest access before passing it to all actions
  def contest_user_check_action(
        %Conn{assigns: %{current_user: user}, params: %{"contest_id" => id} = params} = conn,
        module
      ) do
    authorize_contest(conn, user, id, fn {:ok, contest} ->
      apply(module, action_name(conn), [conn, params, contest])
    end)
  end

  # Private helpers

  # Checks whether the user has one of the roles given in opts.
  defp role_check(%Conn{assigns: %{current_user: current_user}} = conn, opts) do
    if opts[:roles] && current_user.role in opts[:roles],
      do: conn,
      else: unauthorized(conn, Routes.internal_page_path(conn, :home))
  end

  defp check_contest_deadline(conn, id, success_fun) do
    contest = Foundation.get_contest!(id)

    if deadline_passed?(contest, Timex.today()) do
      contest_error(conn, :deadline_passed)
    else
      success_fun.({:ok, contest})
    end
  end

  defp check_contest_openness(conn, id, success_fun) do
    contest = Foundation.get_contest!(id)

    cond do
      deadline_passed?(contest, Timex.today()) ->
        contest_error(conn, :deadline_passed)

      !contest.allows_registration ->
        contest_error(conn, :no_registration)

      true ->
        success_fun.({:ok, contest})
    end
  end

  # Checks whether the user may access the contest with given id,
  # and if yes, calls the success handler with {:ok, contest}.
  defp authorize_contest(conn, user, id, success_fun) do
    contest = Foundation.get_contest!(id)

    if Permit.authorized?(user, contest) do
      success_fun.({:ok, contest})
    else
      unauthorized(conn, Routes.internal_page_path(conn, :home))
    end
  end

  defp contest_error(conn, reason) do
    failure_path = Routes.page_path(conn, :registration)

    case reason do
      :deadline_passed ->
        error(
          conn,
          gettext(
            "The registration deadline for this contest has passed. Please contact us if you need assistance."
          ),
          failure_path
        )

      :no_registration ->
        error(
          conn,
          gettext(
            "This contest is not open for registration. Please contact us if you need assistance."
          ),
          failure_path
        )
    end
  end

  defp unauthorized(conn, path) do
    error(conn, dgettext("auth", "You are not authorized to view this page."), path)
  end

  defp error(conn, message, path) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: path)
    |> halt
  end
end
