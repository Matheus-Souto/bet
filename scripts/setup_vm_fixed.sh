#!/bin/bash

# Script corrigido para configurar automaticamente a VM com os serviços necessários
# Execute este script na VM Linux

set -e

echo "🚀 Configurando VM para Bet Analytics (Versão Corrigida)..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir com cor
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Função para executar Docker (com sudo se necessário)
docker_cmd() {
    if groups $USER | grep &>/dev/null '\bdocker\b'; then
        docker "$@"
    else
        sudo docker "$@"
    fi
}

docker_compose_cmd() {
    if groups $USER | grep &>/dev/null '\bdocker\b'; then
        docker-compose "$@"
    else
        sudo docker-compose "$@"
    fi
}

# Verificar se é root
if [[ $EUID -eq 0 ]]; then
   print_error "Este script não deve ser executado como root"
   exit 1
fi

# Detectar distribuição Linux
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
fi

print_status "Detectado: $OS $VER"

# Instalar Docker se não estiver instalado
if ! command -v docker &> /dev/null; then
    print_status "Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    print_warning "Docker instalado. Você precisa fazer logout/login para usar sem sudo"
else
    print_status "Docker já está instalado"
fi

# Verificar se usuário está no grupo docker
if ! groups $USER | grep &>/dev/null '\bdocker\b'; then
    print_status "Adicionando usuário $USER ao grupo docker..."
    sudo usermod -aG docker $USER
    print_warning "Usuário adicionado ao grupo docker. Você precisa fazer logout/login ou executar: newgrp docker"
fi

# Instalar Docker Compose se não estiver instalado
if ! command -v docker-compose &> /dev/null; then
    print_status "Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    print_status "Docker Compose já está instalado"
fi

# Verificar se Docker está rodando
if ! sudo systemctl is-active --quiet docker; then
    print_status "Iniciando serviço Docker..."
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Configurar firewall
print_status "Configurando firewall..."
if command -v ufw &> /dev/null; then
    # Ubuntu/Debian
    sudo ufw allow 5432 comment "PostgreSQL"
    sudo ufw allow 6379 comment "Redis"
    sudo ufw allow 8080 comment "PgAdmin"
    sudo ufw allow 8081 comment "Redis Commander"
    print_status "Firewall configurado (ufw)"
elif command -v firewall-cmd &> /dev/null; then
    # CentOS/RHEL
    sudo firewall-cmd --permanent --add-port=5432/tcp
    sudo firewall-cmd --permanent --add-port=6379/tcp
    sudo firewall-cmd --permanent --add-port=8080/tcp
    sudo firewall-cmd --permanent --add-port=8081/tcp
    sudo firewall-cmd --reload
    print_status "Firewall configurado (firewalld)"
else
    print_warning "Firewall não detectado - configure manualmente as portas 5432, 6379, 8080, 8081"
fi

# Criar diretório do projeto
PROJECT_DIR="$HOME/bet-analytics-vm"
if [ ! -d "$PROJECT_DIR" ]; then
    print_status "Criando diretório do projeto..."
    mkdir -p $PROJECT_DIR
    cd $PROJECT_DIR
else
    print_status "Diretório do projeto já existe: $PROJECT_DIR"
    cd $PROJECT_DIR
fi

# Criar arquivo docker-compose.infrastructure.yml se não existir
if [ ! -f "docker-compose.infrastructure.yml" ]; then
    print_status "Criando arquivo de configuração docker-compose.infrastructure.yml..."
    
    cat > docker-compose.infrastructure.yml << 'EOF'
version: '3.8'

services:
  # PostgreSQL Database
  db:
    image: postgres:15
    container_name: bet_postgres
    environment:
      POSTGRES_USER: bet_user
      POSTGRES_PASSWORD: bet_password
      POSTGRES_DB: bet_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - bet_network
    restart: unless-stopped

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: bet_redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - bet_network
    restart: unless-stopped

  # PgAdmin (Opcional - para gerenciar o banco visualmente)
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: bet_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@bet.com
      PGADMIN_DEFAULT_PASSWORD: admin123
    ports:
      - "8080:80"
    networks:
      - bet_network
    restart: unless-stopped
    depends_on:
      - db

  # Redis Commander (Opcional - para gerenciar Redis visualmente)
  redis-commander:
    image: rediscommander/redis-commander:latest
    container_name: bet_redis_commander
    environment:
      - REDIS_HOSTS=local:redis:6379
    ports:
      - "8081:8081"
    networks:
      - bet_network
    restart: unless-stopped
    depends_on:
      - redis

volumes:
  postgres_data:
  redis_data:

networks:
  bet_network:
    driver: bridge
EOF
    print_status "Arquivo docker-compose.infrastructure.yml criado"
else
    print_status "Arquivo docker-compose.infrastructure.yml já existe"
fi

# Baixar imagens Docker
print_status "Baixando imagens Docker..."
docker_compose_cmd -f docker-compose.infrastructure.yml pull

