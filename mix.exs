defmodule SmartTracer.MixProject do
  use Mix.Project

  def project do
    [
      app: :smart_tracer,
      version: "0.2.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: [
        main: "SmartTracer"
      ],
      source_url: "https://github.com/vinceurag/smart_tracer"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "A simple tracer with recording capabilities that would help you in live debugging."
  end

  defp package() do
    [
      licenses: ["MIT"],
      maintainers: ["Vince Urag"],
      links: %{"GitHub" => "https://github.com/vinceurag/smart_tracer"}
    ]
  end
end
