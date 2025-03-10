defmodule Identicon do
  def main(input) do
    input
    |> hash_string()
    |> generate_image()
    |> pick_color()
    |> build_grid()
    |> filter_odd_squares()
    |> build_pixel_map()
    |> draw_image()
  end

  def hash_string(input) do
    :crypto.hash(:md5, input) |> :binary.bin_to_list()
  end

  def generate_image(hash) do
    %Identicon.Image{hex: hash}
  end

  def pick_color(image) do
    [r, g, b] = Enum.take(image.hex, 3)

    # This syntax %Identicon.Image{image | color: {r, g, b}} is used to create a new struct based on an existing one (image), but with the color field updated to a new value (rgb).
    %Identicon.Image{image | color: {r, g, b}}
  end

  def mirror_row(row) do
    # given the [145, 46, 200] list, return the [145, 46, 200, 46, 145] list, excluding the last element from the original list.
    row ++ Enum.reverse(Enum.take(row, 2))
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      Enum.chunk_every(hex, 3, 3, :discard)
      # Extra safeguard to ensure mirror_row/1 only processes full-length chunks by discarding incomplete chunks.
      |> Enum.filter(fn chunk -> length(chunk) == 3 end)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    filtered_grid =
      Enum.filter(grid, fn {color, _index} ->
        rem(color, 2) == 0
      end)

    %Identicon.Image{image | grid: filtered_grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {color, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{pixel_map: pixel_map, color: color}) do
    width = 250
    height = 250

    # Convert color tuple `{r, g, b}` into an RGB list
    {r, g, b} = color
    default_color = {r, g, b}

    # Create a blank image filled with white
    pixels = for _y <- 1..height, _x <- 1..width, do: {255, 255, 255}

    # Apply filled rectangles from pixel_map
    updated_pixels =
      Enum.reduce(pixel_map, pixels, fn {start, stop}, acc ->
        fill_rectangle(acc, start, stop, width, default_color)
      end)

    {:ok, png_data} = StbImageWrite.write_png(width, height, updated_pixels)

    File.write!("output.png", png_data)
  end

  defp fill_rectangle(pixels, {x1, y1}, {x2, y2}, width, color) do
    Enum.with_index(pixels)
    |> Enum.map(fn {{r, g, b}, i} ->
      x = rem(i, width)
      y = div(i, width)

      if x1 <= x and x <= x2 and y1 <= y and y <= y2 do
        color
      else
        {r, g, b}
      end
    end)
  end
end
