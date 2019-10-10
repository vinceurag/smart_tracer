defmodule SmartTracer do
  @moduledoc """
  A simple wrapper for recon_trace.

  ## Usage

  When connected to a live remote console, issue the `trace/1` passing the function reference and rate limit.

  ### Tracing a global function
  ```
      iex> SmartTracer.trace(&FakeModule.hello/1, 5)
      1
      iex> FakeModule.hello("Vince")
      Elixir.SmartTracer.Support.FakeModule.hello/1 is being called with:
        ["Vince"]
  ```

  ### Tracing a local function
  ```
      iex> SmartTracer.trace(&FakeModule.get_name/1, 5, scope: :local)
      1
      iex> FakeModule.hello("Vince")
      Elixir.SmartTracer.Support.FakeModule.get_name/1 is being called with:
        ["Vince"]
  ```

  ### Tracing a function and getting it's return value (possiblemix hex also for local tracing)
  ```
      iex> SmartTracer.trace(&FakeModulne.hello/1, 5, return: true)
      1
      iex> FakeModule.hello("Vince")
      Elixir.SmartTracer.Support.FakeModule.hello/1 is being called with:
        ["Vince"]
      Elixir.SmartTracer.Support.FakeModule.hello/1 returns:
        "Hello, my name is NAME-Vince"
  ```
  """

  @doc """
  Traces calls for the specified function.

  ## Options
  * `:return` - display return value of the specified function, defaults to `false`
  * `:scope`  - determines wether to trace local calls as well
    * `:global` (default) - trace only public functions
    * `:local` - trace private function calls as well
  """
  @spec trace(function :: fun(), calls_count :: integer(), opts :: keyword()) :: integer()
  def trace(function, calls_count, opts \\ []) when is_list(opts) do
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

  @doc """
  Stops tracing any function calls.
  """
  @spec stop() :: :ok
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
