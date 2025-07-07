class PlayerRequest < ApplicationRecord
  # Secure token
  has_secure_token :auth_token, length: 36

  validates :name,        presence: true
end
