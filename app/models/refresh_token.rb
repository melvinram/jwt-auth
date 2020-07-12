class RefreshToken < ApplicationRecord
  EXPIRATION_PERIOD = 7.days

  belongs_to :user
  before_save :set_default_expiration_time

  has_secure_token

  scope :active, -> { where("expires_at > ?", Time.now) }

  validates_uniqueness_of :token

  def set_default_expiration_time
    self.expires_at ||= EXPIRATION_PERIOD.from_now
  end
end
