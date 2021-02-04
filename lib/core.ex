defmodule SmartTracer.Core do
  @moduledoc false

  alias SmartTracer.Utils.Receiver
  alias SmartTracer.Utils.ProcessManager
  alias SmartTracer.Utils.Recorder

  def trace(function, limit, module, opts \\ []) do
    # Ensure clean slate every trace start
    stop()

    record? = Keyword.get(opts, :record, false)

    function_info = :erlang.fun_info(function)
    arity = function_info[:arity]
    module_name = function_info[:module]
    function_name = function_info[:name]

    ms = get_matchspec(arity, opts[:return])

    scope = if opts[:scope] == :local, do: [:local], else: []
    return = if opts[:return], do: [:return_to], else: []

    tracer_pid = spawn_link(Receiver, :tracer, [])
    Process.register(tracer_pid, :tracer)
    trace_action_pid = spawn_link(Receiver, :trace_action, [module, limit])
    Process.register(trace_action_pid, :trace_action)

    number_of_matches = :erlang.trace_pattern({module_name, function_name, arity}, ms, scope)

    :erlang.trace(:all, true, [:call, {:tracer, tracer_pid} | return])

    # Do not trace tracer processes
    :erlang.trace(trace_action_pid, false, [:all])
    :erlang.trace(tracer_pid, false, [:all])

    if record?, do: Recorder.start_recording()

    if number_of_matches > 0, do: :ok, else: :no_matches
  end

  def stop() do
    # Stop tracing
    :erlang.trace(:all, false, [:all])

    # Disable tracing for all patterns
    :erlang.trace_pattern({:_, :_, :_}, false, [:local])
    :erlang.trace_pattern({:_, :_, :_}, false, [])

    # Kill tracer and trace receiver
    ProcessManager.kill(:tracer)
    ProcessManager.kill(:trace_action)

    # Stop recording traces
    Recorder.stop()
  end

  defp get_matchspec(arity, return?) do
    var_placeholders = generate_var_placeholders(arity)
    trace_opts = if return?, do: [{:return_trace}], else: []
    [{var_placeholders, [], trace_opts}]
  end

  defp generate_var_placeholders(arity) do
    1..arity
    |> Enum.to_list()
    |> Enum.map(fn num -> :"$#{num}" end)
  end
end
