Logstash Avro Schema Registry Codec
===================

How to Install
--------------

```
bin/plugin install logstash-codec-avro_wapiti
```

How to Use
----------
You can use this codec to decode avro messages
in a Kafka topic input. Each message must be prefixed
with a 5-byte struct containing a magic byte and
the schema id.

You must pass the endpoint of the schema registry server.

Along with the logstash config for reading in messages of this
type using the avro codec with the logstash-input-kafka plugin.

### logstash.conf

```
input {
  kafka {
    topic_id => 'test_topic'
    codec => avro_wapiti {
      endpoint => 'http://schemas.example.com'
    }
  }
}

output {
  stdout {
    codec => rubydebug
  }
}
```

### Running the setup
```
bin/logstash -f logstash.conf
```
