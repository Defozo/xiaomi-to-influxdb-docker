# Xiaomi to InfluxDB

Dockerized script which acquires temperature, humidity and PM2.5 measurements from Xiaomi sensors such as those in Xiaomi air purifiers (Mi Air Purifier, Mi Air Purifier 2 or Mi Air Purifier Pro) and sends them to Influx database.

## Example usage

```bash
docker run -dit --restart=unless-stopped \
	-e DEVICE_HOST=192.168.0.25 \
	-e DB_NAME=mydb \
	-e DB_URL=http://localhost:8086 \
	-e DB_USERNAME=root \
	-e DB_PASSWORD=root \
	-e DB_MEASUREMENTS_TAGS=DEVICE_NAME=xiaomi_1 \
	-e SENDING_INTERVAL_IN_SECONDS=30 \
	-e LOGGING_LEVEL=DEBUG \
	defozo/xiaomi-to-influxdb
```

## Configuration

| Environmental variable            | Default value           | Description                                                                                                |
|-----------------------------------|-------------------------|------------------------------------------------------------------------------------------------------------|
| `DEVICE_HOST`                     |                         | Hostname or IP address of Xiaomi device. Required value.                                                   |
| `DB_NAME`                         | `mydb`                  | Name of the database. Must already exist.                                                                  |
| `DB_URL`                          | `http://localhost:8086` | InfluxDB URL with port.                                                                                    |
| `DB_USERNAME`                     | `root`                  | InfluxDB username for authentication. Optional value.                                                      |
| `DB_PASSWORD`                     | `root`                  | InfluxDB password for authentication. Optional value.                                                      |
| `DB_MEASUREMENTS_TAGS`            | `DEVICE_NAME=xiaomi_1`  | Tags to be added to every measurement in InfluxDB format - eg. DEVICE_NAME=xiaomi_1,DEVICE_LOCATION=office |
| `SENDING_INTERVAL_IN_SECONDS`     | `30`                    | Sleep time (in seconds) between measurements acquisition.                                                  |
| `LOGGING_LEVEL`                   | `DEBUG`                 | Available logging levels: `DEBUG`, `INFO`, `ERROR`.                                                        |
| `DB_TEMPERATURE_MEASUREMENT_NAME` | `temperature`           | Name of the temperature measurement in InfluxDB.                                                           |
| `DB_HUMIDITY_MEASUREMENT_NAME`    | `humidity`              | Name of the humidity measurement in InfluxDB.                                                              |
| `DB_PM2_5_MEASUREMENT_NAME`       | `pm2_5`                 | Name of the PM2.5 measurement in InfluxDB.                                                                 |

## Architecture

`armv71` (Raspberry Pi 2 / 3)