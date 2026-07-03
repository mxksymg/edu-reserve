FactoryBot.define do
  factory :schedule do
    weekday { 1 }
    start_time { "2026-07-03 17:40:48" }
    end_time { "2026-07-03 17:40:48" }
    room { "MyString" }
    course { nil }
    teacher { nil }
  end
end
