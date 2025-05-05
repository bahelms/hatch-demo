defmodule Hatch.Repo.Migrations.CreateConversationsTable do
  use Ecto.Migration

  def change do
    create table(:conversations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :participate_one_id, references(:participants, type: :binary_id)
      add :participate_two_id, references(:participants, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:conversations, [:participate_one_id, :participate_two_id], name: :conversations_participants_unique_index)
  end
end
