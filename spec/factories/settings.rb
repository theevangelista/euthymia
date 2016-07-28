# frozen_string_literal: true
FactoryGirl.define do
  factory :setting do
    user nil
    reminder_enabled false
    reminder_timer 'MyString'
  end
end
