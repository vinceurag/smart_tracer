defmodule SmartTracer.Utils.Recorder do
  @moduledoc false

  use Agent
  require Logger

  def start_recording() do
    Agent.start_link(fn -> [] end, name: :trace_recorder)
  end

  def record(trace) do
    if is_alive?() do
      Agent.update(:trace_recorder, fn recordings -> [build_record(trace) | recordings] end)
    else
      recording_not_started_error()
    end
  end

  def playback() do
    if is_alive?() do
      Agent.get(:trace_recorder, fn recordings -> Enum.reverse(recordings) end)
    else
      recording_not_started_error()
    end
  end

  def stop() do
    if is_alive?(), do: Agent.stop(:trace_recorder), else: :ok
  end

  def is_alive?() do
    pid = Process.whereis(:trace_recorder)

    not is_nil(pid)
  end

  defp build_record({:call, {module, func_name, args, erl_time}}) do
    %SmartTracer.Utils.Recorder.Call{
      type: :call,
      module: module,
      function: func_name,
      args: args,
      arity: Enum.count(args),
      datetime: get_datetime(erl_time)
    }
  end

  defp build_record({:return, {module, func_name, arity, return_value, erl_time}}) do
    %SmartTracer.Utils.Recorder.Return{
      type: :return,
      module: module,
      function: func_name,
      arity: arity,
      return_value: return_value,
      datetime: get_datetime(erl_time)
    }
  end

  defp get_datetime({megasec, sec, _}) do
    unix_timestamp = megasec * 1_000_000 + sec

    DateTime.from_unix!(unix_timestamp)
  end

  defp recording_not_started_error() do
    Logger.error("""
    Trace recording was not started. 
    Be sure to start the recording by using SmartTracer.start_recording/0
    or by using `record: true` option when starting a trace.
    """)
  end
end
