### requisitos
Terraform version v1.1.7 or greater
https://learn.hashicorp.com/tutorials/terraform/install-cli

Docker runtime

JQ in linux

AWS CLI v2.4.39 or greater

SO Linux


### Como usar 
é necessário instalar as dependencias citadas a cima

Após todas as dependencias instaladas, configure a aws cli com um profile com as credencias da conta em que você deseja criar os recursos

Após isso crie um bucket s3 ou use um já existente para salvar o estado da infra que o terraform irá usar para gerenciar o estado dos recursos

Analise o arquivo terraforn.tfvars, este arquivo é onde definimos algumas variaveis de escopo global, olhe as variaveis e configure conforme seu uso

Após tudo isso configurado, execute o script start.sh que irá criar a infra caso houver algum erro, os recursos que foram criados até o momento do erro serão deletados da conta