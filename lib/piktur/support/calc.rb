# frozen_string_literal: true

module Piktur

  module Support
    
    # Simple calculators
    module Calc

      SECONDS = 24 * (60 * 60)

      # @see https://stackoverflow.com/a/1404
      # @param [Date] birthday
      # @return [Integer]
      Age = proc do |birthday|
        birthday      = birthday.to_date unless birthday.is_a?(::Date)
        current_date  = Date.today
        current_year  = current_date.year
        birth_year    = birthday.year

        # Calculate the age.
        age = current_year - birth_year
        # Go back to the year the person was born in case of a leap year
        birthday > current_date.advance(years: -age) ? age - 1 : age
      end

      # Return today full day name
      # @return [Symbol]
      def self.day_name
        ::Time.zone.now.strftime('%A').downcase.to_sym
      end

      # Parse string representation of time and advance to time on the coming `day`
      # @param [String, Time] time string
      # @param [Symbol] day
      def self.next_day(time, day)
        time    = ::Time.zone.parse(time) if time.is_a?(String)
        from    = ::Date::DAYS_INTO_WEEK[day_name] * SECONDS
        to      = ::Date::DAYS_INTO_WEEK[day.to_sym] * SECONDS

        ::Time.zone.today.beginning_of_day
          .advance(seconds: (to - from) + time.seconds_since_midnight)
      end

    end

  end

end
