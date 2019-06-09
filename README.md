# fluent-plugin-avro

[![Build Status](https://travis-ci.org/takebayashi/fluent-plugin-avro.svg)](https://travis-ci.org/takebayashi/fluent-plugin-avro)

fluent-plugin-avro provides a formatter plugin for Fluentd.

## Configurations

Either `schema_file` or `schema_json` is required.

| Name | Description |
| ---- | ----------- |
| `schema_file` | filename of Avro schema |
| `schema_json` | JSON representation of Avro schema |

### Example

```
<source>
  @type http
  port 8888
</source>

<match load>
  @type bigquery_load
  source_format avro

  <format>
    @type avro
    schema_json {
      "type": "record",
      "name": "schema",
      "namespace": "",
      "fields": [
        {"name": "host", "type": "string"},
        {"name": "code", "type": ["int", "null"]},
        {"name": "agent", "type": ["string", "null"]}
      ]
    }
  </format>

  <buffer>
    @type file
    path /Users/Seii/fluentd-test/bigquery.*.buffer
    flush_mode immediate
    flush_at_shutdown true
    timekey 1d
    timekey_use_utc
  </buffer>

  auth_method json_key
  json_key /Users/Seii/fluentd-test/sandbox-243014-756717c8cd99.json

  project sandbox-243014
  dataset fluentd
  table fluentd_test
  auto_create_table true
  fetch_schema false

#  schema [
#    {"name": "host", "type": "STRING"},
#    {"name": "code", "type": "INTEGER"},
#    {"name": "agent", "type": "STRING"}
#  ]
</match>

<match file>
  @type file
  path /Users/Seii/fluentd-test/file
  <format>
    @type avro
    schema_json {
      "type": "record",
      "name": "fluentd",
      "fields": [
        {"name": "host", "type": "string"},
        {"name": "code", "type": ["int", "null"]},
        {"name": "agent", "type": ["string", "null"]}
      ]
    }
    # You can use schema_file instead of schema_json
    # schema_file /path/to/schema.avsc
  </format>
  <buffer time>
    flush_mode immediate
    path /Users/Seii/fluentd-test
  </buffer>
</match>
```

```bash
fluentd -c ~/fluentd-test/fluentd.conf -v
```

```bash
curl -X POST -H "Content-Type: application/json" --data-binary @- http://localhost:8888/load <<EOF
[
  {"agent":"test","code":0,"host":"test"},
  {"agent":"test","code":0,"host":"test"},
  {"host":"-"}
]
EOF
```

## License

Apache License, Version 2.0.
