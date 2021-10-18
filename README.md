- [Laravel Helm Demo](#laravel-helm-demo)
  - [Building Image](#building-image)
    - [NGINX + PHP-FPM](#nginx--php-fpm)
    - [Octane](#octane)
    - [Workers](#workers)
    - [Installing Dependencies](#installing-dependencies)
    - [Deploy Script](#deploy-script)
  - [Deploying on Kubernetes](#deploying-on-kubernetes)
    - [Deploying Chart](#deploying-chart)
    - [Autoscaling](#autoscaling)

# Laravel Helm Demo

Run Laravel on Kubernetes using Helm. This project is horizontal scale-ready, and it can either be used with NGINX + PHP-FPM or Octane.

## 🤝 Supporting

[<img src="https://github-content.s3.fr-par.scw.cloud/static/25.jpg" height="210" width="418" />](https://github-content.renoki.org/github-repo/25)

If you are using one or more Renoki Co. open-source packages in your production apps, in presentation demos, hobby projects, school projects or so, spread some kind words about our work or sponsor our work via Patreon. 📦

[<img src="https://c5.patreon.com/external/logo/become_a_patron_button.png" height="41" width="175" />](https://www.patreon.com/bePatron?u=10965171)

## Building Image

This project offers three alternative to build an image:

- for PHP-FPM + NGINX projects (using `Dockerfile.fpm`)
- for Octane (using `Dockerfile.octane`)
- for Workers (like CLI commands, using `Dockerfile.worker`)

All images are based on [Laravel Docker Base images](https://github.com/renoki-co/laravel-docker-base), a small repository that contains Dockerfiles that already compile the extensions and enable them, to speed up the project deployment, since the same extensions are always installed during the normal project CI/CD pipeline.

### NGINX + PHP-FPM

The images generated with NGINX + PHP-FPM are using [renoki-co/laravel chart](https://github.com/renoki-co/charts/tree/master/charts/laravel) and you may find there the documentation on how to deploy the chart.

### Octane

The images generated with Octane are using [renoki-co/laravel-octane chart](https://github.com/renoki-co/charts/tree/master/charts/laravel-octane) and you may find there the documentation on how to deploy the chart.

### Workers

The images generated for Workers are using [renoki-co/laravel-worker chart](https://github.com/renoki-co/charts/tree/master/charts/laravel-worker) and you may find there the documentation on how to deploy the chart.

### Installing Dependencies

It's recommended that the dependencies and other static data to be installed alongside with the container in CI/CD pipeline. This way, your pods will not take additional time each time they start to complete additional long steps like installing the dependencies or compiling the frontend assets.

### Deploy Script

In the project root, you will find a `deploy.sh` file that will contain additional steps to run on each Pod startup. You might change it according to your needs, but keep in mind that it shouldn't take too much. The more it takes, the slower your autoscaling will be.

## Deploying on Kubernetes

### Deploying Chart

A brief example can be found in `.helm/deploy.sh` on how to deploy a Laravel Octane application. You will also find optional Helm releases that might help you deploying the application, such as Prometheus for PHP-FPM + NGINX scaling or NGINX Ingress Controller to port NGINX to the app service.

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
