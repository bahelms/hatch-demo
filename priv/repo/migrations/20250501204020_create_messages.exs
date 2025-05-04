defmodule Hatch.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :from, :string
      add :to, :string
      add :type, :string
      add :body, :text
      add :attachments, {:array, :string}
      add :timestamp, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
