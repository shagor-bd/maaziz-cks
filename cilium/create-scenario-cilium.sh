#!/bin/bash
echo cleaning team-orange
kubectl delete namespaces team-orange --force --grace-period 0
echo 
echo Create senario for CiliumNetworkPolicy
kubectl apply -f https://raw.githubusercontent.com/shagor-bd/maaziz-cks/refs/heads/main/cilium/team-orange.yaml

kubectl wait -n team-orange --for=condition=ready pod --all --timeout 30s

echo
echo Pods and Services in Namespace team-orange
kubectl -n team-orange get pod -o wide --show-labels | sed 's/NOMINATED NODE/NOMINATED_NODE/g' | sed 's/READINESS GATES/READINESS_GATES/g' | awk '{print $1,$3,$5,$6,$10}' | column -t
kubectl -n team-orange get svc -o wide --show-labels | awk '{print $1,$3,$5,$7}' | column -t

echo
echo Existing CiliumNetworkPolicy in Namespace team-orange
kubectl get cnp -n team-orange default-allow
