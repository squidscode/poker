require "thread"

include GamesHelper

BUY_IN = 1000
BIG_BLIND = BUY_IN / 100

GAME_MUTEX = {}
GAME_CONDITION_VAR = {}
GAME_PAUSED = {}

class Game < ApplicationRecord
  # Secure token for auth
  has_secure_token :auth_token, length: 36

  # Validations
  validates :auth_token,      presence: true
  validates :deck,            presence: true
  validates :name,            presence: true
  validates :pot,             presence: true

  has_many :players
  has_many :player_requests

  def self.new(**kwargs)
    super(deck:self.initial_deck().join(","), **kwargs)
  end

  def self.initial_deck()
    a = []
    for suit in ["H", "S", "D", "C"] do
      for rank in ["A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"] do
        a << rank + suit
      end
    end
    return a.shuffle()
  end
  
=begin
  A big issue with the play_game function right now, is that it 
  uses a thread to suspend a the game while waiting for clients 
  to make their moves.

  TODO: add the state of the game to the SQL database so that we don't need to 
  use threads to suspend the function.
=end

  def play_game
    GAME_MUTEX[self.id] = Mutex.new
    GAME_CONDITION_VAR[self.id] = ConditionVariable.new
    GAME_PAUSED[self.id] = 0
    return Thread.new do
      self._play_game()
    end
  end

  def _play_game
    # Refresh player list
    self.players = Player.where(game_id: self.id)
    self.player_ids = self.players.map {|player| player.id}
    self.community_cards = nil
    self.winners = nil

    # Initialize the game
    self.deck = Game.initial_deck().join(",")
    self.set_dealer(self.player_ids)
    self.set_active_player(self.player_ids)
    self.pot = 0

    # Deal the hole cards
    self.deal_hole_cards()

    # Start taking turns
    self.take_turn(0, true)
    self.take_turn(3)
    self.take_turn(1)
    self.take_turn(1)

    # No players are allowed to bet anymore
    self.active_player = 0
    self.save()

    # Determine and give payout
    hole_cards = players.map {|player| player.hole_cards}
    winning_player_indices = get_winners(self.community_cards, hole_cards)
    puts "Winners for game ##{self.id}: #{winning_player_indices}"
    winning_player_indices.each do |i|
      self.players[i].chips += self.pot / winning_player_indices.length
      self.players[i].save
    end

    self.pot = 0
    self.winners = winning_player_indices
      .map {|i| self.players[i].id}
      .join(",")
    self.save()
  end

  def set_active_player(player_ids)
    puts "player_ids: #{player_ids}"
    puts "dealer: #{self.dealer}"
    self.active_player = player_ids[
      (player_ids.index(self.dealer) + 3) % player_ids.length
    ]
  end


  def set_dealer(player_ids)
    if self.dealer == nil
      self.dealer = player_ids[0]
    else
      p = (player_ids.index(self.dealer) + 1) % player_ids.length
      self.dealer = player_ids[p]
    end
  end

  def deal_hole_cards()
    self.players.each do |player|
      player.hole_cards = self.shift_cards_from_deck(2)
      player.fold = 0
      player.save
    end
    self.save
  end

  def shift_cards_from_deck(n)
    deck = self.deck.split(",")
    cards = deck.shift(n)
    self.deck = deck.join(",")
    return cards.join(",")
  end

  # A turn consists of first revealing n cards, then allowing the 
  # players to make their bets
  def take_turn(cards_to_reveal, first_round = false)
    self.reveal_n_cards(cards_to_reveal)
    self.take_player_bets(first_round)
  end

  def reveal_n_cards(n)
    if self.community_cards == nil || self.community_cards == ""
      self.community_cards = shift_cards_from_deck(n)
    else
      self.community_cards += "," + shift_cards_from_deck(n)
    end
  end

  def take_player_bets(first_round = false)
    puts "taking player bets..."
    n = self.players.length
    dealer_index = self.player_ids.index(self.dealer)
    active_player_index = dealer_index

    self.players.each do |player|
      player.bet = 0
      player.save
    end
    
    if first_round
      for i in 1..2 do
        player = self.players[(dealer_index + i) % n]
        self.raise(player, BUY_IN / 100 / (3-i))
      end
    end

    active_player_index = (dealer_index + 3) % n
    self.active_player = self.player_ids[active_player_index]
    self.raise_opportunities = n
    self.save

    # Loop until entire circle of betting with 
    # ~no raising~ has happened
    while self.raise_opportunities > 0
      self.broadcast_change()

      if self.players[active_player_index].fold == 0
        self.pause()
        self.reload
      end

      active_player_index = (active_player_index + 1) % n
      self.active_player = self.player_ids[active_player_index]
      self.raise_opportunities -= 1
      self.save
    end

    self.players.each do |player|
      self.pot += player.bet
      player.bet = 0
      player.save
    end

    self.save()
    self.broadcast_change()
  end

  def broadcast_change
    ActionCable.server.broadcast("game_#{self.id}", {action: "reload"})
  end


  def pause
    GAME_MUTEX[self.id].synchronize {
      while GAME_PAUSED[self.id] == 0
        GAME_CONDITION_VAR[self.id].wait(GAME_MUTEX[self.id])
      end
      GAME_PAUSED[self.id] -= 1
    }
  end

  def unpause
    GAME_MUTEX[self.id].synchronize {
      GAME_PAUSED[self.id] = 1            # unpause the game
      GAME_CONDITION_VAR[self.id].signal
    }
  end

  def raise(player, raise_amount)
    if self.players == nil
      self.players = Player.where(game_id: self.id)
    end

    max_bet = 0
    self.players.each do |players|
      max_bet = [players.bet, max_bet].max
    end

    if max_bet <= player.chips + raise_amount && raise_amount <= player.chips # if valid
      player.chips -= raise_amount
      player.bet   += raise_amount
      player.save

      if max_bet < raise_amount
        self.raise_opportunities = self.players.length
      end

      self.save

      return true
    else # else if invalid
      puts "TODO: DO SOMETHING!"
      return false
    end
  end

  def fold(player)
    player.fold = 1
    player.save
  end
end
