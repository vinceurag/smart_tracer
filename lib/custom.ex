defmodule SmartTracer.Custom do
  @moduledoc ~S"""
  With SmartTracer, you can also specify how you would want to present the traces.

  Here's an example.

        defmodule SmartTracer.Examples.CustomTracer do
          use SmartTracer.Custom

          def action(:call, {module, fun, args}) do
            IO.puts("#{module}.#{fun}/#{length(args)} was called with #{inspect(args)}")
          end

          def action(:return, {module, fun, arity, return_value}) do
            IO.puts("#{module}.#{fun}/#{arity} returned: #{inspect(return_value)}")
          end
        end

  """

  @callback action(:call, {module :: module(), function :: fun(), args :: list(term())}) :: any()
  @callback action(
              :return,
              {module :: module(), function :: fun(), args :: list(term()), return_value :: any()}
            ) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)

      defdelegate stop(), to: SmartTracer.Core

      def trace(function, limit, opts \\ []),
        do: SmartTracer.Core.trace(function, limit, [custom_formatter: __MODULE__] ++ opts)
    end
  end
end
