ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Hatch.Repo, :manual)

# Define mocks for providers
Mox.defmock(Hatch.EmailProviderMock, for: Hatch.Providers.ProviderBehaviour)
Mox.defmock(Hatch.PhoneProviderMock, for: Hatch.Providers.ProviderBehaviour)

# Set global mode for all tests
Application.put_env(:hatch, :email_provider, Hatch.EmailProviderMock)
Application.put_env(:hatch, :phone_provider, Hatch.PhoneProviderMock)
