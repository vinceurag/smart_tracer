defmodule SmartTracer.Core do
  @moduledoc false

  alias SmartTracer.Utils.Formatter
  alias SmartTracer.Utils.Recorder

  def trace(function, limit, opts \\ []) do
    function_info = :erlang.fun_info(function)
    arity = function_info[:arity]
    module_name = function_info[:module]
    function_name = function_info[:name]

    ms = if opts[:return], do: get_matchspec(arity), else: arity

    maybe_record(opts)

    formatter = fn trace ->
      Formatter.format(trace, opts[:custom_formatter])
    end

    :recon_trace.calls(
      {module_name, function_name, ms},
      limit,
      opts ++ [timestamp: :trace, formatter: formatter]
    )
  end

  def stop() do
    :recon_trace.clear()
  end

  defp get_matchspec(arity) do
    var_placeholders = generate_var_placeholders(arity)

    [{var_placeholders, [], [{:return_trace}]}]
  end

  defp generate_var_placeholders(arity) do
    1..arity
    |> Enum.to_list()
    |> Enum.map(fn num -> :"$#{num}" end)
  end

  defp maybe_record(opts) do
    if opts[:record], do: start_recording()
  end

  defp start_recording() do
    if not Recorder.is_alive?() do
      Recorder.start_recording()
    end
  end
end
