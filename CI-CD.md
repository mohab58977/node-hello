# CI/CD Pipeline

This document outlines the CI/CD pipeline for the Node.js Hello World application, which is managed using GitHub Actions.

## Pipeline Overview

The CI/CD pipeline is defined in the `.github/workflows/ci-cd.yml` file and consists of the following jobs:

- **Lint**: This job checks the code for style and formatting errors using ESLint and Prettier.
- **Build and Push**: This job builds a Docker image of the application, tags it with a unique version, and pushes it to the GitHub Container Registry.
- **Update Helm Values**: This job updates the `values.yaml` file in the Helm chart with the new Docker image tag and pushes the changes back to the repository.
- **Security Scan**: This job scans the Docker image for vulnerabilities using Trivy and uploads the results to the GitHub Security tab.
- **Cleanup Old Images**: This job removes old Docker images from the GitHub Container Registry to save space.

## Triggers

The pipeline is triggered by the following events:

- A push to the `main` or `master` branch.
- A pull request to the `main` or `master` branch.

The pipeline ignores changes to the `helm/node-hello/values.yaml` file and any files with the `.md` extension.

## Secrets
the pipeline doesn't need any secrets to work as it uses the github registry

## Jobs

### Lint

This job runs on an `ubuntu-latest` runner and consists of the following steps:

1. **Checkout code**: This step checks out the code from the repository.
2. **Setup Node.js**: This step sets up Node.js with the specified version and caches the npm dependencies.
3. **Install dependencies**: This step installs the npm dependencies using `npm ci`.
4. **Run ESLint**: This step runs ESLint to check for style and formatting errors.
5. **Run Prettier check**: This step runs Prettier to check for formatting errors.

### Build and Push

This job runs on an `ubuntu-latest` runner and depends on the `lint` job. It consists of the following steps:

1. **Checkout code**: This step checks out the code from the repository.
2. **Generate version tag**: This step generates a unique version tag based on the current timestamp and the short SHA of the commit.
3. **Log in to Container Registry**: This step logs in to the GitHub Container Registry.
4. **Set up Docker Buildx**: This step sets up Docker Buildx to enable multi-platform builds.
5. **Build and push Docker image**: This step builds the Docker image and pushes it to the GitHub Container Registry with two tags: the unique version tag and the `latest` tag.

### Update Helm Values

This job runs on an `ubuntu-latest` runner and depends on the `build-and-push` job. It consists of the following steps:

1. **Checkout code**: This step checks out the code from the repository.
2. **Update Helm values**: This step updates the `image.tag` value in the `helm/node-hello/values.yaml` file with the new Docker image tag.
3. **Commit and push changes**: This step commits the changes to the `values.yaml` file and pushes them back to the repository.

### Security Scan

This job runs on an `ubuntu-latest` runner and depends on the `build-and-push` job. It consists of the following steps:

1. **Run Trivy vulnerability scanner**: This step scans the Docker image for vulnerabilities using Trivy and saves the results in a SARIF file.
2. **Upload Trivy scan results to GitHub Security tab**: This step uploads the SARIF file to the GitHub Security tab.

### Cleanup Old Images

This job runs on an `ubuntu-latest` runner and depends on the `build-and-push` and `security-scan` jobs. It only runs on pushes to the `main` or `master` branch. It consists of the following steps:

1. **Log in to Container Registry**: This step logs in to the GitHub Container Registry.
2. **Clean up old Docker images**: This step removes old Docker images from the GitHub Container Registry, keeping only the latest 5 images.

