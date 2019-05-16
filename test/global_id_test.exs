defmodule GlobalIdTest do
  use ExUnit.Case
  doctest GlobalId

  test "greets the world" do
    id = GlobalId.get_id()
    assert is_integer(id)
    assert id <= 0xFFFFFFFFFFFFFFFF
  end
end
