require 'csv'
require 'time'

require_relative 'csv_record'

module RideShare
  class Trip < CsvRecord
    attr_reader :id, :passenger, :passenger_id,:driver, :driver_id, :start_time, :end_time, :cost, :rating

    def initialize(
          id:,
          passenger: nil,
          passenger_id: nil,
          driver: nil,
          driver_id: nil,
          start_time:,
          end_time:,
          cost: nil,
          rating:
        )
      super(id)

      if passenger
        @passenger = passenger
        @passenger_id = passenger.id

      elsif passenger_id
        @passenger_id = passenger_id

      else
        raise ArgumentError, 'Passenger or passenger_id is required'
      end

      raise ArgumentError, 'Driver or driver_id is required' unless driver || driver_id
      @driver = driver
      @driver.nil? ? @driver_id = driver_id : @driver_id = driver.id

      @start_time = start_time
      @end_time = end_time
      raise ArgumentError.new("Start time should occur before the end time") if @start_time > @end_time unless @end_time.nil?

      @cost = cost

      @rating = rating
      raise ArgumentError.new("Invalid rating #{@rating}") if @rating > 5 || @rating < 1 unless @rating.nil?

    end

    def duration
      if @end_time.nil?
        duration = 0
      else
        duration = @end_time - @start_time
      end
      return duration.to_i
    end

    def inspect
      # Prevent infinite loop when puts-ing a Trip
      # trip contains a passenger contains a trip contains a passenger...
      "#<#{self.class.name}:0x#{self.object_id.to_s(16)} " +
        "id=#{id.inspect} " +
        "passenger_id=#{passenger&.id.inspect} " +
        "driver_id=#{driver&.id.inspect} " +
        "start_time=#{start_time} " +
        "end_time=#{end_time} " +
        "cost=#{cost}  " +
        "rating=#{rating}>"
    end

    def connect(passenger, driver)
      @passenger = passenger
      @driver = driver
      passenger.add_trip(self)
      driver.add_trip(self)
    end

    private

    def self.from_csv(record)
      return self.new(
               id: record[:id],
               passenger_id: record[:passenger_id],
               driver_id: record[:driver_id],
               start_time: Time.parse(record[:start_time]),
               end_time: Time.parse(record[:end_time]),
               cost: record[:cost],
               rating: record[:rating]
             )
    end
  end
end
