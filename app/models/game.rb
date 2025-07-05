class Game < ApplicationRecord
  # Secure token for auth
  has_secure_token :auth_token, length: 36

  # Validations
  validates :auth_token,      presence: true
  validates :deck,            presence: true
  validates :name,            presence: true
  validates :pot,             presence: true

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
end
