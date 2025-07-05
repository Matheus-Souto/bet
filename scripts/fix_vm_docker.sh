#!/bin/bash

# Script para resolver problemas de permissão Docker na VM

echo "🔧 Resolvendo problemas de Docker na VM..."
echo

# Verificar se Docker está rodando
if ! sudo systemctl is-active --quiet docker; then
    echo "📦 Iniciando serviço Docker..."
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Adicionar usuário atual ao grupo docker
echo "👤 Adicionando usuário $(whoami) ao grupo docker..."
sudo usermod -aG docker $USER

# Verificar se o grupo foi adicionado
echo "✅ Usuário $(whoami) adicionado ao grupo docker"

# Mostrar grupos do usuário
echo "📋 Grupos atuais do usuário:"
groups $USER

echo
echo "⚠️  IMPORTANTE: Para as permissões fazerem efeito, você precisa:"
echo "1. Fazer logout e login novamente, OU"
echo "2. Executar: newgrp docker, OU" 
echo "3. Reiniciar a VM"
echo

# Testar Docker com sudo temporariamente
echo "🧪 Testando Docker com sudo..."
sudo docker --version

echo
echo "🐳 Testando se Docker funciona..."
if sudo docker ps >/dev/null 2>&1; then
    echo "✅ Docker está funcionando com sudo"
else
    echo "❌ Docker não está funcionando"
    echo "Tentando iniciar serviço..."
    sudo systemctl restart docker
    sleep 3
    
    if sudo docker ps >/dev/null 2>&1; then
        echo "✅ Docker funcionando após restart"
    else
        echo "❌ Problema persistente com Docker"
        echo "Verifique os logs: sudo journalctl -u docker"
    fi
fi

echo
echo "🏃‍♂️ Para continuar com o setup:"
echo "1. Execute: newgrp docker"
echo "2. Ou faça logout/login"
echo "3. Depois execute novamente: ./setup_vm.sh"
echo

echo "🔧 Ou execute os comandos Docker com sudo por enquanto:"
echo "sudo docker-compose -f docker-compose.infrastructure.yml up -d" 