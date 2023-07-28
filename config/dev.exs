import Config

# REST API CONFIGURATION
config :web_server,
 port: 8085,
 env: Mix.env()


# HTTP LIBRARY
config :web_server,
  http_timeout: 3000,
  cacert_path: File.cwd!() <> "/lib/priv/cacerts.pem"
