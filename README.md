Docker Container for [collectd](https://collectd.org) - a system statistics collection daemon.

## Example Usages 

### Monitor DNS

Collect statistics from a Bind (DNS) server and write to an Influx DB to visualize in Grafana.

Enable the statistics channel in bind first (named.conf):

```
statistics-channels {
  inet 0.0.0.0 port 8053;
};
```

Setup the container with docker-compose:

```
version: '2'

services:
  dns:
    restart: always
    image: eyevinntechnology/docker-collectd:5.6-1.0
    volumes:
      - /private/var/docker/dns-collect/conf.d:/etc/collectd/collectd.conf.d
```

In `/private/var/docker/dns-collect/conf.d` we have the configuration files.

```
LoadPlugin bind
<Plugin "bind">
        URL "http://bind:8053/"

        OpCodes true
        QTypes true

        ServerStats true
        ZoneMaintStats true
        ResolverStats false
        MemoryStats true
</Plugin>
```

and

```
LoadPlugin network
<Plugin network>
        Server "influxdb" "25826"
</Plugin>
```

Create the `collectd` database in Influx DB:

```
curl -X POST http://influxdb:8086/query --data-urlencode "q=CREATE DATABASE collectd"
```

And make sure you have the following in the Influx configuration

```
[collectd]
enabled = true
bind-address = ":25826"
database = "collectd"
typesdb = "/usr/share/collectd/types.db"
```

With Influx DB running as Docker Container the docker-compose configuration would be something like this:

```
version: '2'

services:
  influxdb:
    restart: always
    image: influxdb:latest
    environment:
      - INFLUXDB_COLLECTD_ENABLED=true
      - INFLUXDB_COLLECTD_BIND_ADDRESS=:25826
      - INFLUXDB_COLLECTD_DATABASE=collectd
      - INFLUXDB_COLLECTD_TYPESDB=/usr/local/share/collectd/types.db
    volumes:
      - /private/var/docker/influxdb:/var/lib/influxdb
      - /private/var/docker/influxdb/collectd:/usr/local/share/collectd
```

and where the `types.db` file is located at `/private/var/docker/influxdb/collectd/types.db`