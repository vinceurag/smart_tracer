defmodule SmartTracerTest do
  use ExUnit.Case, async: true

  alias SmartTracer.Support.FakeModule

  setup do
    Code.ensure_loaded(FakeModule)

    on_exit(fn ->
      SmartTracer.stop()
    end)
  end

  describe "trace/3" do
    test "starts the tracer and receiver processes" do
      SmartTracer.trace(&FakeModule.hello/1, 1)

      assert Process.alive?(Process.whereis(:tracer))
      assert Process.alive?(Process.whereis(:trace_handler))
    end

    test "stops the tracer and receiver processes" do
      SmartTracer.trace(&FakeModule.hello/1, 1)

      tracer_pid = Process.whereis(:tracer)
      trace_handler_pid = Process.whereis(:trace_handler)

      assert Process.alive?(tracer_pid)
      assert Process.alive?(trace_handler_pid)

      SmartTracer.stop()

      refute Process.alive?(tracer_pid)
      refute Process.alive?(trace_handler_pid)
    end

    test "starts the recorder process" do
      SmartTracer.trace(&FakeModule.hello/1, 1, record: true)

      assert Process.alive?(Process.whereis(:trace_recorder))
    end

    test "stops the recorder process" do
      SmartTracer.trace(&FakeModule.hello/1, 1, record: true)

      recorder_pid = Process.whereis(:trace_recorder)

      assert Process.alive?(recorder_pid)

      SmartTracer.stop()

      refute Process.alive?(recorder_pid)
    end

    test "receives a call message when tracing" do
      SmartTracer.trace(&FakeModule.hello/1, 1)

      trace_handler_pid = Process.whereis(:trace_handler)

      :erlang.trace(trace_handler_pid, true, [:receive])

      FakeModule.hello("Vince")

      assert_receive {:trace, ^trace_handler_pid, :receive, {:trace_ts, _pid, :call, _, _ts}}
    end

    test "receives a return_from message when tracing with `return: true`" do
      SmartTracer.trace(&FakeModule.hello/1, 1, return: true)

      trace_handler_pid = Process.whereis(:trace_handler)

      :erlang.trace(trace_handler_pid, true, [:receive])

      result = FakeModule.hello("Vince")

      assert_receive {:trace, ^trace_handler_pid, :receive,
                      {:trace_ts, _pid, :return_from, _mfa, ^result, _ts}}
    end
  end
end
