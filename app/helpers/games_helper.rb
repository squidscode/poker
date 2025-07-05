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

end
