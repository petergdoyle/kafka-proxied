# Dockerize MirrorMaker

### Step by Step

1. Install Docker and Docker-Compose locally
```bash
$ sudo su
$ ./install_docker.sh
```
2. Build the Docker image
```bash
$ ./docker_build_kafka_image.sh
```
3. Start ```docker-compose``` interactively specifying startup options for running the  ```kafka-mirror-maker-service```...
```bash
$ ./docker_compose_run_mirror_maker_service.sh
```
4. Scale the ```kafka-mirror-maker-service```
```bash
$ ./docker_compose_scale_mirror_maker_service.sh
```
