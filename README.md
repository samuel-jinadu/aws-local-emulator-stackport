# Local AWS Development Environment with FakeCloud & Stackport

A containerized local development environment that emulates AWS services using **FakeCloud** and provides a **Stackport** dashboard for managing infrastructure — all without touching real AWS.

## 📦 What's Inside

| Service | Purpose | Image | Port |
|---------|---------|-------|------|
| **FakeCloud** | Local AWS emulator (S3, SQS, SNS, DynamoDB, Lambda, etc.) | `ghcr.io/faiscadev/fakecloud:v0.51.0` | `4566` |
| **Stackport** | Web dashboard for browsing/manager local AWS resources | `davireis/stackport:0.4.5` | `8080` |

## 🚀 Quick Start

```bash
git clone https://github.com/samuel-jinadu/aws-local-emulator-stackport.git
cd aws-local-emulator-stackport
docker compose up -d
```

Check status:

```bash
docker compose ps
```

## 🔌 Connecting Your Application

Point your AWS SDK / CLI to FakeCloud using these credentials — **any non-empty values work**:

```bash
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_REGION=us-east-1
```

Example with the AWS CLI:

```bash
aws --endpoint-url http://localhost:4566 s3 mb s3://my-bucket
aws --endpoint-url http://localhost:4566 s3 ls
aws --endpoint-url http://localhost:4566 sqs create-queue --queue-name my-queue
```

## 🖥️ Stackport Dashboard

Open **[http://localhost:8080](http://localhost:8080)** to inspect your emulated resources visually — buckets, queues, tables, functions, and more.

It's pre-wired to talk to FakeCloud via:

```yaml
AWS_ENDPOINT_URL=http://fakecloud:4566
```

## 💾 Data Persistence

Both services persist data to host-mounted directories:

| Host path | Container path | Service |
|-----------|----------------|---------|
| `./fakecloud_data` | `/var/lib/fakecloud` | FakeCloud |
| `./stackport_data` | `/root/.stackport` | Stackport |

Data survives `docker compose down` and container restarts. To wipe everything, use the reset script below.

## 🔁 Resetting the Environment

To stop all services **and** erase persisted data:

```bash
chmod +x ./reset.sh
./reset.sh
```

What it does:

1. Runs `docker compose down`
2. Empties `fakecloud_data/` and `stackport_data/` (preserving `.gitkeep`)
3. Reports which directories were cleaned

## 🗂️ Project Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json          # Dev container definition
│   └── docker-compose.dev.yaml    # App service for dev container
├── compose.yaml                   # fakecloud + stackport services
├── reset.sh                       # Tear down & wipe data
├── fakecloud_data/                # Persistent FakeCloud state
├── stackport_data/                # Persistent Stackport state
└── README.md
```

## ⚙️ Configuration Reference

### FakeCloud (`compose.yaml`)

| Variable | Value | Notes |
|----------|-------|-------|
| `FAKECLOUD_STORAGE_MODE` | `persistent` | Keeps state across restarts |
| `FAKECLOUD_DATA_PATH` | `/var/lib/fakecloud` | Must match the mount point |
| `FAKECLOUD_ADDR` | `0.0.0.0:4566` | Listen address |

Healthcheck runs every 5s; `stackport` waits for `fakecloud` to be healthy before starting.

### Resource Limits

FakeCloud is capped at **1 GB memory** to keep the dev environment lightweight. Adjust under `deploy.resources.limits.memory` if you run heavier workloads (e.g., Lambda).

## 🧰 Requirements

- **Docker** 20.10+ with Compose v2
- **4 GB RAM** recommended
- **VS Code** + Dev Containers extension (for Option 1)

## 🛠 Troubleshooting

**Port already in use**
```bash
# Change the host port in compose.yaml, e.g. "4567:4566"
```

**FakeCloud fails to start**
```bash
docker compose logs fakecloud
```

**Docker socket permission denied (Dev Container)**
The Dev Container uses `docker-in-docker`, so Docker commands should work inside the workspace. If not, rebuild the container.

**Start over completely**
```bash
./reset.sh
docker compose up -d
```

## 📚 Resources

- [FakeCloud](https://github.com/faiscadev/fakecloud)
- [Stackport](https://hub.docker.com/r/davireis/stackport)
