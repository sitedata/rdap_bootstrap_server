# RDAP Bootstrap Server

The Registration Data Access Protocol (RDAP) defines a bootstrapping process in [RFC 7484](https://tools.ietf.org/html/rfc7484).
A bootstrap server aids clients by reading the bootstrapping information published by IANA and using
it to send HTTP redirects to RDAP queries. Clients utilizing a bootstrap server will not need to
conduct their own bootstrapping.

## Build And Runtime Requirements

This server is written as a Java servlet and should run in any Java Servlet 3.0 container or higher.
It should build against Java 6 or higher.

To build using Gradle:

```gradle test```

which will create the build and run the unit tests.

To build with Maven (being deprecated):

```mvn package```

## Properties and Bootstrap Files

Bootstrap files may either be listed in a properties file pointed to by the system property
`arin.rdapbootstrap.resource_files` or they may be listed using system properties directly. Here is
an example of a properties file pointed to by `arin.rdapbootstrap.resource_files`:

    default_bootstrap = /default_bootstrap.json
    as_bootstrap = /as_bootstrap.json
    domain_bootstrap = /domain_bootstrap.json
    v4_bootstrap = /v4_bootstrap.json
    v6_bootstrap = /v6_bootstrap.json
    entity_bootstrap = /entity_bootstrap.json

The system properties directly listing these are the keys of the properties file prefixed with
`arin.rdapbootstrap.bootfile.`. So the AS bootstrap would be `arin.rdapbootstrap.bootfile.as_bootstrap`, etc...

The server ships with a properties file that points to a set of built-in bootstrap files. These bootstrap files
are useful for getting the server up and running, but ultimately will need to be replaced with files
that are updated periodically from the IANA.

So there are three types of configuration.

### Configuration Setup Type 1 Example

Do not thing and let the server use the bootstrap files that ship with it.

### Configuration Setup Type 2 Example

Set the Java system property `arin.rdapbootstrap.resource_files` to be `/var/rdap/resource_files.properties`.

In the the `/var/rdap/resource_files.properties` file have the following:

    default_bootstrap = /var/rdap/default_bootstrap.json
    as_bootstrap = /var/rdap/as_bootstrap.json
    domain_bootstrap = /var/rdap/domain_bootstrap.json
    v4_bootstrap = /var/rdap/v4_bootstrap.json
    v6_bootstrap = /var/rdap/v6_bootstrap.json
    entity_bootstrap = /var/rdap/entity_bootstrap.json

### Configuration Setup Type 3 Example

Have the following Java system properties:

    arin.rdapbootstrap.bootfile.default_bootstrap = /var/rdap/default_bootstrap.json
    arin.rdapbootstrap.bootfile.as_bootstrap = /var/rdap/as_bootstrap.json
    arin.rdapbootstrap.bootfile.domain_bootstrap = /var/rdap/domain_bootstrap.json
    arin.rdapbootstrap.bootfile.v4_bootstrap = /var/rdap/v4_bootstrap.json
    arin.rdapbootstrap.bootfile.v6_bootstrap = /var/rdap/v6_bootstrap.json
    arin.rdapbootstrap.bootfile.entity_bootstrap = /var/rdap/entity_bootstrap.json
    
## Updating Bootstrap Files

The server checks every minute to see if a file has been modified, and if any of them have it will
automatically reload all of them.

The AS, v4, v6, and domain files will be published periodically by IANA. You can set a cron or system
process to fetch them, perhaps once a week, from the following places:

    http://data.iana.org/rdap/asn.json
    http://data.iana.org/rdap/ipv4.json
    http://data.iana.org/rdap/ipv6.json
    http://data.iana.org/rdap/dns.json

The other bootstrap files take the form of the IANA files but are custom to your particular installation
of the bootstrap server.

### Entity Bootstrap File

The entity bootstrap file is used to redirect queries for entities based on the last component of the
entity handle or identifier. Some registries, most notably all of the RIRs, append a registry signifier
such as `-ARIN`. While entity bootstrapping is not officially part of the IETF specification, this
server attempts to issue redirects based on those signifiers if present. Here is an example of an
entity bootstrap file:

```json
{
  "rdap_bootstrap": {
    "version": "1.0",
    "publication": "2014-09-09T15:39:03-0400",
    "services": [
      [
        [
          "ARIN"
        ],
        [
          "https://rdappilot.arin.net/restfulwhoi/rdap",
          "http://rdappilot.arin.net/restfulwhois/rdap"
        ]
      ],
      [
        [
          "AP"
        ],
        [
          "https://rdap.apnic.net",
          "http://rdap.apnic.net"
        ]
      ],
      [
        [
          "RIPE"
        ],
        [
          "https://rdap.db.ripe.net",
          "http://rdap.db.ripe.net"
        ]
      ],
      [
        [
          "AFRINIC"
        ],
        [
          "https://rdap.rd.me.afrinic.net/whois/AFRINIC",
          "http://rdap.rd.me.afrinic.net/whois/AFRINIC"
        ]
      ],
      [
        [
          "LACNIC"
        ],
        [
          "https://rdap.labs.lacnic.net/rdap",
          "http://rdap.labs.lacnic.net/rdap"
        ]
      ]
    ]
  }
}
```

### Default Bootstrap File

The default bootstrap file is consulted when all the other bootstrap files have failed. It takes the
following form:

```json
{
  "rdap_bootstrap": {
    "version": "1.0",
    "publication": "2014-09-09T15:39:03-0400",
    "services": [
      [
        [
          "ip",
          "autnum",
          "nameserver"
        ],
        [
          "https://rdappilot.arin.net/restfulwhois/rdap",
          "http://rdappilot.arin.net/restfulwhois/rdap"
        ]
      ],
      [
        [
          "entity"
        ],
        [
          "https://rdappilot.arin.net/restfulwhois/rdap",
          "http://rdappilot.arin.net/restfulwhois/rdap"
        ]
      ],
      [
        [
          "domain"
        ],
        [
          "https://tlab.verisign.com/COM",
          "http://tlab.verisign.com/COM"
        ]
      ]
    ]
  }
}
```

Each service type in this file represents an RDAP query type.