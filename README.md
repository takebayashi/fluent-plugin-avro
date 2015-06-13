# fluent-plugin-avro

fluent-plugin-avro provides a formatter plugin for Fluentd.

## Configurations

| Name | Description |
| ---- | ----------- |
| schema_file | filename of Avro schema |

### Example

```
<match example.avro>
  type file
  path /path/to/output
  format avro

  schema_file /path/to/schema.avsc
</match>
```

## License

Apache License, Version 2.0.
