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
