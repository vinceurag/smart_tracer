defmodule SmartTracer.Core do
  @moduledoc false

  alias SmartTracer.Utils.Receiver
  alias SmartTracer.Utils.ProcessManager
  alias SmartTracer.Utils.Recorder

  def trace(function, limit, module, opts \\ []) do
    # Ensure clean slate every trace start
    stop()

    Process.flag(:trap_exit, true)

    record? = Keyword.get(opts, :record, false)

    function_info = :erlang.fun_info(function)
    arity = function_info[:arity]
    module_name = function_info[:module]
    function_name = function_info[:name]

    ms = get_matchspec(arity, opts[:return])

    scope = if opts[:scope] == :local, do: [:local], else: []
    return = if opts[:return], do: [:return_to], else: []

    tracer_pid = spawn_link(Receiver, :tracer, [])
    {:group_leader, tracer_group_leader} = Process.info(tracer_pid, :group_leader)
    Process.register(tracer_pid, :tracer)

    trace_handler_pid = spawn_trace_handler(tracer_pid, module, limit)
    Process.register(trace_handler_pid, :trace_handler)

    number_of_matches = :erlang.trace_pattern({module_name, function_name, arity}, ms, scope)

    :erlang.trace(:all, true, [:call, :timestamp, {:tracer, tracer_pid} | return])

    # Do not trace tracer processes
    :erlang.trace(trace_handler_pid, false, [:all])
    :erlang.trace(tracer_pid, false, [:all])
    :erlang.trace(tracer_group_leader, false, [:all])

    if record?, do: Recorder.start_recording()

    if number_of_matches > 0, do: :ok, else: :no_matches
  end

  def stop() do
    stop_tracing()

    # Stop recording traces
    Recorder.stop()
  end

  def stop_tracing() do
    # Stop tracing
    :erlang.trace(:all, false, [:all])

    # Disable tracing for all patterns
    :erlang.trace_pattern({:_, :_, :_}, false, [:local])
    :erlang.trace_pattern({:_, :_, :_}, false, [])

    # Kill tracer and trace receiver
    ProcessManager.kill(:tracer)
    ProcessManager.kill(:trace_handler)

    Process.flag(:trap_exit, false)
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

  defp spawn_trace_handler(tracer_pid, module, limit) do
    send(tracer_pid, {:spawn_trace_handler, {module, limit}, self()})

    receive do
      {:spawn_trace_handler, trace_handler_pid} ->
        trace_handler_pid
    after
      500 ->
        raise "Failed to initialize trace handler."
    end
  end
end
