# Ferramenta de Linha de Comando VSW-Tools

> Um canivete suíço para automação de tarefas comuns em desenvolvimento e testes de sistemas embarcados e de medição.

`VSW-Tools` é um script de shell projetado para agilizar o fluxo de trabalho de engenheiros e desenvolvedores, centralizando funções essenciais como cálculo de hashes, verificação de integridade de arquivos (CRC/Checksum) e comunicação direta com dispositivos via portas seriais ou TCP.


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
    sudo apt-get install libarchive-tools
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
