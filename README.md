# CloudResume
Cloud Resume Challenge 
The Challenge can be found on: [Challenge - Azure](https://cloudresumechallenge.dev/docs/the-challenge/azure/)
The website can be found on: [LINK](https://www.messo.ai)

# Architecture

## Frontend
An Azure Storage Account is created with the static website feature actvated.
With this the $web container is created, where all the website content is stored. 
Following this Azure Front Door, Microsoft's CDN for global delivery, is set up to handle certificates and my custom domain (messo.ai).  

## Backend
A CosmosDB Account and a connected Database was created for storing the visitor count. To update this count, an Azure Function was set up using the Python SDK. This function connects to the DB and and updates the visitor count.

## CI/CD 
Currently two Github Actions are implemented (can be found under .github/workflows/)

### frontend.yml
Authenticates to Azure using federated credentials whenever updates are pushed to the /frontend folder. It uploads the frontend files to the blob storage and then purges the CDN cache so visitors get the latest version.

### backend.yml
Automatically deploys the Azure Functions app (visitorcount) whenever changes are pushed to the /api folder branch. It sets up Python, authenticates to Azure using federated credentials, and deploys the backend code to the function app. 

## TODO
- [ ] Add DNSSEC with Cloudflare
- [ ] Finish the Terraform setup to keep the full Infrastructure as Code.
- [ ] Add unit tests for the azure function.
- [ ] Implement some sort of Rate limiting on the visitor API
- [ ] Set up automated testing in the CI/CD pipeline
