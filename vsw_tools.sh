#!/bin/bash

# vsw_tools - Um canivete suíço para ensaios funcionais de Metrologia Legal.

# --- CORES PARA O OUTPUT ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_CYAN='\033[0;36m'
C_NC='\033[0m' # Sem Cor

# --- FUNÇÃO DE AJUDA/USO ---
ajuda() {
    # MUDANÇA: Trocado 'echo -e' por 'printf' para garantir a interpretação das cores.
    # O '%b' diz ao printf para processar os códigos de escape (como \033), e o '\n' adiciona a quebra de linha.
    printf "%b\n" "${C_CYAN}Ferramenta de Linha de Comando para ensaios funcionais${C_NC}"
    printf "Uso: %s <comando> [opções]\n" "$0"
    echo ""
    printf "%b\n" "${C_YELLOW}Comandos disponíveis:${C_NC}"
    printf "  %b\n" "${C_GREEN}hash <arquivo>${C_NC}          Calcula os hashes mais comuns de um arquivo."
    printf "  %b\n" "${C_GREEN}check <arquivo>${C_NC}          Calcula CRC32 e Checksum de um arquivo."
    printf "  %b\n" "${C_GREEN}sendhex <tipo> [opções]${C_NC}   Envia uma string hexadecimal para um medidor."
    echo ""
    printf "%b\n" "${C_YELLOW}Detalhes do 'sendhex':${C_NC}"
    printf "  Uso: %s sendhex %b\n" "$0" "${C_BLUE}serial <dispositivo> <baudrate> <hex_string>${C_NC}"
    printf "    Ex: %s sendhex serial /dev/ttyUSB0 9600 'AABB1001'\n" "$0"
    echo ""
    printf "  Uso: %s sendhex %b\n" "$0" "${C_BLUE}tcp <host> <porta> <hex_string>${C_NC}"
    printf "    Ex: %s sendhex tcp 192.168.1.100 9760 'DEADBEEF'\n" "$0"
    echo ""
    printf "  %b\n" "${C_GREEN}ajuda${C_NC}                     Mostra esta mensagem de ajuda."
    echo ""
    exit 1
}

# --- FUNÇÃO PARA CALCULAR HASHES ---
listar_aplicativos(){

local saida="$1"
if [-z "$saida"]; then
printf "%b\n" "${C_RED}Erro: Nenhum arquivo de saida foi especificado.${C_NC}"
        ajuda
fi

    printf "%b\n" "${C_CYAN}Listando os programas da TV-BOX:${C_NC} ${ARQUIVO}"
    printf "%b\n" "${C_YELLOW}-------------------------------------------------${C_NC}"
    echo '[INFO] Instalando ferramentas necessárias'
    echo '[INFO] Iniciando script TV-BOX'
    adb shell pm list packages -s -e -f > aplicativos.md
    printf "[RESULTS] Aplicatitvos encontrados: %b\n" "${C_GREEN}$(adb shell pm list packages -s -e -f "$saida" | awk '{print $1}')${C_NC}"
    printf "%b\n" "${C_YELLOW}-------------------------------------------------${C_NC}"


}

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

# --- FUNÇÃO PARA ENVIAR COMANDOS HEXADECIMAIS ---
enviar_hex() {
    local TIPO="$1"
    
    local HEX_STRING_RAW
    local HEX_STRING_FORMATADA

    formatar_hex() {
        HEX_STRING_RAW=$(echo "$1" | tr -d '[:space:]')
        if ! [[ $HEX_STRING_RAW =~ ^[0-9a-fA-F]+$ ]]; then
            printf "%b\n" "${C_RED}Erro: A string hexadecimal contém caracteres inválidos.${C_NC}"
            exit 1
        fi
        HEX_STRING_FORMATADA=$(echo "$HEX_STRING_RAW" | sed 's/\([0-9a-fA-F]\{2\}\)/\\x\1/g')
    }

    case "$TIPO" in
        serial)
            local DISPOSITIVO="$2"
            local BAUDRATE="$3"
            local HEX_INPUT="$4"

            if [ -z "$DISPOSITIVO" ] || [ -z "$BAUDRATE" ] || [ -z "$HEX_INPUT" ]; then
                printf "%b\n" "${C_RED}Erro: Argumentos insuficientes para 'sendhex serial'.${C_NC}"
                ajuda
            fi

            printf "%b\n" "${C_CYAN}Configurando porta serial ${DISPOSITIVO} para ${BAUDRATE} baud...${C_NC}"
            stty -F "$DISPOSITIVO" raw "$BAUDRATE" -echo || { printf "%b\n" "${C_RED}Erro ao configurar a porta serial. Verifique as permissões.${C_NC}"; exit 1; }

            formatar_hex "$HEX_INPUT"

            printf "%b\n" "${C_CYAN}Enviando bytes: ${C_GREEN}${HEX_STRING_RAW}${C_NC}"
            printf "$HEX_STRING_FORMATADA" > "$DISPOSITIVO"

            printf "%b\n" "${C_YELLOW}Comando enviado. Escutando por resposta por 5 segundos... (Ctrl+C para parar)${C_NC}"
            timeout 5s cat "$DISPOSITIVO" | hexdump -C || printf "\n%b\n" "${C_GREEN}Leitura finalizada.${C_NC}"
            ;;

        tcp)
            local HOST="$2"
            local PORTA="$3"
            local HEX_INPUT="$4"

            if [ -z "$HOST" ] || [ -z "$PORTA" ] || [ -z "$HEX_INPUT" ]; then
                printf "%b\n" "${C_RED}Erro: Argumentos insuficientes para 'sendhex tcp'.${C_NC}"
                ajuda
            fi

            if ! command -v nc &> /dev/null; then
                printf "%b\n" "${C_RED}Erro: O comando 'nc' (netcat) não foi encontrado. Por favor, instale-o.${C_NC}"
                exit 1
            fi

            formatar_hex "$HEX_INPUT"
            
            printf "%b\n" "${C_CYAN}Enviando bytes para ${HOST}:${PORTA}...${C_NC}"
            printf "Bytes: %b\n" "${C_GREEN}${HEX_STRING_RAW}${C_NC}"
            
            printf "$HEX_STRING_FORMATADA" | nc -w 5 "$HOST" "$PORTA" | hexdump -C
            printf "%b\n" "${C_GREEN}Comando enviado e conexão fechada.${C_NC}"
            ;;

        *)
            printf "%b\n" "${C_RED}Erro: Tipo de envio '${TIPO}' desconhecido para 'sendhex'. Use 'serial' ou 'tcp'.${C_NC}"
            ajuda
            ;;
    esac
}


# --- SCRIPT PRINCIPAL ---
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
     tvbox)
         listar_aplicativos "$@"
        ;;
    ajuda|-h|--help)
        ajuda
        ;;
    *)
        printf "%b\n" "${C_RED}Erro: Comando '${COMANDO}' desconhecido.${C_NC}"
        ajuda
        ;;
esac
