defmodule SmartTracer.Examples.CustomTracer do
  @moduledoc false
  use SmartTracer.Custom

  def handle(:call, {module, fun, args}) do
    IO.puts("#{module}.#{fun}/#{length(args)} was called with #{inspect(args)}")
  end

  def handle(:return, {module, fun, arity, return_value}) do
    IO.puts("#{module}.#{fun}/#{arity} returned: #{inspect(return_value)}")
  end
end
