#!/bin/bash

namespace=kube-system

for var in $(kubectl get pods --namespace=$namespace | awk '{print $1}' | sed '1d')
do
echo $var $(kubectl describe pods $var --namespace=$namespace | grep "Controlled By:")
done


