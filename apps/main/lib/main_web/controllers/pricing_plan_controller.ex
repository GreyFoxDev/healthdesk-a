defmodule MainWeb.PricingPlanController do
  use MainWeb.SecuredContoller

  alias Data.{PricingPlan, Location}

  def index(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    pricing_plans =
      conn
      |> current_user()
      |> PricingPlan.all(location_id)

    render conn, "index.html", location: location, pricing_plans: pricing_plans
  end

  def new(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    render(conn, "new.html",
      changeset: PricingPlan.get_changeset(),
      location: location,
      errors: [])
  end

  def edit(conn, %{"id" => id, "location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- PricingPlan.get_changeset(id, user) do

      render(conn, "edit.html",
        changeset: changeset,
        location: location,
        errors: [])
    end
  end

  def create(conn, %{"pricing_plan" => network, "team_id" => team_id, "location_id" => location_id}) do
    network
    |> Map.put("location_id", location_id)
    |> PricingPlan.create()
    |> case do
         {:ok, _plan} ->
           conn
           |> put_flash(:success, "Pricing Plan created successfully.")
           |> redirect(to: team_location_pricing_plan_path(conn, :index, team_id, location_id))

         {:error, changeset} ->
           conn
           |> put_flash(:error, "Pricing Plan failed to create")
           |> render_page("new.html", changeset, changeset.errors)
       end
  end

  def update(conn, %{"id" => id, "pricing_plan" => network, "team_id" => team_id, "location_id" => location_id}) do
    network
    |> Map.merge(%{"id" => id, "location_id" => location_id})
    |> PricingPlan.update()
    |> case do
         {:ok, _plan} ->
           conn
           |> put_flash(:success, "Pricing Plan updated successfully.")
           |> redirect(to: team_location_pricing_plan_path(conn, :index, team_id, location_id))
         {:error, changeset} ->
           conn
           |> put_flash(:error, "Pricing Plan failed to update")
           |> render_page("edit.html", changeset, changeset.errors)
       end
  end

  def delete(conn, %{"id" => id, "team_id" => team_id, "location_id" => location_id}) do
    %{"id" => id, "deleted_at" => DateTime.utc_now()}
    |> PricingPlan.update()
    |> case do
         {:ok, _plan} ->
           conn
           |> put_flash(:success, "Pricing Plan deleted successfully.")
           |> redirect(to: team_location_pricing_plan_path(conn, :index, team_id, location_id))

         {:error, _changeset} ->
           conn
           |> put_flash(:error, "Pricing Plan failed to delete")
           |> render_page("index.html", team_id, location_id)
       end
  end

  defp render_page(conn, page, changeset, errors \\ []) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
