defmodule SmartTracer.MixProject do
  use Mix.Project

  def project do
    [
      app: :smart_tracer,
      version: "0.1.2",
      elixir: "~> 1.6",
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

  defp deps do
    [
      {:recon, "~> 2.3.6"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "A simple wrapper around `recon_trace` that would help you in live debugging."
  end

  defp package() do
    [
      licenses: ["MIT"],
      maintainers: ["Vince Urag"],
      links: %{"GitHub" => "https://github.com/vinceurag/smart_tracer"}
    ]
  end
end
