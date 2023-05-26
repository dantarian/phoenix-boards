defmodule PhoenixBoards.Repo.Migrations.CreateBoards do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :title, :string
      add :description, :text
      add :in_character, :boolean, default: false, null: false
      add :open, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:boards, [:title])
  end
end
