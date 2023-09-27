
## Instalar pacotes binários

Primeiro é necessário exportar o caminho (``PATH``) para que o comando ``pkg_add `` encontre os pacotes necessário na Internet. Neste caso está sendo utilizada a versão 9.3 do NetBSD no ``PATH``

```console
nbsd# export PKG_PATH="http://cdn.netbsd.org/pub/pkgsrc/packages/NetBSD/amd64/9.3/All/"
```

>> **Atenção** nos testes não funcionou URL do repositório com HTTPS, só o HTTP. Neste caso basta trocar ``https`` para ``http`` na URL. Também é possível utilizar outros meios que não a Internet, tal como CD-ROM, etc.

Após configurar o caminho do repositório na Internet, vamos instalar o programa ``pkgin``, que seria o equivalente a um ``apt-get`` do NetBSD.

```console
nbsd# pkg_add pkgin

pkg_add: Warning: package `pkgin-22.10.0nb1' was built for a platform:
pkg_add: NetBSD/x86_64 9.0 (pkg) vs. NetBSD/x86_64 9.3 (this host)
pkg_add: Warning: package `pkg_install-20211115' was built for a platform:
pkg_add: NetBSD/x86_64 9.0 (pkg) vs. NetBSD/x86_64 9.3 (this host)
pkgin-22.10.0nb1: copying /usr/pkg/share/examples/pkgin/repositories.conf.example to /usr/pkg/etc/pkgin/repositories.conf
```

Com o ``pkgin`` instalado agora é possível utilizá-lo para por exemplo procurar algum pacote, tal como no exemplo a seguir:

```console
nbsd# pkgin search apache
...
apache-2.4.56        Apache HTTP (Web) server, version 2.4
apache-ant-1.10.13nb1  Apache Project's Java-Based make(1) replacement
apache-ant-1.9.13    Java make(1) replacement
apache-ant-1.5.4nb2  "Apache Project's Java-Based make(1) replacement"
apache-cassandra-3.11.2nb3  Highly scalable, distributed structured key-value store
apache-cassandra-2.2.12nb3  Highly scalable, distributed structured key-value store
apache-ivy-2.5.0     "Apache Project's Java-Based agile dependency manager"
apache-maven-3.8.6   Apache Project's software project management and comprehension tool
apache-roller-5.1.2nb1  Full-featured, multi-user and group-blog server
apache-solr-8.11.1   High performance search server built using Lucene Java
apache-tomcat-9.0.62  Implementation of Java Servlet and JavaServer Pages technologies
apache-tomcat-8.5.61  Implementation of Java Servlet and JavaServer Pages technologies
apache-tomcat-8.0.53nb1  Implementation of Java Servlet and JavaServer Pages technologies
apache-tomcat-7.0.106  Implementation of Java Servlet and JavaServer Pages technologies
apache-tomcat-6.0.45nb1  Implementation of Java Servlet and JavaServer Pages technologies
apache-tomcat-5.5.35  The Apache Project's Java Servlet 2.4 and JSP 2.0 server
...
```
>> Partes da saída do comando forma omitidas.

Anterior mente foi pesquisado se há algum pacote com o nome ``apache``, na intenção de instalar o servidor HTTP Apache. Tal busca resulta em vários pacotes. A seguir é utilizado a opção ``install`` para instalar um desses pacotes:

```console
nbsd# pkgin install apache-2.4.56
calculating dependencies...done.

12 packages to install:
  apache-2.4.56 readline-8.2nb1 pcre2-10.42 nghttp2-1.52.0 libxml2-2.10.4 brotli-1.0.9 apr-util-1.6.3 apr-1.7.2 xmlcatmgr-2.2nb1 python310-3.10.10
  libuuid-2.32.1nb1 libffi-3.4.4

0 to refresh, 0 to upgrade, 12 to install
25M to download, 147M to install

proceed ? [Y/n]
```

## Redes

### Configuração de rede volátil

#### IP e Máscara de rede
A configuração de IPs e máscaras de rede no NetBSD pode ser realizada através do comando ``ifconfig``, tal como:

```console
nbsd# ifconfig wm3 10.0.0.2/24
```
Neste caso foi atribuída a placa de rede ``wm3``, o IP/máscara 10.0.0.2/24. A efetividade da configuração pode ser vista com o mesmo comando, tal como:

