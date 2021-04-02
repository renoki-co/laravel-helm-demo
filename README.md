- [Laravel Helm Demo](#laravel-helm-demo)
  - [Building Image](#building-image)
  - [Dependencies](#dependencies)
    - [Change deployment steps](#change-deployment-steps)
    - [Change PHP-FPM version](#change-php-fpm-version)
  - [Deploying](#deploying)
    - [Helm v3](#helm-v3)

# Laravel Helm Demo

A slight demo on how to run Laravel on Kubernetes using Helm, horizontally-scaled, using NGINX Ingress Controller and PHP-FPM.

## Building Image

Make sure you build an image with your vendor/tag:

```bash
$ docker build . -t myapp/laravel
```

This will later be used in the Kubernetes chart: [renoki-co/charts/laravel](https://github.com/renoki-co/charts/tree/master/charts/laravel).

An example image build workflow can be found in [.github/workflows/docker-release-tag.yaml](.github/workflows/docker-release-tag.yaml).

## Dependencies

It's recommended that the dependencies will be installed alongside with the container to ensure your pods will not take additional time each time they start.

### Change deployment steps

When deploying, `deploy.sh` from the root folder will be ran. Check it for deployment steps and you can change them accordingly.

### Change PHP-FPM version

To change the PHP-FPM version, simply start from another PHP-FPM image version in `Dockerfile`. Basically,
the final image will contain the project with dependencies installed, as long as the entire PHP-FPM process.

## Deploying

### Helm v3

You will need Helm v3+ to deploy the chart. You need to run the `.helm/deploy.sh` file:

```bash
$ cd .helm && sh deploy.sh
```

The example also comes with NGINX Ingress Controller and is going to be deployed to the cluster.
