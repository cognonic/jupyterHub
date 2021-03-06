#!/bin/bash

RELEASE=jhub
NAMESPACE=jhub

helm upgrade --cleanup-on-fail \
  --install $RELEASE jupyterhub/jupyterhub \
  --namespace $NAMESPACE \
  --create-namespace \
  --version=0.10.6 \
  --values config.yaml \
  --wait \
  --timeout 20m

# wait for pods to start
sleep 1m

# show pod status
echo ""
kubectl get pod --namespace $NAMESPACE

# show proxy-public info
echo ""
kubectl get svc proxy-public --namespace $NAMESPACE
echo ""
