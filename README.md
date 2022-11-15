## Document Demo

This is a set of scripts to get the document demo up and running. The defaults include a one node Aerospike cluster for loading wine reviews, a one node Aerospike cluster containing region data, a Trino 399 server with a the client CLI installed and Aerospike connector, and a Jupyter server with a notebook to access the database.

### Prerequisites

For this demo you will need macOS (this demo can run on other operating systems, but these scripts were written specifically for macOS), [KubeLab](https://github.com/aerospike-community/docker-amd64-mac-m1), and [aerolab](https://github.com/aerospike/aerolab/blob/master/docs/GETTING_STARTED.md)

> **Note**
> 
> You can use Docker Desktop instead of Kubelab, but will need to utilize a VPN to access container IP addresses. If using Kubelab, ensure Docker Desktop is **not** running.

Resizing the `rw data disk` to greater than 8GB in KubeLab is required. Mine is set to 50GB. 

Once you have both applications up and running continue on.

### Install

Run the `setup-demo` script to install.

Usage:

|Flag   |Definition         |Default        |
|-------|-------------------|---------------|
|`-C`   |Cluster name       |document-demo  |
|`-c`   |Node count         |1              |
|`-t`   |Trino version      |399            |
|`-a`   |Connector version  |4.2.1-391      |
|`-n`   |Namespace name     |demo           |

### Start

Run the `start-demo` script to start the Trino and Jupyter server.

Trino will launch into the CLI for running SQL queries (in the trino-queries file) and Jupyter will launch the notebook server and open in your browser. Open the notebook.ipynb to start interacting with the database.

### Stop

Run the `stop-demo` script to stop all the associated containers.

### Remove

Run the `remove-demo` script to remove all the associated containers.