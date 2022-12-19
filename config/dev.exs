import Config

# REST API CONFIGURATION
config :web_server,
 port: 8082,
 env: Mix.env()

 config :cache_manager,
  client_implementation: :redis,
  cache_entry_ttl: 20,
  redis_host: System.get_env("REDIX_HOST"),
  redis_port: System.get_env("REDIX_PORT")