```console
nbsd# ifconfig wm3
wm3: flags=0x8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
        capabilities=2bf80<TSO4,IP4CSUM_Rx,IP4CSUM_Tx,TCP4CSUM_Rx>
        capabilities=2bf80<TCP4CSUM_Tx,UDP4CSUM_Rx,UDP4CSUM_Tx,TCP6CSUM_Tx>
        capabilities=2bf80<UDP6CSUM_Tx>
        enabled=0
        ec_capabilities=7<VLAN_MTU,VLAN_HWTAGGING,JUMBO_MTU>
        ec_enabled=2<VLAN_HWTAGGING>
        address: 08:00:27:83:88:1e
        media: Ethernet autoselect (none)
        status: no carrier
        inet 10.0.0.2/24 broadcast 10.0.0.255 flags 0x0
        inet6 fe80::a00:27ff:fe83:881e%wm3/64 flags 0x8<DETACHED> scopeid 0x4
```

É possível ver na saída que o IP/máscara foram atribuídas com sucesso (penúltima linha) na placa de rede ``wm3``.

#### Rota padrão

Para adicionar a rota padrão:

```console
nbsd# route add default 192.168.122.1
add net default: gateway 192.168.122.1
```

No exemplo anterior o *gateway* padrão é o IP 192.168.122.1.

Para remover a rota padrão:
```console
nbsd# route delete default
delete net default
```

É possível verificar as rotas através dos comandos:
* ``route -n show ``;
* ``netstat -r -f inet`` - a opção ``-f inet``, apresenta apenas as rotas IPv4, para ver todas é só remover tal opção.

### Configurando rede via arquivos

#### IPs e máscaras de rede
Para configurar a rede via arquivo, de forma que as configurações persistam depois do *boot*, é possível criar/editar o arquivo ``/etc/ifconfig.wm0``, sendo que ``wm0`` deve ser trocado pelo nome da placa de rede a ser configurada. Então neste exemplo a placa de rede chama-se ``wm0``.

> É possível ver as placas de rede através do comando ``ifconfig -a``.

Um exemplo de configuração seria:

```console
nbsd# cat /etc/ifconfig.wm0
#dhcp
inet 192.168.122.10 netmask 255.255.255.0
```

