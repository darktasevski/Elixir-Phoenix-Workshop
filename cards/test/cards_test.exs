defmodule CardsTest do
  use ExUnit.Case
  doctest Cards

  test "create_deck creates a deck of cards" do
    deck = Cards.create_deck()
    assert Enum.count(deck) == 52
  end

  test "shuffle shuffles the deck" do
    deck = Cards.create_deck()
    shuffled = Cards.shuffle(deck)
    assert deck != shuffled
  end

  test "contains? checks if a card is in the deck" do
    deck = Cards.create_deck()
    assert Cards.contains?(deck, "2 of Hearts")
  end

  test "deal deals a hand of cards from the deck" do
    deck = Cards.create_deck()
    {hand, rest} = Cards.deal(deck, 1)
    assert Enum.count(hand) == 1
    assert Enum.count(rest) == 51
    assert Enum.at(hand, 0) == Enum.at(deck, 0)
  end
end
