class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         # using JWT for authentication and the JWTBlacklist model to revoke invalidated tokens
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist
  # enum is a built-in Rails feature that defines a model attribute as a set of predefined values (roles).
  # As a result, the database stores integer values (e.g. 0, 1, 2, 3), while in Ruby you can work with descriptive names such as :admin or :student
  # enum role: { student: 0, teacher: 1, school_owner: 2, admin: 3 }
  has_many :reservations, dependent: :destroy
  # JWTBlacklist stores revoked JWT tokens. It allows users to log out by invalidating their tokens, preventing further access to the API
  # Without a blacklist : JWT is stateless, tokens remain valid until they expire, logging out does not invalidate the token
  # With a blacklist : each token has a unique identifier (jti), every request checks whether the token has been revoked, logging out
  # adds the token to the blacklist, revoked tokens can no longer be used, expired blacklist entries can be removed periodically
  def generate_jwt
    # Creates a payload hash containing the data that will be encoded into the JWT.
    # user_id: id – stores the user's ID, which will be used for identification during authentication.
    # exp: – sets the token expiration time.
    # 24.hours.from_now returns a time object representing a point 24 hours in the future.
    # .to_i converts it into a Unix timestamp (seconds since 1970-01-01).
    # Example of payload : { user_id: 1, exp: 1719937800 }
    payload = { user_id: id, exp: 24.hours.from_now.to_i }
    # JWT.decode - a method provided by the jwt gem that decodes and verifies a JWT.
    # It accepts four arguments : token – the JWT string to decode, secret – the secret key used to verify the token's signature,
    # verify – whether the token should be verified (true enables signature verification), options – a hash of additional options
    # such as the signing algorithm
    JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
  end
  # The database does not contain an admin column. It uses a role column instead. However SchoolPolicy calls user.admin?, which does not exist
  # by default. By adding an admin? method to the User model, user.admin? becomes available and checks the value of the role attribute to
  # determine whether the user is an administrator.
  def admin?
    role == "admin"
  end
  def school_owner?
    role == "school_owner"
  end
end
