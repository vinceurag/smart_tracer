defmodule SmartTracerTest do
  use ExUnit.Case
  doctest SmartTracer

  test "greets the world" do
    assert SmartTracer.hello() == :world
  end
end
