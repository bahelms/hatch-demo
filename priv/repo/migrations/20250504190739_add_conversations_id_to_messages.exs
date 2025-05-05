defmodule Hatch.Repo.Migrations.AddConversationsIdToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :conversation_id, references(:conversations, type: :binary_id)
    end

    create index(:messages, [:conversation_id])
  end
end
