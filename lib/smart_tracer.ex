defmodule SmartTracer do
  @moduledoc """
  A simple wrapper for recon_trace.

  ## Usage

  When connected to a live remote console, issue the `trace/2` passing the function reference and rate limit.

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

  ### Tracing a function and getting it's return value (possible also for local tracing)
  ```
      iex> SmartTracer.trace(&FakeModulne.hello/1, 5, return: true)
      1
      iex> FakeModule.hello("Vince")
      Elixir.SmartTracer.Support.FakeModule.hello/1 is being called with:
        ["Vince"]
      Elixir.SmartTracer.Support.FakeModule.hello/1 returns:
        "Hello, my name is NAME-Vince"
  ```

  ### Tracing a function and recording calls and returns
  ```
      iex> SmartTracer.trace(&FakeModulne.hello/1, 5, return: true, record: true)
      1
  ```
  To playback all the recordings, use `playback/0`
  ```
      iex> SmartTracer.playback()
      [%SmartTracer.Utils.Recorder.Call{
        args: ["Vince"],
        arity: 1,
        function: :hello,
        module: SmartTracer.Support.FakeModule,
        type: :call
      },
      %SmartTracer.Utils.Recorder.Return{
        arity: 1,
        function: :hello,
        module: SmartTracer.Support.FakeModule,
        return_value: "Hello, my name is NAME-Vince",
        type: :return
      }]
  ```
  """

  alias SmartTracer.Core
  alias SmartTracer.Utils.Recorder

  @default_formatter Application.get_env(:smart_tracer, :default_formatter)

  @doc """
  Traces calls for the specified function.

  ## Options
  * `:return` - display return value of the specified function, defaults to `false`
  * `:scope`  - determines wether to trace local calls as well
    * `:global` (default) - trace only public functions
    * `:local` - trace private function calls as well

  """
  @spec trace(function :: fun(), calls_count :: integer(), opts :: keyword()) :: :ok | :no_matches
  def trace(function, calls_count, opts \\ []) when is_list(opts) and is_integer(calls_count) do
    Core.trace(function, calls_count, @default_formatter, opts)
  end

  @doc """
  Stops tracing any function calls.
  """
  @spec stop() :: :ok
  def stop() do
    Core.stop()
  end

  @doc """
  Returns a list of all the traces.
  """
  @spec playback() ::
          [call: {module(), atom(), [String.t()]}]
          | [return: {module(), atom(), integer(), String.t()}]
  def playback(), do: Recorder.playback()

  @doc false
  def action(:call, {module, func_name, args}) do
    IO.puts("\n#{module}.#{func_name}/#{length(args)} is being called with:")
    IO.puts(IO.ANSI.format([:yellow, "\t#{inspect(args)}"]))
  end

  @doc false
  def action(:return, {module, func_name, arity, return_value}) do
    IO.puts("\n#{module}.#{func_name}/#{arity} returns:")
    IO.puts(IO.ANSI.format([:green, "\t#{inspect(return_value)}"]))
  end
end
