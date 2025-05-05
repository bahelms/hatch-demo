defmodule Hatch.Providers.ProviderBehaviour do
  @moduledoc """
  Behaviour for message providers (email and phone).
  """

  @callback send(map()) :: {:ok, map()} | {:error, term()}
end 