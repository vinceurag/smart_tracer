defmodule SmartTracer.Utils.Recorder.Call do
  @type t() :: %__MODULE__{
          type: :call,
          module: module(),
          function: atom(),
          args: list(any()),
          arity: integer(),
          datetime: DateTime.t()
        }

  defstruct [:type, :module, :function, :args, :arity, :datetime]
end
