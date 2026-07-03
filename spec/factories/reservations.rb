FactoryBot.define do
  factory :reservation do
    user { nil }
    schedule { nil }
    status { "MyString" }
  end
end
