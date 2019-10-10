defmodule SmartTracer.Support.FakeModule do
  @moduledoc false

  @doc false
  def hello(name) do
    "Hello, my name is #{get_name(name)}"
  end

  defp get_name(name) do
    "NAME-#{name}"
  end
end
