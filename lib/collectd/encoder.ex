defmodule Collectd.Encoder do
  alias Collectd.{Sample, TypeCode}

  # TODO: Use a macro
  @part_host <<0::integer-32>>
  @part_values <<6::integer-32>>
  @part_intervalhr <<7::integer-32>>
  @part_timehr <<8::integer-32>>

  def generate(%Sample{} = sample) do
    <<>>
    |> encode_host(sample)
    |> encode_timehr(sample)
    |> encode_intervalhr(sample)
    |> encode_values(sample)
  end

  defp encode_host(binary, %Sample{host: host}) do
    binary <> @part_host <> host <> <<0>>
  end

  defp encode_timehr(binary, %Sample{timehr: timehr}) do
    binary <> <<@part_timehr, timehr::integer-64>>
  end

  # FIXME: This should be called intervalhr
  defp encode_intervalhr(binary, %Sample{interval: intervalhr}) do
    binary <> <<@part_intervalhr, intervalhr::integer-64>>
  end

  defp encode_values(binary, %Sample{metrics: metrics}) do
    codes =
      metrics
      |> Enum.map(fn {type_code, _} ->
        TypeCode.type_code(type_code)
      end)
      |> Enum.map(fn c -> <<c::integer-8>> end)
      |> Enum.into(<<>>)

    values =
      Enum.reduce(metrics, codes, fn {_, value}, acc ->
        acc <> <<value::integer-64>>
      end)

    binary <> <<@part_values, byte_size(values)::integer-16, map_size(metrics)::integer-16>> <> values
  end
end
