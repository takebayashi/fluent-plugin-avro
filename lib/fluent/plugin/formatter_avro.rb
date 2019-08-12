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
        if not ((@schema_json.nil? ? 0 : 1) + (@schema_file.nil? ? 0 : 1) + (@schema_url.nil? ? 0 : 1) == 1) then
          raise Fluent::ConfigError, 'schema_json, schema_file, or schema_url is required, but not multiple!'
        end
        if (@schema_json.nil? && !@schema_file.nil?) then
          @schema_json = File.read(@schema_file)
        end
        if (@schema_json.nil? && !@schema_url.nil?) then
          @schema_json = fetch_schema(@schema_url,@schema_url_key)
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
          schema_changed = false
          begin
            new_schema_json = fetch_schema(@schema_url,@schema_url_key)
            new_schema = Avro::Schema.parse(@schema_json)
            schema_changed = (new_schema_json == @schema_json)
            @schema_json = new_schema_json
            @schema = new_schema
          rescue
          end
          if schema_changed then
            @writer = Avro::IO::DatumWriter.new(@schema)
            @writer.write(record, encoder)
          else
            raise e
          end
        end
        buffer.string
      end

      def fetch_url(url)
        uri = URI.parse(url)
        response = Net::HTTP.get_response uri
        response.body
      end

      def fetch_schema(url,schema_key)
        response_body = fetch_url(url)
        if schema_key.nil? then
          return response_body
        else
          return JSON.parse(response_body)[schema_key]
        end
      end
    end
  end
end
