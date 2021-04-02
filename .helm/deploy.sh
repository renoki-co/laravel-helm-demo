#!/bin/bash

helm repo add renoki-co https://helm.renoki.org
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Deploy the Secret that will contain the .env file.
kubectl apply -f secret.yaml

# Optional: deploy NGINX Ingress Controller into your cluster.
helm upgrade nginx \
    --version=3.26.0 \
    -f nginx-values.yaml \
    --install \
    ingress-nginx/ingress-nginx

helm upgrade laravel \
    --version=0.1.3 \
    -f laravel-values.yaml \
    --install \
    renoki-co/laravel
