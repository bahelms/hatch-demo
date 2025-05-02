defmodule Hatch.Repo do
  use Ecto.Repo,
    otp_app: :hatch,
    adapter: Ecto.Adapters.Postgres
end
