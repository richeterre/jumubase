defmodule JumubaseWeb.Schema.Objects do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 3]
  alias Jumubase.Foundation
  alias Jumubase.Showtime
  alias JumubaseWeb.{FoundationResolver, ShowtimeResolver}

  object :appearance do
    field :id, non_null(:id)

    field :participant_name, non_null(:string) do
      description "The full name of the appearance's participant."
      resolve &ShowtimeResolver.participant_name/3
    end

    field :instrument_name, non_null(:string) do
      description "The name of the participant's instrument in this appearance."
      resolve &ShowtimeResolver.instrument_name/3
    end

    field :result, :result do
      description "The appearance's result, if publicly available."

      resolve dataloader(Showtime, :performance,
                args: %{scope: :result},
                callback: &ShowtimeResolver.result/3
              )
    end
  end

  object :contest do
    field :id, non_null(:id)

    field :name, non_null(:string) do
      description "The contest’s name containing the round, year and host."
      resolve &FoundationResolver.name/3
    end

    field :country_code, non_null(:string) do
      description "The country code of the contest's host."
      resolve &FoundationResolver.country_code/3
    end

    field :dates, non_null(list_of(non_null(:date))) do
      description "The dates on which the contest is happening."
      resolve &FoundationResolver.dates/3
    end

    field :stages, non_null(list_of(non_null(:stage))) do
      description "The stages used in this contest."
      resolve &FoundationResolver.stages/3
    end

    field :contest_categories, non_null(list_of(non_null(:contest_category))) do
      description "The contest categories offered at this contest."
      resolve dataloader(Foundation)
    end
  end

  object :contest_category do
    field :id, non_null(:id)

    field :name, non_null(:string) do
      description "The contest category's name."
      resolve &FoundationResolver.name/3
    end

    field :public_result_count, non_null(:integer) do
      description "The amount of performances with public results in this contest category."

      resolve dataloader(Foundation, :performances,
                callback: &FoundationResolver.public_result_count/3
              )
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
      resolve &ShowtimeResolver.category_info/3
    end

    field :predecessor_host, :host do
      description "The host of the performance's predecessor contest."
      resolve &ShowtimeResolver.predecessor_host/3
    end

    field :appearances, non_null(list_of(non_null(:appearance))) do
      description "The performance's appearances."
      resolve &ShowtimeResolver.appearances/3
    end

    field :pieces, non_null(list_of(non_null(:piece))) do
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

      resolve &ShowtimeResolver.person_info/3
    end

    field :title, non_null(:string) do
      description "The title of the piece."
    end
  end

  object :result do
    field :points, non_null(:integer) do
      description "The points awarded to this appearance."
    end

    field :prize, :string do
      description "The prize corresponding to the appearance's points."
    end

    field :advances, non_null(:boolean) do
      description "Whether the participant will advance to the next round with this appearance."
    end
  end

  object :stage do
    field :id, non_null(:id)

    field :name, non_null(:string) do
      description "The public name of the stage."
    end
  end

  input_object :performance_filter do
    field :stage_date, :date do
      description "The date on which the performances are scheduled."
    end

    field :stage_id, :id do
      description "The ID of the stage on which the performances happen."
    end
  end
end
