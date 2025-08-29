# Ferramenta VSW-Tools - Ensaios de Metrologia e CiberSegurança.
  > Um canivete suíço para automação de tarefas do laboratório de Verificação de Software do LABELO.

`VSW-Tools` é um script de shell projetado para agilizar o fluxo de trabalho, centralizando funções essenciais como cálculo de hashes, verificação de integridade de arquivos (CRC/Checksum) e comunicação direta com dispositivos via portas seriais ou TCP/IP.

## Visão Geral
No Laboratório, frequentemente precisamos realizar tarefas repetitivas tanto para o Metrologia legal quanto para ensaios de CiberSegurança.

### Metrologia Legal:
-   Verificar a integridade de um binário ou diretório.
-   Calcular um CRC para garantir que a transmissão de dados foi bem-sucedida.
-   Enviar comandos de baixo nível para um dispositivo para verificar uma funcionalidade específica.
### Roteadores e TV-Box
-   Listar pacotes disponíveis em uma TV-BOX.
-   Iniciar script nmap nos padrões do laboratório.

Esta ferramenta foi criada para substituir a necessidade de abrir múltiplos softwares (como calculadoras crc, Hércules, etc.), oferecendo uma interface de linha de comando unificada, rápida e scriptável. O script pode inclusive ser remodelado diversas vezes para cada caso em especifico, visando ser uma ferramenta de uso ao longo dos anos.

## Funcionalidades
-   **Cálculo de Hashes:** Calcula rapidamente os hashes criptográficos mais comuns (MD5, SHA1, SHA256, SHA512) para qualquer arquivo.
-   **Verificação de Integridade:** Calcula o Checksum padrão POSIX e o CRC32, ideais para verificação de erros.
-   **Comunicação com Dispositivos:** Envia sequências de bytes (em formato hexadecimal) para dispositivos de hardware através de:
    -   **Portas Seriais** (`/dev/ttyUSB0`, `/dev/ttyS0`, etc.).
    -   **Conexões TCP/IP**.
  
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

## Comandos
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
