defmodule SmartTracer.FakeFormatter do
  @moduledoc false

  @doc false
  def action(_, _) do
    nil |> IO.inspect()
  end
end
