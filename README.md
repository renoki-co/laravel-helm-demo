- [Laravel Helm Demo](#laravel-helm-demo)
  - [Building Image](#building-image)
    - [Dependencies](#dependencies)
    - [Change deployment steps](#change-deployment-steps)
    - [Change PHP-FPM version](#change-php-fpm-version)
    - [Change Octane version](#change-octane-version)
    - [Workers](#workers)
  - [Deploying](#deploying)
    - [Helm v3](#helm-v3)
    - [Autoscaling](#autoscaling)

# Laravel Helm Demo

A slight demo on how to run Laravel on Kubernetes using Helm, horizontally-scaled, using NGINX Ingress Controller and PHP-FPM.

## Building Image

Make sure you build an image with your vendor/tag:

```bash
$ docker build . -t myapp/laravel
```

This will later be used in the Kubernetes chart: [renoki-co/charts/laravel](https://github.com/renoki-co/charts/tree/master/charts/laravel).

An example image build workflow can be found in [.github/workflows/docker-release-tag.yaml](.github/workflows/docker-release-tag.yaml).

All images work on [base images](https://github.com/renoki-co/laravel-docker-base) that already have extensions enabled to speed up the project copy into the container thus leading to faster deployments.

### Dependencies

It's recommended that the dependencies will be installed alongside with the container to ensure your pods will not take additional time each time they start.

### Change deployment steps

When deploying, `deploy.sh` from the root folder will be ran. Check it for deployment steps and you can change them accordingly.

### Change PHP-FPM version

To change the PHP-FPM version, simply start from another PHP-FPM image version in `Dockerfile.fpm`. Basically,
the final image will contain the project with dependencies installed, as long as the entire PHP-FPM process.

### Change Octane version

The project contains an Octane-based image. Same as with the PHP-FPM version, you can change the Octane-based image by editing `Dockerfile.octane`.

To deploy Octane workloads in Kubernetes, check the [dedicated Helm chart](https://github.com/renoki-co/charts/tree/master/charts/laravel-octane) for Octane.

### Workers

The project contains an PHP CLI-based image that you can use to run your Laravel workers, such as queues or schedulers. To change the image, edit `Dockerfile.worker`.

To deploy wokers in Kubernetes, check the [dedicated Helm chart](https://github.com/renoki-co/charts/tree/master/charts/laravel-worker) for such workloads.

## Deploying

### Helm v3

You will need Helm v3+ to deploy the chart.

Inside `.helm/deploy.sh` you will find commented the versions of Laravel you may deploy using Helm charts. Uncomment the one that's favorable for you (vanilla or Octane-based).

Then you need to run the `.helm/deploy.sh` file:

```bash
$ cd .helm && sh deploy.sh
```

The example also comes with NGINX Ingress Controller and is going to be deployed to the cluster.

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
