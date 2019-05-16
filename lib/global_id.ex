defmodule GlobalId do
  @moduledoc """
  GlobalId module contains an implementation of a guaranteed globally unique id system.     
  """

  @max_counter 0x1FFFF #13 bits left for counter
  @max_node_id 1024

  @doc """
  64 bit non negative integer output
  """
  @spec get_id() :: non_neg_integer
  def get_id() do
    n_id = node_id()
    ts = timestamp()
    counter = :ets.update_counter(
      :counters,              #:ets.new(:counters, [:named_table, :public, :ordered_set])
      {ts, n_id},             #key is {timestamp, node_id}
      {2,1, @max_counter, 0}, #counter is increased by one until it reaches max value fitting into id
      {:undefined, 0}         #default counter values is 0, key is ignored here
    )
    <<r :: size(64)>> =
      <<n_id :: size(11),     #1024 fits into 11 bits
        ts :: size(40),       #UTS is 32 bits for seconds + 8 bits for milliseconds
        counter :: size(13)>>  #rest of 64 bits is left for counter, which guarantees uniqueness
    r
  end

  def max_node_id() do
    @max_node_id
  end

  @doc """
  Returns your node id as an integer.
  It will be greater than or equal to 0 and less than or equal to 1024.
  It is guaranteed to be globally unique. 
  """
  @spec node_id() :: non_neg_integer
  def node_id do
    1000
  end

  @doc """
  Returns timestamp since the epoch in milliseconds. 
  """
  @spec timestamp() :: non_neg_integer
  def timestamp do
    :erlang.system_time(:milli_seconds) #worst case scenario. "This time is not a monotonically increasing time in the general case."
  end
end