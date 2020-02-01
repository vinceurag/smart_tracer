defmodule SmartTracer.Utils.Recorder.Return do
  @type t() :: %__MODULE__{
          type: :return,
          module: module(),
          function: atom(),
          arity: integer(),
          return_value: any(),
          datetime: DateTime.t()
        }

  defstruct [:type, :module, :function, :return_value, :arity, :datetime]
end
