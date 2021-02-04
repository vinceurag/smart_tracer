[![Hex.pm Version](https://img.shields.io/hexpm/v/smart_tracer?style=for-the-badge)](https://hex.pm/packages/smart_tracer)

# SmartTracer

A simple tracer with recording capabilities that would help you in a live debugging session.

## Installation

To use SmartTracer, update the `mix.exs` to include it on your dependencies.

```elixir
def deps do
  [
    {:smart_tracer, "~> 0.2.0"}
  ]
end
```

Documentation can be viewed here: [https://hexdocs.pm/smart_tracer](https://hexdocs.pm/smart_tracer).

## Usage

When connected to a live remote console, issue the `trace/2` passing the function reference and rate limit.

### Tracing a global function

```elixir
    iex> SmartTracer.trace(&FakeModule.hello/1, 5)
    1
    iex> FakeModule.hello("Vince")
    Elixir.SmartTracer.Support.FakeModule.hello/1 is being called with:
      ["Vince"]
```

### Tracing a local function

```elixir
    iex> SmartTracer.trace(&FakeModule.get_name/1, 5, scope: :local)
    1
    iex> FakeModule.hello("Vince")
    Elixir.SmartTracer.Support.FakeModule.get_name/1 is being called with:
      ["Vince"]
```

### Tracing a function and getting it's return value (possible also for local tracing)

```elixir
    iex> SmartTracer.trace(&FakeModulne.hello/1, 5, return: true)
    1
    iex> FakeModule.hello("Vince")
    Elixir.SmartTracer.Support.FakeModule.hello/1 is being called with:
      ["Vince"]
    Elixir.SmartTracer.Support.FakeModule.hello/1 returns:
      "Hello, my name is NAME-Vince"
```

### Tracing a function and recording calls and returns

```elixir
    iex> SmartTracer.trace(&FakeModulne.hello/1, 5, return: true, record: true)
    1
```

To playback all the recordings, use `playback/0`

```elixir
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
