# AtividadeLinuxAWS
Atividade utilizando uma Instancia EC2 Linux, VPCs, WebServer Nginx e monitoramento de indisponibilidade

### 1. Criação da VPC:

Acessar o painel de VPC

![Painel da criacao da VPC](images/painelVPC.png)

Acessar a tela de criação de VPC

Nomear a VPC e configurar a criação de sub-redes

![Criacao da VPC](images/criacaoVPC.png)

Preview da VPC:

![Preview da VPC](images/previewVPC.png)

Executar a criação da VPC

### 2. Criação do Security Group

Acesse a tela de criação de grupos de segurança (essa sessão pode ser encontrada tanto no menu da EC2 quanto no menu da aba de VPCs)

- Informe os detalhes básicos do SG (security group):
    - Importante: selecione a VPC criada para o projeto!

![image.png](images/criacaoSG1.png)

- Adicione as regras de entrada e de saída
    - As regras de entrada (SSH e HTTP) devem estar configuradas para o seu IP
    - As regras de saída (HTTP e HTTPS) devem estar configuradas para qualquer endereço IPV4
    
![image.png](images/criacaoSG2.png)

Em seguida, crie o grupo de segurança.

### 3. Criação da Instancia EC2

Acessar o painel da instancia:

![image.png](images/painelEC2.png)

Na tela de criação de instancias:

Configurar o nome e as tags necessarias para a criacao da sua instancia

![image.png](images/chaveCriacaoEC2.png)

Em seguida, escolher o tipo de instancia e a AMI (imagem) que sera utilizada:

- nesse caso a AMI Ubuntu sera utilizada numa instancia do tipo t2.micro

![image.png](images/selecaoAMI.png)

Em seguida, escolher a chave SSH que sera utilizada para acessar a instancia:

![image.png](images/chaveCriacaoEC2.png)

Agora, e necessário alterar as configurações de rede da instancia:

- Selecione a VPC criada para o projeto
- Na Sub-rede, selecione uma das sub redes PUBLICAS da sua VPC
- Ative a atribuição de IP publico
- Selecione o SG criado para o projeto

![image.png](images/redesCriacaoEC2.png)

Na sessão de armazenamento:

- Selecione o tipo de armazenamento gp3 (e a versão melhorada e mais barata do armazenamento gp2)

![image.png](images/armazenamentoCriacaoEC2.png)

Nesse momento a instancia ja pode ser criada.

# Etapa 2: Servidor Web

1. Instalar o servidor Nginx na EC2
2. Criar uma pagina HTML para ser exibida
3. Configurar o Nginx para servir a pagina
    
    Personalizar a pág. com informações sobre o projeto
    
    Criar um serviço `systemd` para reiniciar o Nginx automaticamente
    

## Criação do servidor com `Nginx`

Apos a instancia ser criada, acesse a maquina via chave `SSH`

Voce tambem pode acessar a maquina usando o Visual Studio Code com a extensao `Remote - SSH`

Para fazer isso instale a extensão, aperte CTRL + SHIFT + P e acesse → `Remote-SHH: Connect to host` , → `Configure SSH Hosts` → Edite o arquivo de configurações com suas informações

![image.png](images/configConexao.png)

Com a maquina conectada, o terminal ira se parecer com isso: 

![image.png](images/terminalConectado.png)

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

![image.png](images/nginxStatus.png)

## Criação da pagina `HTML`

Crie a pagina HTML a ser exibida:

```bash
sudo nano /usr/share/nginx/html/index.html
```
(verifique se o seu Nginx esta apontando para o diretório correto, pode acontecer de, por padrão, o nginx apontar para /var/www/html e nao /usr/share/nginx/html)


A terminal ira abrir o `nano` para editar o arquivo index.html:

Aqui voce devera digitar ou colar o seu arquivo HTML que sera exibido

![image.png](images/nanoPagHTML.png)
[Pagina HTML](index.html)
[Folha de estilo](style.css)


Salve o arquivo com `CTRL + X`, `Y`, `Enter`

Reinicie o `Nginx` para começar a exibir a pagina HTML:

```bash
sudo systemctl restart nginx
```

Agora, acesse a instancia pelo seu IP publico no navegador:

`http://SEU_IP_PUBLICO`

![image.png](images/pagHTMLOnline.png)

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
