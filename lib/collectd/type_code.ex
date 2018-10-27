defmodule Collectd.TypeCode do
  def type_code(0), do: :counter
  def type_code(1), do: :gauge
  def type_code(2), do: :derive
  def type_code(3), do: :absolute

  def type_code(:counter), do: 0
  def type_code(:gauge), do: 1
  def type_code(:derive), do: 2
  def type_code(:absolute), do: 3
end
