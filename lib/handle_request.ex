defmodule HandleRequest do
  def extract_payload(conn) do
    DataTypeUtils.normalize(conn.body_params)
  end
end
