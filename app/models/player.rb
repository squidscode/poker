class Player < ApplicationRecord
  # Secure token
  has_secure_token :auth_token, length: 36

  # Validations
  validates :name,        presence: true
  validates :game_id,     presence: true
  validates :chips,       presence: true
end
