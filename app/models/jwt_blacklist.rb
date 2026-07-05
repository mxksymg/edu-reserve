# class JwtBlacklist < ApplicationRecord - defines the JWTBlacklist model, which inherits from ApplicationRecord.
class JwtBlacklist < ApplicationRecord
    # Includes the built-in token revocation strategy provided by the devise-jwt gem. This enables the model to automatically handle :
    # storing the token's unique identifier (jti), checking whether a token has been blacklisted, adding a token to the blacklist when the user logs out
    include Devise::JWT::RevocationStrategies::Denylist
end
