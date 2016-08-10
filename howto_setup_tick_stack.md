# HOWTO setup a TICK stack for particle measurements

Prerequisites:

* MQTT server gathers topics with measurements directly from nodes, e.g.

    topic=dusti/esp8266-14426623/DHT22/temperature value=13.5

* Telegraf, InfluxDB and Chronograph are installed from the TICK stack https://docs.influxdata.com/
    * here all of them are installed (and listening only) on localhost

## Telegraf

Telegraf will take the measurements from MQTT broker and store them in InfluxDB.
The following config file was successfully tested with the command.

    telegraf -config telegraf/mqtt2influx.conf
If the DB does not exist in InfluxDB, it will be created.
The system wide config file is `/etc/telegraf/telegraf.conf`.


~~~
[global_tags]
[agent]
  interval = "1s"
  round_interval = true
  metric_buffer_limit = 1000
  flush_buffer_when_full = true
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  debug = false
  quiet = false
[[inputs.mqtt_consumer]]
  servers = ["mqtt.opendataset.click:1883"]
  qos = 0
  topics = [
    "dusti/+/+/P1",
    "dusti/+/+/P2",
    "dusti/+/+/temperature",
    "dusti/+/+/humidity",
    "dusti/+/+/lat",
    "dusti/+/+/lon",
  ]
  persistent_session = true
  client_id = "telemqtt2iflux"
  
  data_format = "value"
  data_type = "float"
[[outputs.influxdb]]
  urls = ["http://localhost:8086"] # required
  database = "tm2i" # required
  retention_policy = "default"
  precision = "s"
  timeout = "5s"
~~~


## InfluxDB

Not much to do apart from having it running. 
If you want AUTH, see documentation, here were are without (listening only on localhost).
Here are some commands to create the DB and show some information about it:

    CREATE DATABASE tm2i
    USE tm2i
    SHOW RETENTION POLICIES ON tm2i

### General queries on InfluxDB

    -- queries for mqtt inputs 
    -- example insert line from telegraf:
    -- mqtt_consumer,host=zapp,topic=dusti/esp8266-14426623/PPD42NS/P1 value=0.62 1470789545925980255

    SHOW MEASUREMENTS
    SHOW TAG KEYS FROM "mqtt_consumer"
    SHOW TAG VALUES FROM "mqtt_consumer" WITH KEY = "topic"
    SHOW TAG VALUES FROM "mqtt_consumer" WITH KEY = "host"

    SELECT * FROM "mqtt_consumer" 
    SELECT * FROM tm2i."default"."mqtt_consumer" 

    SELECT * FROM "mqtt_consumer" WHERE topic = 'dusti/esp8266-14426623/DHT22/temperature'
    SELECT * FROM "mqtt_consumer" WHERE topic =~ /.*\/temperature/

## Chronograf queries

Run Chronograf via `sudo service chronograf start`, then visit [http://localhost:10000/](http://localhost:10000/).
Add new Influxdb-server (HOST=localhost, NICKNAME=local), `save` (button) and `< done` (on top, if not working: use start link, see before).
Now you can create visualisations and dashboards, e.g. with the following example queries:

    -- chronograf plotting queries for all sensors
    SELECT value FROM tm2i."default".mqtt_consumer WHERE tmpltime() AND topic =~ /.*\/temperature/ GROUP BY topic
    SELECT value FROM tm2i..mqtt_consumer WHERE tmpltime() AND topic =~ /.*\/humidity/ GROUP BY topic
    SELECT value FROM tm2i..mqtt_consumer WHERE tmpltime() AND topic =~ /.*\/P.$/ GROUP BY topic
    SELECT value FROM tm2i..mqtt_consumer WHERE tmpltime() AND topic =~ /.*\/P1$/ GROUP BY topic
    SELECT value FROM tm2i..mqtt_consumer WHERE tmpltime() AND topic =~ /.*\/P2$/ GROUP BY topic

    -- topic selection:
    SELECT value FROM tm2i..mqtt_consumer WHERE tmpltime() AND topic = tmpltagvalue('topic', 'topic')

    -- 5 min averaged data, select topic from dropdown
    SELECT mean(value) FROM tm2i..mqtt_consumer WHERE tmpltime() AND topic = tmpltagvalue('topic', 'topic') GROUP BY time(5m), topic

