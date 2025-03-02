defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list()
    %Identicon.Image{hex: hex}
  end

  def pick_color(%Identicon.Image{hex: [red, green, blue | _tail],} = image) do
    %Identicon.Image{ image | color: {red, green, blue}}
  end

  def build_grid(%Identicon.Image{hex: hex,} = image) do
   grid =
    hex
    |> Enum.chunk(3)
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    |> Enum.with_index
    %Identicon.Image{image | grid: grid}
  end

  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid =
      Enum.filter grid, fn({hex, _index} = _square) ->
          rem(hex, 2) == 0
      end
    %Identicon.Image{ image | grid: grid }
  end

  def build_pixel_map(%Identicon.Image{grid: grid,} = image) do
    pixel_map = Enum.map grid, fn({_hex, index}) ->
      horizotal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizotal, vertical}
      bottom_right = {horizotal + 50, vertical + 50}

      {top_left, bottom_right}
     end
     %Identicon.Image{ image | pixel_map: pixel_map }
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
        :egd.filledRectangle(image, start, stop, fill)
    end
    :egd.render(image)
  end

  def save_image(image, name) do
    File.write("#{name}.png", image)
  end

end
