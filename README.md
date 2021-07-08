# fluent-plugin-avro-confluent


[![Build Status](https://travis-ci.org/takebayashi/fluent-plugin-avro.svg)](https://travis-ci.org/takebayashi/fluent-plugin-avro)

fluent-plugin-avro provides a formatter plugin for Fluentd.

## Configurations

Either `schema_file`, `schema_json`, or `schema_url` is required.

| Name | Description |
| ---- | ----------- |
| `schema_file` | filename of Avro schema |
| `schema_json` | JSON representation of Avro schema |
| `schema_url`  | URL to JSON representation of Avro schema |
| `schema_url_key`  | JSON key under response body of where the JSON representation of Avro schema is |
| `schema_id`  | SchemaRegistry Id to be added to avro file |

### Example

```
<match example.avro>
  @type file
  path /path/to/output
  <formatter>
    @type avro
    schema_file /path/to/schema.avsc
  </formatter>

  ## You can use schema_json instead of schema_file
  # schema_json {"type":"record","name":"example","namespace":"org.example","fields":[{"name":"message","type":"string"}]}
  ## You can also use schema_url to fetch from a schema registry
  # schema_url http://localhost:8081/subjects/prod/versions/latest
  # If your URL adds metadata around the schema, schema_url_key can be used to pull that out. If your response body was like this:
  # {"subject":"prod","version":2,"id":2,"schema":"{\"type\":\"record\",\"name\":\"example\",\"namespace\":\"org.example\",\"fields\":[{\"name\":\"message\",\"type\":\"string\"}]}"}
  # Then the below line would extract that out
  # schema_url_key schema
</match>
```

## License

Apache License, Version 2.0.
