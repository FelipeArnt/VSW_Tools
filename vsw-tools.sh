#!/bin/bash
# vsw_tools - Canivete suíço para desenvolvimento embarcado

# Cores para output
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
C='\033[0;36m'
NC='\033[0m'

# Lista de dependências por comando
declare -A DEPENDENCIAS=(
  ["hash"]="md5sum sha1sum sha256sum sha512sum"
  ["check"]="cksum crc32"
  ["ip"]="ip sudo"
)

# Função que exibe mensagens fatais e sai do script
die() {
  echo -e "${R}Erro: $1${NC}" >&2
  exit 1
}

# Função para verificar dependências específicas de cada comando
verificar_dependencias() {
  local comando="$1"
  local faltando=()

  if [ -n "${DEPENDENCIAS[$comando]}" ]; then
    for cmd in ${DEPENDENCIAS[$comando]}; do
      if ! command -v "$cmd" &>/dev/null; then
        faltando+=("$cmd")
      fi
    done
  fi

  if [ ${#faltando[@]} -gt 0 ]; then
    die "Comandos necessários não encontrados: ${faltando[*]}\nInstale os pacotes apropriados e tente novamente."
  fi
}

# Função para verificar todas as dependências do script
verificar_todas_dependencias() {
  echo -e "${Y}Verificando todas as dependências...${NC}"
  local todas_faltando=()

  for comando in "${!DEPENDENCIAS[@]}"; do
    for cmd in ${DEPENDENCIAS[$comando]}; do
      if ! command -v "$cmd" &>/dev/null; then
        todas_faltando+=("$cmd")
      fi
    done
  done

  if [ ${#todas_faltando[@]} -gt 0 ]; then
    # Remove duplicatas
    local faltando_unicas=($(printf "%s\n" "${todas_faltando[@]}" | sort -u))
    echo -e "${R}Dependências faltando:${NC}"
    printf "  - %s\n" "${faltando_unicas[@]}"
    echo -e "${Y}Instale os comandos faltantes antes de continuar.${NC}"
    return 1
  else
    echo -e "${G}Todas as dependências estão instaladas!${NC}"
    return 0
  fi
}

# Funções principais
ajuda() {
  printf "%b\n" "${C}Ferramenta para Metrologia Legal e Segurança Cibernética.${NC}\nUso: ${0} <comando> [args]"
  printf "\n${Y}Comandos:${NC}\n"
  printf "  ${G}hash <arquivo>${NC}    Calcula MD5, SHA1, SHA256, SHA512\n"
  printf "  ${G}check <arquivo>${NC}   Calcula CRC32 e Checksum\n"
  printf "  ${G}ip${NC}                Configura IP estático da interface\n"
  printf "  ${G}verificar${NC}         Verifica todas as dependências do script\n"
  printf "  ${G}ajuda${NC}             Mostra esta ajuda\n"
  exit 0
}

calcular_hashes() {
  [ -z "$1" ] && {
    printf "%b\n" "${R}Erro: Arquivo não especificado${NC}"
    ajuda
  }
  [ -f "$1" ] || {
    printf "%b\n" "${R}Erro: Arquivo '$1' não encontrado${NC}"
    exit 1
  }

  printf "%b\n" "${C}Hashes para:${NC} $1\n${Y}----------------------------------------${NC}"

  local algoritmos=("md5" "sha1" "sha256" "sha512")
  for algo in "${algoritmos[@]}"; do
    printf "%-7s: ${G}" "${algo^^}"
    case $algo in
    md5 | sha1 | sha256 | sha512)
      ${algo}sum "$1" 2>/dev/null | awk '{print $1}' || echo "N/A"
      ;;
    esac
    printf "${NC}"
  done
  printf "${Y}----------------------------------------${NC}\n"
}

calcular_checksum() {
  [ -z "$1" ] && {
    printf "%b\n" "${R}Erro: Arquivo não especificado${NC}"
    ajuda
  }
  [ -f "$1" ] || {
    printf "%b\n" "${R}Erro: Arquivo '$1' não encontrado${NC}"
    exit 1
  }

  printf "%b\n" "${C}Checksum/CRC para:${NC} $1\n${Y}----------------------------------------${NC}"

  # Checksum POSIX
  if command -v cksum &>/dev/null; then
    printf "Checksum (POSIX): ${G}$(cksum "$1" | awk '{print $1}')${NC}\n"
  else
    printf "${Y}cksum: não disponível${NC}\n"
  fi

  # CRC32
  if command -v crc32 &>/dev/null; then
    printf "CRC32          : ${G}$(crc32 "$1")${NC}\n"
  else
    printf "${Y}CRC32: instale libarchive-utils ou similar${NC}\n"
  fi
  printf "${Y}----------------------------------------${NC}\n"
}

configurar_ip() {
  # Mostrar interfaces disponíveis
  printf "${Y}Interfaces disponíveis:${NC}\n"
  ip link show | grep -E '^[0-9]+:' | awk -F: '{print $2}' | tr -d ' '

  # Coletar dados
  read -p "Interface: " interface
  ip link show "$interface" &>/dev/null || {
    printf "%b\n" "${R}Interface '$interface' não existe${NC}"
    return 1
  }

  read -p "IP/CIDR (ex: 192.168.1.10/24): " ip_cidr
  [[ $ip_cidr =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]{1,2}$ ]] || {
    printf "%b\n" "${R}Formato IP/CIDR inválido${NC}"
    return 1
  }

  # Aplicar configuração
  printf "${Y}Aplicando:${NC} ip addr add $ip_cidr dev $interface\n"
  sudo ip addr add "$ip_cidr" dev "$interface" 2>/dev/null &&
    printf "${G}IP configurado com sucesso!${NC}\n" ||
    printf "${R}Erro ao configurar IP${NC}\n"

  # Mostrar configuração atual
  printf "${Y}Configuração atual:${NC}\n"
  ip addr show "$interface" | grep inet
}

# Processamento de comandos
case "${1,,}" in
verificar)
  verificar_todas_dependencias
  ;;
hash)
  verificar_dependencias "hash"
  calcular_hashes "$2"
  ;;
check)
  verificar_dependencias "check"
  calcular_checksum "$2"
  ;;
ip)
  verificar_dependencias "ip"
  configurar_ip
  ;;
ajuda | -h | --help)
  ajuda
  ;;
*)
  echo -e "${R}Comando não reconhecido: $1${NC}"
  ajuda
  ;;
esac
