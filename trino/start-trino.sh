#!/bin/bash

# Assign arguments
while getopts n: flag
do
    case "${flag}" in
        n) namespace=${OPTARG};; # Aerospike cluster namespace, e.g. test
    esac
done

# Set defaults
if [ -z "$namespace" ]; then namespace="test"; fi

su - trino -c "bash ./trino --server 127.0.0.1:8080 --catalog aerospike --schema ${namespace}"