module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Time #:nodoc:
      # Methods for creating TimeWithZone objects from Time instances
      module Zones
        
        def self.included(base) #:nodoc:
          base.extend(ClassMethods) if base == ::Time # i.e., don't include class methods in DateTime
        end
        
        module ClassMethods
          attr_reader :zone

          # Sets a global default time zone, separate from the system time zone in ENV['TZ']. 
          # Accepts either a Rails TimeZone object, a string that identifies a 
          # Rails TimeZone object (e.g., "Central Time (US & Canada)"), or a TZInfo::Timezone object
          #
          # Any Time or DateTime object can use this default time zone, via #in_current_time_zone.
          # Example:
          #
          #   Time.zone = 'Hawaii'                  # => 'Hawaii'
          #   Time.utc(2000).in_current_time_zone   # => Fri, 31 Dec 1999 14:00:00 HST -10:00
          def zone=(zone)
            @zone = get_zone(zone)
          end
          
          def zone_reset!
            @zone = nil
          end
          
          def get_zone(zone)
            ::String === zone || ::Numeric === zone ? TimeZone[zone] : zone
          end
        end
        
        # Gives the corresponding time in the supplied zone. self is assumed to be in UTC regardless of constructor.
        #
        # Examples:
        #
        #   t = Time.utc(2000)        # => Sat Jan 01 00:00:00 UTC 2000
        #   t.in_time_zone('Alaska')  # => Fri, 31 Dec 1999 15:00:00 AKST -09:00
        #   t.in_time_zone('Hawaii')  # => Fri, 31 Dec 1999 14:00:00 HST -10:00
        def in_time_zone(zone)
          ActiveSupport::TimeWithZone.new(self, ::Time.get_zone(zone))
        end

        # Returns the simultaneous time in Time.zone
        def in_current_time_zone
          in_time_zone(::Time.zone)
        end

        # Replaces the existing zone; leaves time value intact. Examples:
        #
        #   t = Time.utc(2000)            # => Sat Jan 01 00:00:00 UTC 2000
        #   t.change_time_zone('Alaska')  # => Sat, 01 Jan 2000 00:00:00 AKST -09:00
        #   t.change_time_zone('Hawaii')  # => Sat, 01 Jan 2000 00:00:00 HST -10:00
        def change_time_zone(zone)
          ActiveSupport::TimeWithZone.new(nil, ::Time.get_zone(zone), self)
        end

        # Replaces the existing zone to Time.zone; leaves time value intact
        def change_time_zone_to_current
          change_time_zone(::Time.zone)
        end
      end
    end
  end
end