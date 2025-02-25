defmodule Squeeze.ActivityMatcherTest do
  use Squeeze.DataCase

  @moduledoc false

  import Squeeze.Factory

  alias Squeeze.ActivityMatcher
  alias Squeeze.Dashboard.Activity
  alias Squeeze.TimeHelper

  describe "get_closest_activity/2" do
    setup [:create_user, :today]

    test "with planned activity on the same day", %{user: user, today: today} do
      activity = insert(:planned_activity, planned_date: today, user: user)
      insert(:planned_activity, status: :complete, planned_date: today, user: user)
      attrs = %Activity{start_at: Timex.now, type: "Run"}

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end

    test "with complete activity on the same day", %{user: user, today: today} do
      activity = insert(:planned_activity, status: :complete, planned_date: today, user: user)
      attrs = %Activity{start_at: Timex.now, type: "Run"}

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end

    test "with distance match on the same day", %{user: user, today: today} do
      [activity, _] = insert_pair(:planned_activity, planned_date: today, user: user)
      attrs = %Activity{start_at: Timex.now, distance: activity.planned_distance, type: "Run"}

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end

    test "with duration match on the same day", %{user: user, today: today} do
      [activity, _] = insert_pair(:planned_activity, planned_date: today, user: user)
      attrs = %Activity{start_at: Timex.now, duration: activity.planned_duration, type: "Run"}

      assert ActivityMatcher.get_closest_activity(user, attrs).id == activity.id
    end

    test "with an activity of a different type", %{user: user, today: today} do
      insert(:planned_activity, planned_date: today, user: user)
      attrs = %Activity{start_at: Timex.now, type: "Yoga"}

      assert ActivityMatcher.get_closest_activity(user, attrs) == nil
    end
  end

  defp create_user(_) do
    user = insert(:user)
    {:ok, user: user}
  end

  defp today(%{user: user}) do
    today = TimeHelper.today(user)
    {:ok, today: today}
  end
end
