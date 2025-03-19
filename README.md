# configuration-manager compose recipe

## Getting Start

### 1. Environment Setup

1. Create a Docker network (if not already created)

    ``` sh
    docker network create cdim-net
    ```

1. Build

    For the configuration-manager-compose environment

    ```sh
    docker compose up -d --build
    ```

### 2. Controlling the Containers

#### 2-1. Checking Container Status

Verify that the containers are running by running:

```sh
docker ps
```

#### 2-2. Stopping Containers

Stop the containers using:

```sh
docker compose down
```

## License

[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)
