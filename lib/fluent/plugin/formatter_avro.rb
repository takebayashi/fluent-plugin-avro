require 'avro'

module Fluent
  module TextFormatter
    class AvroFormatter < Formatter
      Fluent::Plugin.register_formatter('avro', self)

      config_param :schema_file, :string, :default => nil
      config_param :schema_json, :string, :default => nil

      def configure(conf)
        super
        if not (@schema_json.nil? ^ @schema_file.nil?) then
          raise Fluent::ConfigError, 'schema_json or schema_file (but not both) is required'
        end
        if @schema_json.nil? then
          @schema_json = File.read(@schema_file)
        end
        @schema = Avro::Schema.parse(@schema_json)
      end

      def format(tag, time, record)
        writer = Avro::IO::DatumWriter.new(@schema)
        buffer = StringIO.new
        encoder = Avro::IO::BinaryEncoder.new(buffer)
        writer.write(record, encoder)
        buffer.string
      end
    end
  end
end
