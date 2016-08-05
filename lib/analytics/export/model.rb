module Analytics
  module Export
    module Model
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          attr_accessor :data
        end
      end

      def initialize(loaded_data)
        self.data = loaded_data
      end

      def filter(rows)
        rows
      end

      def records
        @records ||= self.filter data[self.class.rows]
      end

      # {
      #   username: ["blah", "blah2", "blah3"],
      #   role: ["admin", "owner", "owner"], ...
      # }
      def schema_records(records_set=nil)
        puts "  => generating schema records"
        recs = records_set || self.records

        Hash.new { |hash, key| hash[key] = [] }.tap do |h|
          total_records = recs.size
          all_elapsed = Benchmark.realtime do
            self.class.schema.each do |column, value|
              elapsed = Benchmark.realtime do
                puts "    => column #{column.inspect}, value #{value.inspect}"
                h[column] = recs.each_with_index.map do |record, i|
                  print "\r       record #{i} of #{total_records} (#{(i*100.0/total_records).round}%)" if i % 5 == 0 || i == (total_records - 1)

                  if value.respond_to? :call
                    value.call(record)
                  elsif record.respond_to? value
                    record.send(value)
                  else
                    self.send(value, record, i) if self.respond_to? value
                  end

                end
              end
              puts "\n       Done. Elapsed time: #{elapsed} seconds"
            end
          end
          puts "     Done. Elapsed time: #{all_elapsed} seconds"
        end
      end

      def filter_schema_records(&filter)
        record_set = filter.call(self.records)
        self.schema_records record_set
      end

      def generate_csv(path, file_name=nil, schema_record_set=nil)
        schema_recs = schema_record_set || self.schema_records

        file_name ||= "#{self.class.name.underscore}.csv"

        CSV.open(File.join(path, file_name), "w") do |csv|
          # Write header row
          csv << self.class.schema.keys

          # Zip schema_records values from each key
          schema_recs.values.transpose.each{ |record| csv << record }
        end
      end

      module ClassMethods
        def set_schema(schema_hash)
          @schema = schema_hash
        end

        def schema
          @schema
        end

        def rows_by(collection)
          @rows = collection
        end

        def rows
          @rows
        end
      end
    end
  end
end
