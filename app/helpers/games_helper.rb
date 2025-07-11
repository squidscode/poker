RANKS = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
SUITS = ["H", "D", "S", "C"]

module GamesHelper
  def back 
    "sofu_playing_cards_pack/PNG/cards(large)/card_back_01.png"
  end

  def rank
    return {
      A: "A", 
      "2": "02",
      "3": "03", "4": "04", "5": "05", "6": "06", "7": "07", "8": "08", "9": "09",
      T: "10", J: "j", Q: "Q", K: "K"
    }
  end

  def suit
    return {
      H: "hearts", S: "spades", D: "diamonds", C: "clubs"
    }
  end

  def card_src(c)
    return "sofu_playing_cards_pack/PNG/cards(large)/card_" \
        "#{suit[c[1].intern]}_#{rank[c[0].intern]}.png"
  end


  # Returns the index of the winner
  def get_winners(community_cards, hole_cards)
    community_cards = community_cards.split(",")
    hole_cards = hole_cards.map {|hc| hc.split(",")}
    if (winners = royal_flush(community_cards, hole_cards)) != []
      return winners
    elsif (winners = straight_flush(community_cards, hole_cards)) != []
      return winners
    elsif (winners = four_of_a_kind(community_cards, hole_cards)) != []
      return winners
    elsif (winners = full_house(community_cards, hole_cards)) != []
      return winners
    elsif (winners = pflush(community_cards, hole_cards)) != []
      return winners
    elsif (winners = straight(community_cards, hole_cards)) != []
      return winners
    elsif (winners = three_of_a_kind(community_cards, hole_cards)) != []
      return winners
    elsif (winners = two_pair(community_cards, hole_cards)) != []
      return winners
    elsif (winners = pair(community_cards, hole_cards)) != []
      return winners
    else 
      return high_card(community_cards, hole_cards)
    end
  end

  def collect_winners(cc, hcs, condition)
    winners = []; best = nil
    hcs.map.with_index do |hc, i|
      if (val = method(condition).call(cc + hc)) != nil \
          && (best == nil || best <= val)
        if best != nil && best < val; winners = []; end
        if best == nil; best = val; end
        winners << i
      end
    end
    return winners
  end

  def royal_flush(cc, hcs)
    collect_winners(cc, hcs, :is_royal_flush)
  end

  def is_royal_flush(cards)
    return SUITS.map do |suit|
      cards
        .filter {|card| card[1] == suit}
        .map {|card| card[0]}
        .filter {|rank| ["T", "J", "Q", "K", "A"].include?(rank)}
        .length
    end
      .any? {|l| l == 5}
      .then {|tf| tf ? 1 : nil }
  end

  def straight_flush(cc, hcs)
    collect_winners(cc, hcs, :is_straight_flush)
  end

  def is_straight_flush(cards)
    return ["H", "D", "S", "C"].map do |suit|
      cards
        .filter {|card| card[1] == suit}
        .map {|card| card[0]}
        .sort {|r1, r2| RANKS.index(r1) <=> RANKS.index(r2)}
        .then {|c| c.include?(12) ? c.unshift(-1) : c }
        .map {|r| RANKS.index(r)}
      end
      .tap {|arr| p "checking for straight flush in ", arr}
      .map do |arr|
        prev = -2; run = 0; max_run = 0
        max_card = -2
        arr.each do |i|
          if i == prev + 1; run += 1
          else; run = 1; end
          if run >= 5; max_card = i; end
          max_run = [max_run, run].max; prev = i
        end
        max_run >= 5 ? max_card : -5
      end
      .filter {|mc| mc != -5}
      .max
  end

  def four_of_a_kind(cc, hcs)
    collect_winners(cc, hcs, :is_four_of_a_kind)
  end

  def is_four_of_a_kind(cards)
    return RANKS
      .map {|rank| cards.filter {|card| card[0] == rank}}
      .then {|arr| arr.length >= 4 ? RANKS.index(arr[0][0]) : nil}
  end

  def full_house(cc, hcs)
    return collect_winners(cc, hcs, :is_full_house)
  end

  def is_full_house(cards)
    rank_map = RANKS
      .map {|rank| cards.filter {|card| card[0] == rank}}
      .map {|arr| arr.map {|card| RANKS.index(card[0])}}
    threes = rank_map
      .filter {|arr| arr.length == 3}
      .map {|arr| arr[0]}
      .max
    pairs = rank_map
      .filter  {|arr| arr.length == 2}
      .map {|arr| arr[0]}
      .max
    # Rank by the order of threes first, then the order of the pairs
    return threes.nil? || pairs.nil? ? nil : 100 * threes + pairs
  end

  def pflush(cc, hcs)
    return collect_winners(cc, hcs, :is_flush)
  end

  def is_flush(cards)
    return SUITS
      .map {|suit| cards.filter {|card| card[1] == suit}}
      .filter {|arr| arr.length == 5}
      .map {|arr| RANKS.index(arr[0][0])}
      .max
  end

  def straight(cc, hcs)
    return collect_winners(cc, hcs, :is_straight)
  end

  def is_straight(cards)
    return cards
      .map {|card| card[0]}
      .sort {|r1, r2| RANKS.index(r1) <=> RANKS.index(r2)}
      .map {|r| RANKS.index(r)}
      .then {|arr| arr.include?(12) ? arr.unshift(-1) : arr }
      .then do |arr|
        prev = -2; run = 0; max_run = 0
        max_card = -2
        arr.each do |i|
          if i == prev + 1; run += 1
          else; run = 1; end
          if run >= 5; max_card = i; end
          max_run = [max_run, run].max; prev = i
        end
        max_run >= 5 ? max_card : nil
      end
  end

  def three_of_a_kind(cc, hcs)
    return collect_winners(cc, hcs, :is_three_of_a_kind)
  end

  def is_three_of_a_kind(cards)
    return RANKS
      .map {|rank| cards.filter {|card| card[0] == rank}}
      .filter {|arr| arr.length >= 3}
      .map {|arr| RANKS.index(arr[0][0])}
      .max
  end

  def two_pair(cc, hcs)
    return collect_winners(cc, hcs, :is_two_pair)
  end

  def is_two_pair(cards)
    RANKS
      .map {|rank| cards.filter {|card| card[0] == rank}}
      .filter {|arr| arr.length >= 2}
      .map {|arr| RANKS.index(arr[0][0])}
      .then do |arr|
        arr.length >= 2 ? 
        100 * arr.max(2)[0] + arr.max(2)[1] :
        nil
      end
  end

  def pair(cc, hcs)
    return collect_winners(cc, hcs, :is_pair)
  end

  def is_pair(cards)
    return RANKS
      .map {|rank| cards.filter {|card| card[0] == rank}}
      .filter {|arr| arr.length >= 2}
      .map {|arr| RANKS.index(arr[0][0])}
      .max
  end

  def high_card(cc, hcs)
    return collect_winners(cc, hcs, :is_high_card)
  end

  def is_high_card(cards)
    return cards
      .map {|card| RANKS.index(card[0])}
      .max
  end
end
