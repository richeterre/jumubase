defmodule JumubaseWeb.Schema.Objects do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  import JumubaseWeb.Schema.Helpers
  alias Jumubase.Showtime
  alias JumubaseWeb.{AppearanceResolver, ContestResolver, PerformanceResolver, PieceResolver}

  object :appearance do
    field :id, non_null(:id)

    field :participant_name, non_null(:string) do
      description "The full name of the appearance's participant."
      resolve &AppearanceResolver.participant_name/2
    end

    field :instrument_name, non_null(:string) do
      description "The name of the participant's instrument in this appearance."
      resolve &AppearanceResolver.instrument_name/2
    end
  end

  object :contest do
    field :id, non_null(:id)

    field :name, non_null(:string) do
      description "The contest’s name containing the round, year and host."
      resolve &ContestResolver.name/2
    end

    field :country_code, non_null(:string) do
      description "The country code of the contest's host."
      resolve &ContestResolver.country_code/2
    end

    field :start_date, non_null(:date) do
      description "The first day of the contest."
    end

    field :end_date, non_null(:date) do
      description "The last day of the contest."
    end

    field :dates, non_null_list_of(:date) do
      description "The dates on which the contest is happening."
      resolve &ContestResolver.dates/2
    end

    field :stages, non_null_list_of(:stage) do
      description "The stages used in this contest."
      resolve &ContestResolver.stages/2
    end
  end

  object :host do
    field :id, non_null(:id)

    field :name, non_null(:string) do
      description "The name of the host."
    end

    field :country_code, non_null(:string) do
      description "The country code of the host."
    end
  end

  object :performance do
    field :id, non_null(:id)

    field :stage_time, non_null(:time) do
      description "The scheduled wall time of the performance."
    end

    field :category_info, non_null(:string) do
      description "The performance's contest category and age group."
      resolve &PerformanceResolver.category_info/2
    end

    field :predecessor_host, :host do
      description "The host of the performance's predecessor contest."
      resolve &PerformanceResolver.predecessor_host/2
    end

    field :appearances, non_null_list_of(:appearance) do
      description "The performance's appearances."
      resolve &PerformanceResolver.appearances/2
    end

    field :pieces, non_null_list_of(:piece) do
      description "The performance's pieces."
      resolve dataloader(Showtime)
    end
  end

  object :piece do
    field :id, non_null(:id)

    field :person_info, non_null(:string) do
      description """
      For classical pieces, this contains the name and biographical dates of the piece's composer.
      For popular pieces, the artist name is returned.
      """

      resolve &PieceResolver.person_info/2
    end

    field :title, non_null(:string) do
      description "The title of the piece."
    end
  end

  object :stage do
    field :id, non_null(:id)

    field :name, non_null(:string) do
      description "The public name of the stage."
    end
  end

  input_object :performance_filter do
    field :stage_date, :date
    field :stage_id, :id
  end
end
