defmodule Metallurgy.MixProject do
  use Mix.Project

  @test_envs [:test, :integration]

  def project do
    [
      app: :metallurgy,
      version: "0.1.0",
      elixir: "~> 1.8",
      escript: [main_module: Metallurgy],
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      test_paths: test_paths(Mix.env()),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:cli_spinners, "~> 0.1.0"},
      {:mogrify, "~> 0.7.2"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:dogma, "~> 0.1", only: [:dev]}
    ]
  end

  defp elixirc_paths(env) when env in @test_envs, do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
  defp test_paths(:integration), do: ["test/integration"]
  defp test_paths(:test), do: ["test/unit"]
  defp test_paths(_), do: ["test/dev"]
end
