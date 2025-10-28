#!/bin/bash

# vsw_tools - Um canivete suíço para tarefas de desenvolvimento embarcado.

# --- CORES PARA O OUTPUT ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_CYAN='\033[0;36m'
C_NC='\033[0m' # Sem Cor

# --- FUNÇÃO DE AJUDA/USAGE ---
ajuda() {
    # MUDANÇA: Trocado 'echo -e' por 'printf' para garantir a interpretação das cores.
    # O '%b' diz ao printf para processar os códigos de escape (como \033), e o '\n' adiciona a quebra de linha.
    printf "%b\n" "${C_CYAN}Ferramenta de Linha de Comando para ensaios funcionais${C_NC}"
    printf "Uso: vsw_tools <comando> [opções]\n" "$0"
    echo ""
    printf "%b\n" "${C_YELLOW}Comandos disponíveis:${C_NC}"
    printf "  %b\n" "${C_GREEN}hash <arquivo>${C_NC}          Calcula os hashes mais comuns de um arquivo."
    printf "  %b\n" "${C_GREEN}check <arquivo>${C_NC}          Calcula CRC32 e Checksum de um arquivo."
    echo ""
    printf "  %b\n" "${C_GREEN}ajuda${C_NC}                     Mostra esta mensagem de ajuda."
    echo ""
    exit 1
}

# --- FUNÇÃO PARA CALCULAR HASHES ---
calcular_hashes() {
    local ARQUIVO="$1"
    if [ -z "$ARQUIVO" ]; then
        printf "%b\n" "${C_RED}Erro: Nenhum arquivo especificado.${C_NC}"
        ajuda
    fi
    if [ ! -f "$ARQUIVO" ]; then
        printf "%b\n" "${C_RED}Erro: Arquivo '${ARQUIVO}' não encontrado.${C_NC}"
        exit 1
    fi

    printf "%b\n" "${C_CYAN}Calculando hashes para o arquivo:${C_NC} ${ARQUIVO}"
    printf "%b\n" "${C_YELLOW}-------------------------------------------------${C_NC}"
    printf "MD5     : %b\n" "${C_GREEN}$(md5sum "$ARQUIVO" | awk '{print $1}')${C_NC}"
    printf "SHA1    : %b\n" "${C_GREEN}$(sha1sum "$ARQUIVO" | awk '{print $1}')${C_NC}"
    printf "SHA256  : %b\n" "${C_GREEN}$(sha256sum "$ARQUIVO" | awk '{print $1}')${C_NC}"
    printf "SHA512  : %b\n" "${C_GREEN}$(sha512sum "$ARQUIVO" | awk '{print $1}')${C_NC}"
    printf "%b\n" "${C_YELLOW}-------------------------------------------------${C_NC}"
}

# --- FUNÇÃO PARA CALCULAR CHECKSUM E CRC ---
calcular_checksum() {
    local ARQUIVO="$1"
    if [ -z "$ARQUIVO" ]; then
        printf "%b\n" "${C_RED}Erro: Nenhum arquivo especificado.${C_NC}"
        ajuda
    fi
    if [ ! -f "$ARQUIVO" ]; then
        printf "%b\n" "${C_RED}Erro: Arquivo '${ARQUIVO}' não encontrado.${C_NC}"
        exit 1
    fi

    printf "%b\n" "${C_CYAN}Calculando Checksum e CRC para o arquivo:${C_NC} ${ARQUIVO}"
    printf "%b\n" "${C_YELLOW}-------------------------------------------------${C_NC}"
    printf "Checksum (POSIX): %b\n" "${C_GREEN}$(cksum "$ARQUIVO" | awk '{print $1}')${C_NC}"
    
    if command -v crc32 &> /dev/null; then
        printf "CRC32           : %b\n" "${C_GREEN}$(crc32 "$ARQUIVO")${C_NC}"
    else
        printf "%b\n" "${C_YELLOW}Aviso: Para calcular CRC32, instale o pacote 'libarchive-utils'.${C_NC}"
        printf "%b\n" "${C_YELLOW}(sudo apt-get install libarchive-utils ou sudo dnf install libarchive-utils)${C_NC}"
    fi
    printf "%b\n" "${C_YELLOW}-------------------------------------------------${C_NC}"
}

# --- SCRIPT PRINCIPAL (MENU DE COMANDOS) ---
COMANDO="$1"
# Se nenhum comando for dado, mostra a ajuda
if [ -z "$COMANDO" ]; then
    ajuda
fi
shift

case "$COMANDO" in
    hash)
        calcular_hashes "$1"
        ;;
    check)
        calcular_checksum "$1"
        ;;
    sendhex)
        enviar_hex "$@"
        ;;
    ajuda|-h|--help)
        ajuda
        ;;
    *)
        printf "%b\n" "${C_RED}Erro: Comando '${COMANDO}' desconhecido.${C_NC}"
        ajuda
        ;;
esac
