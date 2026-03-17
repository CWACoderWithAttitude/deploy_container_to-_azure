build:
	#docker build --rm -t azure:latest .
	docker build --platform linux/amd64 --rm -t azure:latest .

run_local:
	npm start
run_docker:
	docker run --rm -p 3000:3000 -t azure:latest

login:
	az login

acr:
	az group create --name meine-app-gruppe --location germanywestcentral

registry:
	az acr create \
  	  --resource-group meine-app-gruppe \
	  --name meineappregistry \
	  --sku Basic \
	  --admin-enabled true

acr_login:
	az acr login --name meineappregistry
# Image taggen & pushen
tag: build
	docker tag azure:latest meineappregistry.azurecr.io/meine-app:v1

push: tag
	docker push meineappregistry.azurecr.io/meine-app:v1

create_env:
	az containerapp env create \
	  --name meine-app-env \
	  --resource-group meine-app-gruppe \
	  --location germanywestcentral
#acr_pwd:
#	ACR_PASSWORD=$(az acr credential show \
# 		--name meineappregistry \
#  		--query "passwords[0].value" -o tsv)
#	echo acr-pwd: $(ACR_PASSWORD)	
ACR_PASSWORD="51vMHmbfIHkcKMfbiUaBq71vSG1wsIm5oVqChA9omieV2ouITxGZJQQJ99CCACPV0roEqg7NAAACAZCRVZN7"
deploy:
	az containerapp create \
	  --name meine-container-app \
	  --resource-group meine-app-gruppe \
	  --environment meine-app-env \
	  --image meineappregistry.azurecr.io/meine-app:v1 \
	  --target-port 3000 \
	  --ingress external \
	  --registry-server meineappregistry.azurecr.io \
	  --registry-username meineappregistry \
	  --registry-password $(ACR_PASSWORD) \
	  --cpu 0.5 --memory 1.0Gi

get_url:
	az containerapp show \
	  --name meine-container-app \
	  --resource-group meine-app-gruppe \
	  --query "properties.configuration.ingress.fqdn" -o tsv
# EoF
