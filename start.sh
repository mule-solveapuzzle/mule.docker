#!/usr/bin/env bash

echo Starting Mule server

# Expect license digest file mounted from platform
# Note: a digested license must be retrieved from http://mulelicenseverifier.cloudhub.io/ by supplying the Mule license
if [ -f /mnt/mule/conf/muleLicenseKey.lic ]
then
    if [ -f $MULE_HOME/conf/muleLicenseKey.lic ]
    then
        echo "Removing current license $MULE_HOME/conf/muleLicenseKey.lic"
        rm -rf $MULE_HOME/conf/muleLicenseKey.lic
    fi
    echo "Copying license from volume /mnt/mule/conf to $MULE_HOME/conf/ folder"
    cp /mnt/mule/conf/muleLicenseKey.lic $MULE_HOME/conf/muleLicenseKey.lic
    echo "Restoring working directory"
    cd /
fi

# if JMXTrans Agent is enabled generate its
if [ "$MULE_MANAGEMENT_ENABLE_JMXTRANS_AGENT" = true ] && [ -f /opt/mule/conf/jmxtrans-agent.xml.erb ]
then
    echo "Generating jmxtrans config..."
    if [ -f /mnt/mule/conf/jmxtrans-agent.xml.erb ]
    then
        echo "Grabbing jmxtrans template from mounted volume /mnt/mule/conf"
        erb /mnt/mule/conf/jmxtrans-agent.xml.erb > /opt/mule/conf/jmxtrans-agent.xml
    else    
        echo "Grabbing jmxtrans template from /opt/mule/conf"
        erb /opt/mule/conf/jmxtrans-agent.xml.erb > /opt/mule/conf/jmxtrans-agent.xml
        rm /opt/mule/conf/jmxtrans-agent.xml.erb
    fi
fi

# replace templated config on first run
if [ -f /opt/mule/conf/wrapper.conf.erb ]
then
    erb /opt/mule/conf/wrapper.conf.erb > /opt/mule/conf/wrapper.conf
    rm /opt/mule/conf/wrapper.conf.erb
fi

if [ -f /opt/mule/conf/jolokia-policy.xml.erb ]
then
    erb /opt/mule/conf/jolokia-policy.xml.erb > /opt/mule/conf/jolokia-policy.xml
    rm /opt/mule/conf/jolokia-policy.xml.erb
fi

if [ -f /opt/mule/conf/jolokia.properties.erb ]
then
    erb /opt/mule/conf/jolokia.properties.erb > /opt/mule/conf/jolokia.properties
    rm /opt/mule/conf/jolokia.properties.erb
fi

if [ -f /opt/mule/conf/app.sh ]
then
    exec app.sh

    RET_VAL_STATUS=$?
    echo $RET_VAL_STATUS
    if [ $RET_VAL_STATUS -ne 0 ]; then
        echo "application bootstrap scripts failed"
        exit
    fi
fi

exec mule console 2>&1
