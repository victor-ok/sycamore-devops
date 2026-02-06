# Root Cause Analysis

**Summary**: CrashLoopBackOff Investigation.
**Date**: 6th Feb, 2026
**Engineer**: Victor Okafor
**Severity**: Critical
**Status**: Resolved

	


# Executive Summary

The sycamore-api deployment experienced immediate and continuous pod failures, entering a CrashLoopBackOff state within seconds of deployment. Investigation revealed an intentional memory leak in the container command causing Out-of-Memory (OOM) kills. The issue was resolved by replacing the faulty deployment file with a proper application deployment file, implementing appropriate resource limits.

## Problem statements

 - **Symptoms**: Pod enters CrashLoopBackOff state immediately after deployment.
 - **Impact**: API Service completely unavailable resulting to 100% failure rate.
 - **Frequency**: Every attempt for pod restart attempt fails consistently.
 - **Timeline**: Issue persists from initial deployment.

## Investigation

 1. apply manifest file and watch the deployment
	 .# Deploy the broken manifest
	 
		kubectl apply -f k8s/broken-manifest.yaml
		deployment.apps/sycamore-api created
	.# Watch pod status in real-time
	
		kubectl get pods -w -l app=sycamore-api

| NAME | READY | STATUS | RESART
-----------------
| sycamore-api-7d8f9c6b5d-x7k2m | 0/1 | ContainerCreating | 0
| sycamore-api-7d8f9c6b5d-x7k2m | 0/1 | OOMKilled             | 0
| sycamore-api-7d8f9c6b5d-x7k2m | 0/1 | CrashLoopBackOff             | 0
| sycamore-api-7d8f9c6b5d-x7k2m | 0/1 | OOMKilled | 1
| sycamore-api-7d8f9c6b5d-x7k2m | 0/1 | CrashLoopBackOff             | 1

**Key Observation**: Pod consistently shows OOMKilled status before
entering CrashLoopBackOff

2. Detailed Pod Inspection
	 .# Get detailed pod information
	 
		kubectl describe pod sycamore-api-7d8f9c6b5d-x7k2m

		
# Resolution

 - Delete the broken deployment
 
			kubectl delete -f k8s/broken-manifest.yaml
 - Resource Optimization
			 resources:
				limits:
					memory: "256Mi"
					cpu: "500m"
				requests:
					memory: "128Mi"
					cpu: "200m"


## Fix Verification

 1.   Apply the fixed manifest
 
	kubectl apply -f k8s/fixed-manifest.yaml
2. Verify deployment rollout

kubectl rollout status deployment/sycamore-api

## Results: 
✅ Both pods running successfully
✅ Memory usage stable at ~85 MB (well below 256 MB limit)
✅ CPU usage normal (~50m, well below 500m limit)
✅ Health checks passing consistently
✅ No restarts observed over 24-hour period