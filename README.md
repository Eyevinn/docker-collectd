Docker Container for [collectd](https://collectd.org) - a system statistics collection daemon.

## Example Usages 

### Monitor DNS

Collect statistics from a Bind (DNS) server and write to an Influx DB.

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
        Server "influxdb" "8086"
</Plugin>
```

### Monitor Nginx

