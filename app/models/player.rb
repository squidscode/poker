class Player < ApplicationRecord
  # Secure token
  has_secure_token :auth_token, length: 36

  # Validations
  validates :name,        presence: true
  validates :game_id,     presence: true
  validates :chips,       presence: true

  after_initialize :set_defaults, unless: :persisted?

  def set_defaults
    self.kick = 0
    self.fold = 0
  end
end
