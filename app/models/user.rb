class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         # using JWT for authentication and the JWTBlacklist model to revoke invalidated tokens
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist
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
end
