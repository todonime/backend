use Mix.Config

config :storage,
  adapter: Storage.Adapters.Local

if Mix.env == :dev do
  import_config "../rel/config/config.exs"
end