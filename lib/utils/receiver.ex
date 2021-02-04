defmodule SmartTracer.Utils.Receiver do
  @moduledoc false

  require Logger
  alias SmartTracer.Utils.Recorder

  @doc false
  def trace_action(module, limit) when limit > 0 do
    receive do
      {:trace, _pid, :call, {m, f, a}} ->
        apply(module, :action, [:call, {m, f, a}])
        if Recorder.is_alive?(), do: Recorder.record({:call, {m, f, a}})
        trace_action(module, limit - 1)

      {:trace, _pid, :return_from, {m, f, a}, return_value} ->
        apply(module, :action, [:return, {m, f, a, return_value}])
        if Recorder.is_alive?(), do: Recorder.record({:return, {m, f, a, return_value}})
        trace_action(module, limit)
    end
  end

  def trace_action(_mod, 0), do: Logger.info("Limit reached.")

  @spec tracer :: no_return
  @doc false
  def tracer() do
    receive do
      msg ->
        send(Process.whereis(:trace_action), msg)
    end

    tracer()
  end
end
