defmodule Cleaner do
  @moduledoc false

  @interval 5_000

  use GenServer


  def start_link([]) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(_opts) do
    tid = :ets.new(:counters, [:named_table, :public, :ordered_set,
                              read_concurrency: true, write_concurrency: true]) #need benchmarking to say if needed
    schedule_work()
    {:ok, tid}
  end

  def handle_info(:work, tid) do
    delete_obsolete(
      :ets.first(tid),
      {GlobalId.timestamp() - @interval, GlobalId.max_node_id()} #delete counters older than 5 seconds
    )
    schedule_work()
    {:noreply, tid}
  end

  defp delete_obsolete(:"$end_of_table", _) do
    :ok
  end
  defp delete_obsolete(it, max_key) when it < max_key do
    :ets.delete(:counters, it)
    delete_obsolete(:ets.next(:counters, it), max_key)
  end
  defp delete_obsolete(_, _) do
    :ok
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @interval)
  end
end