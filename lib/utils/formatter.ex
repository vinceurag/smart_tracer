defmodule SmartTracer.Utils.Formatter do
  @moduledoc false

  alias SmartTracer.Utils.Recorder

  def format({:trace_ts, _pid, :call, {module, func_name, args}, erl_time}) do
    if record?(), do: Recorder.record({:call, {module, func_name, args, erl_time}})

    IO.puts("\n#{module}.#{func_name}/#{length(args)} is being called with:")
    IO.puts(IO.ANSI.format([:yellow, "\t#{inspect(args)}"]))
  end

  def format({:trace_ts, _pid, :return_from, {module, func_name, arity}, return_value, erl_time}) do
    if record?(),
      do: Recorder.record({:return, {module, func_name, arity, return_value, erl_time}})

    IO.puts("\n#{module}.#{func_name}/#{arity} returns:")
    IO.puts(IO.ANSI.format([:green, "\t#{inspect(return_value)}"]))
  end

  defp record?(), do: Recorder.is_alive?()
end
