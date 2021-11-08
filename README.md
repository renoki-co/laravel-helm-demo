- [Laravel Helm Demo](#laravel-helm-demo)
  - [🤝 Supporting](#-supporting)
  - [Building Image](#building-image)
    - [NGINX + PHP-FPM](#nginx--php-fpm)
    - [Octane](#octane)
    - [Workers](#workers)
    - [Installing Dependencies](#installing-dependencies)
    - [Deploy Script](#deploy-script)
  - [Deploying on Kubernetes](#deploying-on-kubernetes)
    - [Deploying Chart](#deploying-chart)
    - [Configuring Environment Variables](#configuring-environment-variables)
    - [Database](#database)
    - [Filesystems](#filesystems)
    - [Autoscaling](#autoscaling)
    - [Scaling Horizon & Octane](#scaling-horizon--octane)

# Laravel Helm Demo

Run Laravel on Kubernetes using Helm. This project is horizontal scale-ready, and it can either be used with NGINX + PHP-FPM or Octane.

## 🤝 Supporting

**If you are using one or more Renoki Co. open-source packages in your production apps, in presentation demos, hobby projects, school projects or so, sponsor our work with [Github Sponsors](https://github.com/sponsors/rennokki). 📦**

[<img src="https://github-content.s3.fr-par.scw.cloud/static/25.jpg" height="210" width="418" />](https://github-content.renoki.org/github-repo/25)

## Building Image

This project offers three alternative to build an image:

- for PHP-FPM + NGINX projects (using `Dockerfile.fpm`)
- for Octane (using `Dockerfile.octane`)
- for Workers (like CLI commands, using `Dockerfile.worker`)

All images are based on [Laravel Docker Base images](https://github.com/renoki-co/laravel-docker-base), a small repository that contains Dockerfiles that already compile the extensions and enable them, to speed up the project deployment, since the same extensions are always installed during the normal project CI/CD pipeline.

### NGINX + PHP-FPM

The images generated with NGINX + PHP-FPM are using [renoki-co/laravel chart](https://github.com/renoki-co/charts/tree/master/charts/laravel) and you may find there the documentation on how to deploy the chart.

Basically, the final Docker image will be built using the `Dockerfile.fpm` file. It includes logs creation, permission changes and eventually clearing up additional files that you may not want to clutter your image with.

### Octane

The images generated with Octane are using [renoki-co/laravel-octane chart](https://github.com/renoki-co/charts/tree/master/charts/laravel-octane) and you may find there the documentation on how to deploy the chart.

The `Dockerfile.octane` file will guide the image to be built in the same manner as the usual PHP-FPM version, but it comes with a lightweight PHP-Swoole image to start from. The defined entrypoint command can be later replaced in the Kubernetes Deployment configuration.

### Workers

The images generated for Workers are using [renoki-co/laravel-worker chart](https://github.com/renoki-co/charts/tree/master/charts/laravel-worker) and you may find there the documentation on how to deploy the chart.

Workers need only the PHP CLI to be available. It's almost like Octane, but some processes do not require Swoole, like Horizon.

### Installing Dependencies

It's recommended that the dependencies and other static data to be installed alongside with the container in CI/CD pipeline. This way, your pods will not take additional time each time they start to complete additional long steps like installing the dependencies or compiling the frontend assets.

In this demo project, in `.github/workflows/docker-release-tag.yml`, for example, the CI/CD pipeline will run additional steps like `composer install` and build the image. The final build will have dependencies already installed and you will be easily be implementing a fast-responding app, which is ready to scale really fast.

### Deploy Script

In the project root, you will find a `deploy.sh` file that will contains additional steps to run on each Pod startup. You might change it according to your needs, but keep in mind that it shouldn't take too much. The more it takes, the slower your scaling up will be.

In this file you may run additional steps that depend on your `.env` file, as at the Pod startup, the `.env` file is injected via the Secret kind.

Commands like `php artisan migrate` or `php artisan route:cache` are the most appropriate ones to run here.

## Deploying on Kubernetes

### Deploying Chart

A brief example can be found in `.helm/deploy.sh` on how to deploy a Laravel Octane application. You will also find optional Helm releases that might help you deploying the application, such as Prometheus for PHP-FPM + NGINX scaling or NGINX Ingress Controller to port NGINX to the app service.

### Configuring Environment Variables

The nature of Laravel (as Deployment Kind) in Kubernetes is to be stateless. Meaning that the pods (holding the images built earlier) are created and destroyed without any persistence between roll-outs or roll-ins. To preserve this, the `.env` file is mounted as a `Secret` kind, and once the Pod creates, the contents of the secret is spilled out in the `.env` file within the pod.

These secrets can be encrypted at rest. For example, in AWS, you can specify [to encrypt Secret kinds with KMS](https://aws.amazon.com/about-aws/whats-new/2020/03/amazon-eks-adds-envelope-encryption-for-secrets-with-aws-kms/).

### Database

As explained earlier, because the nature of Laravel (or any other app as Deployment) in Kubernetes is to be stateless, you may want to persist data for your application using another service. You can use AWS RDS if you are in AWS, for example.

You can also deploy your databases, such as MySQL or PostgreSQL, such as [third party Helm Charts](https://bitnami.com/stack/mysql/helm).

### Filesystems

Using local storage will delete all your stored files between pod lifecycles. The best way is to use a third-party service, like AWS S3, Minio, Google Cloud Storage etc.

### Autoscaling

For better understading of autoscaling, Prometheus and Prometheus Adapter may be used to scrap the PHP-FPM Process Manager's active children and scale pods up or down based on the number.

There is an article that explains the way this works: [Scaling PHP FPM based on utilization demand on Kubernetes](https://blog.wyrihaximus.net/2021/01/scaling-php-fpm-based-on-utilization-demand-on-kubernetes/).

The only setting you should be aware of is that there are two containers in the Laravel pod that expose metrics. To allow Prometheus to scrape them both, don't use the port annotation on the pod and add the following source label in the Prometheus job ([original gist](https://gist.github.com/bakins/5bf7d4e719f36c1c555d81134d8887eb)):

```yaml
jobs:
  - job_name: 'kubernetes-pods'
    ...

    relabel_configs:
      ...

      - source_labels: [__meta_kubernetes_pod_container_port_name]
        action: keep
        regex: (.+)-metrics

      ...
```

### Scaling Horizon & Octane

It is well known that for Kubernetes, you may scale based on CPU or memory allocated to each pod. But you can also scale based on Prometheus metrics.

For ease of access, you may use the following exporters for your Laravel application:

- [Laravel Horizon Exporter](https://github.com/renoki-co/horizon-exporter) - used to scale application pods that run the queue workers
- [Laravel Octane Exporter](https://github.com/renoki-co/octane-exporter) - used to scale the Octane pods to ensure better parallelization
