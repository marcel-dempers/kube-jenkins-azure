# Jenkins on Kubernetes with Azure Persistance

## Configure your cluster with helm

```
kubectl create -f ./prerequisites/helm-rbac.yaml
helm init --service-account tiller

```

## Fill out parameters

Inside ./helm-charts there is a `values.yaml` that needs to be filled out.
NOTE: Keep your sensitive secrets safe and do not check this into your source control!

## Deploy the storage

```
cd helm-charts
helm install --name azure-storage azure-storage --values values.yaml --namespace jenkins 
```

## Deploy Jenkins

```
helm install --name jenkins-azure jenkins-azure --values values.yaml --namespace jenkins
```

## Access Jenkins

After a couple of seconds, Jenkins should be accessible
This will print out logs with initial password for one time auth
It will also connect through `port-forward` on `http://localhost:8080`
```
jenkins=$(kubectl get pods -n jenkins --selector=name=jenkins --output=jsonpath='{.items[*].metadata.name}')
kubectl logs $jenkins -n jenkins
kubectl port-forward -n jenkins $jenkins 8080:8080
```