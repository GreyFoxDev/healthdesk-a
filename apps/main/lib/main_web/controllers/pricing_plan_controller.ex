defmodule MainWeb.PricingPlanController do
  use MainWeb.SecuredContoller

  alias Data.{PricingPlan, Location}

  def index(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    with %Data.Schema.User{} = user <- current_user(conn),
         [plan|_] <- PricingPlan.all(user, location_id),
         {:ok, changeset} <- PricingPlan.get_changeset(plan.id, user) do

      render(conn, "index.html",
        changeset: changeset,
        location: location,
        teams: teams(conn),
        errors: [])
    else
      [] ->
        render(conn, "new.html",
          changeset: PricingPlan.get_changeset(),
          location: location,
          teams: teams(conn),
          errors: [])

    end
  end

  def create(conn, %{"pricing_plan" => network, "team_id" => team_id, "location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    network
    |> Map.put("location_id", location_id)
    |> PricingPlan.create()
    |> case do
         {:ok, _plan} ->
           conn
           |> put_flash(:success, "Pass Price created successfully.")
           |> redirect(to: team_location_pricing_plan_path(conn, :index, team_id, location_id))

         {:error, changeset} ->
           conn
           |> put_flash(:error, "Pass Price failed to create")
           |> render("index.html", location: location, changeset: changeset, errors: changeset.errors, teams: teams(conn))
       end
  end

  def update(conn, %{"id" => id, "pricing_plan" => network, "team_id" => team_id, "location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    network
    |> Map.merge(%{"id" => id, "location_id" => location_id})
    |> PricingPlan.update()
    |> case do
         {:ok, _plan} ->
           conn
           |> put_flash(:success, "Pass Price updated successfully.")
           |> redirect(to: team_location_pricing_plan_path(conn, :index, team_id, location_id))
         {:error, changeset} ->
           conn
           |> put_flash(:error, "Pass Price failed to update")
           |> render("index.html", location: location, changeset: changeset, errors: changeset.errors, teams: teams(conn))
       end
  end
end
