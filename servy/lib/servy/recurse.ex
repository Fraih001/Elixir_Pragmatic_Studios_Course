defmodule Recurse do
  def my_map([head | tail], function) do
    [function.(head) | my_map(tail, function)]
  end

  def my_map([], _fun), do: []
end
