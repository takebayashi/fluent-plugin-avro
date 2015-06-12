require 'avro'

module Fluent
  module TextFormatter
    class AvroFormatter < Formatter
      Fluent::Plugin.register_formatter('avro', self)

      config_param :schema_file, :string

      def configure(conf)
        super
        @schema = Avro::Schema.parse(File.read(@schema_file))
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
