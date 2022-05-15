#!/bin/bash

#--- Variables ---
RESOURCEGROUP=your_resource_group
CERTPASSWD=certpasswd
IPNAME=applicationpubulicip

#--- Get certdata ---
INKEY=yourpath/private.key
INFILE=yourpath/certificate.crt
CRTPATH=yourpath/ca_bundle.crt
PFXPATH=yourpath/certificate_combined.pfx
openssl pkcs12 -password pass:${CERTPASSWD} -export -out "${PFXPATH}" -inkey "${INKEY}" -in "${INFILE}" -certfile ${CRTPATH}
CERTDATA=$(base64 -w0 ${PFXPATH})

#--- Dploy blobstorage ---
BLOBNAME=yourblobname

az deployment group create \
  --name ${BLOBNAME} \
  --resource-group ${RESOURCEGROUP} \
  --template-file blob_template.json \
  --parameters storageAccountName=${BLOBNAME} storageSku=Standard_GZRS

#--- Deploy applicationgateway ---
ENDPOINT=$(az storage account show --name ${BLOBNAME} | jq -r .primaryEndpoints.web | sed -E 's/^.*(http|https):\/\/([^/]+).*/\2/g')

az deployment group create \
  --name yourAppgateway \
  --resource-group ${RESOURCEGROUP} \
  --template-file agw_template.json \
  --parameters ipName=${IPNAME} fqdn=${ENDPOINT} certData=${CERTDATA} certPassword=${CERTPASSWD}

#--- Added arecord ---
TTL=60
ZONENAME=yourdomain
IPADDR=$(az network public-ip show --resource-group ${RESOURCEGROUP} --name ${IPNAME} | jq -r .ipAddress)
RECORDNAME=("@" "www")

for (( i = 0; i < ${#RECORDNAME[@]}; ++i ));do
az network dns record-set a add-record \
  --resource-group ${RESOURCEGROUP} \
  --zone-name ${ZONENAME} \
  --record-set-name ${RECORDNAME[$i]} \
  --ipv4-address $IPADDR \
  --ttl ${TTL}
done