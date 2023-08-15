# Mule EE Base Docker Image

Image to create a mule runtime container for docker

Docker/Microservice Mule application images can extend this image

This image has the jolokia jvm agent enabled by default and jmx metrics are available at 0.0.0.0:8778/jolokia/read

Alternatively, a [jmxtrans-agent](https://github.com/jmxtrans/jmxtrans-agent) can be enabled by passing the below env vars. The agent will query for JMX metrics as specified in `mule/conf/jmxtrans-agent.xml.erb` and export them to a statsd server (with the below host/port). Furthermore, the `jmx-trans-agent.xml.erb` can also be mounted as a volume to override the image default configuration.

* MULE_MANAGEMENT_ENABLE_JMXTRANS_AGENT=true
* MULE_MANAGEMENT_JMXTRANS_STATSD_HOST=<STATSD HOST>
* MULE_MANAGEMENT_JMXTRANS_STATSD_PORT=<STATSD PORT>

## build
```
docker build --build-arg GIT_COMMIT=$(git rev-parse HEAD) --tag npiper/mule39-ee-base .
```

## run as daemon
```
docker run -Pit \
    -v /var/log/mule:/opt/mule/logs \
    -e "MULE_TUNING_GC=G1" \
    -e "MULE_MANAGEMENT_ENABLE_JMX=true" \
    -e "MULE_MEMORY_MIN_HEAP=10" \
    -e "MULE_MEMORY_MAX_HEAP=300" \
    -e "MULE_LOGGING_VERBOSE_GB=true" \
    -e "MULE_LOGGING_DEFAULT_LEVEL='INFO'" \
    -e "MULE_LOGGING_MULE_LEVEL='INFO'" \
    -e "MULE_LOGGING_ESB_JAVA_LEVEL='INFO'" \
    -e "MULE_LOGGING_XML_FILTERS='INFO'" \
    -e "MULE_LOGGING_ESB_UTILS='INFO'" \
    npiper/mule39-ee-base:latest
```
## run with jmxtrans-agent enabled
```
docker run -Pit \
    -e MULE_MANAGEMENT_ENABLE_JMXTRANS_AGENT=true \
    -e MULE_MANAGEMENT_JMXTRANS_STATSD_HOST=10.11.12.85
    -e MULE_MANAGEMENT_JMXTRANS_STATSD_PORT=8125
    mule38ee-base :latest
```
## run with jmxtrans-agent enabled supplying your own configuration
```
docker run -Pit \
    -e MULE_MANAGEMENT_ENABLE_JMXTRANS_AGENT=true \
    -e MULE_MANAGEMENT_JMXTRANS_STATSD_HOST=10.11.12.85
    -e MULE_MANAGEMENT_JMXTRANS_STATSD_PORT=8125
    -v /tmp/mule/conf:/mnt/mule/conf
    mule38ee-base :latest
```
With the above configuration, the startup script will look the container's `/mnt/mule/conf` directory for a `jmxtrans-agent.xml.erb` template file and will override the image's default template located at `/opt/mule/conf/jmxtrans-agent.xml.erb`.

# run as daemon (and supply a new digested license)
The below will install a Mule EE digested license file namely `muleLicenseKey.lic` which will get mounted as volume on `/mnt/mule/conf/`. 
In Openshift and Kubernetes the license can be stored as a `Secret` and mounted as a volume in the container. This allows for the license to be updated without building a new image and be shared across multiple containers.
```
docker run -Pit 
    -v /tmp/mule/conf:/mnt/mule/conf
    npiper/mule39-ee-base:latest
```

# push
```
docker push npiper/mule39-ee-base:latest
```

# Environment Variables


| Variable | Description
| -------- | -----------
| MULE_TUNING_GC |
| MULE_MEMORY_MIN_HEAP |
| MULE_MEMORY_MAX_HEAP |
| MULE_LOGGING_VERBOSE_GC |
| MULE_LOGGING_VERBOSE_EXCEPTIONS |
| MULE_LOGGING_DEFAULT_LEVEL | _Currently ignored_
| MULE_LOGGING_MULE_LEVEL | _Currently ignored_
| MULE_LOGGING_ESB_JAVA_LEVEL | _Currently ignored_
| MULE_LOGGING_XML_FILTERS | _Currently ignored_
| MULE_LOGGING_ESB_UTILS | _Currently ignored_
| MULE_WRAPPER_CUSTOM_ARG_1 | There are MULE_WRAPPER_CUSTOM_ARG_1 to MULE_WRAPPER_CUSTOM_ARG_10 available for defining extra custom jvm arguments, if more needed, add MULE_WRAPPER_CUSTOM_ARG_<n> to conf/wrapper.conf.erb
| MULE_MANAGEMENT_ENABLE_JMXTRANS_AGENT | Setting this to true will enable jmxtrans-agent (and disable Jolokia)
| MULE_MANAGEMENT_JMXTRANS_STATSD_HOST | The Statsd host jmxtrans-agent will write to.
| MULE_MANAGEMENT_JMXTRANS_STATSD_PORT | The Statsd port jmxtrans-agent will write to.

# API Gateway support

To enable integration with API Manager, the file `/opt/mule/conf/apigw/api-gateway.properties` needs to be present inside the running container (probably mounted as a Docker/Kubernetes volume).

The file must contain Anypoint Organisation credentials defined in the following properties:

```
gw_client_id=???
gw_client_secret=???
```

## Dependencies

[Yelp dumb-init](https://github.com/Yelp/dumb-init) is installed and use as an init system for PID1

[Jolokia JVM + Mule Agents](https://jolokia.org/agent/mule.html)

Editing tools - vim, less

[Ruby - erb templating system for shell outputs](https://docs.ruby-lang.org/en/2.3.0/ERB.html)

Network tools - curl, wget, unzip, netstat-nat net-tools iputils-ping telnet

## TO DO

Add Maven support
Download / Upgrade to Jolokia 1.7.2 - https://jolokia.org/download.html to `/lib/user`

Download / Upgrade to JMX Trans 1.2.11 - https://github.com/jmxtrans/jmxtrans-agent to `/lib/user`

Add a DockerCompose with services like JMX Clients, [StatsD Collator](https://hub.docker.com/r/statsd/statsd)

Add [Prometheus performance monitoring](https://prometheus.io/docs/prometheus/latest/installation/)


```
 <dependency>
   <groupId>org.jolokia</groupId>
   <artifactId>jolokia-core</artifactId>
   <version>1.7.2</version>
 </dependency>
 ```

 ```
 <dependency>
    <groupId>org.jmxtrans.agent</groupId>
    <artifactId>jmxtrans-agent</artifactId>
    <version>1.2.11</version>
</dependency>
```