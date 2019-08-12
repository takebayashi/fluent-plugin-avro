require 'avro'
require 'fluent/plugin/formatter'
require 'net/http'
require 'uri'
require 'json'

module Fluent
  module Plugin
    class AvroFormatter < Formatter
      Fluent::Plugin.register_formatter('avro', self)

      config_param :schema_file, :string, :default => nil
      config_param :schema_json, :string, :default => nil
      config_param :schema_url, :string, :default => nil
      config_param :schema_url_key, :string, :default => nil

      def configure(conf)
        super
        if not((@schema_json.nil? ? 0 : 1)+(@schema_file.nil? ? 0:1)+(@schema_url.nil? ? 0:1) == 1) then
          raise Fluent::ConfigError, 'schema_json, schema_file, or schema_url is required, but not multiple!'
        end
        if @schema_json.nil? && not @schema_file.nil? then
          @schema_json = File.read(@schema_file)
        end
        if @schema_json.nil? && not @schema_url.nil? then
          @schema_json = fetchSchema(@schema_url,@schema_url_key)
        end
        @schema = Avro::Schema.parse(@schema_json)
        @writer = Avro::IO::DatumWriter.new(@schema)
      end

      def format(tag, time, record)
        buffer = StringIO.new
        encoder = Avro::IO::BinaryEncoder.new(buffer)
        begin
          @writer.write(record, encoder)
        rescue => e
          raise e if schema_url.nil?
          @schema_json = fetchSchema(@schema_url,@schema_url_key)
          @schema = Avro::Schema.parse(@schema_json)
          @writer = Avro::IO::DatumWriter.new(@schema)
          @writer.write(record, encoder)
        end
        buffer.string
      end

      def fetchURL(url)
        uri = URI.parse(url)
        response = Net::HTTP.get_response uri
        response.body
      end

      def fetchSchema(url,schema_key)
        responseBody = fetchURL(url)
        if schema_key.nil? then
          return responseBody
        else
          return JSON.parse(responseBody)[schema_key]
        end
      end
    end
  end
end
