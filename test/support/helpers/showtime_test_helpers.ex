defmodule Jumubase.ShowtimeTestHelpers do
  import Jumubase.Factory

  @doc """
  Returns valid attributes for creating an Appearance,
  including nested data that isn't handled by the Factory.
  """
  def valid_appearance_attrs do
    params_with_assocs(:appearance)
    # Replace linked by nested participant
    |> Map.delete(:participant_id)
    |> Map.put(:participant, params_for(:participant))
  end

  @doc """
  Returns valid attributes for creating a Performance,
  including nested data that isn't handled by the Factory.
  """
  def valid_performance_attrs do
    params_with_assocs(:performance)
    |> Map.put(:appearances, [valid_appearance_attrs()])
  end
end
