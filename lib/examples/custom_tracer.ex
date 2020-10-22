defmodule SmartTracer.Examples.CustomTracer do
  @moduledoc false
  use SmartTracer.Custom

  def action(:call, {module, fun, args}) do
    IO.puts("#{module}.#{fun}/#{length(args)} was called with #{inspect(args)}")
  end

  def action(:return, {module, fun, arity, return_value}) do
    IO.puts("#{module}.#{fun}/#{arity} returned: #{inspect(return_value)}")
  end
end
