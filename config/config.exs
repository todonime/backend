use Mix.Config

storage =
  case System.get_env("STORAGE_PATH") do
    path when is_binary(path) -> path
    nil -> Path.absname("storage")
  end

config :todonime, Todonime.Guardian,
  issuer: "todonime",
  secret_key: "vJ5QDCWttU06g705sgcbOa4C7DFYR4bwd/fqRJupx/cKZvbI4tyXNyaeY0gtM4ai"

config :todonime,
  storage: storage,
  public: "#{storage}/public",
  database: "#{storage}/databases/todonime.sqlite3",
  port: System.get_env("PORT")

config :storage,
  adapter: Storage.Adapters.Local

config :storage, Storage.Adapters.Local,
  root: "#{storage}/public",
  host: [
    url: "https://s.todonime.ru",
    from: ""
  ]