# AtividadeLinuxAWS
Atividade utilizando uma Instancia EC2 Linux, VPCs, WebServer Nginx e monitoramento de indisponibilidade

### 1. Criação da VPC:

Acessar o painel de VPC

![image.png](attachment:5524ea49-5521-4074-ae98-6c6b52e735db:image.png)

Acessar a tela de criação de VPC

Nomear a VPC e configurar a criação de sub-redes

![image.png](attachment:40fb3983-d13c-42a4-9c54-4d07f42ba2d9:image.png)

Preview da VPC:

![image.png](attachment:156dd296-e425-49ec-803f-ab65ca479293:image.png)

Executar a criação da VPC

### 2. Criação do Security Group

Acesse a tela de criação de grupos de segurança (essa sessão pode ser encontrada tanto no menu da EC2 quanto no menu da aba de VPCs)

- Informe os detalhes básicos do SG (security group):
    - Importante: selecione a VPC criada para o projeto!

![image.png](attachment:3cbcdb93-be4c-48f9-b10d-19f269ca555a:image.png)

- Adicione as regras de entrada e de saída
    - As regras de entrada (SSH e HTTP) devem estar configuradas para o seu IP
    - As regras de saída (HTTP e HTTPS) devem estar configuradas para qualquer endereço IPV4
    

![image.png](attachment:9e096bc1-d201-449a-b852-e89bcf6143e6:image.png)

Em seguida, crie o grupo de segurança.

### 3. Criação da Instancia EC2

Acessar o painel da instancia:

![image.png](attachment:3e145777-88d5-4e5f-9758-58d036407ec8:image.png)

Na tela de criação de instancias:

Configurar o nome e as tags necessarias para a criacao da sua instancia

![image.png](attachment:4b8e9281-ef43-4685-b053-263b458c55ec:image.png)

Em seguida, escolher o tipo de instancia e a AMI (imagem) que sera utilizada:

- nesse caso a AMI Amazon Linux 2 sera utilizada numa instancia do tipo t2.micro

![image.png](attachment:fab596cf-f6c8-45b7-8608-ab01c6a28953:image.png)

Em seguida, escolher a chave SSH que sera utilizada para acessar a instancia:

![image.png](attachment:c4375e01-2b05-4331-b76f-19ba3b5566b0:image.png)

Agora, e necessário alterar as configurações de rede da instancia:

- Selecione a VPC criada para o projeto
- Na Sub-rede, selecione uma das sub redes PUBLICAS da sua VPC
- Ative a atribuição de IP publico
- Selecione o SG criado para o projeto

![image.png](attachment:d944dfde-b7af-4cd3-b7c1-8cead5811729:image.png)

Na sessão de armazenamento:

- Selecione o tipo de armazenamento gp3 (e a versão melhorada e mais barata do armazenamento gp2)

![image.png](attachment:6d7f68af-c16e-443f-a922-2e5c667f218c:image.png)

Nesse momento a instancia ja pode ser criada.

# Etapa 2: Servidor Web

1. Instalar o servidor Nginx na EC2
2. Criar uma pagina HTML para ser exibida
3. Configurar o Nginx para servir a pagina
    
    Personalizar a pág. com informações sobre o projeto
    
    Criar um serviço `systemd` para reiniciar o Nginx automaticamente
    

## Criação do servidor com `Nginx`

Apos a instancia ser criada, acesse a maquina via chave `SSH`

![image.png](attachment:f22b16a3-c41a-4bd2-a1c7-d360ada10d2b:image.png)

No terminal da instancia, faca as atualizações necessárias com:

```bash
sudo yum update -y
```

Agora instale o `Nginx`:

```bash
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
```

Inicialize e habilite o `Nginx`:

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

Verifique o status:

```bash
sudo systemctl status nginx
```

O terminal deve aparecer da seguinte maneira:

![image.png](attachment:78a41cad-6083-4d12-9761-56d1123e5742:image.png)

## Criação da pagina `HTML`

Crie a pagina HTML a ser exibida:

```bash
sudo nano /usr/share/nginx/html/index.html
```

A terminal ira abrir o `nano` para editar o arquivo index.html:

Aqui voce devera digitar ou colar o seu arquivo HTML que sera exibido

[Pagina HTML](index.html)
[Folha de estilo](style.css)

![image.png](attachment:36514391-5f3d-4a0b-ba61-b019b8829a30:image.png)

Salve o arquivo com `CTRL + X`, `Y`, `Enter`

Reinicie o `Nginx` para começar a exibir a pagina HTML:

```bash
sudo systemctl restart nginx
```

Agora, acesse a instancia pelo seu IP publico no navegador:

`http://SEU_IP_PUBLICO`

# Etapa 3: Monitoramento e notificações

Para iniciar a criação do script, verifique se a versão do python e do pip (instalador de pacotes python) estão atualizadas, caso contrario, as atualize.

```bash
python3 --version
pip3 --version
```

Agora ja sera possível instalar as bibliotecas necessárias para a execução do script:

```bash
pip install requests
pip install logging
```

Caso nao for possível instalar utilizando o PIP, voce pode instalar as bibliotecas usando o APT:

```bash
sudo apt install python3-requests
sudo apt install python3-logging
```

Agora, crie o script em um diretório de sua preferencia:

```bash
sudo nano /home/ubuntu/scripts/server_status.py
```

Em seguida, cole o script e salve as alterações com `CTRL + X, Y, ENTER`

[Script de monitoramento](script.py)

Adicione a permicao de EXECUCAO para o script:

```bash
sudo chmod +x server_status.py
```

Teste o script:

```bash
python3 server_status.py
```

Agora, crie a automação utilizando o serviço `crontab`:

```bash
crontab -e
1

#Em quando o arquivo de configs abrir com o nano, adicione a linha:
* * * * * /usr/bin/python3 /home/ubuntu/scripts/server_status.py
#Isso ira garantir que o script se excecute automaticamente a cada minuto
```

Em seguida, ative a execucao do servico `contrab` :

```bash
sudo systemctl enable cron
```
