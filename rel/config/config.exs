use Mix.Config

storage = "/var/todonime/data"

config :todonime, Todonime.Guardian,
  issuer: "todonime",
  secret_key: "vJ5QDCWttU06g705sgcbOa4C7DFYR4bwd/fqRJupx/cKZvbI4tyXNyaeY0gtM4ai"

config :todonime,
  storage: storage,
  public: "#{storage}/public",
  database: "#{storage}/databases/todonime.sqlite3"

config :storage, Storage.Adapters.Local,
  root: "#{storage}/public",
  host: [
    url: "https://s.todonime.ru",
    from: ""
  ]