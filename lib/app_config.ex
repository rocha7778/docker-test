defmodule AppConfig do
  def get_port do
     Application.get_env(:web_server, :port, 8081)
     
  end

end
