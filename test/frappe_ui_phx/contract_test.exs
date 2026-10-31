defmodule FrappeUIPhx.ContractTest do
  use ExUnit.Case, async: true

  alias FrappeUIPhx.Contract

  test "require!/3 devolve o valor quando está no domínio" do
    assert Contract.require!(:solid, [:solid, :ghost], "variant") == :solid
  end

  test "require!/3 falha alto, nomeando o campo e o domínio" do
    error = assert_raise ArgumentError, fn -> Contract.require!(:sombrio, [:solid], "variant") end
    assert error.message =~ "variant"
    assert error.message =~ ":sombrio"
    assert error.message =~ ":solid"
  end

  test "ensure!/2 aceita condição verdadeira e falha alto na falsa" do
    verdadeiro = Enum.any?([1])
    falso = Enum.empty?([1])
    assert Contract.ensure!(verdadeiro, "ok") == :ok
    assert_raise ArgumentError, "quebrou", fn -> Contract.ensure!(falso, "quebrou") end
    assert_raise ArgumentError, fn -> Contract.ensure!(List.first([]), "nil conta como falso") end
  end
end
