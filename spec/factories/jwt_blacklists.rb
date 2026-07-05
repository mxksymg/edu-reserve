FactoryBot.define do
  factory :jwt_blacklist do
    jti { "MyString" }
    exp { "2026-07-05 12:07:07" }
  end
end
