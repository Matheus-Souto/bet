#!/bin/bash

# Script para configurar automaticamente a VM com os serviços necessários
# Execute este script na VM Linux

set -e

echo "🚀 Configurando VM para Bet Analytics..."

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

# Atualizar sistema
print_status "Atualizando sistema..."
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    sudo apt update && sudo apt upgrade -y
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    sudo yum update -y
fi

# Instalar Docker se não estiver instalado
if ! command -v docker &> /dev/null; then
    print_status "Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
else
    print_status "Docker já está instalado"
fi

# Instalar Docker Compose se não estiver instalado
if ! command -v docker-compose &> /dev/null; then
    print_status "Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    print_status "Docker Compose já está instalado"
fi

# Instalar Git se não estiver instalado
if ! command -v git &> /dev/null; then
    print_status "Instalando Git..."
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        sudo apt install -y git
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        sudo yum install -y git
    fi
else
    print_status "Git já está instalado"
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
    
    # Se o repositório estiver disponível, clone
    read -p "URL do repositório Git (ou Enter para pular): " REPO_URL
    if [[ ! -z "$REPO_URL" ]]; then
        git clone $REPO_URL .
    fi
else
    print_status "Diretório do projeto já existe: $PROJECT_DIR"
    cd $PROJECT_DIR
fi

# Verificar se existe docker-compose.infrastructure.yml
if [ ! -f "docker-compose.infrastructure.yml" ]; then
    print_warning "Arquivo docker-compose.infrastructure.yml não encontrado"
    print_status "Criando arquivo de configuração básico..."
    
    cat > docker-compose.infrastructure.yml << 'EOF'
version: '3.8'

services:
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
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: bet_redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
EOF
fi

# Baixar imagens Docker
print_status "Baixando imagens Docker..."
docker-compose -f docker-compose.infrastructure.yml pull

# Iniciar serviços
print_status "Iniciando serviços..."
docker-compose -f docker-compose.infrastructure.yml up -d

# Aguardar serviços ficarem prontos
print_status "Aguardando serviços ficarem prontos..."
sleep 10

# Verificar status dos serviços
print_status "Verificando status dos serviços..."
docker-compose -f docker-compose.infrastructure.yml ps

# Obter IP da máquina
VM_IP=$(hostname -I | awk '{print $1}')

# Testar conexões
print_status "Testando conexões..."

# Testar PostgreSQL
if timeout 5 bash -c "cat < /dev/null > /dev/tcp/localhost/5432"; then
    print_status "✅ PostgreSQL está acessível"
else
    print_error "❌ PostgreSQL não está acessível"
fi

# Testar Redis
if timeout 5 bash -c "cat < /dev/null > /dev/tcp/localhost/6379"; then
    print_status "✅ Redis está acessível"
else
    print_error "❌ Redis não está acessível"
fi

# Criar script de status
cat > check_services.sh << 'EOF'
#!/bin/bash
echo "📊 Status dos Serviços Bet Analytics"
echo "=================================="
docker-compose -f docker-compose.infrastructure.yml ps
echo ""
echo "🌐 Acessos:"
echo "- PostgreSQL: $(hostname -I | awk '{print $1}'):5432"
echo "- Redis: $(hostname -I | awk '{print $1}'):6379"
if docker ps | grep -q pgadmin; then
    echo "- PgAdmin: http://$(hostname -I | awk '{print $1}'):8080"
fi
if docker ps | grep -q redis-commander; then
    echo "- Redis Commander: http://$(hostname -I | awk '{print $1}'):8081"
fi
EOF

chmod +x check_services.sh

# Conclusão
echo ""
echo "🎉 Configuração da VM concluída com sucesso!"
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
if docker ps | grep -q pgadmin; then
    echo "- PgAdmin: http://$VM_IP:8080 (admin@bet.com / admin123)"
fi
if docker ps | grep -q redis-commander; then
    echo "- Redis Commander: http://$VM_IP:8081"
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