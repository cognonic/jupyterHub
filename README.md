## Scripts for installing and updating JupyterHub on a GKE Cluster

To use the bash shell scripts, you need to install the following software components to your local VM environment:
   - installed the Google Cloud SDK on your local VM
      - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)

   - installed Helm
      - [Helm](https://helm.sh/docs/intro/install/)

   - reference material for JupyterHub:
      - [JupyterHub](https://jupyterhub.readthedocs.io/en/stable/installation-guide.html)

   - reference material for Kubernetes:
      - [Google Kubernetes](https://cloud.google.com/kubernetes-engine)

### General File Descriptions:
   - config.yaml.orig
      - example config.yaml file for JupyterHub
      - copy config.yaml.orig to config.yaml 
      - the configuration file for JupyterHub:
         - available notebook images to select from
         - default users and adminUsers
         - group password

   - helmInstall.sh:
      - used to install the base JupyterHub image onto the GKE cluster

   - helmUpdate.sh:
      - used to update the base JupyterHub image on the GKE cluster

### Example Usage:
   - ssh into your local VM
   - create a secret token:
``` 
   $ openssl rand -hex 32
      52364ad82a5fdb75326d60762cf6b7c5c4599ffd15aab17535b4d8dabb5ed2e8
```
   - add the secret token to your config.yaml file
   - modify the config.yaml file:
      - admin_users, allowed_users, and password information
      - image repository location for each Jupyter Notebook image
   - startup your GKE cluster:
```
   $ gcloud container clusters create "kube-jupyterhub-cluster" \
      --project "<project_id>" \
      --zone "us-central1-c" \
      --machine-type n1-standard-2 \
      --num-nodes 3 \
      --enable-autoscaling \
      --min-nodes "1" \
      --max-nodes "4" \
      --node-locations "us-central1-c" \
      --cluster-version latest

   $ kubectl create clusterrolebinding cluster-admin-binding \
      --clusterrole=cluster-admin \
      --user=<your@email.com>
```
   - run the helmInstall.sh bash script
   - wait until all of your JupyterHub pods are running, then locate your External-IP:
```
   $ kubectl --namespace=jhub get pods
      NAME                              READY   STATUS    RESTARTS   AGE
      continuous-image-puller-bjthv     1/1     Running   0          55s
      continuous-image-puller-d4xcb     1/1     Running   0          55s
      continuous-image-puller-g6fr8     1/1     Running   0          55s
      hub-7c49846d4f-x5zv2              1/1     Running   0          55s
      proxy-56b59fcb97-jqz6m            1/1     Running   0          55s
      user-scheduler-599dd58d74-g68xx   1/1     Running   0          54s
      user-scheduler-599dd58d74-x9w6p   1/1     Running   0          55s
            
   $ helm list --namespace jhub        
      NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
      jhub    jhub            3               2021-03-02 10:27:41.795209061 -0500 EST deployed        jupyterhub-0.10.6       1.2.2
            
   $ helm history jhub --namespace jhub
      REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
      1               Tue Mar  2 11:41:47 2021        deployed        jupyterhub-0.10.6       1.2.2           Install complete
        
   $ kubectl --namespace=jhub get svc proxy-public
      NAME           TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
      proxy-public   LoadBalancer   10.127.251.139   35.192.196.154   80:30254/TCP   7m29s
``` 
   - connect to your JupyterHub Server via the External-IP and login with one of your user_admin IDs
```
   Browser:
      http://35.192.196.154/
```

### JupyterHub Config Changes:
   - if you make changes to your JupyterHub config.yaml file, then use the helmUpdate.sh bash script
   
