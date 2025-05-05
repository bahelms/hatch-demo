defmodule Hatch.Repo.Migrations.CreateParticipantsTable do
  use Ecto.Migration

  def change do
    create table(:participants, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :phone_number, :string
      add :email, :string

      timestamps(type: :utc_datetime)
    end

    create index(:participants, [:phone_number])
    create index(:participants, [:email])
  end
end
