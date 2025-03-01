#!/bin/bash

# Atualiza a lista de pacotes e instala o NGINX e o python3-pip
apt-get update -y
apt-get install -y nginx python3-pip

# Instala a biblioteca 'requests' via pip (a biblioteca 'logging' já vem instalada com o Python)
pip3 install requests

# Habilita o NGINX para iniciar automaticamente e inicia o serviço
systemctl enable nginx
systemctl start nginx

# Cria uma página HTML customizada para o NGINX
cat <<EOF > /var/www/html/index.html

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
      rel="stylesheet"
      integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
      crossorigin="anonymous"
    />
    <link rel="stylesheet" href="style.css">
  </head>
  <body class=" text-center text-bg-dark">
    <div class="cover-container d-flex w-100 h-100 p-3 mx-auto flex-column">
      <header class="mb-auto">
        <div>
          <h3 class="float-md-start mb-0">Arthur Fudali - Atividade Linux e AWS</h3>
          <nav class="nav nav-masthead justify-content-center float-md-end">
            <a
              class="nav-link fw-bold py-1 px-0 active"
              aria-current="page"
              href="#"
              >Home</a
            >
          </nav>
        </div>
      </header>

      <main class="px-3">
        <h1></h1>
        <p class="lead">
          Esta pagina esta sendo servida por uma instancia EC2 rodando Amazon Linux via um Servidor Web Nginx 
        </p>
        <p class="lead">
          <a href="#" class="btn btn-lg btn-light fw-bold border-white bg-white"
            >Learn more</a
          >
        </p>
      </main>

      <footer class="mt-auto text-white-50">
        <p>
          
        </p>
      </footer>
    </div>

    <script
      src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
      integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
      crossorigin="anonymous"
    ></script>
  </body>
</html>

EOF

# Cria a folha de estilo para a pagina HTML previamente criada

cat <<'EOF' > /var/www/html/sytle.css
.btn-light,
.btn-light:hover,
.btn-light:focus {
  color: #333;
  text-shadow: none; /* Prevent inheritance from `body` */
}
body {
  text-shadow: 0 0.05rem 0.1rem rgba(0, 0, 0, 0.5);
  box-shadow: inset 0 0 5rem rgba(0, 0, 0, 0.5);
  height: 100vh !important;
  display: flex;
}
.cover-container {
  max-width: 42em;
}
.nav-masthead .nav-link {
  color: rgba(255, 255, 255, 0.5);
  border-bottom: 0.25rem solid transparent;
}
.nav-masthead .nav-link:hover,
.nav-masthead .nav-link:focus {
  border-bottom-color: rgba(255, 255, 255, 0.25);
}
.nav-masthead .nav-link + .nav-link {
  margin-left: 1rem;
}
.nav-masthead .active {
  color: #fff;
  border-bottom-color: #fff;
}
EOF


# Cria um script Python que utiliza as bibliotecas requests e logging

cat <<'EOF' > /usr/local/bin/server_status.py
#!/usr/bin/python3

#IMPORTACAO DE BIBLIOTECAS
import requests
import logging

#CONFIGURACAO DO LOG DO STATUS USANDO LOGGING
LOG_FILE = "/home/ubuntu/logs/monitoramento.log" #COLOQUE AQUI O ENDERECO DO SEU ARQUIVO DE LOGS
logging.basicConfig(filename=LOG_FILE, level=logging.INFO, format="%(asctime)s - %(message)s")

#URLS DO SITE A SER MONITORADO E DA WEBHOOK DO DISCORD
SITE_URL = "http://localhost" 
DISCORD_WEBHOOK_URL = "" #COLOQUE AQUI SUA URL

#FUNCAO QUE VERIFICA O STATUS DO SITE VIA CODIGOS HTTP
def verificar_site():
    try:
        #ENVIA O REQUEST PARA O SITE
        resposta = requests.get(SITE_URL, timeout=5)

        #CODIGO DE OPERACAO BEM SUCEDIDA
        if resposta.status_code == 200: 
            logging.info(f"✅O site está online: Código de resposta: {resposta.status_code}")
            return True
        
        else:
            logging.warning(f"⚠️O Site retornou um código de resposta: {resposta.status_code}")
            return False
        
    #TRATAMENTO DE ERROS
    except requests.RequestException as e:
        logging.error(f"❌O Site esta offline! Erro: {e}")
        return False

#FUNCAO PARA ENVIAR DISPONIBILIDADE DO SITE PARA O DISCORD
def enviar_alerta():

    #O DISCORD ACEITA MENSAGEM EM FORMATO DE JSON:
    mensagem = {"content": f"🚨O site está fora do ar!"}

    #ENVIA A MENSAGEM PARA O DISCORD
    requests.post(DISCORD_WEBHOOK_URL, json=mensagem)

if __name__ == "__main__":
    if not verificar_site():
        enviar_alerta()
EOF

# Adiciona permissão de execução para o script Python
chmod +x /usr/local/bin/server_status.py

# Adiciona o script Python ao crontab para ser executado a cada minuto
cat <<EOF > /etc/cron.d/server_status
* * * * * root /usr/local/bin/server_status.py
EOF

# Reinicia o serviço do cron para garantir que a nova tarefa seja carregada
systemctl enable cron
service cron restart
