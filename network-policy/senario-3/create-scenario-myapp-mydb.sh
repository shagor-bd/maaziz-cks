#!/bin/bash
echo cleaning myapp and mydb Namespaces
kubectl delete namespaces myapp mydb --force --grace-period 0
echo 
echo Create senario for NetworkPolicy
kubectl apply -f https://raw.githubusercontent.com/shagor-bd/maaziz-cks/refs/heads/main/network-policy/senario-3/script-environment-seprate-db-namespace.yaml

kubectl wait -n myapp --for=condition=ready pod --all --timeout 30s
kubectl wait -n mydb --for=condition=ready pod --all --timeout 30s

echo
echo Pods and Services in Namespace myapp
kubectl -n myapp get pod -o wide --show-labels | sed 's/NOMINATED NODE/NOMINATED_NODE/g' | sed 's/READINESS GATES/READINESS_GATES/g' | awk '{print $1,$3,$5,$6,$10}' | column -t
kubectl -n myapp get svc -o wide --show-labels | awk '{print $1,$3,$5,$7}' | column -t

echo
echo Pods and Services in Namespace mydb
kubectl -n mydb get pod -o wide --show-labels | sed 's/NOMINATED NODE/NOMINATED_NODE/g' | sed 's/READINESS GATES/READINESS_GATES/g' | awk '{print $1,$3,$5,$6,$10}' | column -t
kubectl -n mydb get svc -o wide --show-labels | awk '{print $1,$3,$5,$7}' | column -t
