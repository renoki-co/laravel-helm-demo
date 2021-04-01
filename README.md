# Laravel Helm Demo

A slight demo on how to run Laravel on Kubernetes using Helm, horizontally-scaled, using NGINX Ingress Controller and PHP-FPM.

## Building Image

Make sure you build an image with your vendor/tag:

```bash
$ docker build . -t myapp/laravel
```

This will later be used in the Kubernetes chart: [renoki-co/charts/laravel](https://github.com/renoki-co/charts/tree/master/charts/laravel).

## Change deployment steps

When deploying, `deploy.sh` will be ran. Check it for deployment steps and you can change them accordingly.

## Change PHP-FPM version

To change the PHP-FPM version, simply start from another PHP-FPM image version in `Dockerfile`.
