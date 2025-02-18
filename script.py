#!/usr/bin/python3

#IMPORTACAO DE BIBLIOTECAS
import requests
import logging

#CONFIGURACAO DO LOG DO STATUS USANDO LOGGING
LOG_FILE = "/home/ubuntu/logs/monitoramento.log" #COLOQUE AQUI O ENDERECO DO SEU ARQUIVO DE LOGS
logging.basicConfig(filename=LOG_FILE, level=logging.INFO, format="%(asctime)s - %(message)s")

#URLS DO SITE A SER MONITORADO E DA WEBHOOK DO DISCORD
SITE_URL = "http://localhost" 
DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1339930323089100841/-89wQnbpzKxSGd86a9g12OFPHNq7PxV5x6YuBPrXrqCcoqHkqLOngp9xvd96NLpZLEEJ" #COLOQUE AQUI SUA URL

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

    #PEGA O CODIGO DE ERRO DO SITE
    request = requests.get(SITE_URL, timeout=5)
    status_code = request.status_code

    #O DISCORD ACEITA MENSAGEM EM FORMATO DE JSON:
    mensagem = {"content": f"🚨O site está fora do ar! Erro: {status_code}"}

    #ENVIA A MENSAGEM PARA O DISCORD
    requests.post(DISCORD_WEBHOOK_URL, json=mensagem)

if __name__ == "__main__":
    if not verificar_site():
        enviar_alerta()
