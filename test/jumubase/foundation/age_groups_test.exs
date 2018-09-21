defmodule Jumubase.AgeGroupsTest do
  use Jumubase.DataCase
  alias Jumubase.Foundation.AgeGroups

  test "all/0 returns all available age groups" do
    assert [_ | _] = result = AgeGroups.all()
    assert length(result) == 8
  end

  test "calculate_age_group/2 returns the correct age group for a single birthdate" do
    assert AgeGroups.calculate_age_group(~D[2019-12-31], 56) == "Ia"
    assert AgeGroups.calculate_age_group(~D[2011-01-01], 56) == "Ia"

    assert AgeGroups.calculate_age_group(~D[2010-12-31], 56) == "Ib"
    assert AgeGroups.calculate_age_group(~D[2009-01-01], 56) == "Ib"

    assert AgeGroups.calculate_age_group(~D[2008-12-31], 56) == "II"
    assert AgeGroups.calculate_age_group(~D[2007-01-01], 56) == "II"

    assert AgeGroups.calculate_age_group(~D[2006-12-31], 56) == "III"
    assert AgeGroups.calculate_age_group(~D[2005-01-01], 56) == "III"

    assert AgeGroups.calculate_age_group(~D[2004-12-31], 56) == "IV"
    assert AgeGroups.calculate_age_group(~D[2003-01-01], 56) == "IV"

    assert AgeGroups.calculate_age_group(~D[2002-12-31], 56) == "V"
    assert AgeGroups.calculate_age_group(~D[2001-01-01], 56) == "V"

    assert AgeGroups.calculate_age_group(~D[2000-12-31], 56) == "VI"
    assert AgeGroups.calculate_age_group(~D[1998-01-01], 56) == "VI"

    assert AgeGroups.calculate_age_group(~D[1997-12-31], 56) == "VII"
    assert AgeGroups.calculate_age_group(~D[1992-01-01], 56) == "VII"
  end

  test "calculate_age_group/2 raises an error if the birthdate isn't in any age group" do
    assert_raise CaseClauseError, fn ->
      AgeGroups.calculate_age_group(~D[2020-01-01], 56)
    end
    assert_raise CaseClauseError, fn ->
      AgeGroups.calculate_age_group(~D[1991-12-31], 56)
    end
  end

  test "calculate_age_group/2 returns the correct age group for a list of birthdates" do
    two_birthdates = [~D[2006-12-31], ~D[2007-01-01]]
    assert AgeGroups.calculate_age_group(two_birthdates, 56) == "III"

    three_birthdates = [~D[2006-12-31], ~D[2007-01-01], ~D[2007-01-02]]
    assert AgeGroups.calculate_age_group(three_birthdates, 56) == "II"
  end
end
