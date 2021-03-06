defmodule Collectd.Decoder do
  @moduledoc """
  Sample data:
  data = <<0::integer-32, "localhost">> <> <<0>> <> <<8::integer-32, 8237452385723::integer-64>> <> <<7::integer-32, 10::integer-64>> <> <<6::integer-32, 256::integer-16, 2::integer-16, 0::integer-8, 1::integer-8, 677::integer-64, 10::integer-64>>
  """
  @part_host <<0::integer-32>>
  @part_values <<6::integer-32>>
  @part_intervalhr <<7::integer-32>>
  @part_timehr <<8::integer-32>>

  alias Collectd.{Sample, TypeCode}

  def parse(%Sample{} = sample, <<>>) do
    sample
  end

  def parse(%Sample{} = sample, <<@part_host, rest::binary>>) do
    host =
      for <<b::binary-1 <- rest>> do
        b
      end
      |> Enum.take_while(fn b -> b != <<0>> end)
      |> Enum.into(<<>>)

    host_size = byte_size(host) + 1
    <<_host::binary-size(host_size), buffer::binary>> = rest
    parse(%{sample | host: host}, buffer)
  end

  def parse(%Sample{} = sample, <<@part_timehr, timehr::integer-64, rest::binary>>) do
    parse(%{sample | timehr: timehr}, rest)
  end

  def parse(%Sample{} = sample, <<@part_intervalhr, interval::integer-64, rest::binary>>) do
    parse(%{sample | interval: interval}, rest)
  end

  def parse(%Sample{} = sample, <<@part_values, _length::integer-16, value_count::integer-16, rest::binary>>) do
    type_bytes_count = value_count
    value_bytes_count = value_count * 8
    <<types::binary-size(type_bytes_count), values::binary-size(value_bytes_count), rest::binary>> = rest

    type_list = 
      for <<type::integer-8 <- types>>, into: [] do
        type
      end
      |> Enum.map(&TypeCode.type_code/1)

    value_list = for <<value::integer-64 <- values>>, do: value, into: []

    metrics =
      type_list
      |> Enum.zip(value_list)
      |> Enum.into(%{})

    parse(%{sample | metrics: metrics}, rest)
  end
end
