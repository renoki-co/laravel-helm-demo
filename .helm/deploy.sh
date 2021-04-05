#!/bin/bash

helm repo add renoki-co https://helm.renoki.org
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm repo update

# Deploy the Secret that will contain the .env file.
kubectl apply -f secret.yaml

# Optional: deploy NGINX Ingress Controller into your cluster
# to expose the ingress outside the cluster.
helm upgrade nginx \
    --version=3.26.0 \
    -f nginx-values.yaml \
    --install \
    ingress-nginx/ingress-nginx

# Optional: deploy Prometheus & Prometheus Adapter to scrape
# the pod metrics (if PHP-FPM and NGINX exporters are enabled)
# to automatically scale the containers based on the pm.max_children value.
helm upgrade prometheus \
    --version=13.6.0 \
    -f prometheus-values.yaml \
    --install \
    prometheus-community/prometheus

helm upgrade prometheus-adapter \
    --version=2.12.1 \
    -f prometheus-adapter-values.yaml \
    --install \
    prometheus-community/prometheus-adapter

# Deploy the Laravel app.
helm upgrade laravel \
    --version=0.6.0 \
    -f laravel-values.yaml \
    --install \
    renoki-co/laravel
