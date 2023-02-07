defmodule HttpRequest do
  @moduledoc """
  This module provides the capacity for connecting and making requests to an HTTP server
  """



  @type host_name :: String.t()
  @type path :: String.t()
  @type method :: String.t()
  @type schema :: atom()
  @type request_body :: term()
  @type headers :: list()
  @type opts :: list()

  @doc """
  Provides an HTTP response  to the given request parameters

  Returns `{:ok, term}`.

  ## Examples
      iex> HttpConnector.HttpRequest.request("jsonplaceholder.typicode.com", 443, "/posts/1", "GET", :https, nil, [], [])
      {:ok,  ["{\n  \"userId\": 1,\n  \"id\": 1,\n  \"title\": \"sunt aut \",\n  \"body\": \"quia et eprehum eveniet\"\n}", ""]}
  """
  @spec request(host_name, port, path, method, schema, request_body, headers, opts) ::
          {:ok, term()} | {:error, any()}
  def request(host_name, port, path, method, schema, request_body, headers \\ [], opts \\ [])
      when schema in [:https, :http] and
             is_binary(host_name) and
             is_integer(port) and
             port > 0 and
             is_binary(path) and
             is_binary(method) and
             is_list(headers) and
             is_list(opts) and
             byte_size(method) > 0 do
    HttpClient.request(host_name, port, path, schema, request_body, method, headers, opts)
  end

  defp is_valid_port_number(port_number) do
    is_integer(port_number) and port_number > 0
  end

  def request(_host, _port, _path, _method, schema, _request_body, _headers, _opts)
      when schema not in [:https, :http] do
    {:error, :invalid_schema}
  end

  def request(host_name, _port, _path, _method, _schema, _request_body, _headers, _opts)
      when not is_binary(host_name) do
    {:error, :invalid_host_name}
  end

  def request(_host_name, port, _path, _method, _schema, _request_body, _headers, _opts)
      when not is_integer(port) do
    {:error, :invalid_port_number}
  end

  def request(_host_name, _port, path, _method, _schema, _request_body, _headers, _opts)
      when not is_binary(path) do
    {:error, :invalid_path}
  end

  def request(_host_name, _port, _path, method, _schema, _request_body, _headers, _opts)
      when not is_binary(method) do
    {:error, :invalid_http_method}
  end

  def request(_host_name, _port, _path, _method, _schema, _request_body, headers, _opts)
      when not is_list(headers) do
    {:error, :invalid_headers}
  end

  def request(_host_name, _port, _path, _method, _schema, _request_body, _headers, opts)
      when not is_list(opts) do
    {:error, :invalid_opts}
  end
end
