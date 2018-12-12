defmodule Jumubase.ShowtimeTest do
  use Jumubase.DataCase
  alias Ecto.Changeset
  alias Jumubase.Foundation.{Category, Contest, ContestCategory}
  alias Jumubase.Showtime
  alias Jumubase.Showtime.{Appearance, Participant, Performance, Piece}
  alias Jumubase.Showtime.PerformanceFilter

  @season 56 # important for age group matching in tests

  setup do
    [contest: insert(:contest, season: @season) |> with_contest_categories]
  end

  describe "list_performances/1" do
    test "returns the given contest's performances", %{contest: c} do
      # Performances in this contest
      [cc1, cc2] = c.contest_categories
      p1 = insert_performance(cc1)
      p2 = insert_performance(cc1)
      p3 = insert_performance(cc2)

      # Performance in other contest
      other_c = insert(:contest)
      insert_performance(other_c)

      assert_ids_match_unordered Showtime.list_performances(c), [p1, p2, p3]
    end

    test "preloads the performances' contest categories, categories, appearances and participants", %{contest: c} do
      insert_performance(c, appearances: build_list(1, :appearance))

      assert [%Performance{
        contest_category: %ContestCategory{category: %Category{}},
        appearances: [
          %Appearance{participant: %Participant{}}
        ]
      }] = Showtime.list_performances(c)
    end
  end

  describe "list_performances/2" do
    test "returns all matching performances from the given contest", %{contest: c} do
      [cc1, cc2] = c.contest_categories
      today = ~N[2019-01-01T23:59:59Z]
      tomorrow = ~N[2019-01-02T00:00:00Z]

      [s1, s2] = insert_list(2, :stage, host: c.host)

      filter = %PerformanceFilter{
        stage_date: ~D[2019-01-01],
        stage_id: s1.id,
        contest_category_id: cc1.id,
        age_group: "III"
      }

      # Matching performance
      p = insert_performance(cc1, age_group: "III", stage_id: s1.id, stage_time: today)

      # Non-matching performances
      insert_performance(cc1, age_group: "III", stage_id: s2.id, stage_time: today)
      insert_performance(cc1, age_group: "III", stage_id: s1.id, stage_time: nil)
      insert_performance(cc1, age_group: "III", stage_id: s1.id, stage_time: tomorrow)
      insert_performance(cc1, age_group: "IV", stage_id: s1.id, stage_time: today)
      insert_performance(cc2, age_group: "III", stage_id: s1.id, stage_time: today)
      insert_performance(cc2, age_group: "IV", stage_id: s1.id, stage_time: today)

      assert_ids_match_unordered Showtime.list_performances(c, filter), [p]
    end
  end

  describe "unscheduled_performances/1" do
    test "returns all performances without a stage time from the contest", %{contest: c} do
      # Matching performances
      [cc1, cc2] = c.contest_categories
      p1 = insert_performance(cc1, stage_time: nil)
      p2 = insert_performance(cc2, stage_time: nil)

      # Non-matching performances
      insert_performance(cc1, stage_time: Timex.now)
      other_c = insert(:contest)
      insert_performance(other_c, stage_time: nil)

      assert_ids_match_unordered Showtime.unscheduled_performances(c), [p1, p2]
    end

    test "preloads the performances' contest categories, categories, appearances and participants", %{contest: c} do
      insert_performance(c, appearances: build_list(1, :appearance))

      assert [%Performance{
        contest_category: %ContestCategory{category: %Category{}},
        appearances: [
          %Appearance{participant: %Participant{}}
        ]
      }] = Showtime.unscheduled_performances(c)
    end
  end

  describe "get_performance!/2" do
    test "gets a performance from the given contest by id", %{contest: c} do
      %{id: id} = insert_performance(c)

      result = Showtime.get_performance!(c, id)
      assert result.id == id
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
      %{id: id} = insert_performance(c,
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

      result = Showtime.get_performance!(c, id, edit_code)
      assert result.id == id
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
      %{id: id, edit_code: edit_code} = insert_performance(c,
        pieces: [build(:piece, title: "Y"), build(:piece, title: "X")]
      )

      %{pieces: [pc1, pc2]} = Showtime.get_performance!(c, id, edit_code)
      assert pc1.title == "Y"
      assert pc2.title == "X"
    end
  end

  describe "lookup_performance/1" do
    test "gets a performance by its edit code", %{contest: c} do
      %{id: id, edit_code: edit_code} = insert_performance(c)

      assert {:ok, result} = Showtime.lookup_performance(edit_code)
      assert result.id == id
    end

    test "preloads the performance's contest category and contest", %{contest: c} do
      %{edit_code: edit_code} = insert_performance(c)

      assert {:ok, %Performance{
        contest_category: %ContestCategory{contest: %Contest{}},
      }} = Showtime.lookup_performance(edit_code)
    end

    test "returns an error for an unknown edit code" do
      assert {:error, :not_found} = Showtime.lookup_performance("unknown")
    end
  end

  describe "lookup_performance!/2" do
    test "gets a performance from the given contest by edit code", %{contest: c} do
      %{id: id, edit_code: edit_code} = insert_performance(c)

      result = Showtime.lookup_performance!(c, edit_code)
      assert result.id == id
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
      %{edit_code: edit_code} = insert_performance(c,
        pieces: [build(:piece, title: "Y"), build(:piece, title: "X")]
      )

      %{pieces: [pc1, pc2]} = Showtime.lookup_performance!(c, edit_code)
      assert pc1.title == "Y"
      assert pc2.title == "X"
    end
  end

  describe "create_performance/2" do
    test "creates a new performance with an edit code", %{contest: c} do
      [cc, _] = c.contest_categories
      attrs = performance_params(cc, [
        {"soloist", birthdate: ~D[2007-01-01]},
      ])

      assert {:ok, %Performance{edit_code: edit_code}} = Showtime.create_performance(c, attrs)
      assert Regex.match?(~r/^[0-9]{6}$/, edit_code)
    end

    test "sets no edit code when the data is invalid", %{contest: c} do
      [cc, _] = c.contest_categories
      attrs = performance_params(cc, [])
      {:error, changeset} = Showtime.create_performance(c, attrs)

      assert Changeset.get_change(changeset, :edit_code) == nil
    end

    test "assigns existing participant when name and birthdate matches", %{contest: c} do
      [cc, _] = c.contest_categories

      insert(:participant, given_name: "Y", family_name: "X", birthdate: ~D[2001-01-01])
      insert(:participant, given_name: "X", family_name: "Y", birthdate: ~D[2001-01-01])
      insert(:participant, given_name: "X", family_name: "X", birthdate: ~D[2001-01-02])
      pt = insert(:participant, given_name: "X", family_name: "X", birthdate: ~D[2001-01-01])

      attrs = performance_params(cc, [
        {"soloist", given_name: "X", family_name: "X", birthdate: ~D[2001-01-01]},
        {"accompanist", birthdate: ~D[2007-01-01]},
      ])

      {:ok, performance} = Showtime.create_performance(c, attrs)
      sol = get_soloist(performance)

      assert sol.participant.id == pt.id
      assert Repo.aggregate(Participant, :count, :id) == 5
    end

    test "updates the existing participant during assignment", %{contest: c} do
      [cc, _] = c.contest_categories

      matching_attrs = [given_name: "X", family_name: "X", birthdate: ~D[2001-01-01]]
      old_pt = insert(:participant, matching_attrs ++ [email: "old@example.org"])

      attrs = performance_params(cc, [
        {"soloist", matching_attrs ++ [email: "new@example.org"]}
      ])

      {:ok, performance} = Showtime.create_performance(c, attrs)
      %{participant: pt} = get_soloist(performance)

      assert pt.id == old_pt.id
      assert pt.email == "new@example.org"
    end

    test "assigns a joint age group based on non-accompanists", %{contest: c} do
      [cc, _] = c.contest_categories
      attrs = performance_params(cc, [
        {"ensemblist", birthdate: ~D[2006-12-31]},
        {"ensemblist", birthdate: ~D[2007-01-01]},
        {"accompanist", birthdate: ~D[2000-01-01]} # should not affect age group
      ])
      {:ok, performance} = Showtime.create_performance(c, attrs)

      assert performance.age_group == "III"
    end

    test "assigns the correct age groups for a classical solo performance", %{contest: c} do
      cc = insert_contest_category(c, "classical")
      attrs = performance_params(cc, [
        {"soloist", birthdate: ~D[2007-01-01]},
        {"accompanist", birthdate: ~D[2000-01-01]},
        {"accompanist", birthdate: ~D[2002-01-02]},
      ])
      {:ok, performance} = Showtime.create_performance(c, attrs)

      assert get_soloist(performance).age_group == "II"

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "VI"
      assert acc2.age_group == "V"
    end

    test "assigns the correct age groups for a classical ensemble performance", %{contest: c} do
      cc = insert_contest_category(c, "classical")
      attrs = performance_params(cc, [
        {"ensemblist", birthdate: ~D[2006-12-31]},
        {"ensemblist", birthdate: ~D[2007-01-01]},
        {"accompanist", birthdate: ~D[2000-01-01]},
        {"accompanist", birthdate: ~D[2002-01-02]},
      ])
      {:ok, performance} = Showtime.create_performance(c, attrs)

      for ens <- get_ensemblists(performance) do
        assert ens.age_group == "III"
      end

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "VI"
      assert acc2.age_group == "V"
    end

    test "assigns the correct age groups for a pop solo performance", %{contest: c} do
      cc = insert_contest_category(c, "popular")
      attrs = performance_params(cc, [
        {"soloist", birthdate: ~D[2007-01-01]},
        {"accompanist", birthdate: ~D[2000-01-01]},
        {"accompanist", birthdate: ~D[2002-01-02]},
      ])
      {:ok, performance} = Showtime.create_performance(c, attrs)

      assert get_soloist(performance).age_group == "II"

      for acc <- get_accompanists(performance) do
        assert acc.age_group == "V"
      end
    end

    test "assigns the correct age groups for a pop ensemble performance", %{contest: c} do
      cc = insert_contest_category(c, "popular")
      attrs = performance_params(cc, [
        {"ensemblist", birthdate: ~D[2006-12-31]},
        {"ensemblist", birthdate: ~D[2007-01-01]},
        {"accompanist", birthdate: ~D[2000-01-01]},
        {"accompanist", birthdate: ~D[2002-01-02]},
      ])
      {:ok, performance} = Showtime.create_performance(c, attrs)

      for ens <- get_ensemblists(performance) do
        assert ens.age_group == "III"
      end

      for acc <- get_accompanists(performance) do
        assert acc.age_group == "V"
      end
    end

    test "assigns the correct age groups for a Kimu solo performance", %{contest: c} do
      cc = insert_contest_category(c, "kimu")
      attrs = performance_params(cc, [
        {"soloist", birthdate: ~D[2011-01-01]},
        {"accompanist", birthdate: ~D[2009-01-01]},
        {"accompanist", birthdate: ~D[2008-12-31]},
      ])
      {:ok, performance} = Showtime.create_performance(c, attrs)

      assert get_soloist(performance).age_group == "Ia"

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "Ib"
      assert acc2.age_group == "II"
    end

    test "assigns the correct age groups for a Kimu ensemble performance", %{contest: c} do
      cc = insert_contest_category(c, "kimu")
      attrs = performance_params(cc, [
        {"ensemblist", birthdate: ~D[2011-01-01]},
        {"ensemblist", birthdate: ~D[2010-12-31]},
        {"accompanist", birthdate: ~D[2009-01-01]},
        {"accompanist", birthdate: ~D[2008-12-31]},
      ])
      {:ok, performance} = Showtime.create_performance(c, attrs)

      for ens <- get_ensemblists(performance) do
        assert ens.age_group == "Ib"
      end

      [acc1, acc2] = get_accompanists(performance)
      assert acc1.age_group == "Ib"
      assert acc2.age_group == "II"
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

      old_p = insert_shorthand_performance(cc, [
        {"ensemblist", birthdate: ~D[2001-01-01]},
        {"ensemblist", birthdate: ~D[2002-01-01]},
        {"ensemblist", birthdate: ~D[2003-01-01]},
      ])

      attrs = performance_params(cc, [
        # Replace the second ensemblist and drop the third
        {"ensemblist", birthdate: ~D[2001-01-01]},
        {"ensemblist", birthdate: ~D[2002-01-02]},
      ])

      {:ok, %{id: id}} = Showtime.update_performance(c, old_p, attrs)
      # Force-reload before checking associations
      performance = Showtime.get_performance!(c, id)

      assert length(performance.appearances) == 2
    end

    test "doesn't allow changes that affect a participant's identity", %{contest: c} do
      [cc, _] = c.contest_categories

      old_p = insert_shorthand_performance(cc, [
        {"soloist", [given_name: "X", family_name: "X", birthdate: ~D[2001-01-01]]}
      ])
      old_sol = get_soloist(old_p)

      attrs = performance_params(cc, [
        {old_sol, "soloist", [given_name: "Y", family_name: "Y", birthdate: ~D[2001-01-02]]}
      ])

      {:error, changeset} = Showtime.update_performance(c, old_p, attrs)
      assert [%Changeset{changes: %{
        participant: %{errors: [
          birthdate: {"can't be changed", []},
          family_name: {"can't be changed", []},
          given_name: {"can't be changed", []},
        ]}
      }}] = changeset.changes[:appearances]
    end

    test "allows changes that don't affect a participant's identity", %{contest: c} do
      [cc, _] = c.contest_categories

      matching_attrs = [given_name: "X", family_name: "X", birthdate: ~D[2001-01-01]]
      old_p = insert_shorthand_performance(cc, [
        {"soloist", matching_attrs ++ [phone: "123", email: "old@example.org"]}
      ])
      old_sol = get_soloist(old_p)

      attrs = performance_params(cc, [
        {old_sol, "soloist", matching_attrs ++ [phone: "456", email: "new@example.org"]}
      ])

      {:ok, performance} = Showtime.update_performance(c, old_p, attrs)
      %{participant: pt} = get_soloist(performance)

      assert pt.phone == "456"
      assert pt.email == "new@example.org"
    end

    test "assigns and updates an existing participant when adding one to match", %{contest: c} do
      [cc, _] = c.contest_categories

      matching_attrs = [given_name: "X", family_name: "X", birthdate: ~D[2001-01-01]]
      old_pt = insert(:participant, matching_attrs ++ [email: "old@example.org"])
      old_p = insert_shorthand_performance(cc, [
        {"soloist", birthdate: ~D[2001-01-02]}
      ])

      attrs = performance_params(cc, [
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

      old_p = insert_shorthand_performance(cc, [
        # These ensemblists together get AG IV
        {"ensemblist", birthdate: ~D[2007-01-01]},
        {"ensemblist", birthdate: ~D[2005-01-01]},
        {"ensemblist", birthdate: ~D[2003-01-01]},
      ])

      attrs = performance_params(cc, [
        # Replace two ensemblists and drop the third
        {"ensemblist", birthdate: ~D[2007-01-02]},
        {"ensemblist", birthdate: ~D[2006-12-31]},
      ])

      {:ok, %{id: id}} = Showtime.update_performance(c, old_p, attrs)
      # Force-reload before checking associations
      performance = Showtime.get_performance!(c, id)

      assert performance.age_group == "II"

      for ens <- get_ensemblists(performance) do
        assert ens.age_group == "II"
      end
    end

    test "updates the age groups after switching the genre", %{contest: c} do
      old_cc = insert_contest_category(c, "classical")

      appearances = [
        {"soloist", birthdate: ~D[2007-01-01]}, # AG II
        {"accompanist", birthdate: ~D[2007-01-02]}, # AG II
        {"accompanist", birthdate: ~D[2005-01-01]}, # AG III
        {"accompanist", birthdate: ~D[2003-01-01]}, # AG IV
      ]

      old_p = insert_shorthand_performance(old_cc, appearances)

      # Once this becomes a pop performance, the accompanists share AG III
      cc = insert_contest_category(c, "popular")
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
      } = old_p = insert_performance(c, pieces: [
        build(:piece, title: "A"),
        build(:piece, title: "B"),
        build(:piece, title: "C"),
      ])

      attrs = %{pieces: [
        params_for(:piece, title: "A changed") |> Map.put(:id, old_pc1.id),
        params_for(:piece, title: "B") |> Map.put(:id, old_pc2.id),
        params_for(:piece, title: "D"),
      ]}

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

  test "load_contest_category/1 fully preloads a performance's contest category", %{contest: c} do
    insert_performance(c)
    performance = Repo.one(Performance)

    assert %{
      contest_category: %{contest: %Contest{}, category: %Category{}}
    } = performance |> Showtime.load_contest_category
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

      assert_ids_match_ordered Showtime.list_participants(c), [pt3, pt2, pt4, pt1]
    end

    test "preloads the participants' performances + categories, but only within the contest", %{contest: c} do
      pt = insert_participant(c)

      other_c = insert(:contest)
      insert_performance(other_c, appearances: [build(:appearance, participant: pt)])

      assert [%Participant{performances: [performance]}] = Showtime.list_participants(c)
      assert %Performance{
        contest_category: %ContestCategory{
          category: %Category{}
        }
      } = performance
    end
  end

  describe "get_participant!/2" do
    test "gets a participant from the given contest by id", %{contest: c} do
      %{id: id} = insert_participant(c)

      result = Showtime.get_participant!(c, id)
      assert result.id == id
    end

    test "gets a participant that has multiple appearances", %{contest: c} do
      %{id: id} = pt = insert_participant(c)
      insert_performance(c, appearances: [build(:appearance, participant: pt)])

      assert %Participant{id: id} = Showtime.get_participant!(c, id)
    end

    test "raises an error if the participant isn't found in the given contest", %{contest: c} do
      %{id: id} = insert_participant(c)
      other_c = insert(:contest)

      assert_raise Ecto.NoResultsError, fn -> Showtime.get_participant!(other_c, id) end
    end
  end

  # Private helpers

  # Returns insertion params for a performance.
  defp performance_params(cc, appearance_shorthands) do
    %{
      contest_category_id: cc.id,
      appearances: Enum.map(appearance_shorthands, fn
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
    Enum.find(appearances, &Appearance.is_soloist/1)
  end

  defp get_ensemblists(%Performance{appearances: appearances}) do
    Enum.filter(appearances, &Appearance.is_ensemblist/1)
  end

  defp get_accompanists(%Performance{appearances: appearances}) do
    Enum.filter(appearances, &Appearance.is_accompanist/1)
  end
end
