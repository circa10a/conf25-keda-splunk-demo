# .conf25-keda-splunk-demo
Demo for splunk's .conf25 showcasing KEDA's Splunk scaler

![alt text](docs/calebs-taco-truck-site.png)

## Install

- Install KEDA
- Run Splunk
    - Configures `taco-truck-customers` saved search
- Run Caleb's Taco Truck (NGINX)
    - Attach Splunk Universal Forwarder sidecar to scrape NGINX logs

```console
$ make install
```

## Access Splunk

Access the Splunk instance at http://localhost:8000

## Access Caleb's Taco Truck

You can visit the taco truck website at http://localhost:8080

## Simulate traffic

Generate traffic from 30 clients

```console
$ make traffic
```

## Cleanup

```console
$ make clean
```
