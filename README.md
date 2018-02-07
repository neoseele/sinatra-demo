# sinatra-demo

## Setup

([Reference](https://cloud.google.com/sql/docs/mysql/connect-container-engine))

* Create CloudSQL instance **mysqldb1**

* Retrieve connection name
```sh
gcloud sql instances describe mysqldb1 | grep connectionName

connectionName: xxx:sinatra1
```

* Create db user
```sh
gcloud sql users create proxyuser cloudsqlproxy~% --instance=mysqldb1
```
* Create serviceaccount **cloudsqlclient**, saved the private key as **cloudsqlclient.json**

* Create k8s secrets

```sh
kubectl -n [dev|canary|prod] create secret generic cloudsql-instance-credentials --from-file=cloudsqlclient.json
kubectl -n [dev|canary|prod] create secret generic sinatra-credentials --from-literal=admin_user=<username> --from-literal=admin_password=<password>
```

* Create SSL cert/key
```sh
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=app.example.com/O=sinatra"
```

* Add SSL cert/key as secret (_tested in dev namespace only_)
```sh
kubectl -n dev create secret generic sinatra-tls --from-file=tls.crt --from-file=tls.key
```

## Tear Down

_TBD_
