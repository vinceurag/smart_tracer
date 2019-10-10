defmodule Test do
  def hello(name) do
    "Hello, my name is #{get_name(name)}"
  end

  defp get_name(name) do
    "WUNDER-#{name}"
  end
end

Smar
