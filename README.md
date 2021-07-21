# Purpose
This project is used to create an OpenEdge Database image (OEDB) and a deployment of my simple Progress Application Server for OpenEdge (PASOE) application for tracking the coordinates of the International Space Station (ISS). This project is a learning exercise for Kubernetes deployments, k3d, PASOE applications, OpenEdge Databases (OEDB), Helm Charts.


# K3D Local Registry
K3D cannot pull images from your local docker registry. In this project, it assumes that a k3d registry has been created, linked to your cluster, and that the iss-pas and issdb images have been pushed to the local registry

# How to Deploy Project to K3D
In the project directory, run 'helm install iss-pas iss-charts/ --values iss-charts/values.yaml'. This will create the Deployment, Service, Secret, and ConfigMap from the iss-charts/template files.


# Create OEDB Image
The oedb_image directory contains a template provided by progress to allow the creation of an OpenEdge database image (which I will be using for my iss_pas PASOE application to store data)

### Database Definition
oedb_image/artifacts/issdb.df is a definitions file created from an exported database named issdb. This file will be used to create the database inside of the OEDB image.

### Progress OEDB License
A license to use a Progress database is required and should be stored in oedb_image/license with the name progress.cfg. Redacted for legal reasons.

### OEDB Image Build
The build.sh script takes the properties defined in config.properties and applies them to the Dockerfile and hook-script.sh as well as validate.sh.




# Create and Deploy PASOE Image
The pasoe_image_create_and_deploy directory contains a template provided by Progress to be able to create a PASOE image and deploy it to Kubernetes (in this case, I am using a local Kubernetes distribution called k3d)

### PASOE Project
The pasoe_image_create_and_deploy/ablapps directory contains a .zip file with the contents of the actual PASOE application that I created and exported from Progress Developer Studio. Unzip ablapps/iss_pas.zip to view the contents of the iss_pas project.

### Runtime Properties
pasoe_image_create_and_deploy/conf/logging/runtime.properties contains a database connection string that is baked into the openedge.properties file of the project during runtime. This makes it so I don't have to unzip, modify openedge.properties, and rezip the project every time there is a change with the database image.

### Progress PASOE License
The pasoe_image_create_and_deploy/license directory contains the progress license, named progress.cfg. This license file is redacted from this project for legal reasons but is required at deployment time.

### Scripts
The pasoe_image_create_and_deploy/scripts/k3d directory contains the deployment definition template and service definition template that are used with the config.properties file to create proper deployment and service definitions required to deploy the project to k3d with the OEDB and PASOE images. The build.xml file is an ant file called by ../build.xml as long as DEPLOYMENT.MODE in config.properties is k3d
