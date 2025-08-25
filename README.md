# Ferramenta de Linha de Comando VSW-Tools

> Um canivete suíço para automação de tarefas comuns em desenvolvimento e testes de sistemas embarcados e de medição.

`VSW-Tools` é um script de shell projetado para agilizar o fluxo de trabalho de engenheiros e desenvolvedores, centralizando funções essenciais como cálculo de hashes, verificação de integridade de arquivos (CRC/Checksum) e comunicação direta com dispositivos via portas seriais ou TCP.

---

## Tabela de Conteúdos

1.  [Visão Geral](#visão-geral)
2.  [Funcionalidades](#funcionalidades)
3.  [Pré-requisitos](#pré-requisitos)
4.  [Instalação](#instalação)
5.  [Guia de Uso e Comandos](#guia-de-uso-e-comandos)
    -   [Exibir Ajuda (`ajuda`)](#1-exibir-ajuda-ajuda)
    -   [Calcular Hashes (`hash`)](#2-calcular-hashes-hash)
    -   [Calcular Checksum e CRC (`check`)](#3-calcular-checksum-e-crc-check)
    -   [Enviar Comandos Hexadecimais (`sendhex`)](#4-enviar-comandos-hexadecimais-sendhex)
        -   [Modo Serial](#modo-serial-sendhex-serial)
        -   [Modo TCP](#modo-tcp-sendhex-tcp)

---

## Visão Geral

No desenvolvimento e teste de firmware, frequentemente precisamos realizar tarefas repetitivas:
-   Verificar a integridade de um binário após a compilação.
-   Calcular um CRC para garantir que a transmissão de dados foi bem-sucedida.
-   Enviar comandos de baixo nível para um dispositivo para verificar uma funcionalidade específica.

Esta ferramenta foi criada para substituir a necessidade de abrir múltiplos softwares (como calculadoras de hash, Hércules, etc.), oferecendo uma interface de linha de comando unificada, rápida e scriptável.

## Funcionalidades

-   **Cálculo de Hashes:** Calcula rapidamente os hashes criptográficos mais comuns (MD5, SHA1, SHA256, SHA512) para qualquer arquivo.
-   **Verificação de Integridade:** Calcula o Checksum padrão POSIX e o CRC32, ideais para verificação de erros.
-   **Comunicação com Dispositivos:** Envia sequências de bytes (em formato hexadecimal) para dispositivos de hardware através de:
    -   **Portas Seriais** (`/dev/ttyUSB0`, `/dev/ttyS0`, etc.).
    -   **Conexões TCP/IP**.

## Pré-requisitos

Para que todas as funcionalidades operem corretamente, alguns pacotes precisam estar instalados no seu sistema (Debian/Ubuntu/Pop!_OS):

1.  **Netcat (`nc`):** Essencial para a função `sendhex tcp`.
    ```bash
    sudo apt-get update && sudo apt-get install netcat
    ```
2.  **Libarchive Utils (`crc32`):** Necessário para a função `check` calcular o CRC32.
    ```bash
    sudo apt-get install libarchive-utils
    ```

## Instalação

Para tornar o script `vsw_tools` acessível de qualquer lugar no seu terminal, siga estes passos:

1.  **Torne o script executável:**
    ```bash
    chmod +x vsw_tools
    ```

2.  **Mova o script para um diretório no seu PATH (recomendado):**
    Isso permite que você chame a ferramenta apenas pelo nome (`vsw_tools`) em vez do caminho completo (`./vsw_tools`). O diretório `/usr/local/bin` é o local padrão para isso.
    ```bash
    sudo mv vsw_tools /usr/local/bin/
    ```

## Guia de Uso e Comandos

A sintaxe geral para usar a ferramenta é:

```bash
vsw_tools <comando> [argumentos...]
```

---

### 1. Exibir Ajuda (`ajuda`)

Exibe uma mensagem com todos os comandos disponíveis e exemplos de uso.

**Comando:**
```bash
vsw_tools ajuda
# Ou
vsw_tools
```

### 2. Calcular Hashes (`hash`)

Esta função é utilizada para gerar assinaturas digitais (hashes) de um arquivo. É ideal para verificar se um arquivo de firmware, um bootloader ou qualquer outro binário não foi corrompido durante uma transferência ou compilação.

**Sintaxe:**
```bash
vsw_tools hash <caminho_do_arquivo>
```

**Exemplo:**
```bash
vsw_tools hash meu_firmware_v1.2.bin
```

**Saída Exemplo:**
```
Calculando hashes para o arquivo: meu_firmware_v1.2.bin
-------------------------------------------------
MD5     : e4d909c290d0fb1ca068ffaddf22cbd0
SHA1    : 2ef7bde608ce5404e97d5f042f95f89f1c232871
SHA256  : f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2
SHA512  : ...
-------------------------------------------------
```

### 3. Calcular Checksum e CRC (`check`)

Calcula somas de verificação para detecção de erros. Diferente dos hashes criptográficos, o foco aqui não é segurança, mas sim a detecção de alterações acidentais nos dados.

**Sintaxe:**
```bash
vsw_tools check <caminho_do_arquivo>
```
**Exemplo:**
```bash
vsw_tools check arquivo_de_config.dat
```
**Saída Exemplo:**
```
Calculando Checksum e CRC para o arquivo: arquivo_de_config.dat
-------------------------------------------------
Checksum (POSIX): 3485334332
CRC32           : a1b2c3d4
-------------------------------------------------
```

### 4. Enviar Comandos Hexadecimais (`sendhex`)

Simula o comportamento de softwares como o Hércules, permitindo o envio de sequências de bytes arbitrárias para um dispositivo. A string hexadecimal de entrada **não deve conter espaços ou prefixos como "0x"**.

#### Modo Serial (`sendhex serial`)

Comunica-se com dispositivos conectados a uma porta serial.

**Sintaxe:**
```bash
vsw_tools sendhex serial <dispositivo> <baudrate> <string_hex>
```
-   **`<dispositivo>`:** O caminho para a porta serial (ex: `/dev/ttyUSB0`).
-   **`<baudrate>`:** A velocidade de comunicação (ex: `9600`, `115200`).
-   **`<string_hex>`:** A sequência de bytes a ser enviada (ex: `AABB1001`).

**Importante:** Seu usuário pode precisar de permissão para acessar a porta serial. Adicione seu usuário ao grupo `dialout` para obter permissão permanente:
`sudo usermod -aG dialout $USER` (requer um novo login para ter efeito).

**Exemplo:**
```bash
# Envia o comando 0x02 0x1A 0x05 0x03 para um dispositivo em /dev/ttyUSB0 a 115200 baud
vsw_tools sendhex serial /dev/ttyUSB0 115200 "021A0503"
```
Após o envio, a ferramenta escuta a porta por 5 segundos e exibe qualquer resposta recebida em formato `hexdump`.

#### Modo TCP (`sendhex tcp`)

Comunica-se com dispositivos conectados a uma rede TCP/IP.

**Sintaxe:**
```bash
vsw_tools sendhex tcp <host> <porta> <string_hex>
```
-   **`<host>`:** O endereço IP ou hostname do dispositivo.
-   **`<porta>`:** A porta TCP na qual o dispositivo está escutando.
-   **`<string_hex>`:** A sequência de bytes a ser enviada.

**Exemplo:**
```bash
# Envia o comando 0xDE 0xAD 0xBE 0xEF para o IP 192.168.0.55 na porta 9760
vsw_tools sendhex tcp 192.168.0.55 9760 "DEADBEEF"
```
Após o envio, o script exibe a resposta do servidor (se houver) e fecha a conexão.

---
