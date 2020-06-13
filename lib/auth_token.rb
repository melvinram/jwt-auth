class AuthToken
  attr_accessor :value, :user

  def initialize(value: nil, user: nil)
    @value = value
    @user = user
  end

  def valid?
    @value.present?
  end
end
