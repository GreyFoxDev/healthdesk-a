defmodule MainWeb.AutomationController do
  use MainWeb.SecuredContoller

  alias Data.{Location, Automation, User}


  def new(conn, %{"location_id" => location_id} = _params) do

    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    automations = Automation.get_by_location_id(location_id)

    render(
      conn,
      "new.html",
      changeset: Automation.get_changeset(),
      location_id: location_id,
      automations: automations,
      location: location,
      teams: teams(conn),
      has_sidebar: true,
      errors: [],
      automation_limit: Location.get_automation_limit(location_id)
    )
  end

  def create(conn, %{"question" => question, "answer" => answer, "location_id" => location_id, "team_id" => team_id}=params) do

    location =
      conn
      |> current_user()
      |> Location.get(location_id)
    with {:ok, _} <- Automation.create(params) do
      body = "A new automation has been added as \n Question: #{question} \n Answer: #{answer} \n at Location: #{location.location_name}"
      subject="Automation Added"
      email_list= User.get_admin_emails
      Enum.each(email_list, fn email ->
        email
        |> Main.Email.generate_email(body, subject)
        |> Main.Mailer.deliver_now()
      end)
      conn
      |> put_flash(:success, "Automation created successfully.")
      |> redirect(to: team_location_automation_path(conn, :new, location.team_id, location.id))
    else
      {:error, _changeset} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        automations = Automation.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "Automation failed to create")
        |> render(
             "new.html",
             changeset: Automation.get_changeset(),
             location_id: location_id,
             automations: automations,
             location: location,
             has_sidebar: true,
             automation_limit: Location.get_automation_limit(location_id)

           )
    end
  end

  def update(conn, %{"id" => id, "location_id" => location_id, "team_id" => team_id} = params) do
    with %Data.Schema.Automation{} = automation <- Automation.get_by( id),
         {:ok, _} <- Automation.update(automation, params) do
      location =
        conn
        |> current_user()
        |> Location.get(location_id)
      conn
      |> put_flash(:success, "Automation updated successfully.")
      |> redirect(to: team_location_automation_path(conn, :new, location.team_id, location.id))    else
      {:error, changeset} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        intents = Automation.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "Automation failed to update")
        |> render(
             "new.html",
             changeset: Automation.get_changeset(),
             location_id: location_id,
             intents: intents,
             location: location,
             teams: teams(conn),
             has_sidebar: true,
             errors: changeset.errors,
             automation_limit: Location.get_automation_limit(location_id)
           )
    end
  end

  def delete(conn, %{"id" => id, "location_id" => location_id, "team_id" => team_id}) do
    with %Data.Schema.Automation{} = automation <- Automation.get_by(id),
         {:ok, _} <- Automation.delete(automation) do
      location =
        conn
        |> current_user()
        |> Location.get(location_id)
      conn
      |> put_flash(:success, "Automation deleted successfully.")
      |> redirect(to: team_location_automation_path(conn, :new, location.team_id, location.id))
    else
      {:error, :no_record_found} ->
        location =
          conn
          |> current_user()
          |> Location.get(location_id)
        automations = Automation.get_by_location_id(location_id)
        conn
        |> put_flash(:error, "failed to delete Automation")
        |> render(
             "new.html",
             changeset: Automation.get_changeset(),
             location_id: location_id,
             automations: automations,
             location: location,
             teams: teams(conn),
             has_sidebar: true,
             errors: [],
             automation_limit: Location.get_automation_limit(location_id)


           )
    end
  end

end