Neste exemplo a placa ``wm0`` receberá o IP 192.168.122.10/24. Note que a configuração via DHCP está desabilitada, para habilitá-la seria necessário descomentar a linha do ``dhcp`` (removendo o ``#``) e inserindo um ``#``, na linha que inicia com ``inet``.

#### Rota Padrão

Para configurar a rota padrão é possível criar/editar o arquivo ``/etc/mygate``, tal como:

```console
nbsd# cat /etc/mygate
192.168.122.1
```

No exemplo anterior, o *gateway* padrão é o *host* 192.168.122.1.

#### Aplicando as configurações de rede

Após alterar IPs, máscaras e *gateway* padrão utilizando os arquivos dos passos anteriores, é possível reiniciar o *host*, ou executar o comando ``/etc/rc.d/network``, para que as configurações sejam aplicadas imediatamente. Exemplo:

```console
nbsd# /etc/rc.d/network restart

Stopping network.
Deleting aliases.
Downing network interfaces: wm0 wm1 wm2.
Starting network.
Hostname: nbsd
IPv6 mode: host
Configuring network interfaces: wm0 wm1 wm2.
Adding interface aliases:.
add net default: gateway 192.168.122.1
Waiting for DAD to complete for statically configured addresses...
```
#### Servidor de nomes

A configuração do servidor de nomes no NetBSD é a mesma utilizada em outros sistemas Unix-Like, exemplo:

```console
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```
Neste caso foi adicionado o servidor 8.8.8.8, como servidor de nomes principal do *host*.

> Não é necessário reiniciar nenhum serviço para que a configuração do DNS passe a valer.


### Verificando conexões de redes

```console
nbsd# sockstat -4ln
USER     COMMAND    PID   FD PROTO  LOCAL ADDRESS         FOREIGN ADDRESS
root     dhcpcd     181   11 udp    *.68                  *.*
root     sshd       340    4 tcp    *.22                  *.*
_httpd   httpd      3822   5 tcp    *.80                  *.*
```

```console
nbsd# netstat -f inet
Active Internet connections
Proto Recv-Q Send-Q  Local Address          Foreign Address        State
tcp        0      0  192.168.56.21.ssh      192.168.56.1.52060     ESTABLISHED
```

```console
nbsd# netstat -f inet -r
Routing tables

Internet:
Destination        Gateway            Flags    Refs      Use    Mtu Interface
default            10.0.2.2           UGS         -        -      -  wm0
10.0.2/24          link#1             UC          -        -      -  wm0
10.0.2.15          link#1             UHl         -        -      -  lo0
127/8              localhost          UGRS        -        -  33624  lo0
localhost          lo0                UHl         -        -  33624  lo0
192.168.56/24      link#2             UC          -        -      -  wm1
192.168.56.21      link#2             UHl         -        -      -  lo0
192.168.56.1       0a:00:27:00:00:00  UHL         -        -      -  wm1
192.168.56.2       08:00:27:1c:1b:63  UHL         -        -      -  wm1
10.0.2.2           52:54:00:12:35:02  UHL         -        -      -  wm0
```

### NAT (mascaramento)

Ative o roteamento:

```console
nbsd# sysctl -w net.inet.ip.forwarding=1
net.inet.ip.forwarding: 0 -> 1
```

Crie/edite o arquivo ``/etc/ipnat.conf``:

```console
nbsd# vi /etc/ipnat.conf
map wm0 0/0 -> 0/32
```
Neste caso estamos pedindo para "mapear"/mascarar, tudo (``0/0``) que for sair pela interface ``wm0``, para o IP que estiver na interface ``wm0``.

> Atenção, este exemplo a interface ``wm0`` é a interface de rede conectada à Internet! Então você tem que ver se o nome da interface no seu cenário de rede é o mesmo...

Iniciar e carregar o NAT:

```console
nbsd# /etc/rc.d/ipnat onestart
Enabling ipfilter for NAT.
Installing NAT rules ... 1 entries flushed from NAT table
```

## Quagga

Instalar o Quagga:
```console
nbsd# pkgin install quagga
```

Configurar o zebra:

```console
nbsd# cat /usr/pkg/etc/zebra/zebra.conf
!
! Zebra configuration saved from vty
!   2023/07/29 12:02:46
!
hostname nbsd-router
password 123mudar
enable password 123mudar
log syslog
!
interface lo0
!
interface wm0
!
interface wm1
 ip address 172.16.0.10/24
!
interface wm2
 ip address 172.16.1.10/24
!
interface wm3
!
ip forwarding
!
!
line vty
!
```
Configurar o OSPF, ou outro similar:

```console
nbsd# cat /usr/pkg/etc/zebra/ospfd.conf
!
! Zebra configuration saved from vty
!   2023/07/29 12:02:46
!
hostname nbsd-router
password 123mudar
enable password 123mudar
log syslog
!
!
!
interface lo0
!
interface wm0
!
interface wm1
!
interface wm2
!
interface wm3
!
router ospf
 ospf router-id 10.10.10.10
 network 172.16.0.0/24 area 0.0.0.0
 network 172.16.1.0/24 area 0.0.0.0
 default-information originate
!
line vty
!
```

Iniciar:

```console
nbsd# mkdir /var/run/zebra
nbsd# chown quagga.quagga /var/run/zebra/
nbsd# /usr/pkg/sbin/zebra -d
nbsd# /usr/pkg/sbin/ospfd  -d
```
> Neste caso sempre que reiniciar a máquina vai ter que criar o diretório e dar esse para o usuário/grupo ``quagga``, então seria bom fazer um *script*. Isso pode ser feito com o arquivo ``/usr/pkg/share/examples/rc.d/zebra``.

O quagga/zebra também pode ser acessado pelo comando:

```console
nbsd# vtysh
```

> Atenção que quando você executa esse comando não muda nada no terminal, então é bom digitar ``help`` para ver se você está no ``vtysh``, ou no terminal normal. Para sair do terminal ``vtysh``, digite o comando ``quit``, os outros comandos são bem similares ao terminal CISCO.

## Referências

### Instalação

* <https://www.unixmen.com/howto-install-pkgin-on-netbsd-6/>

* <https://www.netbsd.org/docs/pkgsrc/using.html>

### Rede

* <https://www.netbsd.org/docs/guide/en/chap-net-practice.html>

* <https://man.netbsd.org/NetBSD-6.0/ifconfig.if.5>

* <https://man.netbsd.org/NetBSD-9.1/sockstat.1>

* <https://man.netbsd.org/NetBSD-9.1/netstat.1>

### Quagga

* <https://wiki.netbsd.org/tutorials/quagga/>

### NAT

* <https://wiki.netbsd.org/nsps/>

* <https://man.netbsd.org/ipnat.conf.5>

* <https://man.netbsd.org/NetBSD-9.3/npf.conf.5>
