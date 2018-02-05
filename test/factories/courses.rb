# == Schema Information
#
# Table name: courses
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  year              :string(255)
#  secret            :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  description       :text(65535)
#  visibility        :integer          default("visible")
#  registration      :integer          default("open")
#  correct_solutions :integer
#  color             :integer
#  teacher           :string(255)      default("")
#

FactoryGirl.define do
  factory :course do
    name { "#{Faker::Hacker.adjective.titlecase} Programming" }
    description { Faker::Hacker.say_something_smart }
    visibility 'visible'
    registration 'open'
    teacher { "Prof. #{Faker::Name.first_name} #{Faker::Name.last_name}" }

    transient do
      series_count 0
      exercises_per_series 0
      start_year Time.zone.today.year
    end

    year { "#{start_year}-#{start_year + 1}" }
  end
end
