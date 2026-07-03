FactoryBot.define do
  factory :invitation do
    email { "MyString" }
    token { "MyString" }
    school { nil }
    sent_at { "2026-07-03 23:33:54" }
    accepted_at { "2026-07-03 23:33:54" }
    expired_at { "2026-07-03 23:33:54" }
  end
end
