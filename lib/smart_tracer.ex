defmodule SmartTracer do
  def trace(function, calls_count \\ 10, opts \\ []) do
    function_info = :erlang.fun_info(function)
    arity = function_info[:arity]
    module_name = function_info[:module]
    function_name = function_info[:name]

    ms = if opts[:return], do: get_matchspec(arity), else: arity

    :recon_trace.calls(
      {module_name, function_name, ms},
      calls_count,
      opts ++ [formatter: &format/1]
    )
  end

  def stop() do
    :recon_trace.clear()
  end

  defp get_matchspec(arity) do
    var_placeholders = generate_var_placeholders(arity)

    [{var_placeholders, [], [{:return_trace}]}]
  end

  defp format({:trace, _pid, :call, {module, func_name, args}}) do
    IO.puts("\n#{module}.#{func_name}/#{length(args)} is being called with:")
    IO.puts(IO.ANSI.format([:yellow, "\t#{inspect(args)}"]))
  end

  defp format({:trace, _pid, :return_from, {module, func_name, arity}, return_value}) do
    IO.puts("\n#{module}.#{func_name}/#{arity} returns:")
    IO.puts(IO.ANSI.format([:green, "\t#{inspect(return_value)}"]))
  end

  defp generate_var_placeholders(arity) do
    1..arity
    |> Enum.to_list()
    |> Enum.map(fn num -> :"$#{num}" end)
  end
end
