import Config

# REST API CONFIGURATION
config :web_server,
 port: 8082,
 env: Mix.env()


# HTTP LIBRARY
config :http_connector,
  http_timeout: 3000,
  cacert_path: File.cwd!() <> "/lib/priv/cacerts.pem"
