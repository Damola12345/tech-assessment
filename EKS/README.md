## EKS Cluster Provisioning with Terraform
This repository contains Terraform modules and configuration files to provision an Amazon Elastic Kubernetes Service (EKS) cluster, along with various additional components to enhance its functionality. Below is an overview of the key components and how to use them.

## Components:
`Terraform Modules`: The  directory contains Terraform modules for creating and managing the EKS cluster, ensuring a consistent and reliable infrastructure setup.

`Helm LoadBalancer Controller (Nginx Controller)`: Utilize Helm to deploy the LoadBalancer Controller, powered by Nginx, to manage ingress and load balancing within your EKS cluster. You can find the Helm chart and values in the helm/ directory for customization.

`Karpenter for Node Scaling`: Utilize Helm to deploy Karpenter into EKS cluster.  Karpenter is employed to automatically scale the nodes within the EKS cluster based on resource demands. 

`Cert Manager and Let's Encrypt`: To enhance security, integrated Cert Manager for automatic certificate management and Let's Encrypt for free SSL certificates.

`EBS-CSI Driver`: We've included the EBS Container Storage Interface (CSI) driver to facilitate dynamic provisioning of Amazon Elastic Block Store (EBS) volumes for Kubernetes workloads.

`k8s`: This directory contains the Kubernetes deployment files.
- `Deployment`: The deployment.yaml file defines a Kubernetes Deployment resource. Deployments are used to manage the deployment of  application's pods and ensure high availability and scalability.

- `Service`: The service.yaml file defines a Kubernetes Service resource. Services expose the Deployment's pods to the network, making them accessible within or outside the cluster, depending on the Service type.

- `Ingress`: The ingress.yaml file defines a Kubernetes Ingress resource. Ingress resources provide external access to your services by managing the routing of incoming traffic based on defined rules.