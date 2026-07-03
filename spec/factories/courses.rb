FactoryBot.define do
  factory :course do
    name { "MyString" }
    description { "MyText" }
    category { "MyString" }
    level { "MyString" }
    age_group { "MyString" }
    duration { 1 }
    price { "9.99" }
    school { nil }
    teacher { nil }
    max_students { 1 }
  end
end
