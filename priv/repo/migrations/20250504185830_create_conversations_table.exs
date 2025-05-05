defmodule Hatch.Repo.Migrations.CreateConversationsTable do
  use Ecto.Migration

  def change do
    create table(:conversations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :participant_one_id, references(:participants, type: :binary_id)
      add :participant_two_id, references(:participants, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:conversations, [:participant_one_id, :participant_two_id],
             name: :conversations_participants_unique_index
           )
  end
end
