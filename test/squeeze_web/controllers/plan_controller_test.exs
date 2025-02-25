defmodule SqueezeWeb.PlanControllerTest do
  use SqueezeWeb.ConnCase

  alias Squeeze.TrainingPlans

  describe "index" do
    setup [:create_plan]

    test "lists all training_plans", %{conn: conn, plan: plan} do
      conn = get conn, plan_path(conn, :index)
      assert html_response(conn, 200) =~ plan.name
    end
  end

  describe "new plan" do
    test "renders form", %{conn: conn} do
      conn = get conn, plan_path(conn, :new)
      assert html_response(conn, 200) =~ "New Plan"
    end
  end

  describe "create plan" do
    test "redirects to edit when data is valid", %{conn: conn, user: user} do
      attrs = params_for(:training_plan, %{name: "some name"})
      conn = post conn, plan_path(conn, :create), plan: attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == plan_path(conn, :edit, id)
      assert TrainingPlans.get_plan!(user, id).name == "some name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      attrs = %{name: nil}
      conn = post conn, plan_path(conn, :create), plan: attrs
      assert html_response(conn, 200) =~ "New Plan"
    end
  end

  describe "update plan" do
    setup [:create_plan]

    test "redirects when data is valid", %{conn: conn, plan: plan, user: user} do
      attrs = %{name: "some updated name"}
      conn = put conn, plan_path(conn, :update, plan), plan: attrs
      assert redirected_to(conn) == plan_path(conn, :show, plan)
      assert TrainingPlans.get_plan!(user, plan.id).name == "some updated name"
    end
  end

  defp create_plan(%{user: user}) do
    plan = insert(:training_plan, user: user)
    {:ok, plan: plan}
  end
end
