## Microservices Sidecar Pattern Demo

This project try to demonstrate Sidecar Pattern with Envoy.

Building Application Package:
```bash
$ mvn clean compile package
```

Building Docker Image:
```bash
$ docker build . -t sidecar-envoy
```

Running Docker:
```bash
$ docker run --rm --name=envoy -p 9000:9000 -p 9001:9001 sidecar-envoy
```
