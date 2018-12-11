defmodule Jumubase.Foundation.Stage do
  use Ecto.Schema
  alias Jumubase.Foundation.Host

  schema "stages" do
    field :name, :string

    belongs_to :host, Host

    timestamps()
  end
end
