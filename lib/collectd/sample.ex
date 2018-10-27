defmodule Collectd.Sample do
  defstruct [:host, :timehr, :interval, :metrics]

  def new do
    %__MODULE__{}
  end
end
