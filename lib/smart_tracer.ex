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
        datetime: #DateTime<2020-02-01 18:13:04Z>,
        function: :hello,
        module: SmartTracer.Support.FakeModule,
        type: :call
      },
      %SmartTracer.Utils.Recorder.Return{
        arity: 1,
        datetime: #DateTime<2020-02-01 18:13:04Z>,
        function: :hello,
        module: SmartTracer.Support.FakeModule,
        return_value: "Hello, my name is NAME-Vince",
        type: :return
      }]
  ```
  """

  alias SmartTracer.Core
  alias SmartTracer.Utils.Recorder

  @doc """
  Traces calls for the specified function.

  ## Options
  * `:return` - display return value of the specified function, defaults to `false`
  * `:record` - record calls and returns from traces. Playback using `playback/0`
  * `:scope`  - determines wether to trace local calls as well
    * `:global` (default) - trace only public functions
    * `:local` - trace private function calls as well
  """
  @spec trace(function :: fun(), calls_count :: integer(), opts :: keyword()) :: integer()
  def trace(function, calls_count, opts \\ []) when is_list(opts) do
    Core.trace(function, calls_count, opts)
  end

  @doc """
  Stops tracing any function calls.
  """
  @spec stop() :: :ok
  def stop() do
    Recorder.stop()
    :recon_trace.clear()
  end

  @doc """
  Start recording calls/returns to an Agent.
  """
  @spec start_recording() :: {:ok, pid()}
  defdelegate start_recording(), to: Recorder

  @doc """
  Returns all the recordings.
  """
  @spec playback() :: [Recorder.Call.t() | Recorder.Return.t()]
  defdelegate playback(), to: Recorder
end
