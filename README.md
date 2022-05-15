# Azurestaticsite  
Azure StaticHostingPattern Building ARM template

# Description  
This is the configuration file for Azure's ARMTemplate and the Shell script to invoke it.
The configuration is a combination of ApplicationGateway and BlobStorage static hosting sites, and the IP address of the ApplicationGateway is set in AzureDNS.  

# Operating environment  
Ubuntu 20.04.4 LTS  
azure-cli 2.14.0  
python 3.10.2  

# Usage  
1.Please register your DNS in advance and issue an SSL key at ZeroSSL.　　

2.Please register your DNS in advance, issue an SSL key at ZeroSSL, and upload the SSL file to the terminal where you will run the shell script.  

3.Register your domain and CNAME issued by ZeroSSL in AzureDNS with the following command  
ARM application command for DNS registration command  

$ az deployment group create \
  --name dnstohonokaitk \
  --resource-group lb_tohonokai_test \
  --template-file dns_template.json \
  --parameters zoneName=yourdomain recordName=_Publishedzerossl.comodoca.com  
  
4.Execute shellscript  
$ ./deploy.sh  