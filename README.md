# Logstash Codec - Wapiti

This plugin encapsulates events to/from an AVRO datum for Kafka
according to the 'Wapiti' schema. The Wapiti schema describes
a backbone queuing format for numerous types of messages. Each
message has a 'shipping label', which consumers (not just logstash)
can use to make quick decisions (eg. do I care about this data,
which file should I archive this data to), without having to parse
the embedded message in any way.

The encapsulated message therefore can take any form, although JSON is
most common. You could imagine packet-data, or even files going through
the backbone.

## Building

This repository is set up for easy development using VSCode's Remote
Containers feature using cameronkerrnz/logstash-plugin-dev

Within a shell session, use the following commands to build it:

```
bundle install
gem build logstash-codec-avro_wapiti.gemspec
```

## Installation

You'll need to grab the release from github; this plugin is not
available as a regular logstash plugin, but you can still install
it using logstash-plugin.

##  Decoding (input)

When this codec is used to decode the input, you may pass the following options:
- ``endpoint`` - always required.
- ``username`` - optional.
- ``password`` - optional.

If the input stream is binary encoded, you should use the ``ByteArrayDeserializer``
in the Kafka input config.

## Encoding (output)

This codec uses the Confluent schema registry to register a schema and
encode the data in Avro using schema_id lookups.

When this codec is used to encode, you may pass the following options:
- ``endpoint`` - always required.
- ``username`` - optional.
- ``password`` - optional.
- ``schema_id`` - when provided, no other options are required.
- ``subject_name`` - required when there is no ``schema_id``.
- ``schema_version`` - when provided, the schema will be looked up in the registry.
- ``schema_uri`` - when provided, JSON schema is loaded from URL or file.
- ``schema_string`` - required when there is no ``schema_id``, ``schema_version`` or ``schema_uri``
- ``check_compatibility`` - will check schema compatibility before encoding.
- ``register_schema`` - will register the JSON schema if it does not exist.
- ``binary_encoded`` - will output the encoded event as a ByteArray.
  Requires the ``ByteArraySerializer`` to be set in the Kafka output config.
- ``client_certificate`` -  Client TLS certificate for mutual TLS
- ``client_key`` -  Client TLS key for mutual TLS
- ``ca_certificate`` -  CA Certificate
- ``verify_mode`` -  SSL Verify modes.  Valid options are `verify_none`, `verify_peer`,  `verify_client_once` , and `verify_fail_if_no_peer_cert`.  Default is `verify_peer`

*NOTE* There is currently no configuration exposed for logstash-codec-avro_wapiti;
all behaviour is currently hard-coded at this early stage.

## Known Issues

- Should be more robust in the face of errors (dead letter queue, etc.)
  Currently logstash will crash when an unhandled exception occurs.
- Code is tightly coupled to the schema implementation.

## Usage

### Basic usage with Kafka output

Imagine you have logstash acting as a reception/submission tier. This
layer has a role to read messages (probably from the network), and produce
them into the Kafka queue according to an AVRO schema known as Wapiti.

```
input {
    tcp {
        host => "0.0.0.0"
        port => 5140
        mode => "server"
        codec => "json_lines"
    }
}

input {
    beats {
        port => 5044
        add_field => {
            "[@metadata][wapiti][processing_key]" => "%{type}"
        }
    }
}

output {
  kafka {
    topic_id => "wapiti_backbone_sandpit"
    compression_type => "snappy"

    codec => avro_schema_registry {
      endpoint => "http://127.0.0.1:8081"
      subject_name => "wapiti_backbone_submitted-value"
      schema_version => "4"
      register_schema => false
      binary_encoded => true
    }

    value_serializer => "org.apache.kafka.common.serialization.ByteArraySerializer"
  }
}
```

### Basic usage with Kafka input

This would represent the enrichment tier, and typically you would end up
throwing this at Elasticsearch. Here we illustrate a development configuration
that uses the rubydebug codec with the metadata option set to true so we can
inspect the `@metadata` field.

```
input {
  kafka {
    bootstrap_servers => "127.0.0.1:9092"
    client_id => "logstash_enrichment_1"
    group_id => "logstash_enrichment"
    topics => ["wapiti_backbone_submitted"]

    decorate_events => true

    codec => avro_schema_registry {
      endpoint => "http://127.0.0.1:8081"
      subject_name => "wapiti_backbone_submitted-value"
      schema_version => "4"
      register_schema => false
      binary_encoded => true
    }

    value_deserializer_class => "org.apache.kafka.common.serialization.ByteArrayDeserializer"
  }
}

output {
    file {
        path => "/tmp/enrichment.out"
        codec => rubydebug {
            metadata => true
        }
    }
}
```
