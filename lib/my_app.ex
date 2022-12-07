defmodule MyApp do
  use Plug.Router
  import Plug.Conn
  require Logger

  alias HandleError
  alias HandleResponse
  alias HandleRequest

  plug(Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)


  def init(options) do
    options
  end


  post "/v1/retrieve" do
    request = HandleRequest.extract_payload(conn)
    IO.inspect(request, label: :request)
    account = %{account_number: "73216154", balance: 15000000}
    HandleResponse.build_response(%{status: 200, body: %{data: [%{account: account}]}}, conn)
  end

  match _ do
    Logger.error("Recurso no encontrado")
    {body, conn} = HandleError.handle_error({:error, :not_found}, conn)
    HandleResponse.build_response(body, conn)
  end

end
