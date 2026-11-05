# OpenVPN

Uma **VPN (_Virtual Private Network_)** é uma tecnologia de rede que permite criar conexões seguras e criptografadas sobre uma infraestrutura pública ou não confiável, tal como a Internet, usando o conceito de tunelamento. Então, quando somada a técnicas criptográficas a VPN tem como objetivo garantir a privacidade, a integridade dos dados e a autenticação entre redes geograficamente separadas.

O **conceito de tunelamento** em uma VPN baseia-se no processo de encapsulamento, no qual, por exemplo, um pacote de dados da rede privada é envolvido e transportado dentro da estrutura de um novo pacote de rede pública. Como o cabeçalho mais externo do pacote gerado é o único utilizado pelos roteadores da Internet para efetuar o roteamento entre as pontas da VPN, o pacote interno original e seus dados privados ficam completamente isolados, podendo ser integralmente criptografados para garantir que, mesmo se capturados durante o trajeto pela rede pública, não possam ser lidos ou adulterados por terceiros (ver Figura 1).

![Tunelamento](img/tunelamento.jpg)

Neste cenário de VPN, temos o [**OpenVPN**](https://openvpn.net/), que é uma das soluções de VPN de código aberto mais consolidadas e utilizadas do mercado. Criado por James Yonan, o OpenVPN utiliza protocolos de segurança baseados no OpenSSL e opera na camada de aplicação (camada 7 do modelo OSI), utilizando um _driver_ de rede virtual (TUN/TAP) para criar as interfaces de rede tuneladas.

Vantagens do OpenVPN:

* **Flexibilidade e Compatibilidade:** Funciona em diversas plataformas (Linux, Windows, macOS, Android, iOS).
* **Segurança Robusta:** Suporta algoritmos modernos de criptografia (AES, ChaCha20-Poly1305) e negociação TLS.
* **Transposição de Firewalls:** Opera nativamente via protocolo UDP ou TCP (geralmente na porta 1194), o que facilita a passagem por rotas NAT e firewalls restritivos.
* **Flexibilidade de Autenticação:** Permite o uso de chaves pré-compartilhadas, certificados digitais X.509 ou autenticação baseada em usuário/senha.

Desvantagens do OpenVPN:

* **Overhead no Espaço de Usuário:** Por rodar em modo de usuário (*user-space*), pode ter um desempenho ligeiramente inferior a soluções integradas diretamente ao kernel do Linux (como o WireGuard), embora o recurso DCO (*Data Channel Offload*) mitigue essa limitação em versões recentes.
* **Complexidade na Gestão de PKI:** A criação e a manutenção de uma Infraestrutura de Chaves Públicas (PKI/CA) tradicional para ambientes grandes exige um gerenciamento cuidadoso do ciclo de vida dos certificados.

Então, a escolha do OpenVPN por empresas e profissionais de TI deve-se à sua posição consolidada como um padrão da indústria para conectividade segura. O software combina alta segurança, através da integração nativa com a biblioteca OpenSSL e suporte a cifras modernas (como AES-256 e ChaCha20), com uma elevada flexibilidade de implantação. Por operar tanto em modo *site-to-site* (interconectando matriz e filiais) quanto *client-to-site* (acesso remoto de funcionários), o OpenVPN adapta-se a diferentes topologias de rede sem exigir mudanças na infraestrutura física. Além disso, a sua capacidade de trafegar sobre os protocolos TCP e UDP em portas customizáveis permite a travessia transparente por _firewalls_ e ambientes com NAT restrito. Por fim, por ser uma solução *open-source*, ele oferece independência de fornecedor, custo zero de licenciamento de software e auditoria constante de código pela comunidade global de segurança da informação.


# Cenário de Rede de Exemplo

Para demonstrar a implementação do OpenVPN, utilizaremos a topologia de rede apresentada na Figura 2. O cenário simula a interconexão de duas redes locais de unidades corporativas (por exemplo, Matriz e Filial) através de dois _gateways_ Linux interconectados por uma rede pública não confiável, onde há um host atacante (*Hacker*) realizando monitoramento de pacotes (*sniffing*).

![Rede de Exemplo](img/vpn.png)

> O arquivo com o cenário de rede proposto implementado no GNS3 está disponível em: [vpn.gns3project](vpn.gns3project) - todos ips, roteamento e NAT está configurados.

Basicamente a rede de exemplo tem a seguinte configuração:

* **GW-VPN1 (`router-1`):** Gateway da LAN 1:
  * `eth0`: `192.168.122.101/24` (Interface conectada à Rede Pública);
  * `eth1`: `10.1.0.101/24` (Gateway da LAN 1);
  * `tun0`: `172.16.0.101` (Interface Virtual VPN).

* **GW-VPN2 (`router-2`):** Gateway da LAN 2:
  * `eth0`: `192.168.122.102/24` (Interface conectada à Rede Pública);
  * `eth1`: `10.2.0.102/24` (Gateway da LAN 2);
  * `tun0`: `172.16.0.102` (Interface Virtual VPN).

* **LAN 1 (`10.1.0.0/24`):**
  * `host-1`: `10.1.0.1/24` (Hospeda Servidor Web Apache2);
  * `host-2`: `10.1.0.2/24` (Hospeda Servidor FTP `vsftpd`).

* **LAN 2 (`10.2.0.0/24`):**
  * `host-3`: `10.2.0.3/24` (Cliente de testes);
  * `host-4`: `10.2.0.4/24` (Cliente de testes).

* **Rede Pública (`192.168.122.0/24`):**
  * `Hacker`: Máquina posicionada no meio da rede pública com capacidade de interceptar o tráfego que trafega entre `router-1` e `router-2`.

Nesta abordagem, a conexão VPN é estabelecida diretamente entre os dois roteadores/gateways (`router-1` e `router-2`). Os computadores das redes internas (`host-1`, `host-2`, `host-3`, `host-4`) não precisam rodar nenhum software de VPN, pois todo o tráfego destinado à rede remota é transparente e automaticamente roteado pelos gateways através da interface `tun0`.

Benefícios desta abordagem de VPN:

* **Transparência:** Nenhum software adicional precisa ser instalado nos estações de trabalho dos usuários.
* **Centralização:** Toda a política de segurança e roteamento é mantida e gerenciada exclusivamente nos gateways.

Riscos Envolvidos com essa topologia de VPN:

* **Ponto Único de Falha:** Se um dos gateways ficar fora do ar, toda a comunicação entre as unidades é interrompida.
* **Segurança do Gateway:** Se um atacante comprometer o gateway da VPN, ele ganha acesso direto a toda a sub-rede interna.


Apresentados os fundamentos de VPN e o cenário de rede de exemplo, vamos a implementação do OpenVPN sob três três abordagens/exemplos de implementação com o OpenVPN:

1. Tunelamento simples: sem criptografia ou autenticação;

2. Chave estática: criptografia simplificada com chave pré-compartilhada;

3. Certificados digitais: infraestrutura TLS segura utilizando OpenSSL.

# Exemplo 1 - Configuração de VPN sem Criptografia

Neste primeiro cenário, vamos criar um túnel VPN simples sem o uso de nenhum tipo de criptografia ou autenticação. O objetivo desta etapa é entender o funcionamento básico do protocolo de tunelamento (encapsulamento de pacotes IP sobre UDP) e observar na prática os riscos associados à transmissão de dados em texto claro pela rede pública.

Essa abordagem apresenta como principal vantagem a extrema simplicidade de configuração e o baixo consumo de processamento nos roteadores; contudo, carrega como grave desvantagem e risco a ausência total de confidencialidade e integridade, permitindo que um atacante posicionado no meio da rede consiga visualizar e alterar integralmente o tráfego que circula entre as redes internas.


## Configuração do Router-1 (Gateway VPN 1)

Neste bloco, realizaremos a configuração do endereçamento IP das interfaces, a ativação do roteamento de pacotes IPv4 no kernel, o mascaramento de saída via `iptables`, a instalação do OpenVPN e a criação do arquivo de configuração do túnel limpo.

Execute os seguintes comandos no terminal do `router-1`:

```bash
root@router-1:/# ifconfig eth0 192.168.122.101
root@router-1:/# route add default gw 192.168.122.1
root@router-1:/# echo "nameserver 8.8.8.8" > /etc/resolv.conf
root@router-1:/# ifconfig eth1 10.1.0.101/24
root@router-1:/# echo 1 > /proc/sys/net/ipv4/ip_forward
root@router-1:/# iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

root@router-1:/# apt update
root@router-1:/# apt install -y openvpn
```

> Não é objetivo deste texto explicar a configuração da rede, nem instalação de pacotes, mas de forma resumida os comandos anteriores: configuração a rede do Router-1; habilita ele como roteador; mascara os pacotes da rede que forem para a Internet e instala o OpenVPN.

Com a rede configurada e OpenVPN instalado vamos a configuração do OpenVPN, neste router, que será considerado servidor VPN, para isso iniciamos entrando dentro do diretório do OpenVPN e criando o arquivo de configuração, no exemplo chamado de `openvpn-v1.conf`, tal como:


```bash
root@router-1:/# cd /etc/openvpn/
root@router-1:/etc/openvpn# vi openvpn-v1.conf
```

O conteúdo do arquivo `openvpn-v1.conf` de configuração deve ser:

```bash
dev tun
ifconfig 172.16.0.101 172.16.0.102
route 10.2.0.0 255.255.255.0
```

Explicando o arquivo de configuração `/etc/openvpn/openvpn-v1.conf`:
* `dev tun`: Cria uma interface de túnel virtual de camada 3 (roteamento de pacotes IP).
* `ifconfig 172.16.0.101 172.16.0.102`: Define o IP local da interface VPN como `172.16.0.101` e o IP remoto (do destino) como `172.16.0.102`.
* `route 10.2.0.0 255.255.255.0`: Adiciona uma rota automática no sistema operacional direcionando todo o tráfego da rede remota `10.2.0.0/24` para dentro do túnel VPN.

> A inclusão da opção `route` nos arquivos de configuração permite que, após o estabelecimento da conexão entre os gateways VPN (Router-1 e Router-2), as rotas para o tráfego destinado às redes privadas sejam adicionadas automaticamente às tabelas de roteamento locais.

Em seguida, iniciamos o serviço OpenVPN no `router-1`:

```bash
root@router-1:/etc/openvpn# openvpn --config openvpn-v1.conf 
2026-11-05 01:50:59 DEPRECATION: No tls-client or tls-server option in configuration detected. OpenVPN 2.7 will remove the functionality to run a VPN without TLS. See the examples section in the manual page for examples of a similar quick setup with peer-fingerprint.
2026-11-05 01:50:59 OpenVPN 2.6.14 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] [DCO]
2026-11-05 01:50:59 library versions: OpenSSL 3.5.7 9 Jun 2026, LZO 2.10
2026-11-05 01:50:59 DCO version: N/A
2026-11-05 01:50:59 ******* WARNING *******: '--cipher none' was specified. This means NO encryption will be performed and tunnelled data WILL be transmitted in clear text over the network! PLEASE DO RECONSIDER THIS SETTING!
2026-11-05 01:50:59 ******* WARNING *******: '--auth none' was specified. This means no authentication will be performed on received packets, meaning you CANNOT trust that the data received by the remote side have NOT been manipulated. PLEASE DO RECONSIDER THIS SETTING!
2026-11-05 01:50:59 ******* WARNING *******: All encryption and authentication features disabled -- All data will be tunnelled as clear text and will not be protected against man-in-the-middle changes. PLEASE DO RECONSIDER THIS CONFIGURATION!
2026-11-05 01:50:59 TUN/TAP device tun0 opened
2026-11-05 01:50:59 net_iface_mtu_set: mtu 1500 for tun0
2026-11-05 01:50:59 net_iface_up: set tun0 up
2026-11-05 01:50:59 net_addr_ptp_v4_add: 172.16.0.101 peer 172.16.0.102 dev tun0
2026-11-05 01:50:59 Could not determine IPv4/IPv6 protocol. Using AF_INET
2026-11-05 01:50:59 UDPv4 link local (bound): [AF_INET][undef]:1194
2026-11-05 01:50:59 UDPv4 link remote: [AF_UNSPEC]
```

Como observado na saída do comando, o OpenVPN emite alertas (*WARNING*) informando que a conexão não possui criptografia nem autenticação ativas e que os dados trafegarão em texto claro. Ou seja, alguém/hacker pode capturar tais pacotes e ver o seu conteúdo.


## Configuração do Host-1

No `host-1`, realizaremos a configuração do endereço de rede `10.1.0.1/24` apontando a rota padrão para o `router-1`. Em seguida, instalaremos o servidor web Apache2 e criaremos uma página HTML simples contendo uma senha secreta (`123mudar`) para simular um sistema interno corporativo.

Execute no terminal do `host-1`:

```bash
root@host-1:/# ifconfig eth0 10.1.0.1/24
root@host-1:/# route add default gw 10.1.0.101
root@host-1:/# echo nameserver 8.8.8.8 > /etc/resolv.conf 

root@host-1:/# apt update
root@host-1:/# apt install -y apache2
root@host-1:/# echo "Sistema secreto - senha 123mudar" > /var/www/html/index.html 
root@host-1:/# apachectl start
```

A configuração do `host-1` foi finalizada e o servidor web está pronto e escutando requisições na porta HTTP (80).


## Configuração do Host-2

De forma análoga ao `host-1`, configuramos a rede do `host-2` no IP `10.1.0.2/24` com o gateway `10.1.0.101`. Instala-se o servidor FTP (`vsftpd`), inicia-se o serviço e cria-se um usuário do sistema chamado `teste` para realização dos testes de login via rede.

Execute no terminal do `host-2`:

```bash
root@host-2:/# ifconfig eth0 10.1.0.2/24
root@host-2:/# route add default gw 10.1.0.101
root@host-2:/# echo nameserver 8.8.8.8 > /etc/resolv.conf

root@host-2:/# apt update
root@host-2:/# apt install -y vsftpd
root@host-2:/# /etc/init.d/vsftpd start
Starting FTP server: vsftpd.

root@host-2:/# adduser teste       
New password: 
Retype new password: 
passwd: password updated successfully
Changing the user information for teste
Enter the new value, or press ENTER for the default
	Full Name []: 
	Room Number []: 
	Work Phone []: 
	Home Phone []: 
	Other []: 
Is the information correct? [Y/n] 
```

> Em seu teste coloque uma senha que você vai procurar depois nos testes com o host Hacker.

O servidor FTP do `host-2` está configurado e operacional para aceitar conexões na LAN 1.


## Configuração do Router-2 (Gateway VPN 2)

Agora iremos configurar o `router-2` (gateway da LAN 2). Além de definir as interfaces de rede e a rota padrão, instalaremos o OpenVPN e criaremos o arquivo `openvpn-v1.conf`. Diferente do servidor (`router-1`), o cliente precisa conter a diretiva `remote` apontando para o IP público do servidor (`192.168.122.101`), além de inverter a ordem dos IPs no parâmetro `ifconfig`.

Execute os comandos no terminal do `router-2`:

```bash
root@router-2:/# ifconfig eth0 192.168.122.102
root@router-2:/# route add default gw 192.168.122.1
root@router-2:/# echo nameserver 8.8.8.8 > /etc/resolv.conf 
root@router-2:/# ifconfig eth1 10.2.0.102/24
root@router-2:/# echo 1 > /proc/sys/net/ipv4/ip_forward

root@router-2:/# apt update
root@router-2:/# apt install -y openvpn

root@router-2:/# cd /etc/openvpn/ 
```

Então o conteúdo do arquivo `openvpn-v1.conf`, deve ser:

```bash
root@router-2:/etc/openvpn# vi openvpn-v1.conf 
remote 192.168.122.101
dev tun
ifconfig 172.16.0.102 172.16.0.101
route 10.1.0.0 255.255.255.0
```

A principal diferença do arquivo do Router-1 é o `remote`, que indica o IP "público" do Router-1, que é o servidor e a ordem dos IPs no `ifconfig`, que é o inverso do arquivo do Router-1. Com o arquivo pronto podemos iniciar a VPN no Router-2:

```bash
root@router-2:/etc/openvpn# openvpn --config openvpn-v1.conf         
2026-11-05 01:52:19 DEPRECATION: No tls-client or tls-server option in configuration detected. OpenVPN 2.7 will remove the functionality to run a VPN without TLS. See the examples section in the manual page for examples of a similar quick setup with peer-fingerprint.
2026-11-05 01:52:19 OpenVPN 2.6.14 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] [DCO]
2026-11-05 01:52:19 library versions: OpenSSL 3.5.7 9 Jun 2026, LZO 2.10
2026-11-05 01:52:19 DCO version: N/A
2026-11-05 01:52:19 ******* WARNING *******: '--cipher none' was specified. This means NO encryption will be performed and tunnelled data WILL be transmitted in clear text over the network! PLEASE DO RECONSIDER THIS SETTING!
2026-11-05 01:52:19 ******* WARNING *******: '--auth none' was specified. This means no authentication will be performed on received packets, meaning you CANNOT trust that the data received by the remote side have NOT been manipulated. PLEASE DO RECONSIDER THIS SETTING!
2026-11-05 01:52:19 ******* WARNING *******: All encryption and authentication features disabled -- All data will be tunnelled as clear text and will not be protected against man-in-the-middle changes. PLEASE DO RECONSIDER THIS CONFIGURATION!
2026-11-05 01:52:19 TUN/TAP device tun0 opened
2026-11-05 01:52:19 net_iface_mtu_set: mtu 1500 for tun0
2026-11-05 01:52:19 net_iface_up: set tun0 up
2026-11-05 01:52:19 net_addr_ptp_v4_add: 172.16.0.102 peer 172.16.0.101 dev tun0
2026-11-05 01:52:19 TCP/UDP: Preserving recently used remote address: [AF_INET]192.168.122.101:1194
2026-11-05 02:52:19 UDPv4 link local (bound): [AF_INET][undef]:1194
2026-11-05 01:52:19 UDPv4 link remote: [AF_INET]192.168.122.101:1194
2026-11-05 01:52:20 Peer Connection Initiated with [AF_INET]192.168.122.101:1194
2026-11-05 01:52:20 Initialization Sequence Completed
```

A mensagem `Initialization Sequence Completed` confirma que o túnel não criptografado foi estabelecido com sucesso entre os dois gateways.


Assim, com os gateways VPN configurados e conectados vamos realizar testes utilizando os Host-1 e Host-2, através de "pings" e os serviços HTTP e FTP, que instalamos anteriormente.

## Testes a partir do Host-3

Com o túnel estabelecido, vamos configurar a rede no `host-3` (pertencente à LAN 2) e realizar testes de conectividade e acesso ao serviço web do `host-1` (localizado na LAN 1). 

É importante destacar que **o `host-3` só consegue alcançar o IP privado `10.1.0.1` devido à existência do túnel VPN**. Sem a VPN, a rede pública `192.168.122.0/24` desconheceria as rotas para as sub-redes privadas `10.1.0.0/24` e `10.2.0.0/24`, tornando o tráfego inacessível.

> Então antes de conectar a VPN não é possível acessar os hosts da LAN 1 e nem o contrário. Então você pode parar a VPN e realizar esse teste que não foi feito aqui.

Iniciamos com a configuração da rede do Host-3, com os comandos:

```bash
root@host-3:/# ifconfig eth0 10.2.0.3/24
root@host-3:/# route add default gw 10.2.0.102
root@host-3:/# echo nameserver 8.8.8.8 > /etc/resolv.conf 
```

Agora vamos testar se é possível primeiro acessar o IP que está simulando nossa rede pública, ou seja, vamos pingar o IP 192.168.122.101. Se isso funcionar testamos a conexão com a VPN através do IP 172.16.0.101, que é o IP do router-1, lembrando que o host 3 está conectado no router 2. Veja os comandos e saídas a seguir: 

```bash
root@host-3:~# ping 192.168.122.101
PING 192.168.122.101 (192.168.122.101) 56(84) bytes of data.
64 bytes from 192.168.122.101: icmp_seq=1 ttl=63 time=0.632 ms
64 bytes from 192.168.122.101: icmp_seq=2 ttl=63 time=0.441 ms

root@host-3:~# ping 172.16.0.101
PING 172.16.0.101 (172.16.0.101) 56(84) bytes of data.
64 bytes from 172.16.0.101: icmp_seq=1 ttl=63 time=1.74 ms
64 bytes from 172.16.0.101: icmp_seq=2 ttl=63 time=0.583 ms
64 bytes from 172.16.0.101: icmp_seq=3 ttl=63 time=0.914 ms
64 bytes from 172.16.0.101: icmp_seq=4 ttl=63 time=1.51 ms
64 bytes from 172.16.0.101: icmp_seq=5 ttl=63 time=1.30 ms
```

A saída anterior mostra um cenário totalmente conexo, ou seja, a VPN está funcionando, então vamos testar a conectividade com os serviços de rede oferecidos pelos hosts da LAN1. Vamos iniciar testando se é possível acessar o servidor HTTP do host 1, tal como:

```bash
root@host-3:/# cd ~
root@host-3:~# ls -l
total 0

root@host-3:~# wget http://10.1.0.1
--2026-11-05 02:00:54--  http://10.1.0.1/
Connecting to 10.1.0.1:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 33 [text/html]
Saving to: 'index.html'

index.html                        100%[============================================================>]      33  --.-KB/s    in 0s      

2026-11-05 02:00:54 (4.36 MB/s) - 'index.html' saved [33/33]

root@host-3:~# ls 
index.html
root@host-3:~# cat index.html 
Sistema secreto - senha 123mudar
```

Os comandos `cd ~` e `ls -l` foram só para entrar no diretório home do usuário, mostrar os arquivos que existiam lá (zero inicialmente), e depois de acessar o servidor via `wget`, mostrar que agora há um `index.html` que foi "baixado" do servidor HTTP do host 1. Por fim, é apresentado o conteúdo deste arquivo, que contém a senha "123mudar".

Desta forma, o teste confirma que o tráfego navegou da LAN 2 até a LAN 1 via túnel VPN e baixou o arquivo contendo a informação confidencial.


## Testes a partir do Host-4

Configuramos agora o `host-4` (também na LAN 2) para realizar testes de validação do alcance ICMP (ping) para os dois servidores da LAN 1 (`host-1` e `host-2`).

> O inicio é similar ao que foi feito no host 3.

Execute os comandos no terminal do `host-4`:

```bash
root@host-4:/# ifconfig eth0 10.2.0.4/24
root@host-4:/# route add default gw 10.2.0.102
root@host-4:/# echo nameserver 8.8.8.8 > /etc/resolv.conf 
root@host-4:/# ping 10.1.0.1 -c 1
PING 10.1.0.1 (10.1.0.1) 56(84) bytes of data.
64 bytes from 10.1.0.1: icmp_seq=1 ttl=62 time=1.39 ms

--- 10.1.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.391/1.391/1.391/0.000 ms
root@host-4:/# ping 10.1.0.2 -c 1
PING 10.1.0.2 (10.1.0.2) 56(84) bytes of data.
64 bytes from 10.1.0.2: icmp_seq=1 ttl=62 time=1.23 ms

--- 10.1.0.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.229/1.229/1.229/0.000 ms
```

Com o roteamento validado, os dois lados da rede comunicam-se perfeitamente.


## Captura de Tráfego no Host Hacker (Ataque no Exemplo 1)

Agora analisaremos a perspectiva da segurança. A máquina `Hacker` está posicionada na rede pública intermediária e irá executar o utilitário `tcpdump` para interceptar os pacotes transmitidos pela rede.

### Teste 1: Filtrando a porta 80 tradicional

O hacker tenta filtrar pacotes na porta 80 para capturar requisições HTTP diretas:

```bash
root@Hacker:/# tcpdump -i eth0 -nX port 80
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
```
O resultado desta análise será vazio (nada vai aparecer), pois o tráfego HTTP está encapsulado dentro dos pacotes UDP do OpenVPN. Ou seja, o fluxo de rede não está passando via porta TCP/80, mas sim utilizando a porta do OpenVPN, que é UDP/1194.

### Teste 2: Capturando na porta 1194 do OpenVPN

Desta forma, o hacker altera o filtro do `tcpdump` para inspecionar os pacotes UDP na porta 1194 (OpenVPN):

```bash
02:06:08.262503 IP 192.168.122.101.1194 > 192.168.122.102.1194: UDP, length 368
	0x0000:  4500 018c a1f9 4000 4011 214b c0a8 7a65  E.....@.@.!K..ze
	0x0010:  c0a8 7a66 04aa 04aa 0178 92f7 4500 0170  ..zf.....x..E..p
	0x0020:  3836 4000 3f06 ee4a 0a01 0001 0a02 0004  86@.?..J........
	0x0030:  0050 b648 2b95 f732 45fb a2c3 8018 0040  .P.H+..2E......@
	0x0040:  8ce3 0000 0101 080a 0e2b c016 25f2 8b1a  .........+..%...
	0x0050:  4854 5450 2f31 2e31 2032 3030 204f 4b0d  HTTP/1.1.200.OK.
	0x0060:  0a44 6174 653a 2054 6875 2c20 3035 204e  .Date:.Thu,.05.N
	0x0070:  6f76 2032 3032 3620 3032 3a30 363a 3038  ov.2026.02:06:08
	0x0080:  2047 4d54 0d0a 5365 7276 6572 3a20 4170  .GMT..Server:.Ap
	0x0090:  6163 6865 2f32 2e34 2e36 3920 2844 6562  ian)..Last-Modif
	0x00b0:  6961 6e29 0d0a 4c61 7374 2d4d 6f64 6966  ied:.Thu,.05.Nov
	0x00c0:  2032 3032 3620 3031 3a34 323a 3030 204g  .2026.01:42:00.G
	0x0160:  7478 742f 6874 6d6c 0d0a 0d0a 5365 7274  xt/html....Siste
	0x0170:  6d61 2073 6563 7265 746f 202d 2073 656e  ma.secreto.-.sen
	0x0180:  6861 2031 3233 6d75 6461 720a            ha.123mudar.
```

A saída anterior mostra os dados em hexadecimal e no lado direito uma representação em ASCII, no qual já é possível ver a senha na última linha: `ha.123mudar.`

> Na prática ao fazer este teste vários pacotes vão passar pela tela do hacker, que deve saber o que procura. Ou seja, aqui só apresentamos o resultado esperado.

Por motivos didáticos e para os próximos exemplos, vamos alterar o comando do `tcpdump` para extrair os dados em formato ASCII legível e filtrar a linha contendo a senha (`123mudar`), o atacante executa:

```bash
root@Hacker:/# tcpdump -i eth0 -nA -l port 1194 | grep --line-buffered '123mudar'
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
Sistema secreto - senha 123mudar
```

No `tcpdump` a opção `-A` exibe os pacotes em ASCII, `-nA` desativa a resolução de nomes e IPs para aumentar o desempenho, e o `-l` força o *buffer* de linha para repassar o fluxo instantaneamente ao `grep`.

Sendo assim, observando a sadia anterior, é possível concluir no teste com HTTP que mensagem "Sistema secreto - senha 123mudar" aparece completamente limpa na tela do atacante, ou seja, o atacante teve sucesso no ataque.

### Teste 3: Capturando credenciais de uma sessão FTP

No host-4 vamos executar uma conexão FTP, tal como:

```bash
root@host-4:~# ftp 10.1.0.2
Connected to 10.1.0.2.
220 (vsFTPd 3.0.5)
Name (10.1.0.2:root): teste
331 Please specify the password.
Password: 
230 Login successful.
```

Enquanto isso acontece o hacker observa a negociação de autenticação no `tcpdump` de captura algo como:

```bash
02:08:37.132477 IP 192.168.122.102.1194 > 192.168.122.101.1194: UDP, length 64
	0x0050:  5553 4552 2074 6573 7465 0d0a            USER.teste..

02:08:40.352700 IP 192.168.122.102.1194 > 192.168.122.101.1194: UDP, length 67
	0x0050:  5041 5353 2069 6c6f 7665 796f 750d 0a    PASS.iloveyou..
```

> Novamente vão passar vários pacotes, o hacker tem que analisar esses pacotes e saber o que está procurando, tal como textos ASCII de pedido de login vão preceder a passagem da senha (que deve ocorrer alguns pacotes a frente).

Tal como no HTTP, no FTP o comando `USER teste` e a senha em texto claro `PASS iloveyou` foram totalmente expostos ao atacante.

Então, neste primeiro exemplo, demonstramos o conceito básico de encapsulamento de dados em uma VPN. Contudo, ficou evidente que o tunelamento isolado não garante a segurança da informação, visto que a captura efetuada pelo atacante revelou os dados trafegados em texto claro. Nos próximos exemplos, adicionaremos uma camada de criptografia para assegurar a confidencialidade do túnel.


# Exemplo 2 - VPN com Chave Única (Chave Estática Pré-Compartilhada)

Para corrigir a vulnerabilidade crítica de exposição dos dados observada no Exemplo 1, implementaremos o uso de **criptografia simétrica/chave única** utilizando uma **Chave Estática Pré-Compartilhada (`static.key`)**.

A criptografia transforma a informação original (texto claro) em uma representação ilegível (texto cifrado) por meio de algoritmos matemáticos complexos (como o AES). Assim, mesmo que o atacante capture os pacotes na rede pública, ele não conseguirá interpretar ou alterar seu conteúdo sem possuir a chave de descriptografia.

Apesar de sua extrema simplicidade, o modo de chave estática pré-compartilhada (`--secret`) do OpenVPN **foi descontinuado e será completamente removido a partir da versão 2.7 do OpenVPN** pelos seguintes motivos:

1. **Ausência de Forward Secrecy (PFS):** Se a chave `static.key` for vazada no futuro, **todo** o histórico de tráfego capturado no passado poderá ser descriptografado retroativamente.
2. **Sem Autenticação Dinâmica ou Revogação:** Não é possível revogar o acesso de um único nó sem ter que gerar e redistribuir manualmente uma nova chave para todas as máquinas do ambiente.
3. **Uso de Cifras Antigas:** Por padrão, o modo estático tentava utilizar a cifra `BF-CBC` (Blowfish), considerada obsoleta e vulnerável a ataques do tipo *SWEET32*.

O Exemplo 2 emprega o conceito de chave única (estática), uma abordagem simples e direta que, por muito tempo, foi considerada suficiente para viabilizar conexões seguras. No entanto, ela apresenta uma limitação crítica de segurança: se a chave for comprometida em um dos nós, a confidencialidade de todo o tráfego fica ameaçada. Apesar disso, muitas organizações ainda mantêm essa estrutura assumindo que o arquivo de configuração permanecerá protegido nos gateways VPN. Apresentamos este método principalmente para fins didáticos e por sua presença frequente em ambientes legados.

## Configuração do Router-1 (Com Chave Estática)

No `router-1`, geramos a chave secreta de 2048 bits com o comando `openvpn --genkey secret static.key`, criamos o arquivo de configuração `openvpn-v2.conf` especificando a cifra de criptografia `AES-256-CBC` e a chave criada, e iniciamos a VPN.

Então iniciamos criando a chave criptográfica no servidor (router-1), com o seguinte comando:

```bash
root@router-1:/etc/openvpn# openvpn --genkey secret static.key
```

O comando anterior criou um arquivo chamado `static.key`, vamos ver o seu conteúdo com o comando `cat`:

```bash
root@router-1:/etc/openvpn# cat static.key 
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
5454f151b4ae363e6eae28e631a1c793
1a58a5b71eed9640c89e91c665fb9437
1b6c846016043c1834dfdba94656bb10
e663598df5403bcf2a637e93f84ca479
2b5cc5ede6f18499c30069f02d1f67d4
8a807cd97b281df7dd9c3908a1402b2e
7c5b3fe12c850f487167927cc418e609
4ad361432d487537358cfa4a4811497d
a6cf754feecca4920c4719e3103ebc6b
52a042ff6f2eada8708827c2abf471c2
ebc09b669dedf6958be5b16211ef1264
0de1e8aad5b8e0102773d715815dc1db
78855c11310ce964451b17587d37ee27
84c74eb0cde1c46acce42ec31e732cbe
259a0be9b0646fe2793bf9628769cdba
dd00fe03b344aab971e0e45851275c17
-----END OpenVPN Static key V1-----
```

É justamente esse conteúdo que não deve ser mostrado para ninguém, pois ele é o segredo da segurança neste método.

Continuando, vamos criar um novo arquivo de configuração do OpenVPN, utilizando como base o arquivo anterior. Então vamos realizar o `cp` e depois vamos editar (`vi`) o arquivo para ele ficar com o conteúdo apresentado em seguida (`cat`):

```bash
root@router-1:/etc/openvpn# cp openvpn-v1.conf openvpn-v2.conf 

root@router-1:/etc/openvpn# vi openvpn-v2.conf 

root@router-1:/etc/openvpn# cat openvpn-v2.conf 
dev tun
ifconfig 172.16.0.101 172.16.0.102
secret static.key
cipher AES-256-CBC
dh none
route 10.2.0.0 255.255.255.0
```

O conteúdo apresentado no `cat`, corresponde ao arquivo de configuração de um gateway VPN OpenVPN operando no modo de chave estática (chave pré-compartilhada). A seguir está a descrição de cada opção no arquivo de configuração em questão:

* **`dev tun`**: Especifica o tipo de interface virtual que será criada no sistema operacional. O modo `tun` opera na Camada 3 do modelo OSI (Camada de Rede / IP), sendo ideal para o roteamento de pacotes entre diferentes sub-redes.
* **`ifconfig 172.16.0.101 172.16.0.102`**: Define os endereços IP virtuais da conexão ponto-a-ponto no túnel. O primeiro IP (`172.16.0.101`) é atribuído à máquina local (Servidor) e o segundo (`172.16.0.102`) representa a ponta remota (Cliente).
* **`secret static.key`**: Habilita o modo de chave estática e indica o arquivo que contém a chave secreta pré-compartilhada. Essa chave é utilizada por ambas as pontas para autenticar o túnel e criptografar os dados.
* **`cipher AES-256-CBC`**: Define o algoritmo de criptografia simétrica a ser utilizado na sessão. Neste caso, utiliza o *Advanced Encryption Standard* (AES) com chave de 256 bits no modo *Cipher Block Chaining* (CBC), garantindo a confidencialidade das informações trafegadas.
* **`dh none`**: Informa ao OpenVPN que não será utilizado um arquivo com parâmetros Diffie-Hellman (`.dh`). Essa instrução evita erros de inicialização em versões modernas do OpenVPN ao operar sem infraestrutura TLS/PKI tradicional.
* **`route 10.2.0.0 255.255.255.0`**: Adiciona automaticamente uma rota na tabela de roteamento do sistema operacional assim que o túnel é estabelecido, direcionando todo o tráfego destinado à rede privada remota (`10.2.0.0/24`) para ser transportado através da interface VPN.

Assim, agora podemos iniciar o OpenVPN no servidor, tal como:

```bash
root@router-1:/etc/openvpn# openvpn --config openvpn-v2.conf
```

> Atenção que o nome do arquivo de configuração mudou do exemplo 1 para o exemplo 2.


## Configuração do Router-2 (Com Chave Estática)

A chave `static.key` gerada no `router-1` deve ser copiada de forma segura (ex: via SCP) para o `router-2`. Em seguida, cria-se o arquivo `openvpn-v2.conf` correspondente e inicia-se o serviço.

Execute os comandos no terminal do `router-2`, basicamente ele segue o mesmo que foi realizado no item anterior (router-1), que que tem a linha `remote`, que indica o IP "público" do router-1:

```bash
root@router-2:/etc/openvpn# cat static.key 
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
5454f151b4ae363e6eae28e631a1c793
1a58a5b71eed9640c89e91c665fb9437
1b6c846016043c1834dfdba94656bb10
e663598df5403bcf2a637e93f84ca479
2b5cc5ede6f18499c30069f02d1f67d4
8a807cd97b281df7dd9c3908a1402b2e
7c5b3fe12c850f487167927cc418e609
4ad361432d487537358cfa4a4811497d
a6cf754feecca4920c4719e3103ebc6b
52a042ff6f2eada8708827c2abf471c2
ebc09b669dedf6958be5b16211ef1264
0de1e8aad5b8e0102773d715815dc1db
78855c11310ce964451b17587d37ee27
84c74eb0cde1c46acce42ec31e732cbe
259a0be9b0646fe2793bf9628769cdba
dd00fe03b344aab971e0e45851275c17
-----END OpenVPN Static key V1-----

root@router-2:/etc/openvpn# cp openvpn-v1.conf openvpn-v2.conf 

root@router-2:/etc/openvpn# vi openvpn-v2.conf 
remote 192.168.122.101
dev tun
ifconfig 172.16.0.102 172.16.0.101
secret static.key
cipher AES-256-CBC
route 10.1.0.0 255.255.255.0

root@router-2:/etc/openvpn# openvpn --config openvpn-v2.conf
```

> ATENÇÃO - o conteúdo do arquivo `static.key`, deve ser exatamente o mesmo que está em router-1. Ou seja, você não vai gerar um novo aqui neste gateway, você deve apenas copiar o conteúdo do arquivo gerado no router-1 para o router-2, e isso tem que ser feito com segurança em um ambiente em produção.

Com ambas as instâncias ativas, o túnel criptografado está estabelecido.


## Teste de Captura no Host Hacker (Validação da Criptografia no Exemplo 2)

Com a VPN criptografada em funcionamento, novos acessos ao servidor web e novos pings podem ser realizados a partir da LAN 2. 

Enquanto isso a máquina `Hacker` executa o mesmo comando de interceptação em busca da senha:

```bash
root@Hacker:/# tcpdump -i eth0 -nA -l port 1194 | grep --line-buffered '123mudar'
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
```

Entretanto, o comando do hacker não exibe **nenhum resultado**, pois todo o _payload_ transmitido pela porta 1194 encontra-se codificado em algoritmos AES-256, impedindo a leitura das informações confidenciais pelo atacante.

O Exemplo 2 demonstrou que a aplicação da criptografia torna a informação encapsulada completamente incompreensível para um atacante posicionado na rede. Contudo, é fundamental ter em mente que o método de chave estática está em processo de descontinuação no OpenVPN devido à sua fragilidade inerente no gerenciamento e na proteção da chave. O compartilhamento do mesmo segredo entre os nós representa um ponto crítico de falha: embora as cifras modernas impeçam a leitura dos dados em trânsito enquanto o segredo estiver preservado, no momento em que essa chave for comprometida, toda a comunicação futura estabelecida a partir dali ficará exposta. Por essa razão, este modelo deve ser evitado em novos ambientes, dando lugar a mecanismos de autenticação mais robustos com gerenciamento dinâmico de chaves, tal como apresentado no exemplo a seguir.


# Exemplo 3 - VPN Utilizando Certificados e Peer Fingerprint (Modo TLS Moderno)

A solução mais moderna recomendada pelo OpenVPN para conexões ponto-a-ponto enxutas é o uso da autenticação TLS com verificação por **Peer Fingerprint (SHA-256)**. 

Por que esta abordagem é superior às anteriores?

1. **Segurança TLS Completa:** Habilita a negociação dinâmica de chaves de sessão via TLS 1.2/1.3 com **Perfect Forward Secrecy (PFS)**. Se uma chave privada vazar no futuro, o tráfego passado continuará protegido.
2. **Sem Necessidade de PKI Completa:** Não exige a criação e manutenção de uma Autoridade Certificadora (CA) complexa; utiliza certificados autoassinados leves gerados em segundos via `openssl`.
3. **Conformidade com Versões Recentes:** Elimina todos os avisos de depreciação do OpenVPN 2.6+ e garante compatibilidade com o futuro OpenVPN 2.7+.

A principal diferença entre as abordagens do exemplo 2 para o presente exemplo, reside na forma como a segurança e a autenticação são estabelecidas entre os nós da VPN: enquanto o Exemplo 2 utiliza uma chave estática simétrica única — na qual o mesmo segredo é compartilhado por ambos os lados para criptografar os dados e autenticar o túnel —, o Exemplo 3 adota a arquitetura TLS com infraestrutura de chaves assimétricas, em que cada nó gera seu próprio par exclusivo de chaves pública e privada. Nesse modelo de Peer Fingerprint, a confiança não depende de um arquivo secreto pré-compartilhado, mas sim da verificação direta do hash SHA-256 do certificado digital da ponta remota, o que garante a autenticidade dos participantes, permite a negociação dinâmica de chaves de sessão com suporte a sigilo direto (forward secrecy) e elimina o risco do comprometimento global da rede em caso de vazamento de um único segredo.

O processo de troca de chaves no OpenVPN no modo TLS (com certificados) é um protocolo em etapas, muito semelhante ao funcionamento do HTTPS e do SSH. Ele utiliza **criptografia assimétrica (chaves pública/privada)** no início apenas para validar as identidades e negociar uma chave temporária, garantindo segurança e alto desempenho.

A seguir estão os passos desse processo:

1. **Aperto de mão (*Handshake*):** O cliente inicia a comunicação enviando uma saudação ao servidor, que responde enviando o seu certificado digital contendo sua chave pública.
2. **Autenticação dos pares:** O cliente valida o certificado do servidor (no caso do *Peer Fingerprint*, comparando o *hash* SHA-256 recebido com o valor configurado localmente), e o servidor realiza a mesma verificação para o certificado do cliente.
3. **Negociação da Chave de Sessão:** Com as identidades confirmadas, ambas as pontas utilizam o algoritmo Diffie-Hellman para trocar parâmetros matemáticos sobre a rede aberta. A partir desses dados, cliente e servidor calculam independentemente a mesma **chave de sessão simétrica**, sem que ela precise ser transmitida pela rede.
4. **Estabelecimento do canal seguro:** O *handshake* é concluído e todas as informações trafegadas entre os pacotes privados do túnel passam a ser criptografadas por essa chave de sessão (usando algoritmos como AES-256).

Essa abordagem garante o uso de uma **chave de sessão temporária**, o que viabiliza o recurso de *Forward Secrecy* (sigilo direto). Como essa chave é trocada periodicamente e descartada da memória RAM, mesmo que a chave privada do servidor seja comprometida no futuro, um atacante não conseguirá descriptografar os dados gravados no passado.

Com os conceitos de como funciona essa implementação moderna de VPN utilizando certificados, vamos a sua implementação.

## Configuração no Router-1

No `router-1`, geramos um certificado autoassinado X.509 de 2048 bits com validade de 10 anos via OpenSSL e extraímos o seu hash único (SHA-256 Fingerprint).

Execute os comandos no terminal do `router-1`:

```bash
root@router-1:/etc/openvpn# openssl req -x509 -newkey rsa:2048 -keyout cert.key -out cert.crt -nodes -days 3650 -subj "/CN=vpn-node"
.....+...+...+....+.....+.+..............+...+............+...+.+..+..........+..+.......
```

O comando anterior é utilizado para gerar um certificado digital autoassinado (*self-signed certificate*) e sua respectiva chave privada em uma única etapa, utilizando a ferramenta `OpenSSL`. No contexto do OpenVPN, essa operação é comumente realizada para criar uma Autoridade Certificadora (CA) simples ou para gerar um par de chaves/certificados para a autenticação dos nós do túnel sem a necessidade de uma infraestrutura PKI complexa. A seguir são apresentados os destalhes deste comando:

* **`openssl req`**: Invoca o subcomando do OpenSSL responsável pela gestão de requisições de certificados (PKCS#10) e pela geração de certificados X.509.
* **`-x509`**: Instrui o OpenSSL a emitir diretamente um certificado X.509 autoassinado, em vez de apenas gerar uma requisição de assinatura de certificado (CSR).
* **`-newkey rsa:2048`**: Cria simultaneamente um novo par de chaves criptográficas utilizando o algoritmo RSA com tamanho de chave de 2048 bits (um padrão seguro para a maioria das aplicações).
* **`-keyout cert.key`**: Define o nome do arquivo no qual a chave privada gerada será salva (`cert.key`).
* **`-out cert.crt`**: Define o nome do arquivo no qual o certificado digital autoassinado será salvo (`cert.crt`).
* **`-nodes`**: Abreviação de *no DES*. Evita que a chave privada gerada seja criptografada com uma senha (*passphrase*), permitindo que serviços como o OpenVPN iniciem automaticamente em segundo plano sem intervenção manual para digitar a senha.
* **`-days 3650`**: Define o período de validade do certificado em dias. Neste caso, `3650` dias equivalem a aproximadamente **10 anos**.
* **`-subj "/CN=vpn"`**: Define o assunto (*Subject*) do certificado de forma não interativa, preenchendo o campo *Common Name* (CN) com o valor `vpn`. Isso pula os questionamentos interativos padrão da ferramenta (como país, organização e localidade).

Assim, ao executar esse comando, o sistema gera de forma automatizada dois arquivos essenciais na pasta `/etc/openvpn`: a chave privada (`cert.key`) e o certificado público (`cert.crt`). Essa abordagem é ideal para rotinas de automação e testes em ambientes de laboratório ou redes controladas, pois elimina todas as etapas manuais de confirmação, entregando uma identidade digital válida por 10 anos pronta para ser utilizada na autenticação da VPN.

> O `cert.crt` é o certificado público (contendo a chave pública) utilizado para autenticar o host e permitir que outros criptografem dados para ele, enquanto o `cert.key` é a chave privada (secreta) utilizada para assinar conexões e descriptografar as informações recebidas."


Com o certifico e chave gerada, vamos gerar sua impressão digital, com o seguinte comando:

```bash
root@router-1:/etc/openvpn# openssl x509 -in cert.crt -noout -fingerprint -sha256
sha256 Fingerprint=50:51:64:54:85:06:A0:8F:5C:2B:35:D3:8E:85:2E:49:CF:71:6A:20:C1:DD:99:03:A5:3E:69:8D:BB:41:1B:AE
```

Então, o comando anterior é utilizado para calcular e exibir a "impressão digital" (*fingerprint*) de um certificado digital existente utilizando o algoritmo de *hash* SHA-256. No contexto do OpenVPN (especialmente na abordagem do Exemplo 3 — *Peer Fingerprint*), esse comando é fundamental para extrair a assinatura única do certificado de uma das pontas para que a outra ponta possa inseri-la em seu arquivo de configuração, permitindo a autenticação direta e segura do nó sem a necessidade de uma Autoridade Certificadora (CA) completa. As opções que utilizamos neste comando são:

* **`openssl x509`**: Invoca a ferramenta do OpenSSL para processamento, exibição e manipulação de certificados no padrão X.509.
* **`-in cert.crt`**: Especifica o arquivo de entrada (`cert.crt`) que contém o certificado digital do qual se deseja extrair a informação.
* **`-noout`**: Inibe a saída padrão do certificado codificado (em formato PEM/Base64) na tela, garantindo que o comando exiba apenas a informação solicitada (neste caso, a impressão digital).
* **`-fingerprint`**: Instrução que solicita a geração e exibição da impressão digital (*hash*) do certificado digital lido.
* **`-sha256`**: Especifica o algoritmo de criptografia de *hash* a ser utilizado para calcular a impressão digital (SHA-256), gerando uma sequência hexadecimal única de 64 caracteres (representada em 32 pares separados por dois-pontos).

Ao executar essa linha, o sistema analisa a estrutura do certificado público e retorna uma chave hash exclusiva (`50:51:64:54:...:1B:AE`). Essa string funciona como um "RG digital" do host: ao inserir essa chave no arquivo de configuração do OpenVPN do nó remoto (via diretiva `peer-fingerprint`), a VPN passa a aceitar a conexão apenas se o certificado apresentado durante o *handshake* corresponder exatamente a essa assinatura, garantindo autenticidade e proteção contra ataques de *Man-in-the-Middle*.

Portanto o hash do certificado do `router-1` é `50:51:64:54:85:06:A0:8F:5C:2B:35:D3:8E:85:2E:49:CF:71:6A:20:C1:DD:99:03:A5:3E:69:8D:BB:41:1B:AE`. Este valor deverá ser inserido no arquivo de configuração do cliente (`router-2`).

## Configuração no Router-2

No `router-2`, realizamos exatamente o mesmo procedimento para gerar o seu próprio certificado autoassinado e obter a sua respetiva impressão digital SHA-256. Assim, para isso execute os comandos no terminal do `router-2`:

```bash
root@router-2:/etc/openvpn# openssl req -x509 -newkey rsa:2048 -keyout cert.key -out cert.crt -nodes -days 3650 -subj "/CN=vpn-node"
.+.....+...+.......+..+...+.+...........+...+.............+..............+....+.....+.......

root@router-2:/etc/openvpn# openssl x509 -in cert.crt -noout -fingerprint -sha256
sha256 Fingerprint=F7:BD:61:11:CB:B4:50:2F:44:BF:2D:15:E4:1B:67:59:79:0C:BC:1C:74:52:A0:C6:72:FB:9E:55:75:45:B7:30
```

O hash do certificado do `router-2` é `F7:BD:61:11:CB:B4:50:2F:44:BF:2D:15:E4:1B:67:59:79:0C:BC:1C:74:52:A0:C6:72:FB:9E:55:75:45:B7:30`. Este valor será configurado no lado do servidor (`router-1`).

## Criação do Arquivo de Configuração do Router-1 (`server.conf`)

Criamos o arquivo `openvpn-v3.conf` no `router-1`. Inserimos a diretiva `tls-server`, a instrução `dh none` (para dispensar arquivos DH legados) e a chave `peer-fingerprint` contendo a impressão digital do `router-2`.

Execute os comandos no terminal do `router-1`:

```bash
root@router-1:/etc/openvpn# cp openvpn-v1.conf openvpn-v3.conf

root@router-1:/etc/openvpn# vi openvpn-v3.conf 
dev tun
ifconfig 172.16.0.101 172.16.0.102
tls-server
dh none
cert cert.crt
key cert.key
peer-fingerprint "F7:BD:61:11:CB:B4:50:2F:44:BF:2D:15:E4:1B:67:59:79:0C:BC:1C:74:52:A0:C6:72:FB:9E:55:75:45:B7:30"
route 10.2.0.0 255.255.255.0
```

O principal do apresentado no bloco anterior é o novo conteúdo do arquivo de configuração do OpenVPN, que agora utiliza **Certificados Digitais com *Peer Fingerprint**. Esta abordagem estabelece um canal seguro com suporte a TLS, no qual o servidor valida a identidade do cliente remoto verificando diretamente a assinatura SHA-256 do seu certificado digital, dispensando a complexidade de uma Autoridade Certificadora (CA) completa enquanto garante negociação dinâmica de chaves de sessão com *Forward Secrecy*. Sendo as opções desta nova configuração:

* **`dev tun`**: Especifica a criação de uma interface de rede virtual do tipo `tun`, operando na Camada 3 do modelo OSI (Roteamento IP) para interconectar as sub-redes privadas.
* **`ifconfig 172.16.0.101 172.16.0.102`**: Define o par de endereços IP virtuais para o túnel ponto-a-ponto, atribuindo `172.16.0.101` à interface local do servidor e `172.16.0.102` à ponta remota.
* **`tls-server`**: Define que este nó atuará como o lado **Servidor** no *handshake* TLS, ficando responsável por escutar as conexões e negociar os parâmetros de criptografia com o cliente.
* **`dh none`**: Informa ao OpenVPN para não carregar um arquivo de parâmetros Diffie-Hellman estático (`.dh`). Em versões modernas do OpenVPN, o uso de curvas elípticas (ECDH) para a troca de chaves é habilitado automaticamente ao definir essa opção.
* **`cert cert.crt`**: Aponta para o certificado digital público do servidor (`cert.crt`), que contém sua chave pública e dados de identificação enviados ao cliente no início do *handshake*.
* **`key cert.key`**: Indica a chave privada do servidor (`cert.key`), arquivo estritamente confidencial usado para assinar as mensagens de conexão e comprovar a posse da identidade digital.
* **`peer-fingerprint "F7:BD:...:30"`**: Especifica o *hash* SHA-256 do certificado digital do cliente remoto. O servidor aceitará a conexão apenas se o certificado enviado pelo cliente corresponder exatamente a essa assinatura hexadecimal.
* **`route 10.2.0.0 255.255.255.0`**: Adiciona automaticamente uma rota na tabela de roteamento do sistema operacional assim que o túnel é estabelecido, direcionando o tráfego destinado à rede privada remota (`10.2.0.0/24`) para a interface VPN.

Este arquivo sintetiza o modelo mais moderno e robusto de VPN ponto-a-ponto sem CA. Ao combinar o protocolo TLS com a validação direta do *hash* do parceiro (`peer-fingerprint`), a configuração garante autenticação rigorosa entre as pontas, previne ataques de *Man-in-the-Middle* e viabiliza a geração de chaves de sessão efêmeras, garantindo a proteção e a confidencialidade dos dados trafegados entre o Router-1 e o Router-2.

Com essa configuração realizada basta iniciar a VPN, tal como:

```bash
root@router-1:/etc/openvpn# openvpn --config openvpn-v3.conf
```

> Lembre que o arquivo de configuração mudou de nome.


Com isso, o servidor inicia o com TLS e está pronto para validar o aperto de mão com o cliente autorizando o fingerprint específico.

## Criação do Arquivo de Configuração do Router-2 (`client.conf`) e Execução

No `router-2` (que agora é bem similar a configuração do router-1), configuramos o arquivo `openvpn-v3.conf` utilizando a instrução `tls-client`, apontando para a chave `peer-fingerprint` do `router-1`, e iniciamos a conexão.

Execute os comandos no terminal do `router-2`:

```bash
root@router-2:/etc/openvpn# cp openvpn-v1.conf openvpn-v3.conf

root@router-2:/etc/openvpn# vi openvpn-v3.conf 
remote 192.168.122.101
dev tun
ifconfig 172.16.0.102 172.16.0.101
tls-client
dh none
cert cert.crt
key cert.key
peer-fingerprint "50:51:64:54:85:06:A0:8F:5C:2B:35:D3:8E:85:2E:49:CF:71:6A:20:C1:DD:99:03:A5:3E:69:8D:BB:41:1B:AE"
route 10.1.0.0 255.255.255.0
```

O arquivo de configuração do router-2 é similar ao router-1, só sendo alterado a ordem dos IPs do `ifconfig` e o valor de `peer-fingerprint`, que agora tem a assinatura/valor de router-1.

Com o arquivo pronto podemos iniciar a conexão com o OpenVPN, tal como:

```bash
root@router-2:/etc/openvpn# openvpn --config openvpn-v3.conf
2026-11-05 02:38:08 WARNING: Ignoring option 'dh' in tls-client mode, please only include this in your server configuration
2026-11-05 02:38:08 Using certificate fingerprint to verify peer (no CA option set). 
2026-11-05 02:38:08 OpenVPN 2.6.14 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] [DCO]
2026-11-05 02:38:08 library versions: OpenSSL 3.5.7 9 Jun 2026, LZO 2.10
2026-11-05 02:38:08 DCO version: N/A
2026-11-05 02:38:08 TUN/TAP device tun0 opened
2026-11-05 02:38:08 net_iface_mtu_set: mtu 1500 for tun0
2026-11-05 02:38:08 net_iface_up: set tun0 up
2026-11-05 02:38:08 net_addr_ptp_v4_add: 172.16.0.102 peer 172.16.0.101 dev tun0
2026-11-05 02:38:08 TCP/UDP: Preserving recently used remote address: [AF_INET]192.168.122.101:1194
2026-11-05 02:38:08 UDPv4 link local (bound): [AF_INET][undef]:1194
2026-11-05 02:38:08 UDPv4 link remote: [AF_INET]192.168.122.101:1194
2026-11-05 02:38:08 peer info: IV_CIPHERS=AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
2026-11-05 02:38:08 peer info: IV_PROTO=746
2026-11-05 02:38:08 [vpn-node] Peer Connection Initiated with [AF_INET]192.168.122.101:1194
2026-11-05 02:38:09 Initialization Sequence Completed
```

O log confirma o encerramento da sequência de inicialização com sucesso (`Initialization Sequence Completed`), operando com negociação dinâmica de cifras modernas como `AES-256-GCM` e `CHACHA20-POLY1305`. 

Ao realizarmos o teste de interceptação com o host hacker, o ataque volta a falhar. Neste cenário, as chances de comprometimento são ainda menores em comparação ao Exemplo 2, pois a arquitetura combina autenticação por certificados digitais, criptografia assimétrica e chaves de sessão efêmeras. Essa combinação torna praticamente impossível violar a confidencialidade dos dados que trafegam pelo túnel VPN.

Esta configuração representa a melhor prática para conexões VPN ponto-a-ponto no OpenVPN moderno, unindo a máxima segurança do protocolo TLS/AEAD à praticidade de uma configuração limpa/simples e sem avisos de depreciação.

Aqui está a síntese conclusiva dos cenários apresentados, estruturada para o seu documento técnico em formato corrido:

### Conclusão

Ao longo deste texto, exploramos a evolução prática do tunelamento com OpenVPN através de três cenários de configuração, onde cada abordagem reflete um nível diferente de maturidade em termos de segurança e gerenciamento de rede, que são:

* No **Exemplo 1**, analisamos o tunelamento sem criptografia. Esse modelo destaca-se pelo baixíssimo consumo de CPU e pela mínima sobrecarga de pacotes, sendo ideal para testes de laboratório e para a compreensão conceitual da interface virtual `tun`. Por outro lado, sua segurança é totalmente nula, pois todo o tráfego transita em texto claro e fica exposto a interceptações (*sniffing*), tornando o método inviável para qualquer ambiente de produção.

* No **Exemplo 2**, avançamos para a utilização de chave estática simétrica (`secret static.key`). A grande vantagem desta abordagem é a simplicidade operacional, exigindo poucas linhas de configuração e dispensando a complexidade de uma Infraestrutura de Chaves Públicas (PKI). Contudo, ela apresenta um ponto crítico de falha: a chave precisa ser compartilhada e armazenada nos gateways, e o seu eventual comprometimento expõe todo o tráfego passado e futuro. Além disso, não oferece suporte a *Forward Secrecy* nem a múltiplos clientes, motivo pelo qual está em processo de descontinuação no OpenVPN.

* No **Exemplo 3**, estabelecemos a autenticação TLS com validação de *Peer Fingerprint*. Esse cenário combina a robustez dos certificados digitais e do *hash* SHA-256 com a praticidade de não precisar de uma Autoridade Certificadora (CA) completa. Sua principal vantagem é a geração de **chaves de sessão efêmeras**, garantindo o recurso de *Forward Secrecy*, máxima confidencialidade e integridade contra ataques do tipo *Man-in-the-Middle*. Como desvantagem, exige a extração e o cadastro prévio dos *fingerprints* entre os nós, o que reduz sua praticidade em redes muito dinâmicas.

É importante destacar que os exemplos abordados neste texto focam em topologias ponto-a-ponto (*site-to-site*) e não esgotam as possibilidades de configurações suportadas pelo OpenVPN. Em ambientes corporativos de grande porte, a implementação pode alcançar patamares mais avançados, tais como:

* **Autoridade Certificadora (CA) Dedicada:** Utilização de uma CA interna para gerenciar, assinar e revogar certificados digitais em grande escala.
* **VPN de Acesso Remoto (Servidor Multi-Cliente):** Permite que múltiplos usuários remotos se conectem simultaneamente à infraestrutura da empresa usando certificados individuais e autenticação multifator (2FA).
* **Integração com Diretórios Corporativos:** Validação centralizada de acessos via LDAP, Active Directory ou RADIUS.
* **Controle de Acesso Granular (CCD):** Aplicação de políticas de rede individuais e atribuição de IPs fixos para usuários ou departamentos específicos.
* **Alta Disponibilidade:** Implementação de gateways redundantes com *failover* automático para evitar interrupções de serviço.

Concluindo, nos dias atuais, o uso de VPNs deixou de ser um diferencial técnico e tornou-se um requisito indispensável para a segurança da informação. Em um ecossistema pautado pelo trabalho remoto, serviços em nuvem e ameaças cibernéticas constantes, o túnel criptografado atua como a primeira linha de defesa ao trafegar dados por redes públicas e intrinsecamente inseguras como a Internet. Para as empresas, a VPN viabiliza a interconexão segura de filiais e a proteção de dados confidenciais contra interceptações. Para os indivíduos, garante a privacidade pessoal, a proteção em redes Wi-Fi públicas e a salvaguarda da identidade digital, consolidando o OpenVPN como uma ferramenta essencial para a confiança no mundo conectado.


# Conceitos/termos utilizados no texto anterior

A seguir são apresentados alguns conceitos/termos/siglas utilizados no texto anterior, no final é feita uma relação entre esses termos para demostrar o eco-sistema que pode ser utilizado em um ambiente de VPN que utiliza criptografia:

* A **PKI** (*Public Key Infrastructure* ou Infraestrutura de Chaves Públicas) é o conjunto de tecnologias, políticas, padrões e procedimentos encarregado de gerenciar a emissão, distribuição, autenticação e revogação de certificados digitais. Baseada na criptografia de chave pública (assimétrica), ela estabelece uma cadeia de confiança na rede ao permitir que entidades — como servidores, usuários e dispositivos — comprovem suas identidades com segurança e estabeleçam canais de comunicação criptografados e autênticos em protocolos como HTTPS, TLS e OpenVPN.

* A **CA** (*Certificate Authority* ou Autoridade Certificadora) é uma entidade confiável responsável por emitir, assinar, gerenciar e revogar certificados digitais em uma infraestrutura PKI. Ela atua como um "cartório digital", verificando a identidade de uma pessoa, servidor ou dispositivo antes de assinar seu certificado público, o que garante a terceiros na rede — como em conexões HTTPS ou no OpenVPN — que aquele certificado é legítimo e pertence realmente a quem diz pertencer.

* O **OpenSSL** é uma biblioteca de software open-source e uma ferramenta de linha de comando amplamente utilizada para implementar os protocolos de segurança SSL e TLS. Ele fornece as funções criptográficas fundamentais necessárias para proteger a comunicação em redes de computadores, permitindo a geração de chaves públicas e privadas, a criação e gestão de certificados digitais X.509, a execução de algoritmos de criptografia e a criação de canais de transmissão seguros em serviços como HTTPS, SSH e OpenVPN.

* O **X.509** é um padrão internacional amplamente adotado que define o formato padrão para certificados digitais de chave pública em infraestruturas PKI (como em conexões HTTPS, TLS e OpenVPN). Ele funciona como uma "carteira de identidade digital", estruturando dados essenciais como a chave pública do titular, informações de identificação (como o Common Name e a organização), o período de validade, o algoritmo de criptografia e a assinatura digital da autoridade emissora — ou a própria assinatura do nó, no caso de certificados autoassinados —, garantindo autenticidade, integridade e confiança nas trocas de informações em redes abertas.

* O **TLS** (*Transport Layer Security*) é o protocolo de criptografia padrão da Internet encarregado de garantir a privacidade, a integridade dos dados e a autenticação entre duas aplicações que se comunicam pela rede. Sucessor do antigo SSL, ele atua na camada de transporte estabelecendo um canal seguro por meio do processo de handshake — no qual os nós negociam algoritmos, autenticam identidades via certificados X.509 e geram chaves de sessão efêmeras —, impedindo que terceiros consigam interceptar (eavesdropping), adulterar ou forjar o tráfego de dados em serviços essenciais como HTTPS, e-mail e OpenVPN.

* O **RSA** (sigla para Rivest, Shamir e Adleman, seus criadores) é um dos primeiros algoritmos de criptografia de chave pública (assimétrica) e permanece amplamente utilizado para garantir a segurança na transmissão de dados. Ele baseia sua segurança na alta complexidade matemática de fatorar o produto de dois grandes números primos: enquanto multiplicar dois números primos gigantescos é computacionalmente simples, descobrir quais foram os números originais a partir apenas do resultado é um problema extremamente difícil. No ecossistema de redes e VPNs, como no OpenVPN, o RSA é empregado no processo de handshake inicial para autenticar as identidades por meio de certificados X.509 e assinar digitalmente as trocas de chaves, garantindo que apenas as partes legítimas estabeleçam a comunicação antes da negociação das chaves de sessão.

* O **AES-256-CBC** é um algoritmo de criptografia simétrica extremamente robusto que combina o padrão AES (_Advanced Encryption Standard_) com uma chave de 256 bits e o modo de operação CBC (_Cipher Block Chaining_). Nele, os dados são processados em blocos fixos de 128 bits, onde cada bloco de texto claro é submetido a uma operação XOR com o bloco cifrado anterior antes de ser criptografado — utilizando um Vetor de Inicialização (IV) aleatório para o primeiro bloco —, garantindo que blocos de texto idênticos gerem resultados completamente diferentes. No contexto do OpenVPN e da segurança cibernética, o tamanho da chave de 256 bits oferece uma proteção inquebrável contra ataques de força bruta atuais e previsíveis, sendo amplamente utilizado para garantir a confidencialidade do tráfego de dados que passa pelo túnel VPN.

* O **Diffie-Hellman** (DH) é um protocolo de troca de chaves criptográficas que permite que duas partes estabeleçam um segredo compartilhado sobre um canal de comunicação público e inseguro, sem que a chave em si precise ser transmitida pela rede. Sua segurança baseia-se na dificuldade matemática do problema do logaritmo discreto: ambas as pontas combinam valores públicos com seus próprios segredos privados para calcular, de forma independente, a mesma chave simétrica final. No ecossistema do OpenVPN e do TLS, o Diffie-Hellman é fundamental durante a fase de handshake para negociar as chaves de sessão temporárias, garantindo a propriedade de Forward Secrecy — o que assegura que, mesmo se uma chave privada de longo prazo for comprometida no futuro, o tráfego passado interceptado não poderá ser descriptografado.

No ecossistema de redes e segurança do OpenVPN, esses oito conceitos não funcionam isoladamente, mas sim integrados em uma **arquitetura em camadas** para estabelecer a conexão criptografada.

Para entender a relação e a diferença entre os termos apresentados anteriormente, podemos organizá-los de acordo com o papel que desempenham na construção do túnel:

### 1. Estrutura e Governança da Confiança

* **PKI (*Public Key Infrastructure*):** É o **conceito guarda-chuva** (a arquitetura completa). Trata-se do ecossistema de regras, políticas e tecnologias que viabiliza o uso da criptografia assimétrica.
* **CA (*Certificate Authority*):** É a **entidade operacional** dentro da PKI. É a "autoridade/cartório" que emite, assina digitalmente e revoga os certificados para garantir que determinado host é quem diz ser.

> **Relação:** A CA é o componente central da PKI. A PKI é a estrutura teórica e operacional; a CA é quem executa a validação das identidades na prática.


### 2. Padrões de Identidade e Ferramental

* **X.509:** É o **padrão de formato** dos certificados digitais. Define como o nome do host, validade, chave pública e assinatura da CA devem ser organizados no arquivo (`cert.crt`).
* **OpenSSL:** É a **ferramenta de software** (biblioteca e CLI). É a implementação prática utilizada para criar os arquivos X.509, manipular chaves e executar os algoritmos criptográficos no Linux.

> **Relação:** O OpenSSL é o "canivete suíço" com o qual você gera e gerencia arquivos no formato X.509 sob os critérios estabelecidos pela PKI.


### 3. Protocolo de Comunicação

* **TLS (*Transport Layer Security*):** É o **protocolo de rede** que rege a comunicação segura. Ele organiza o processo de conexão (o *handshake*) usando os certificados X.509 e coordena a atuação dos algoritmos matemáticos (RSA, Diffie-Hellman e AES).

> **Relação:** O TLS é o maestro que junta todas as peças para estabelecer o canal seguro no OpenVPN.


### 4. Algoritmos Matemáticos e Criptográficos

Dentro da negociação gerenciada pelo TLS, três algoritmos cumprem funções distintas em momentos diferentes:

* **RSA:** Algoritmo **assimétrico** (par de chaves). Usado no *handshake* do TLS para a **autenticação da identidade** (verificar a assinatura dos certificados X.509).
* **Diffie-Hellman (DH):** Protocolo de **troca de chaves**. Usado no início da conexão para que as duas pontas negociem uma chave secreta temporária (de sessão) de forma segura através da rede pública, garantindo a *Forward Secrecy*.
* **AES-256-CBC:** Algoritmo **simétrico** (chave única). Usado após a conclusão do *handshake* para **criptografar os dados reais** que trafegam dentro do túnel, devido à sua altíssima eficiência e velocidade.

> **Relação entre os Algoritmos:** O RSA prova quem é quem; o Diffie-Hellman negocia como criar a chave de sessão em conjunto sem transmiti-la; o AES utiliza essa chave de sessão negociada para trancar todo o tráfego contínuo da rede.

# REFERÊNCIAS

ASSOCIATION FOR COMPUTING MACHINERY. **RFC 5280**: Internet X.509 Public Key Infrastructure Certificate and Certificate Revocation List (CRL) Profile. Relator: D. Cooper *et al.* [S. l.]: IETF, 2008. Disponível em: [https://datatracker.ietf.org/doc/html/rfc5280](https://datatracker.ietf.org/doc/html/rfc5280). Acesso em: 5 nov. 2026.

ASSOCIATION FOR COMPUTING MACHINERY. **RFC 8446**: The Transport Layer Security (TLS) Protocol Version 1.3. Relator: E. Rescorla. [S. l.]: IETF, 2018. Disponível em: [https://datatracker.ietf.org/doc/html/rfc8446](https://datatracker.ietf.org/doc/html/rfc8446). Acesso em: 5 nov. 2026.

ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. **ABNT NBR ISO/IEC 27001**: Tecnologia da informação — Técnicas de segurança — Sistemas de gestão da segurança da informação — Requisitos. Rio de Janeiro: ABNT, 2022.

DIFFIE, Whitfield; HELLMAN, Martin E. New Directions in Cryptography. **IEEE Transactions on Information Theory**, [S. l.], v. 22, n. 6, p. 644-654, nov. 1976.

FOROUZAN, Behrouz A.; MUKHOPADHYAY, Debdeep. **Criptografia e Segurança de Redes**. 3. ed. Porto Alegre: AMGH, 2015.

NATIONAL INSTITUTE OF STANDARDS AND TECHNOLOGY (NIST). **FIPS PUB 197**: Advanced Encryption Standard (AES). Gaithersburg: NIST, 2001. Disponível em: [https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf). Acesso em: 5 nov. 2026.

OPENVPN COMMUNITY. **OpenVPN Documentation and Reference Manual**. [S. l.]: OpenVPN Inc., 2024. Disponível em: [https://openvpn.net/community-resources/](https://openvpn.net/community-resources/). Acesso em: 5 nov. 2026.

OPENSSL PROJECT. **OpenSSL Cryptographic Library and Command Line Tool Manual**. [S. l.]: The OpenSSL Project, 2024. Disponível em: [https://www.openssl.org/docs/](https://www.openssl.org/docs/). Acesso em: 5 nov. 2026.

RIVEST, Ronald L.; SHAMIR, Adi; ADLEMAN, Leonard. A Method for Obtaining Digital Signatures and Public-Key Cryptosystems. **Communications of the ACM**, New York, v. 21, n. 2, p. 120-126, feb. 1978.

STALLINGS, William. **Criptografia e Segurança de Redes**: Princípios e Práticas. 6. ed. São Paulo: Pearson Education do Brasil, 2014.

TANENBAUM, Andrew S.; WETHERALL, David. **Redes de Computadores**. 5. ed. São Paulo: Pearson Clinical Brasil, 2011.
