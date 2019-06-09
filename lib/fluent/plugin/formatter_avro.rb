require 'avro'
require 'fluent/plugin/formatter'

module Fluent
  module Plugin
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
        @buffer = StringIO.new
        @writer = Avro::DataFile::Writer.new(@buffer, Avro::IO::DatumWriter.new(@schema), @schema)
      end

      def stop
        super
        @writer.close
      end

      def format(tag, time, record)
        if record.has_value?('-') then
          @writer.close
          bytes = @buffer.string
          @buffer = StringIO.new
          @writer = Avro::DataFile::Writer.new(@buffer, Avro::IO::DatumWriter.new(@schema), @schema)
        else
          @writer << record
        end
        bytes
      end
    end
  end
end
