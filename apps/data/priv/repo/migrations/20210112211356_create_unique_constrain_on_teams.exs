defmodule Data.Repo.Migrations.CreateUniqueConstrainOnTeams do
  use Ecto.Migration
  import Ecto.Query

  def change do
    "DELETE FROM members as m WHERE m.id NOT IN
     (SELECT j.id FROM (SELECT DISTINCT ON (p.phone_number, p.team_id) *
     FROM members as p) as j);" |> Data.Repo.query()
    flush()
    create unique_index(:members, [:phone_number, :team_id], where: "deleted_at IS NULL")

  end
end
