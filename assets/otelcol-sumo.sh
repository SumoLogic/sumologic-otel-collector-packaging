#!/bin/sh

if [ -f /etc/otelcol-sumo/sumologic-remote.yaml ]; then
    exec /usr/local/bin/otelcol-sumo --remote-config opamp:/etc/otelcol-sumo/sumologic-remote.yaml
else
    exec /usr/local/bin/otelcol-sumo --config /etc/otelcol-sumo/sumologic.yaml --config "glob:/etc/otelcol-sumo/conf.d/*.yaml"
fi
