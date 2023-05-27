defmodule Sum do
  def loopy([head | tail], sum) do
    loopy(tail, head + sum)
  end

  def loopy([], sum), do: sum

  # def triple([head | tail]) do
  #   [head*3 | triple(tail)]
  # end

  # def triple([]), do: []

  def triple(list) do
    triple(list, [])
  end

  defp triple([head|tail], current_list) do
    triple(tail, [head*3 | current_list])
  end

  defp triple([], current_list) do
    current_list |> Enum.reverse()
  end
end

Sum.loopy([1, 2, 3, 4, 5], 0)
