defmodule SmartTracer.Utils.ProcessManager do
  def kill(process_name) do
    pid = Process.whereis(process_name)

    case pid && Process.alive?(pid) do
      nil ->
        :ok

      true ->
        Process.unregister(process_name)
        Process.unlink(pid)
        Process.exit(pid, :kill)
    end
  end
end
