require 'avro'

module Fluent
  module TextFormatter
    class AvroFormatter < Formatter
      Fluent::Plugin.register_formatter('avro', self)

      config_param :schema, :string, :default => nil,
                   :desc => "avro schema"
      config_param :file, :bool, :default => false,
                   :desc => "set to true if loading schema from file"

      def configure(conf)
        super
        if @file == true then
          @schema = File.read(@schema)
        end
        @schema = Avro::Schema.parse(@schema)
      end

      def format(tag, time, record)
        writer = Avro::IO::DatumWriter.new(@schema)
        buffer = StringIO.new
        writer = Avro::DataFile::Writer.new(buffer, writer, @schema)
        buffer.string
      end
    end
  end
end