# Iniciar serviços
print_status "Iniciando serviços..."
docker_compose_cmd -f docker-compose.infrastructure.yml up -d

# Aguardar serviços ficarem prontos
print_status "Aguardando serviços ficarem prontos..."
sleep 15

# Verificar status dos serviços
print_status "Verificando status dos serviços..."
docker_compose_cmd -f docker-compose.infrastructure.yml ps

# Obter IP da máquina
VM_IP=$(hostname -I | awk '{print $1}')

# Testar conexões
print_status "Testando conexões..."

# Testar PostgreSQL
if timeout 10 bash -c "cat < /dev/null > /dev/tcp/localhost/5432" 2>/dev/null; then
    print_status "✅ PostgreSQL está acessível"
else
    print_error "❌ PostgreSQL não está acessível"
fi

# Testar Redis
if timeout 10 bash -c "cat < /dev/null > /dev/tcp/localhost/6379" 2>/dev/null; then
    print_status "✅ Redis está acessível"
else
    print_error "❌ Redis não está acessível"
fi

# Criar script de status
cat > check_services.sh << 'EOF'
#!/bin/bash
echo "📊 Status dos Serviços Bet Analytics"
echo "=================================="

# Função para executar Docker (com sudo se necessário)
if groups $USER | grep &>/dev/null '\bdocker\b'; then
    docker-compose -f docker-compose.infrastructure.yml ps
else
    sudo docker-compose -f docker-compose.infrastructure.yml ps
fi

echo ""
echo "🌐 Acessos:"
echo "- PostgreSQL: $(hostname -I | awk '{print $1}'):5432"
echo "- Redis: $(hostname -I | awk '{print $1}'):6379"

if docker ps | grep -q pgadmin 2>/dev/null || sudo docker ps | grep -q pgadmin 2>/dev/null; then
    echo "- PgAdmin: http://$(hostname -I | awk '{print $1}'):8080"
fi
if docker ps | grep -q redis-commander 2>/dev/null || sudo docker ps | grep -q redis-commander 2>/dev/null; then
    echo "- Redis Commander: http://$(hostname -I | awk '{print $1}'):8081"
fi
EOF

chmod +x check_services.sh

# Criar script para resolver permissões Docker
cat > fix_docker_permissions.sh << 'EOF'
#!/bin/bash
echo "🔧 Corrigindo permissões Docker..."

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

echo "✅ Usuário adicionado ao grupo docker"
echo "Para aplicar as mudanças:"
echo "1. Execute: newgrp docker"
echo "2. Ou faça logout/login"
echo "3. Ou reinicie a VM"
EOF

chmod +x fix_docker_permissions.sh

# Conclusão
echo ""
echo "🎉 Configuração da VM concluída!"
echo ""
echo -e "${GREEN}📋 Resumo da Configuração:${NC}"
echo "- Docker e Docker Compose instalados"
echo "- Firewall configurado"
echo "- Serviços PostgreSQL e Redis rodando"
echo "- Projeto configurado em: $PROJECT_DIR"
echo ""
echo -e "${BLUE}🌐 Informações de Conexão:${NC}"
echo "- IP da VM: $VM_IP"
echo "- PostgreSQL: $VM_IP:5432"
echo "- Redis: $VM_IP:6379"
echo "- PgAdmin: http://$VM_IP:8080 (admin@bet.com / admin123)"
echo "- Redis Commander: http://$VM_IP:8081"
echo ""

# Verificar se precisa ajustar permissões
if ! groups $USER | grep &>/dev/null '\bdocker\b'; then
    echo -e "${YELLOW}⚠️  ATENÇÃO: Permissões Docker${NC}"
    echo "Para usar Docker sem sudo:"
    echo "1. Execute: newgrp docker"
    echo "2. Ou execute: ./fix_docker_permissions.sh"
    echo "3. Ou faça logout/login"
else
    echo -e "${GREEN}✅ Permissões Docker OK${NC}"
fi

echo ""
echo -e "${YELLOW}📝 Próximos Passos:${NC}"
echo "1. Anote o IP da VM: $VM_IP"
echo "2. Configure sua máquina Windows:"
echo "   - DATABASE_URL=postgresql://bet_user:bet_password@$VM_IP:5432/bet_db"
echo "   - REDIS_URL=redis://$VM_IP:6379"
echo "3. Para verificar status: ./check_services.sh"
echo ""
echo -e "${GREEN}✅ VM está pronta para desenvolvimento!${NC}"

# Mostrar comandos úteis
echo ""
echo -e "${BLUE}🛠️ Comandos Úteis:${NC}"
echo "- Ver logs: docker-compose -f docker-compose.infrastructure.yml logs -f"
echo "- Parar: docker-compose -f docker-compose.infrastructure.yml down"
echo "- Reiniciar: docker-compose -f docker-compose.infrastructure.yml restart"
echo "- Status: ./check_services.sh"
echo "- Corrigir permissões: ./fix_docker_permissions.sh" 