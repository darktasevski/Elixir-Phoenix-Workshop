defmodule Cards do
  @moduledoc """
    Provides methods to create, shuffle, and deal a deck of cards.
  """

  @doc """
    Creates a new deck of cards.
  """
  def create_deck do
    suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
    values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "Ace"]

    for suit <- suits, value <- values, do: "#{value} of #{suit}"
  end

  @doc """
    Shuffles the deck of cards.
  """
  def shuffle(deck) do
    Enum.shuffle(deck)
  end

  @doc """
    Checks if a card is in the deck.

  ## Examples

      iex> deck = Cards.create_deck()
      iex> Cards.contains?(deck, "2 of Hearts")
      true
  """
  def contains?(deck, card) do
    Enum.member?(deck, card)
  end

  @doc """
    Deals a hand of cards from the deck.

  ## Examples

      iex> deck = Cards.create_deck()
      iex> {hand, rest} = Cards.deal(deck, 1)
      iex> hand
      ["2 of Hearts"]
  """
  def deal(deck, hand_size) do
    {hand, rest} = Enum.split(deck, hand_size)

    {hand, rest}
  end

  @doc """
    Saves the deck to a file.
  """
  def save(deck, file_name) do
    binary = :erlang.term_to_binary(deck)
    {:ok, file} = File.open(file_name, [:write])
    IO.binwrite(file, binary)
    File.close(file)
  end

  @doc """
    Loads the deck from a file.
  """
  def load(filename) do
    case File.open(filename, [:read]) do
      {:ok, file} ->
        binary = IO.binread(file, :eof)
        File.close(file)
        :erlang.binary_to_term(binary)

      {:error, reason} ->
        {reason}
    end
  end

  @doc """
    Creates a hand of cards.
  """
  def create_hand(hand_size) do
    Cards.create_deck() |> Cards.shuffle() |> Cards.deal(hand_size)
  end
end
