defmodule CollectdTest do
  use ExUnit.Case
  doctest Collectd

  test "greets the world" do
    assert Collectd.hello() == :world
  end
end
