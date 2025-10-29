#!/bin/bash
# vsw_tools - Canivete suíço para desenvolvimento embarcado

# Cores para output
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
C='\033[0;36m'
NC='\033[0m'

# Funções principais - [ajuda(), calcular_hashes(), calcular_checksum(), configurar_ip]
ajuda() {
  printf "%b\n" "${C}Ferramenta para desenvolvimento embarcado${NC}\nUso: ${0} <comando> [args]"
  printf "\n${Y}Comandos:${NC}\n"
  printf "  ${G}hash <arquivo>${NC}    Calcula MD5, SHA1, SHA256, SHA512\n"
  printf "  ${G}check <arquivo>${NC}   Calcula CRC32 e Checksum\n"
  printf "  ${G}ip${NC}                Configura IP estático da interface\n"
  printf "  ${G}ajuda${NC}             Mostra esta ajuda\n"
  exit 1
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
  for algo in md5 sha1 sha256 sha512; do
    printf "%-7s: ${G}" "${algo^^}"
    ${algo}sum "$1" 2>/dev/null | awk '{print $1}' || echo "N/A"
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
  printf "Checksum (POSIX): ${G}$(cksum "$1" | awk '{print $1}')${NC}\n"
  command -v crc32 &>/dev/null && printf "CRC32          : ${G}$(crc32 "$1")${NC}\n" ||
    printf "${Y}CRC32: instale libarchive-utils${NC}\n"
  printf "${Y}----------------------------------------${NC}\n"
}

configurar_ip() {
  # Mostrar interfaces de rede disponíveis...
  printf "${Y}Interfaces disponíveis:${NC}\n"
  ip link show | grep -E '^[0-9]+:' | awk -F: '{print $2}' | tr -d ' '

  # Coletar entrada do usuário...
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
hash) calcular_hashes "$2" ;;
check) calcular_checksum "$2" ;;
ip) configurar_ip ;;
ajuda | -h | --help | *) ajuda ;;
esac
