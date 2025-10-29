# VSW-Tools - Ensaios de Metrologia e Segurança Cibernética
> Um canivete suíço para automação de tarefas do laboratório de Verificação de Software do LABELO.

`vsw_tools` é um script de shell projetado para agilizar o fluxo de trabalho no laboratório, centralizando funções essenciais como cálculo de hashes, verificação de integridade de arquivos e configuração rápida de rede.

## Visão Geral
No Laboratório, frequentemente precisamos realizar tarefas repetitivas tanto para a Metrologia Legal quanto para ensaios de Segurança Cibernética, como:
- Verificar a integridade de um binário ou diretório.
- Calcular um CRC para garantir que a transmissão de dados foi bem-sucedida.
- Configurar rapidamente uma interface de rede para um teste específico.

Esta ferramenta foi criada para substituir a necessidade de abrir múltiplos softwares ou executar comandos longos, oferecendo uma interface de linha de comando unificada, rápida e scriptável.

## Funcionalidades
Baseado no código-fonte, a ferramenta atualmente suporta:

- **Cálculo de Hashes:** Calcula rapidamente os hashes criptográficos MD5, SHA1, SHA256 e SHA512 para qualquer arquivo.
- **Verificação de Integridade:** Calcula o Checksum padrão POSIX (`cksum`) e o CRC32.
- **Configuração de Rede:** Permite configurar rapidamente um endereço IP estático e máscara (formato CIDR) para uma interface de rede específica.

## Dependências
Para que o `vsw_tools` funcione completamente, os seguintes pacotes são necessários:

- `coreutils`: Fornece `md5sum`, `sha1sum`, `sha256sum`, `sha512sum`, `cksum`, `awk`, `grep`, etc.
- `iproute2`: Fornece o comando `ip` (usado pela função `configurar_ip`).
- `sudo`: Necessário para executar o comando `ip` com privilégios de administrador.
- `libarchive-utils`: Fornece o comando `crc32`. O script informará se ele estiver faltando.

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
````

-----

### 1\. Exibir Ajuda (`ajuda`)

Exibe a mensagem de ajuda com todos os comandos disponíveis.

**Comando:**

```bash
vsw_tools ajuda
# Ou qualquer comando inválido, -h, --help
```

### 2\. Calcular Hashes (`hash`)

Calcula e exibe os hashes MD5, SHA1, SHA256 e SHA512 de um arquivo.

**Uso:**

```bash
vsw_tools hash <caminho_do_arquivo>
```

**Exemplo:**

```bash
$ vsw_tools hash firmware.bin
Hashes para: firmware.bin
----------------------------------------
MD5    : d41d8cd98f00b204e9800998ecf8427e
SHA1   : da39a3ee5e6b4b0d3255bfef95601890afd80709
SHA256 : e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
SHA512 : cf83e135...
----------------------------------------
```

### 3\. Verificar Checksum/CRC (`check`)

Calcula e exibe o Checksum (POSIX) e o CRC32 de um arquivo.

**Uso:**

```bash
vsw_tools check <caminho_do_arquivo>
```

**Exemplo:**

```bash
$ vsw_tools check firmware.bin
Checksum/CRC para: firmware.bin
----------------------------------------
Checksum (POSIX): 4294967295
CRC32          : 00000000
----------------------------------------
```

### 4\. Configurar IP (`ip`)

Inicia um assistente interativo para configurar um IP estático em uma interface de rede[cite: 1]. [cite\_start]O script listará as interfaces disponíveis, solicitará a interface e o IP/CIDR, e aplicará a configuração usando `sudo`.

**Uso:**

```bash
vsw_tools ip
```

**Exemplo:**

```bash
$ vsw_tools ip
Interfaces disponíveis:
lo
eth0
wlan0
Interface: eth0
IP/CIDR (ex: 192.168.1.10/24): 192.168.15.10/24
Aplicando: ip addr add 192.168.15.10/24 dev eth0
[sudo] senha para usuario:
IP configurado com sucesso!
Configuração atual:
    inet 192.168.15.10/24 brd 192.168.15.255 scope global eth0
    inet6 fe80::...
```
