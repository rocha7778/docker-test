defmodule DataTypeUtils do
  @moduledoc """
  This module contains functions to parse and normalize data structures.
  """
  require Logger

  def normalize(%{} = map) do
    Map.to_list(map)
    |> Enum.map(fn {key, value} -> {string_to_atom(key), normalize(value)} end)
    |> Enum.into(%{})
  end

  def normalize(value) when is_list(value), do: Enum.map(value, &normalize/1)
  def normalize(value), do: value

  def string_to_atom(value) when is_atom(value), do: value
  def string_to_atom(value), do: String.to_atom(value)

end
