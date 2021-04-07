defmodule Data.Repo.Migrations.MoveAvatarToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add(:avatar, :string, default: "")
    end

    execute """

    UPDATE users
    SET avatar = t.avatar
    FROM team_members t
    WHERE users.id = t.user_id;

    """

    alter table(:team_members) do
      remove(:avatar)
    end
  end

  def down do
    alter table(:team_members) do
      add(:avatar, :string, default: "")
    end

    execute """

    UPDATE team_members
    SET avatar = u.avatar
    FROM users u
    WHERE team_members.user_id = u.id;

    """

    alter table(:users) do
      remove(:avatar)
    end
  end
end
