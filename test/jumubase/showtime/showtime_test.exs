defmodule Jumubase.ShowtimeTest do
  use Jumubase.DataCase
  alias Ecto.Changeset
  alias Jumubase.Foundation.{Category, Contest, ContestCategory, Host, Stage}
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Participant, Performance, Piece}
  alias Jumubase.Showtime.PerformanceFilter

  # Season used e.g. for age group tests
  @season 56

  setup do
    [contest: insert(:contest, season: @season) |> with_contest_categories]
  end

  describe "list_performances/1" do
    test "returns the given contest's performances in the right order", %{contest: c} do
      now = Timex.now()
      later = Timex.shift(now, seconds: 1)

      # Performances in this contest
      [cc1, cc2] = c.contest_categories
      p1 = insert_performance(cc2)
      p2 = insert_performance(cc2)
      p3 = insert_performance(cc1, stage_time: later)
      p4 = insert_performance(cc1, age_group: "III")
      p5 = insert_performance(cc1, age_group: "II")
      p6 = insert_performance(cc2, stage_time: now)

      # Performance in other contest
      other_c = insert(:contest)
      insert_performance(other_c)

      # Check that performances are ordered by stage time, CC insertion, age group and insertion date
      assert_ids_match_unordered(Showtime.list_performances(c), [p6, p3, p5, p4, p1, p2])
    end

    test "preloads all necessary associations",
         %{contest: c} do
      insert_performance(c, appearances: build_list(1, :appearance), stage: build(:stage))

      assert [
               %Performance{
                 contest_category: %ContestCategory{category: %Category{}},
                 appearances: [%Appearance{participant: %Participant{}}],
                 stage: %Stage{}
               }
             ] = Showtime.list_performances(c)
    end
  end

  describe "list_performances/2" do
    test "returns matching performances from the contest when passing a filter", %{contest: c} do
      [cc1, cc2] = c.contest_categories
      today = ~N[2019-01-01T23:59:59]
      tomorrow = ~N[2019-01-02T00:00:00]

      [s1, s2] = insert_list(2, :stage, host: c.host)

      filter = %PerformanceFilter{
        stage_date: ~D[2019-01-01],
        stage_id: s1.id,
        contest_category_id: cc1.id,
        age_group: "III",
        results_public: true
      }

      # Matching performance
      p =
        insert_performance(cc1,
          age_group: "III",
          stage_id: s1.id,
          stage_time: today,
          results_public: true
        )

      # Non-matching performances
      insert_performance(cc1, age_group: "III", stage_id: s2.id, stage_time: today)
      insert_performance(cc1, age_group: "III", stage_id: s1.id, stage_time: nil)
      insert_performance(cc1, age_group: "III", stage_id: s1.id, stage_time: tomorrow)
      insert_performance(cc1, age_group: "IV", stage_id: s1.id, stage_time: today)
      insert_performance(cc2, age_group: "III", stage_id: s1.id, stage_time: today)
      insert_performance(cc2, age_group: "IV", stage_id: s1.id, stage_time: today)

      insert_performance(cc1,
        age_group: "III",
        stage_id: s1.id,
        stage_time: today,
        results_public: false
      )

      assert_ids_match_unordered(Showtime.list_performances(c, filter), [p])
    end

    test "preloads all necessary associations when passing a filter", %{contest: c} do
      insert_performance(c, age_group: "III", stage: build(:stage))
      filter = %PerformanceFilter{age_group: "III"}

      assert [
               %Performance{
                 contest_category: %ContestCategory{category: %Category{}},
                 appearances: [%Appearance{participant: %Participant{}}],
                 stage: %Stage{}
               }
             ] = Showtime.list_performances(c, filter)
    end

    test "returns matching performances from the contest when passing a list of ids", %{
      contest: c
    } do
      # Matching performances
      p1 = insert_performance(c)
      p2 = insert_performance(c)

      # Non-matching performances
      p3 = insert_performance(insert(:contest))
      insert_performance(c)

      assert_ids_match_unordered(Showtime.list_performances(c, [p3.id, p2.id, p1.id]), [p1, p2])
    end

    test "preloads all necessary associations when passing a list of ids", %{contest: c} do
      p = insert_performance(c, stage: build(:stage))

      assert [
               %Performance{
                 contest_category: %ContestCategory{category: %Category{}},
                 appearances: [%Appearance{participant: %Participant{}}],
                 stage: %Stage{}
               }
             ] = Showtime.list_performances(c, [p.id])
    end
  end

  describe "unscheduled_performance_count/1" do
    test "returns the amount of performances without a stage time in the contest", %{contest: c} do
      # Matching performances
      [cc1, cc2] = c.contest_categories
      insert_performance(cc1, stage_time: nil)
      insert_performance(cc2, stage_time: nil)

      # Non-matching performances
      insert_performance(cc1, stage_time: Timex.now())
      other_c = insert(:contest)
      insert_performance(other_c, stage_time: nil)

      assert Showtime.unscheduled_performance_count(c) == 2
    end
  end

  describe "unscheduled_performances/1" do
    test "returns all performances without a stage time from the contest", %{contest: c} do
      # Matching performances
      [cc1, cc2] = c.contest_categories
      p1 = insert_performance(cc1, stage_time: nil)
      p2 = insert_performance(cc2, stage_time: nil)

      # Non-matching performances
      insert_performance(cc1, stage_time: Timex.now())
      other_c = insert(:contest)
      insert_performance(other_c, stage_time: nil)

      assert_ids_match_unordered(Showtime.unscheduled_performances(c), [p1, p2])
    end

    test "preloads all necessary associations", %{contest: c} do
      insert_performance(c, appearances: build_list(1, :appearance))

      assert [
               %Performance{
                 contest_category: %ContestCategory{category: %Category{}},
                 appearances: [%Appearance{participant: %Participant{}}]
               }
             ] = Showtime.unscheduled_performances(c)
    end
  end

  describe "scheduled_performances/2" do
    test "returns the contest's scheduled performances that match the filter", %{contest: c} do
      [cc1, cc2] = c.contest_categories

      # Matching performances
      p1 = insert_scheduled_performance(cc1, age_group: "III")
      p2 = insert_scheduled_performance(cc2, age_group: "III")

      # Non-matching performances
      insert_scheduled_performance(cc1, age_group: "II")
      insert_performance(cc1, stage_time: nil)
      other_c = insert(:contest)
      insert_performance(other_c, stage_time: nil)

      filter = %PerformanceFilter{age_group: "III"}

      assert_ids_match_unordered(Showtime.scheduled_performances(c, filter), [p1, p2])
    end

    test "preloads all necessary associations", %{contest: c} do
      insert_scheduled_performance(c, appearances: build_list(1, :appearance))

      assert [
               %Performance{
                 contest_category: %ContestCategory{category: %Category{}},
                 appearances: [%Appearance{participant: %Participant{}}]
               }
             ] = Showtime.scheduled_performances(c, %PerformanceFilter{})
    end
  end

  describe "advancing_performances/1" do
    test "returns all performances from the contest that advance to the next round", %{contest: c} do
      [cc1, _] = c.contest_categories

      p =
        insert_performance(cc1,
          appearances: build_list(1, :appearance, role: "soloist", points: 23)
        )

      insert_performance(cc1, appearances: build_list(1, :appearance, role: "soloist", points: 22))

      assert_ids_match_unordered(Showtime.advancing_performances(c), [p])
    end

    test "preloads all necessary associations", %{contest: c} do
      insert_performance(c, appearances: build_list(1, :appearance, role: "soloist", points: 23))

      assert [
               %Performance{
                 contest_category: %ContestCategory{category: %Category{}},
                 appearances: [%Appearance{participant: %Participant{}}]
               }
             ] = Showtime.advancing_performances(c)
    end
  end

  describe "get_performance!/2" do
    test "gets a performance from the given contest by id", %{contest: c} do
      %{id: id} = insert_performance(c)
      assert %Performance{id: ^id} = Showtime.get_performance!(c, id)
    end

    test "raises an error if the performance isn't found in the given contest", %{contest: c} do
      %{id: id} = insert_performance(c)
      other_c = insert(:contest)

      assert_raise Ecto.NoResultsError, fn -> Showtime.get_performance!(other_c, id) end
    end

    test "preloads all associated data of the performance", %{contest: c} do
      %{id: id} = insert_performance(c)

      assert %Performance{
               contest_category: %ContestCategory{category: %Category{}},
               appearances: [%Appearance{participant: %Participant{}}],
               pieces: [%Piece{}]
             } = Showtime.get_performance!(c, id)
    end

    test "loads the performance's pieces in insertion order, earliest first", %{contest: c} do
      %{id: id} =
        insert_performance(c,
          pieces: [build(:piece, title: "Y"), build(:piece, title: "X")]
        )

      %{pieces: [pc1, pc2]} = Showtime.get_performance!(c, id)
      assert pc1.title == "Y"
      assert pc2.title == "X"
    end
  end

  describe "get_performance!/3" do
    test "gets a performance from the given contest by id and edit code", %{contest: c} do
      %{id: id, edit_code: edit_code} = insert_performance(c)
      assert %Performance{id: ^id} = Showtime.get_performance!(c, id, edit_code)
    end

    test "raises an error if the contest doesn't match", %{contest: c} do
      other_c = insert(:contest)
      %{id: id, edit_code: edit_code} = insert_performance(c)

      assert_raise Ecto.NoResultsError, fn ->
        Showtime.get_performance!(other_c, id, edit_code)
      end
    end

    test "raises an error if the edit code doesn't match", %{contest: c} do
      %{id: id} = insert_performance(c)

      assert_raise Ecto.NoResultsError, fn ->
        Showtime.get_performance!(c, id, "unknown")
      end
    end

    test "preloads all associated data of the performance", %{contest: c} do
      %{id: id, edit_code: edit_code} = insert_performance(c)

      assert %Performance{
               contest_category: %ContestCategory{category: %Category{}},
               appearances: [%Appearance{participant: %Participant{}}],
               pieces: [%Piece{}]
             } = Showtime.get_performance!(c, id, edit_code)
    end

    test "loads the performance's pieces in insertion order, earliest first", %{contest: c} do
      %{id: id, edit_code: edit_code} =
        insert_performance(c,
          pieces: [build(:piece, title: "Y"), build(:piece, title: "X")]
        )

      %{pieces: [pc1, pc2]} = Showtime.get_performance!(c, id, edit_code)
      assert pc1.title == "Y"
      assert pc2.title == "X"
    end
  end

  describe "get_public_performance/1" do
    test "gets a public performance by id" do
      c = insert(:contest, timetables_public: true)
      %{id: id} = insert_scheduled_performance(c)
      assert %Performance{id: ^id} = Showtime.get_public_performance(id)
    end

    test "returns nil for a scheduled performance in a non-public contest" do
      c = insert(:contest, timetables_public: false)
      %{id: id} = insert_scheduled_performance(c)
      assert Showtime.get_public_performance(id) == nil
    end

    test "returns nil for an unscheduled performance in a public contest" do
      c = insert(:contest, timetables_public: true)
      %{id: id} = insert_performance(c)
      assert Showtime.get_public_performance(id) == nil
    end

    test "returns nil for an unknown id" do
      assert Showtime.get_public_performance(123) == nil
    end

    test "preloads the correct associations" do
      c = insert(:contest, timetables_public: true)
      %{id: id} = insert_scheduled_performance(c)

      assert %Performance{
               contest_category: %ContestCategory{category: %Category{}},
               appearances: [%Appearance{participant: %Participant{}}],
               pieces: [%Piece{}]
             } = Showtime.get_public_performance(id)
    end

    test "preloads the pieces in insertion order, earliest first" do
      c = insert(:contest, timetables_public: true)
      now = Timex.now()

      %{id: id} =
        insert_scheduled_performance(c,
          pieces: [
            build(:piece, title: "A", inserted_at: now |> Timex.shift(seconds: 1)),
            build(:piece, title: "B", inserted_at: now |> Timex.shift(seconds: -1)),
            build(:piece, title: "C", inserted_at: now)
          ]
        )

      assert %{pieces: [%{title: "B"}, %{title: "C"}, %{title: "A"}]} =
               Showtime.get_public_performance(id)
    end
  end

  describe "lookup_performance/1" do
    test "gets a performance by its edit code", %{contest: c} do
      %{id: id, edit_code: edit_code} = insert_performance(c)
      assert {:ok, %Performance{id: ^id}} = Showtime.lookup_performance(edit_code)
    end

    test "preloads the performance's contest category and contest", %{contest: c} do
      %{edit_code: edit_code} = insert_performance(c)

      assert {:ok,
              %Performance{
                contest_category: %ContestCategory{contest: %Contest{}}
              }} = Showtime.lookup_performance(edit_code)
    end

    test "returns an error for an unknown edit code" do
      assert {:error, :not_found} = Showtime.lookup_performance("unknown")
    end
  end

  describe "lookup_performance!/2" do
    test "gets a performance from the given contest by edit code", %{contest: c} do
      %{id: id, edit_code: edit_code} = insert_performance(c)
      assert %Performance{id: ^id} = Showtime.lookup_performance!(c, edit_code)
    end

    test "raises an error if the performance isn't found in the given contest", %{contest: c} do
      other_c = insert(:contest)
      %{edit_code: edit_code} = insert_performance(c)

      assert_raise Ecto.NoResultsError, fn -> Showtime.lookup_performance!(other_c, edit_code) end
    end

    test "preloads all associated data of the performance", %{contest: c} do
      %{edit_code: edit_code} = insert_performance(c)

      assert %Performance{
               contest_category: %ContestCategory{category: %Category{}},
               appearances: [%Appearance{participant: %Participant{}}],
               pieces: [%Piece{}]
             } = Showtime.lookup_performance!(c, edit_code)
    end

    test "loads the performance's pieces in insertion order, earliest first", %{contest: c} do
      %{edit_code: edit_code} =
        insert_performance(c,
          pieces: [build(:piece, title: "Y"), build(:piece, title: "X")]
        )

      %{pieces: [pc1, pc2]} = Showtime.lookup_performance!(c, edit_code)
      assert pc1.title == "Y"
      assert pc2.title == "X"
    end
  end

  describe "build_performance/1" do
    test "builds a pre-populated performance for Kimu contests with one category" do
      c = insert(:contest, round: 0)
      %{id: cc_id} = insert_contest_category(c)

      assert %Performance{
               contest_category_id: ^cc_id,
               appearances: [%Appearance{}],
               pieces: [%Piece{}]
             } = Showtime.build_performance(c)
    end

    test "builds a bare performance for Kimu contests with multiple categories" do
      c = insert(:contest, round: 0)
      insert_list(2, :contest_category, contest: c)

      assert %Performance{
               contest_category_id: nil,
               appearances: %Ecto.Association.NotLoaded{},
               pieces: %Ecto.Association.NotLoaded{}
             } = Showtime.build_performance(c)
    end

    test "builds a bare performance for RW and LW contests" do
      for round <- [1, 2] do
        c = insert(:contest, round: round)

        assert %Performance{
                 contest_category_id: nil,
                 appearances: %Ecto.Association.NotLoaded{},
                 pieces: %Ecto.Association.NotLoaded{}
               } = Showtime.build_performance(c)
      end
    end
  end

  describe "create_performance/2" do
    test "creates a new performance with an edit code", %{contest: c} do
      [cc, _] = c.contest_categories

      attrs = performance_params(cc, [{"soloist", birthdate: ~D[2007-01-01]}])

      assert {:ok, %Performance{edit_code: edit_code}} = Showtime.create_performance(c, attrs)
      assert Regex.match?(~r/^[0-9]{6}$/, edit_code)
    end

    test "sets no edit code when the data is invalid", %{contest: c} do
      [cc, _] = c.contest_categories
      attrs = performance_params(cc, [])
      {:error, changeset} = Showtime.create_performance(c, attrs)

      assert Changeset.get_change(changeset, :edit_code) == nil
    end

    test "validates concept document when contest category requires one", %{contest: c} do
      cc = insert(:contest_category, contest: c, requires_concept_document: true)

      invalid_attrs = performance_params(cc, [{"soloist", birthdate: ~D[2007-01-01]}])
      valid_attrs = invalid_attrs |> Map.put(:concept_document_url, "foo")

      {:error, changeset} = Showtime.create_performance(c, invalid_attrs)

      assert %Changeset{
               errors: [concept_document_url: {"can't be blank", [validation: :required]}]
             } = changeset

      {:ok, _performance} = Showtime.create_performance(c, valid_attrs)
    end

    test "doesn’t validates concept document when contest category doesn’t require one",
         %{contest: c} do
      cc = insert(:contest_category, contest: c, requires_concept_document: false)

      attrs = performance_params(cc, [{"soloist", birthdate: ~D[2007-01-01]}])

      {:ok, _performance} = Showtime.create_performance(c, attrs)
    end

    test "assigns the earliest existing participant when full name and birthdate matches", %{
      contest: c
    } do
      [cc, _] = c.contest_categories

      insert(:participant, given_name: "Y", family_name: "X", birthdate: ~D[2001-01-01])
      insert(:participant, given_name: "X", family_name: "Y", birthdate: ~D[2001-01-01])
      insert(:participant, given_name: "X", family_name: "X", birthdate: ~D[2001-01-02])
      pt = insert(:participant, given_name: "X", family_name: "X", birthdate: ~D[2001-01-01])

      # Insert another (more recent) matching participant
      insert(:participant, given_name: "X", family_name: "X", birthdate: ~D[2001-01-01])

      attrs =
        performance_params(cc, [
          {"soloist", given_name: "X", family_name: "X", birthdate: ~D[2001-01-01]},
          {"accompanist", birthdate: ~D[2007-01-01]}
        ])

      {:ok, performance} = Showtime.create_performance(c, attrs)
      sol = get_soloist(performance)

      assert sol.participant.id == pt.id
      assert Repo.aggregate(Participant, :count, :id) == 6
    end

    test "updates the existing participant during assignment", %{contest: c} do
      [cc, _] = c.contest_categories

      matching_attrs = [given_name: "X", family_name: "X", birthdate: ~D[2001-01-01]]
      old_pt = insert(:participant, matching_attrs ++ [email: "old@example.org"])

      attrs =
        performance_params(cc, [
          {"soloist", matching_attrs ++ [email: "new@example.org"]}
        ])

      {:ok, performance} = Showtime.create_performance(c, attrs)
      %{participant: pt} = get_soloist(performance)

      assert pt.id == old_pt.id
      assert pt.email == "new@example.org"
    end

    test "assigns a joint age group based on non-accompanists", %{contest: c} do
      [cc, _] = c.contest_categories

      attrs =
        performance_params(cc, [
          {"ensemblist", birthdate: ~D[2006-12-31]},
          {"ensemblist", birthdate: ~D[2007-01-01]},
          # should not affect age group
          {"accompanist", birthdate: ~D[2000-01-01]}
        ])

      {:ok, performance} = Showtime.create_performance(c, attrs)

      assert performance.age_group == "III"
    end

    test "assigns correct age groups for a solo performance with separate accompanists", %{
      contest: c
    } do
      cc = insert(:contest_category, contest: c, groups_accompanists: false)

      attrs =
        performance_params(cc, [
          {"soloist", birthdate: ~D[2007-01-01]},
          {"accompanist", birthdate: ~D[2000-01-01]},
          {"accompanist", birthdate: ~D[2002-01-02]}
        ])

      {:ok, performance} = Showtime.create_performance(c, attrs)

      assert get_soloist(performance).age_group == "II"

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "VI"
      assert acc2.age_group == "V"
    end

    test "assigns correct age groups for an ensemble performance with separate accompanists", %{
      contest: c
    } do
      cc = insert(:contest_category, contest: c, groups_accompanists: false)

      attrs =
        performance_params(cc, [
          {"ensemblist", birthdate: ~D[2006-12-31]},
          {"ensemblist", birthdate: ~D[2007-01-01]},
          {"accompanist", birthdate: ~D[2000-01-01]},
          {"accompanist", birthdate: ~D[2002-01-02]}
        ])

      {:ok, performance} = Showtime.create_performance(c, attrs)

      for ens <- get_ensemblists(performance) do
        assert ens.age_group == "III"
      end

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "VI"
      assert acc2.age_group == "V"
    end

    test "assigns correct age groups for a solo performance with grouped accompanists", %{
      contest: c
    } do
      cc = insert(:contest_category, contest: c, groups_accompanists: true)

      attrs =
        performance_params(cc, [
          {"soloist", birthdate: ~D[2007-01-01]},
          {"accompanist", birthdate: ~D[2000-01-01]},
          {"accompanist", birthdate: ~D[2002-01-02]}
        ])

      {:ok, performance} = Showtime.create_performance(c, attrs)

      assert get_soloist(performance).age_group == "II"

      for acc <- get_accompanists(performance) do
        assert acc.age_group == "V"
      end
    end

    test "assigns correct age groups for an ensemble performance with grouped accompanists", %{
      contest: c
    } do
      cc = insert(:contest_category, contest: c, groups_accompanists: true)

      attrs =
        performance_params(cc, [
          {"ensemblist", birthdate: ~D[2006-12-31]},
          {"ensemblist", birthdate: ~D[2007-01-01]},
          {"accompanist", birthdate: ~D[2000-01-01]},
          {"accompanist", birthdate: ~D[2002-01-02]}
        ])

      {:ok, performance} = Showtime.create_performance(c, attrs)

      for ens <- get_ensemblists(performance) do
        assert ens.age_group == "III"
      end

      for acc <- get_accompanists(performance) do
        assert acc.age_group == "V"
      end
    end

    test "sets no age group when the data is invalid", %{contest: c} do
      [cc, _] = c.contest_categories
      attrs = performance_params(cc, [])
      {:error, changeset} = Showtime.create_performance(c, attrs)

      assert Changeset.get_change(changeset, :age_group) == nil
    end

    test "returns an error when passing no contest category id", %{contest: c} do
      assert {:error, _changeset} = Showtime.create_performance(c, %{contest_category_id: nil})
    end

    test "raises an error when the passed contest and attributes don't match", %{contest: c} do
      [cc, _] = c.contest_categories
      attrs = performance_params(cc, [{"soloist", birthdate: ~D[2007-01-01]}])
      other_c = insert(:contest)
      assert_raise Ecto.NoResultsError, fn -> Showtime.create_performance(other_c, attrs) end
    end
  end

  describe "update_performance/3" do
    test "allows updating of participants", %{contest: c} do
      [cc, _] = c.contest_categories

      old_p =
        insert_shorthand_performance(cc, [
          {"ensemblist", birthdate: ~D[2001-01-01]},
          {"ensemblist", birthdate: ~D[2002-01-01]},
          {"ensemblist", birthdate: ~D[2003-01-01]}
        ])

      attrs =
        performance_params(cc, [
          # Replace the second ensemblist and drop the third
          {"ensemblist", birthdate: ~D[2001-01-01]},
          {"ensemblist", birthdate: ~D[2002-01-02]}
        ])

      {:ok, %{id: id}} = Showtime.update_performance(c, old_p, attrs)
      # Force-reload before checking associations
      performance = Showtime.get_performance!(c, id)

      assert length(performance.appearances) == 2
    end

    test "doesn't allow changes that affect a participant's identity", %{contest: c} do
      [cc, _] = c.contest_categories

      old_p =
        insert_shorthand_performance(cc, [
          {"soloist", [given_name: "X", family_name: "X", birthdate: ~D[2001-01-01]]}
        ])

      old_sol = get_soloist(old_p)

      attrs =
        performance_params(cc, [
          {old_sol, "soloist", [given_name: "Y", family_name: "Y", birthdate: ~D[2001-01-02]]}
        ])

      {:error, changeset} = Showtime.update_performance(c, old_p, attrs)

      assert [
               %Changeset{
                 errors: [
                   participant:
                     {"To change the name or birthdate, please remove and add back this person.",
                      ''}
                 ]
               }
             ] = changeset.changes[:appearances]
    end

    test "allows changes that don't affect a participant's identity", %{contest: c} do
      [cc, _] = c.contest_categories

      matching_attrs = [given_name: "X", family_name: "X", birthdate: ~D[2001-01-01]]

      old_p =
        insert_shorthand_performance(cc, [
          {"soloist", matching_attrs ++ [phone: "123", email: "old@example.org"]}
        ])

      old_sol = get_soloist(old_p)

      attrs =
        performance_params(cc, [
          {old_sol, "soloist", matching_attrs ++ [phone: "456", email: "new@example.org"]}
        ])

      {:ok, performance} = Showtime.update_performance(c, old_p, attrs)
      %{participant: pt} = get_soloist(performance)

      assert pt.phone == "456"
      assert pt.email == "new@example.org"
    end

    test "assigns and updates the earliest existing participant when adding a matching one", %{
      contest: c
    } do
      [cc, _] = c.contest_categories

      matching_attrs = [given_name: "X", family_name: "X", birthdate: ~D[2001-01-01]]
      old_pt = insert(:participant, matching_attrs ++ [email: "old@example.org"])

      # Insert another (more recent) matching participant
      insert(:participant, matching_attrs)

      old_p =
        insert_shorthand_performance(cc, [
          {"soloist", birthdate: ~D[2001-01-02]}
        ])

      attrs =
        performance_params(cc, [
          {"soloist", birthdate: ~D[2001-01-02]},
          {"accompanist", matching_attrs ++ [email: "new@example.org"]}
        ])

      {:ok, performance} = Showtime.update_performance(c, old_p, attrs)
      [%{participant: pt}] = get_accompanists(performance)

      assert pt.id == old_pt.id
      assert pt.email == "new@example.org"
    end

    test "updates the age groups after modifying participants", %{contest: c} do
      [cc, _] = c.contest_categories

      old_p =
        insert_shorthand_performance(cc, [
          # These ensemblists together get AG IV
          {"ensemblist", birthdate: ~D[2007-01-01]},
          {"ensemblist", birthdate: ~D[2005-01-01]},
          {"ensemblist", birthdate: ~D[2003-01-01]}
        ])

      attrs =
        performance_params(cc, [
          # Replace two ensemblists and drop the third
          {"ensemblist", birthdate: ~D[2007-01-02]},
          {"ensemblist", birthdate: ~D[2006-12-31]}
        ])

      {:ok, %{id: id}} = Showtime.update_performance(c, old_p, attrs)
      # Force-reload before checking associations
      performance = Showtime.get_performance!(c, id)

      assert performance.age_group == "II"

      for ens <- get_ensemblists(performance) do
        assert ens.age_group == "II"
      end
    end

    test "updates age groups after switching the contest category", %{contest: c} do
      old_cc = insert(:contest_category, contest: c, groups_accompanists: false)

      appearances = [
        # AG II
        {"soloist", birthdate: ~D[2007-01-01]},
        # AG II
        {"accompanist", birthdate: ~D[2007-01-02]},
        # AG III
        {"accompanist", birthdate: ~D[2005-01-01]},
        # AG IV
        {"accompanist", birthdate: ~D[2003-01-01]}
      ]

      old_p = insert_shorthand_performance(old_cc, appearances)

      # In the new contest category, all accompanists share an age group
      cc = insert(:contest_category, contest: c, groups_accompanists: true)
      attrs = performance_params(cc, appearances)

      {:ok, performance} = Showtime.update_performance(c, old_p, attrs)

      assert performance.age_group == "II"
      assert get_soloist(performance).age_group == "II"

      for acc <- get_accompanists(performance) do
        assert acc.age_group == "III"
      end
    end

    test "allows updating of pieces", %{contest: c} do
      %{
        pieces: [old_pc1, old_pc2, old_pc3]
      } =
        old_p =
        insert_performance(c,
          pieces: [
            build(:piece, title: "A"),
            build(:piece, title: "B"),
            build(:piece, title: "C")
          ]
        )

      attrs = %{
        pieces: [
          params_for(:piece, title: "A changed") |> Map.put(:id, old_pc1.id),
          params_for(:piece, title: "B") |> Map.put(:id, old_pc2.id),
          params_for(:piece, title: "D")
        ]
      }

      {:ok, %{id: id}} = Showtime.update_performance(c, old_p, attrs)
      # Force-reload before checking associations
      performance = Showtime.get_performance!(c, id)
      %{pieces: [pc1, pc2, pc3]} = performance

      assert pc1.id == old_pc1.id
      assert pc1.title == "A changed"
      assert pc2.id == old_pc2.id
      assert pc2.title == "B"
      refute pc3.id == old_pc3.id
      assert pc3.title == "D"
    end

    test "doesn't allow updating performances that have results", %{contest: c} do
      p =
        insert_performance(c,
          appearances: [build(:appearance, points: nil), build(:appearance, points: 1)]
        )

      assert {:error, :has_results} = Showtime.update_performance(c, p, %{})
    end
  end

  describe "change_performance/1" do
    test "returns a performance changeset", %{contest: c} do
      performance = insert_performance(c)
      assert %Changeset{} = Showtime.change_performance(performance)
    end
  end

  describe "delete_performance!/1" do
    test "deletes a performance", %{contest: c} do
      performance = insert_performance(c)
      assert performance = Showtime.delete_performance!(performance)
      refute Repo.get(Performance, performance.id)
    end

    test "raises an error if the performance no longer exists", %{contest: c} do
      performance = insert_performance(c)
      Repo.delete(performance)

      assert_raise Ecto.StaleEntryError, fn ->
        Showtime.delete_performance!(performance)
      end
    end
  end

  describe "reschedule_performances/2" do
    test "updates performances according to the given data", %{contest: c} do
      st1 = ~N[2019-01-01T07:00:00]
      st2 = ~N[2019-01-02T07:00:00]

      [%{id: s1_id} = s1, %{id: s2_id} = s2] = insert_list(2, :stage)
      p1 = insert_performance(c, stage: nil, stage_time: nil)
      p2 = insert_performance(c, stage: s1, stage_time: st1)
      p3 = insert_performance(c, stage: s2, stage_time: st2)

      items = [
        %{id: p1.id, stage_id: s1.id, stage_time: st1},
        %{id: p2.id, stage_id: s2.id, stage_time: st2},
        %{id: p3.id, stage_id: nil, stage_time: nil}
      ]

      assert {:ok, stage_times} = Showtime.reschedule_performances(c, items)

      assert stage_times == [
               {p1.id, st1},
               {p2.id, st2},
               {p3.id, nil}
             ]

      assert %{stage_id: ^s1_id, stage_time: ^st1} = Repo.get(Performance, p1.id)
      assert %{stage_id: ^s2_id, stage_time: ^st2} = Repo.get(Performance, p2.id)
      assert %{stage_id: nil, stage_time: nil} = Repo.get(Performance, p3.id)
    end

    test "cancels the transaction with an error if any item has invalid data", %{contest: c} do
      stage_time = ~N[2019-01-01T07:00:00]

      %{id: s_id} = s = insert(:stage)
      %{id: p1_id} = p1 = insert_performance(c, stage: nil, stage_time: nil)
      p2 = insert_performance(c, stage: s, stage_time: stage_time)

      items = [
        %{id: p1.id, stage_id: s.id, stage_time: nil},
        %{id: p2.id, stage_id: nil, stage_time: nil}
      ]

      assert {:error, ^p1_id, %Changeset{} = cs} = Showtime.reschedule_performances(c, items)
      assert length(cs.errors) == 1
      assert %{stage_id: nil, stage_time: nil} = Repo.get(Performance, p1.id)
      assert %{stage_id: ^s_id, stage_time: ^stage_time} = Repo.get(Performance, p2.id)
    end
  end

  describe "publish_results/2" do
    test "publishes the results of all given performances from the contest", %{contest: c} do
      p1 = insert_performance(c, results_public: false)
      p2 = insert_performance(c, results_public: false)
      p3 = insert_performance(c, results_public: false)
      other_c = insert(:contest)
      p4 = insert_performance(other_c, results_public: false)

      assert {:ok, 2} = Showtime.publish_results(c, [p1.id, p2.id, p4.id])
      assert %{results_public: true} = Repo.get(Performance, p1.id)
      assert %{results_public: true} = Repo.get(Performance, p2.id)
      assert %{results_public: false} = Repo.get(Performance, p3.id)
      assert %{results_public: false} = Repo.get(Performance, p4.id)
    end
  end

  describe "unpublish_results/2" do
    test "unpublishes the results of all given performances from the contest", %{contest: c} do
      p1 = insert_performance(c, results_public: true)
      p2 = insert_performance(c, results_public: true)
      p3 = insert_performance(c, results_public: true)
      other_c = insert(:contest)
      p4 = insert_performance(other_c, results_public: true)

      assert {:ok, 2} = Showtime.unpublish_results(c, [p1.id, p2.id, p4.id])
      assert %{results_public: false} = Repo.get(Performance, p1.id)
      assert %{results_public: false} = Repo.get(Performance, p2.id)
      assert %{results_public: true} = Repo.get(Performance, p3.id)
      assert %{results_public: true} = Repo.get(Performance, p4.id)
    end
  end

  describe "migrate_performances/3" do
    setup do
      [
        rw: insert(:contest, season: 56, round: 1),
        lw: insert(:contest, season: 56, round: 2)
      ]
    end

    test "migrates the performances from an RW to a LW contest", %{rw: rw, lw: lw} do
      cg = insert(:category)
      rw_cc = insert(:contest_category, contest: rw, category: cg)
      lw_cc = insert(:contest_category, contest: lw, category: cg)

      p1 =
        insert_performance(rw_cc,
          edit_code: "100001",
          appearances: [
            build(:appearance, role: "soloist", points: 22),
            build(:appearance, role: "accompanist", points: 22)
          ],
          pieces: build_list(2, :piece),
          stage: build(:stage),
          stage_time: ~N[2019-01-01T09:00:00],
          results_public: true
        )

      assert {:ok, 1} = Showtime.migrate_performances(rw, [p1.id], lw)

      # Check fields of migrated performance
      assert [%Performance{} = p] = Showtime.list_performances(lw) |> Showtime.load_pieces()
      assert p.contest_category.id == lw_cc.id
      assert p.age_group == p1.age_group
      assert p.edit_code == "200001"
      assert p.stage == nil
      assert p.stage_time == nil
      refute p.results_public
      assert p.predecessor_id == p1.id
      assert p.predecessor_contest_id == rw.id
      assert p.predecessor_host_id == rw.host.id
      assert Enum.all?(p.appearances, &(&1.points == nil))
      assert_ids_match_ordered(participants(p.appearances), participants(p1.appearances))
      assert length(p.pieces) == length(p1.pieces)

      # Check that original performance is preserved
      reloaded_p1 = Showtime.get_performance!(rw, p1.id)
      assert_ids_match_ordered(reloaded_p1.appearances, p1.appearances)
      assert_ids_match_ordered(reloaded_p1.pieces, p1.pieces)
    end

    test "does not migrate performances without a target contest category", %{rw: rw, lw: lw} do
      [cg1, cg2] = insert_list(2, :category)
      rw_cc = insert(:contest_category, contest: rw, category: cg1)
      insert(:contest_category, contest: lw, category: cg2)

      p1 = insert_performance(rw_cc)
      assert {:ok, 0} = Showtime.migrate_performances(rw, [p1.id], lw)
      assert [] = Showtime.list_performances(lw)
    end

    test "does not migrate performances that already have a successor", %{rw: rw, lw: lw} do
      cg = insert(:category)
      rw_cc = insert(:contest_category, contest: rw, category: cg)
      lw_cc = insert(:contest_category, contest: lw, category: cg)

      p = insert_performance(rw_cc)
      insert_performance(lw_cc, predecessor: p)

      assert {:ok, 0} = Showtime.migrate_performances(rw, [p.id], lw)
    end

    test "does not migrate anything if the seasons or rounds mismatch", %{rw: rw} do
      c1 = insert(:contest, season: rw.season + 1, round: 2)
      c2 = insert(:contest, season: rw.season, round: 1)
      p = insert_performance(rw)
      assert :error = Showtime.migrate_performances(rw, [p.id], c1)
      assert :error = Showtime.migrate_performances(rw, [p.id], c2)
    end

    test "does not migrate performances not from the given RW contest", %{rw: rw, lw: lw} do
      other_c = insert(:contest, season: rw.season, round: 1)
      p = insert_performance(other_c)
      Showtime.migrate_performances(rw, [p.id], lw)
      assert [] = Showtime.list_performances(lw)
    end
  end

  describe "total_duration/1" do
    test "returns the total duration of a performance" do
      p =
        build(:performance,
          pieces: [
            build(:piece, minutes: 1, seconds: 59),
            build(:piece, minutes: 2, seconds: 34)
          ]
        )

      assert Showtime.total_duration(p) == Timex.Duration.from_clock({0, 4, 33, 0})
    end
  end

  describe "result_completions/1" do
    test "returns result completion data for the given performances" do
      c = insert(:contest)
      separate_acc_cc = insert(:contest_category, contest: c, groups_accompanists: false)
      grouped_acc_cc = insert(:contest_category, contest: c, groups_accompanists: true)

      performances = [
        insert_performance(separate_acc_cc,
          appearances: [
            build(:appearance, role: "soloist", points: 25),
            build(:appearance, role: "accompanist", points: nil),
            build(:appearance, role: "accompanist", points: 25)
          ],
          results_public: false
        ),
        insert_performance(grouped_acc_cc,
          appearances: [
            build(:appearance, role: "ensemblist", points: 25),
            build(:appearance, role: "ensemblist", points: 25),
            build(:appearance, role: "accompanist", points: nil),
            build(:appearance, role: "accompanist", points: nil)
          ],
          results_public: true
        )
      ]

      assert Showtime.result_completions(performances) ==
               %{total: 5, with_points: 3, public: 2}
    end
  end

  describe "statistics/2" do
    test "returns stats for a list of Kimu performances" do
      c = insert(:contest, round: 0)
      pt = insert(:participant)

      p1 =
        insert_performance(c,
          appearances: [
            build(:appearance, role: "ensemblist", participant: pt),
            build(:appearance, role: "ensemblist"),
            build(:appearance, role: "accompanist")
          ]
        )

      p2 =
        insert_performance(c,
          appearances: [
            build(:appearance, role: "soloist", participant: pt),
            build(:appearance, role: "accompanist")
          ]
        )

      assert Showtime.statistics([p1, p2], c.round) ==
               %{appearances: 5, participants: 4, performances: %{total: 2}}
    end

    test "returns stats for an empty Kimu performance list" do
      assert Showtime.statistics([], 0) ==
               %{appearances: 0, participants: 0, performances: %{total: 0}}
    end

    test "returns stats for a list of Jumu performances" do
      c = insert(:contest, round: 1)
      pt = insert(:participant)
      cc1 = insert_contest_category(c, "classical")
      cc2 = insert_contest_category(c, "popular")

      p1 =
        insert_performance(cc1,
          appearances: [
            build(:appearance, role: "ensemblist", participant: pt),
            build(:appearance, role: "ensemblist"),
            build(:appearance, role: "accompanist")
          ]
        )

      p2 =
        insert_performance(cc2,
          appearances: [
            build(:appearance, role: "soloist", participant: pt),
            build(:appearance, role: "accompanist")
          ]
        )

      assert Showtime.statistics([p1, p2], c.round) == %{
               appearances: 5,
               participants: 4,
               performances: %{total: 2, classical: 1, popular: 1}
             }
    end

    test "returns stats for an empty Jumu performance list" do
      assert Showtime.statistics([], 1) == %{
               appearances: 0,
               participants: 0,
               performances: %{total: 0, classical: 0, popular: 0}
             }
    end
  end

  test "load_pieces/1 preloads each performance's pieces in insertion order", %{contest: c} do
    insert_performance(c, pieces: [build(:piece, title: "Y"), build(:piece, title: "X")])
    performance = Repo.one(Performance)

    assert [%{pieces: [%Piece{title: "Y"}, %Piece{title: "X"}]}] =
             Showtime.load_pieces([performance])
  end

  describe "load_successors/1" do
    test "preloads each performance's successor", %{contest: c} do
      p = insert_performance(c)
      lw = insert(:contest, round: 2)
      insert_performance(lw, predecessor: p)

      assert [%Performance{successor: %Performance{}}] = Showtime.load_successors([p])
    end
  end

  describe "load_predecessor_host/1" do
    test "preloads the performance's predecessor host", %{contest: rw} do
      lw = insert(:contest, round: 2)
      insert_performance(lw, predecessor_host: rw.host)
      performance = Repo.one(Performance)

      assert %{predecessor_host: %Host{}} = Showtime.load_predecessor_host(performance)
    end
  end

  describe "load_predecessor_hosts/1" do
    test "preloads each performance's predecessor host", %{contest: rw} do
      lw = insert(:contest, round: 2)
      insert_performance(lw, predecessor_host: rw.host)
      performance = Repo.one(Performance)

      assert [%{predecessor_host: %Host{}}] = Showtime.load_predecessor_hosts([performance])
    end
  end

  test "load_contest_category/1 fully preloads a performance's contest category", %{contest: c} do
    insert_performance(c)
    performance = Repo.one(Performance)

    assert %{
             contest_category: %{contest: %Contest{}, category: %Category{}}
           } = performance |> Showtime.load_contest_category()
  end

  describe "list_participants/1" do
    test "lists only the contest's participants, ordered by name", %{contest: c} do
      pt1 = insert(:participant, family_name: "C")
      pt2 = insert(:participant, family_name: "A", given_name: "B")
      pt3 = insert(:participant, family_name: "A", given_name: "A")
      pt4 = insert(:participant, family_name: "B")
      a1 = build(:appearance, role: "soloist", participant: pt1)
      a2 = build(:appearance, role: "accompanist", participant: pt2)
      a3 = build(:appearance, role: "accompanist", participant: pt3)
      a4 = build(:appearance, role: "soloist", participant: pt4)
      insert_performance(c, appearances: [a1, a2, a3])
      insert_performance(c, appearances: [a4])

      other_c = insert(:contest)
      insert_performance(other_c, appearances: build_list(2, :appearance))

      assert_ids_match_ordered(Showtime.list_participants(c), [pt3, pt2, pt4, pt1])
    end

    test "preloads the necessary associations within an RW contest", %{contest: rw} do
      insert_participant(rw)

      assert [%Participant{performances: [performance]}] = Showtime.list_participants(rw)

      assert %Performance{
               contest_category: %ContestCategory{
                 category: %Category{}
               },
               predecessor_host: nil
             } = performance
    end

    test "preloads the necessary associations within an LW contest", %{contest: rw} do
      lw = insert(:contest, round: 2)
      insert_performance(lw, predecessor_host: rw.host)

      assert [%Participant{performances: [performance]}] = Showtime.list_participants(lw)

      assert %Performance{
               contest_category: %ContestCategory{
                 category: %Category{}
               },
               predecessor_host: %Host{}
             } = performance
    end
  end

  describe "list_orphaned_participants/0" do
    test "returns all participants without appearances, in order of last update", %{contest: c} do
      now = Timex.now()
      # Matching participants
      pt1 = insert(:participant, updated_at: now)
      pt2 = insert(:participant, updated_at: Timex.shift(now, seconds: -1))

      # Non-matching participants
      [pt3, pt4] = insert_list(2, :participant)
      insert_appearance(c, participant: pt3)
      insert_appearance(c, participant: pt4)
      other_c = insert(:contest, round: 2)
      insert_appearance(other_c, participant: pt4)

      assert_ids_match_ordered(Showtime.list_orphaned_participants(), [pt2, pt1])
    end
  end

  describe "delete_orphaned_participants/0" do
    test "deletes all participants without appearances", %{contest: c} do
      [pt1, pt2, pt3] = insert_list(3, :participant)
      insert_appearance(c, participant: pt2)

      Showtime.delete_orphaned_participants()
      refute Repo.get(Participant, pt1.id)
      assert Repo.get(Participant, pt2.id)
      refute Repo.get(Participant, pt3.id)
    end
  end

  describe "list_duplicate_participants/1" do
    test "only finds duplicates for participants of the given contest", %{contest: c} do
      pt1 = insert(:participant, given_name: "A", family_name: "B")
      pt2 = insert_participant(c, given_name: "A", family_name: "B")
      insert(:participant, given_name: "C", family_name: "D")
      insert(:participant, given_name: "C", family_name: "D")

      assert_tuple_ids_match_ordered(
        Showtime.list_duplicate_participants(c),
        [{pt2, pt1}]
      )
    end

    test "only finds duplicates that were created before the participant", %{contest: c} do
      pt1 = insert(:participant, given_name: "A", family_name: "B")
      pt2 = insert_participant(c, given_name: "A", family_name: "B")
      insert(:participant, given_name: "A", family_name: "B")

      assert_tuple_ids_match_ordered(
        Showtime.list_duplicate_participants(c),
        [{pt2, pt1}]
      )
    end

    test "returns participant pairs with the same name", %{contest: c} do
      pt1 = insert(:participant, given_name: "X", family_name: "Y")
      pt2 = insert_participant(c, given_name: "X", family_name: "Y")

      assert_tuple_ids_match_ordered(
        Showtime.list_duplicate_participants(c),
        [{pt2, pt1}]
      )
    end

    test "returns participant pairs whose names differ only by diacritics", %{contest: c} do
      pt1 = insert(:participant, given_name: "Frøya", family_name: "Åsnæs")
      pt2 = insert_participant(c, given_name: "Froya", family_name: "Asnaes")
      pt3 = insert(:participant, given_name: "Jánoš", family_name: "Bečvář")
      pt4 = insert_participant(c, given_name: "Janos", family_name: "Becvar")

      assert_tuple_ids_match_ordered(
        Showtime.list_duplicate_participants(c),
        [{pt2, pt1}, {pt4, pt3}]
      )
    end

    test "returns participant pairs with similar given and family names", %{contest: c} do
      pt1 = insert(:participant, given_name: "Anna Belle", family_name: "Dyson-Cho")
      pt2 = insert(:participant, given_name: "Marianna", family_name: "Cho Dyson")
      pt3 = insert_participant(c, given_name: "Anna", family_name: "Cho")

      assert_tuple_ids_match_ordered(
        Showtime.list_duplicate_participants(c),
        [{pt3, pt1}, {pt3, pt2}]
      )
    end

    test "orders the pairs by the first participant's given name", %{contest: c} do
      pt1 = insert(:participant, given_name: "ABC", family_name: "BAC")
      pt2 = insert_participant(c, given_name: "C", family_name: "A")
      pt3 = insert_participant(c, given_name: "A", family_name: "B")
      pt4 = insert_participant(c, given_name: "B", family_name: "C")

      assert_tuple_ids_match_ordered(
        Showtime.list_duplicate_participants(c),
        [{pt3, pt1}, {pt4, pt1}, {pt2, pt1}]
      )
    end
  end

  describe "list_appearances/2" do
    test "returns the appearances with the given ids from the contest", %{contest: c} do
      a1 = insert_appearance(c)
      a2 = insert_appearance(c)
      other_c = insert(:contest)
      a3 = insert_appearance(other_c)

      assert_ids_match_unordered(Showtime.list_appearances(c, [a1.id, a2.id, a3.id]), [a1, a2])
    end
  end

  describe "set_points/2" do
    setup %{contest: c} do
      a1 = insert_appearance(c)
      a2 = insert_appearance(c)
      [appearances: [a1, a2]]
    end

    test "assigns the given points to the appearances", %{appearances: appearances} do
      assert :ok = Showtime.set_points(appearances, 25)
    end

    test "returns an error for invalid points", %{appearances: appearances} do
      assert :error = Showtime.set_points(appearances, 26)
    end
  end

  describe "get_participant!/1" do
    test "gets a participant by id", %{contest: c} do
      %{id: id} = insert_participant(c)
      assert %Participant{id: ^id} = Showtime.get_participant!(id)
    end

    test "preloads the participant's performances with contests, ordered by contest start date" do
      %{id: c1_id} = c1 = insert(:contest, start_date: ~D[2019-01-02])
      %{id: c2_id} = c2 = insert(:contest, start_date: ~D[2019-01-01])

      pt = insert_participant(c1)
      insert_appearance(c2, participant: pt)

      pt = Repo.get(Participant, pt.id)

      assert %Participant{
               performances: [
                 %Performance{
                   contest_category: %ContestCategory{contest: %Contest{id: ^c2_id}}
                 },
                 %Performance{
                   contest_category: %ContestCategory{contest: %Contest{id: ^c1_id}}
                 }
               ]
             } = Showtime.get_participant!(pt.id)
    end

    test "raises an error if the participant isn't found" do
      assert_raise Ecto.NoResultsError, fn -> Showtime.get_participant!(123) end
    end
  end

  describe "get_participant!/2" do
    test "gets a participant from the given contest by id", %{contest: c} do
      %{id: id} = insert_participant(c)
      assert %Participant{id: ^id} = Showtime.get_participant!(c, id)
    end

    test "gets a participant that has multiple appearances", %{contest: c} do
      %{id: id} = pt = insert_participant(c)
      insert_performance(c, appearances: [build(:appearance, participant: pt)])

      assert %Participant{id: ^id} = Showtime.get_participant!(c, id)
    end

    test "raises an error if the participant isn't found in the given contest", %{contest: c} do
      %{id: id} = insert_participant(c)
      other_c = insert(:contest)

      assert_raise Ecto.NoResultsError, fn -> Showtime.get_participant!(other_c, id) end
    end
  end

  describe "change_participant/1" do
    test "returns a participant changeset", %{contest: c} do
      participant = insert_participant(c)
      assert %Changeset{} = Showtime.change_participant(participant)
    end
  end

  describe "update_participant/1" do
    test "updates a participant with valid data" do
      participant = insert(:participant, given_name: "A")
      assert {:ok, result} = Showtime.update_participant(participant, %{given_name: "B"})
      assert result.given_name == "B"
    end

    test "returns an error changeset for invalid data" do
      participant = insert(:participant)

      assert {:error, %Ecto.Changeset{}} =
               Showtime.update_participant(participant, %{given_name: nil})
    end
  end

  describe "merge_participants/3" do
    test "replaces the first by the second participant across contests", %{contest: c} do
      other_c = insert(:contest, round: 2)

      %{participant: pt1} = pt1_a1 = insert_appearance(c)
      pt1_a2 = insert_appearance(c, participant: pt1)
      pt1_a3 = insert_appearance(other_c, participant: pt1)

      %{participant: pt2} = pt2_a1 = insert_appearance(c)
      pt2_a2 = insert_appearance(c, participant: pt2)
      pt2_a3 = insert_appearance(other_c, participant: pt2)

      assert :ok = Showtime.merge_participants(pt1.id, pt2.id, [])
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(Participant, pt1.id) end

      for a <- [pt1_a1, pt1_a2, pt1_a3, pt2_a1, pt2_a2, pt2_a3] do
        a = Repo.get!(Appearance, a.id) |> Repo.preload(:participant)
        assert a.participant.id == pt2.id
      end
    end

    test "merges the given fields' values into the target participant", %{contest: c} do
      pt1 =
        insert_participant(c,
          given_name: "G1",
          family_name: "F1",
          birthdate: ~D[2000-01-01],
          phone: "1",
          email: "1@example.org"
        )

      pt2 =
        insert_participant(c,
          given_name: "G2",
          family_name: "F2",
          birthdate: ~D[2000-01-02],
          phone: "2",
          email: "2@example.org"
        )

      assert :ok = Showtime.merge_participants(pt1.id, pt2.id, [:given_name, :birthdate, :email])
      pt2 = Repo.get!(Participant, pt2.id)
      # Check that listed fields were replaced
      assert pt2.given_name == pt1.given_name
      assert pt2.birthdate == pt1.birthdate
      assert pt2.email == pt1.email
      # Check that non-listed fields were not replaced
      assert pt2.family_name == pt2.family_name
      assert pt2.phone == pt2.phone
    end

    test "ignores invalid field names", %{contest: c} do
      pt1 = insert_participant(c, given_name: "G1")
      pt2 = insert_participant(c, given_name: "G2")

      assert :ok = Showtime.merge_participants(pt1.id, pt2.id, [:given_name, :unknown])
      pt2 = Repo.get!(Participant, pt2.id)
      assert pt2.given_name == pt1.given_name
    end

    test "recalculates affected age groups during merge", %{contest: c} do
      pt1 = insert(:participant, birthdate: ~D[2006-12-31])
      pt2 = insert(:participant, birthdate: ~D[2007-01-01])

      p1 =
        insert_performance(c,
          age_group: "III",
          appearances: [build(:appearance, age_group: "III", participant: pt1)]
        )

      p2 =
        insert_performance(c,
          age_group: "II",
          appearances: [build(:appearance, age_group: "II", participant: pt2)]
        )

      assert :ok = Showtime.merge_participants(pt1.id, pt2.id, [:birthdate])

      %{appearances: [a1]} = p1 = Repo.get!(Performance, p1.id) |> Repo.preload(:appearances)
      %{appearances: [a2]} = p2 = Repo.get!(Performance, p2.id) |> Repo.preload(:appearances)
      assert p1.age_group == "III"
      assert a1.age_group == "III"
      assert p2.age_group == "III"
      assert a2.age_group == "III"
    end
  end

  describe "handle_category_specific_fields/3" do
    test "casts and validates concept document URL if contest category in data requires it", %{
      contest: c
    } do
      cc = insert(:contest_category, contest: c, requires_concept_document: true)

      appearances = [{"soloist", birthdate: ~D[2001-01-02]}]
      p = insert_shorthand_performance(cc, appearances)
      changeset = Showtime.change_performance(p)

      invalid_attrs = performance_params(cc, appearances)

      assert %Changeset{
               valid?: false,
               errors: [concept_document_url: {"can't be blank", [validation: :required]}]
             } = Showtime.handle_category_specific_fields(changeset, c, invalid_attrs)

      valid_attrs = Map.put(invalid_attrs, :concept_document_url, "#")

      assert %Changeset{valid?: true} =
               Showtime.handle_category_specific_fields(changeset, c, valid_attrs)
    end

    test "casts and validates concept document URL if contest category in changes requires it", %{
      contest: c
    } do
      cc1 = insert(:contest_category, contest: c, requires_concept_document: false)

      appearances = [{"soloist", birthdate: ~D[2001-01-02]}]
      p = insert_shorthand_performance(cc1, appearances)

      cc2 = insert(:contest_category, contest: c, requires_concept_document: true)

      invalid_attrs = performance_params(cc2, appearances)
      changeset = Performance.changeset(p, invalid_attrs, c.round)

      assert %Changeset{
               valid?: false,
               errors: [concept_document_url: {"can't be blank", [validation: :required]}]
             } = Showtime.handle_category_specific_fields(changeset, c, invalid_attrs)

      valid_attrs = Map.put(invalid_attrs, :concept_document_url, "#")

      assert %Changeset{valid?: true} =
               Showtime.handle_category_specific_fields(changeset, c, valid_attrs)
    end

    test "clears concept document URL if contest category doesn’t require one", %{contest: c} do
      cc1 = insert(:contest_category, contest: c, requires_concept_document: true)
      cc2 = insert(:contest_category, contest: c, requires_concept_document: false)
      appearances = [{"soloist", birthdate: ~D[2001-01-02]}]

      initial_attrs =
        performance_params(cc1, appearances)
        |> Map.put(:concept_document_url, "#")

      {:ok, p} = Showtime.create_performance(c, initial_attrs)

      assert p.concept_document_url

      updated_attrs =
        performance_params(cc2, appearances)
        |> Map.put(:concept_document_url, "#")

      changeset = Performance.changeset(p, updated_attrs, c.round)

      assert %Changeset{changes: %{concept_document_url: nil}} =
               Showtime.handle_category_specific_fields(changeset, c, updated_attrs)
    end

    test "does nothing if no contest category is present in data or changes", %{contest: c} do
      attrs = %{}
      changeset = Performance.changeset(%Performance{}, attrs, c.round)
      assert changeset == Showtime.handle_category_specific_fields(changeset, c, attrs)
    end
  end

  # Private helpers

  # Returns insertion params for a performance.
  defp performance_params(cc, appearance_shorthands) do
    %{
      contest_category_id: cc.id,
      appearances:
        Enum.map(appearance_shorthands, fn
          {role, participant_attrs} ->
            appearance_params(role, participant_attrs)

          {existing_appearance, role, participant_attrs} ->
            appearance_params(existing_appearance, role, participant_attrs)
        end),
      pieces: [params_for(:piece)]
    }
  end

  # Returns insertion params for an appearance.
  defp appearance_params(role, participant_attrs) do
    %{
      role: role,
      instrument: "vocals",
      participant: params_for(:participant, participant_attrs)
    }
  end

  defp appearance_params(existing_appearance, role, participant_attrs) do
    %{id: id, participant: %{id: participant_id}} = existing_appearance

    %{
      id: id,
      role: role,
      instrument: "vocals",
      participant:
        params_for(:participant, participant_attrs)
        |> Map.put(:id, participant_id)
    }
  end

  # Inserts a performance using the given appearance shorthands.
  defp insert_shorthand_performance(%ContestCategory{} = cc, appearance_shorthands) do
    insert_performance(cc,
      appearances: Enum.map(appearance_shorthands, &build_appearance/1)
    )
  end

  defp build_appearance({role, participant_attrs}) do
    build(:appearance,
      role: role,
      participant: build(:participant, participant_attrs)
    )
  end

  defp get_soloist(%Performance{appearances: appearances}) do
    Enum.find(appearances, &Appearance.soloist?/1)
  end

  defp get_ensemblists(%Performance{appearances: appearances}) do
    Enum.filter(appearances, &Appearance.ensemblist?/1)
  end

  defp get_accompanists(%Performance{appearances: appearances}) do
    Enum.filter(appearances, &Appearance.accompanist?/1)
  end

  defp participants(appearances) do
    appearances |> Enum.map(& &1.participant)
  end
end
