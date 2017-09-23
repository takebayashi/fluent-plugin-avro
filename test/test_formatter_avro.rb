require_relative 'helper'
require 'fluent/plugin/formatter'
require 'fluent/plugin/formatter_avro'

class AvroFormatterTest < ::Test::Unit::TestCase
  def setup
    @formatter = Fluent::Test::Driver::Formatter.new(Fluent::Plugin::AvroFormatter)
    conf = {
      'schema_json' => %q!
        {
          "type": "record",
          "name": "example",
          "namespace": "org.example",
          "fields": [
            {"name": "foo", "type": "string"},
            {"name": "baz", "type": "int"}
          ]
        }
      !
    }
    @formatter.configure(Fluent::Config::Element.new('', '', conf, []))
  end

  def test_format
    record = {'foo' => 'bar', 'baz' => 0}
    formatted = @formatter.instance.format('example.tag', Fluent::Engine.now, record)
    assert_equal("\u0006bar\u0000", formatted)
  end
end
