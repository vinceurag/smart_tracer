defmodule SmartTracer.Utils.Receiver do
  @moduledoc false

  require Logger
  alias SmartTracer.Core
  alias SmartTracer.Utils.Recorder

  @doc false
  def trace_handler(module, limit) when limit > 0 do
    receive do
      {:trace_ts, _pid, :call, {m, f, a}, erl_ts} ->
        apply(module, :handle, [:call, {m, f, a}])
        if Recorder.is_alive?(), do: Recorder.record({:call, {m, f, a, erl_ts}})
        trace_handler(module, limit - 1)

      {:trace_ts, _pid, :return_from, {m, f, a}, return_value, erl_ts} ->
        apply(module, :handle, [:return, {m, f, a, return_value}])
        if Recorder.is_alive?(), do: Recorder.record({:return, {m, f, a, return_value, erl_ts}})
        trace_handler(module, limit)
    end
  end

  def trace_handler(_mod, 0) do
    Logger.info("Limit reached.")
    Core.stop_tracing()
  end

  @spec tracer :: no_return
  @doc false
  def tracer() do
    receive do
      {:spawn_trace_handler, {module, limit}, caller} ->
        pid = spawn_link(__MODULE__, :trace_handler, [module, limit])
        send(caller, {:spawn_trace_handler, pid})

      msg ->
        send(Process.whereis(:trace_handler), msg)
    end

    tracer()
  end
end
