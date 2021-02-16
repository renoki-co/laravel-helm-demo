# Laravel Helm Demo

A slight demo on how to run Laravel on Kubernetes using Helm.

# Building Image

Make sure you build an image with your vendor/tag:

```bash
$ docker build . -t myapp/laravel
```

This will later be used in the Kubernetes chart: [renoki-co/laravel-helm-chart](https://github.com/renoki-co/laravel-helm-chart).

# Change PHP-FPM version

To change the PHP-FPM version, simply start from another PHP-FPM image version in `Dockerfile`.
