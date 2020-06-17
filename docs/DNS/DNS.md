---
layout: page
---

DNS - Domain Name System
========================

>**UTFPR - Universidade Tecnológica Federal do Paraná, campus Campo Mourão**  
>Autor: **Prof. Dr. Luiz Arthur Feitosa dos Santos**  
>E-mail: **<luizsantos@utfpr.edu.br>**  

-----------------------

## Introdução

## BIND no OpenBSD

### Instalação do BIND

O primeiro passo normalmente é procurar o pacote BIND que vai ser instalado. No OpenBSD isso pode ser feito com o comando ``pkg_info -Q <nome_programa>``, tal como no exemplo a seguir:

```console
openbsd# pkg_info -Q bind
isc-bind-9.11.13v0
isc-bind-9.11.13v0-geoip
isc-bind-9.11.13v0-no_ssl
isc-bind-9.11.14p0v0
isc-bind-9.11.14p0v0-geoip
isc-bind-9.11.14p0v0-no_ssl
isc-bind-9.11.14v0
isc-bind-9.11.14v0-geoip
isc-bind-9.11.14v0-no_ssl
```

Seguindo a saída do comando anterior, vamos instalar,  por exemplo o ``isc-bind-9.11.14v0``. Para isso é necessário executar o comando ``pkg_add``, tal como o exemplo a seguir:
```console
openbsd# pkg_add isc-bind-9.11.14v0     
quirks-3.182 signed on 2019-12-25T20:47:50Z
isc-bind-9.11.14v0:json-c-0.13.1: ok
isc-bind-9.11.14v0:libiconv-1.16p0: ok
isc-bind-9.11.14v0:libunistring-0.9.7: ok
isc-bind-9.11.14v0:libidn2-2.3.0: ok
isc-bind-9.11.14v0:xz-5.2.4: ok
isc-bind-9.11.14v0:libxml-2.9.9: ok
isc-bind-9.11.14v0: ok
Running tags: ok
The following new rcscripts were installed: /etc/rc.d/isc_named
See rcctl(8) for details.
```
Após a instalação, é possível verificar se o servidor DNS BIND está em execução. 

### Verificando o estado do serviço

Após instalar ou realizar alguma alteração no servidor é sempre bom conferir se esse está funcionando corretamento (ativo na rede). No OpenBSD há várias formas de se fazer isso, sendo duas:

* A primeira forma e a mais clássica, é com o comando ``netstat -a -n -p udp``. Neste caso as opções ``-a`` é para mostrar todas as conexões, ``-n`` para mostrar números de não nomes e ``-p udp`` já que o DNS/BIND é executado utilizando o protocolo UDP.
```console
openbsd# netstat -a -n -p udp
Active Internet connections (including servers)
Proto   Recv-Q Send-Q  Local Address          Foreign Address        (state)
udp          0      0  10.0.2.15.29903        201.49.148.135.123    
udp          0      0  10.0.2.15.39674        162.159.200.1.123     
udp          0      0  10.0.2.15.19339        200.160.0.8.123       
udp          0      0  10.0.2.15.32843        52.67.171.238.123     
udp          0      0  10.0.2.15.3947         200.192.232.8.123     
udp          0      0  *.*                    *.*                   
udp          0      0  *.*                    *.*                   
udp          0      0  *.*                    *.*                   
udp          0      0  192.168.56.111.53      *.*                   
udp          0      0  10.0.2.15.53           *.*                   
udp          0      0  127.0.0.1.53           *.*                   
udp          0      0  *.*                    *.*                   
Active Internet connections (including servers)
Proto   Recv-Q Send-Q  Local Address          Foreign Address        (state)
udp6         0      0  *.*                    *.*                   
udp6         0      0  *.*                    *.*                   
udp6         0      0  fe80::1%lo0.53         *.*                   
udp6         0      0  ::1.53                 *.* 
```

* A segunda forma é com o comando ``fstat``, fazendo uso da opção ``-n`` para mostrar número ao invés de nomes. Para melhorar a saída também foi utilizado o comando ``grep udp``, que apresenta apenas as linhas que contém a palavra ``udp``. A diferença do ``fstat`` em relação ao ``netstat`` no OpenBSD, é que o ``fstat`` mostra o processo associado ao protocolo/porta de rede. Exemplo:
```console
openbsd# fstat -n | grep udp 
_bind    named      55537  512* internet6 dgram udp [::1]:53
_bind    named      55537  513* internet6 dgram udp [fe80::1%lo0]:53
_bind    named      55537  514* internet dgram udp 127.0.0.1:53
_bind    named      55537  515* internet dgram udp 10.0.2.15:53
_bind    named      55537  516* internet dgram udp 192.168.56.111:53
_ntp     ntpd       20075    6* internet dgram udp 10.0.2.15:39674 <-> 162.159.200.1:123
_ntp     ntpd       20075    7* internet dgram udp 10.0.2.15:19339 <-> 200.160.0.8:123
_ntp     ntpd       20075    8* internet dgram udp 10.0.2.15:3947 <-> 200.192.232.8:123
_ntp     ntpd       20075    9* internet dgram udp 10.0.2.15:29903 <-> 201.49.148.135:123
_ntp     ntpd       20075   10* internet dgram udp 10.0.2.15:32843 <-> 52.67.171.238:123
root     dhclient   17467    3* internet dgram udp *:0
root     dhclient   17467    5* internet dgram udp *:0
root     dhclient   17738    3* internet dgram udp *:0
root     dhclient   17738    5* internet dgram udp *:0
_slaacd  slaacd     78386    4* internet6 dgram udp *:0
root     slaacd     86655    7* internet6 dgram udp *:0
```
Tanto na saída do ``netstat``, quanto na do ``fstat`` é possível notar que há  porta UDP/53 aberta, e principalmente com o ``fstat`` dá para notar que o processo associado a esta porta é o ``named``, que é justamente o processo do BIND.

### Iniciando/parando e reiniciando o serviço

No OpenBSD é possível executar o _script_ ``/etc/rc.d/isc_named``, com as opções ``start|stop|restart``.

```console
openbsd# /etc/rc.d/isc_named  start|stop|restart
```

Por exemplo, para iniciar o BIND, execute: 
```console
openbsd# /etc/rc.d/isc_named  start
```

### Configurando o BIND

O arquivo de configuração principal do BIND no OpenBSD é o ``/var/named/etc/named.conf``. Antes de alterá-lo é uma boa prática fazer uma cópia de segurança, caso algo dê errado será possível volta o original. Isso pode ser feito com o comando:
```console
openbsd# cp /var/named/etc/named.conf   /var/named/etc/named.conf.def
```

#### Criando as zonas no servidor

Para criar as zonas à serem mantidas no servidor DNS, é necessário editar o arquivo ``/var/named/etc/named.conf`` e incluir no final do arquivo as seguintes linhas (exemplo):

```console
openbsd# vi /var/named/etc/named.conf
...
zone "redes2.comp" {
type master;
file "master/db.redes2.comp";
};

zone "56.168.192.in-addr.arpa" {
type master;
file "master/db.56.168.192";
};

```

Após configurar o arquivo ``named.conf`` é recomendável verificar se ele está correto utilizando o comando ``named-checkconf``.

```console
openbsd# named-checkconf /var/named/etc/named.conf 
``` 

Se nada for retornado pelo comando o arquivo de configuração está com a sintaxe correta. Caso contrário há algo de errado (sintaxe/opções), neste caso volte no arquivo e verifique o que há de errado.

Exemplo, na saída a seguir o ``named-checkconf`` reporta que falta um ``;`` no final da linha 80 do  arquivo ``/var/named/etc/named.conf ``:

```console
openbsd# named-checkconf /var/named/etc/named.conf 
/var/named/etc/named.conf:80: missing ';' before 'file'
```

##### Criando o arquivo de zona

Para iniciar a criação/configuração do arquivo de zona, vamos pegar um modelo de exemplo - para não iniciar o arquivo do zero (em branco). Para isso vamos copiar o arquivo de zona do _localhost_. Exemplo:

```console
openbsd# cp /var/named/standard/localhost /var/named/master/db.redes2.comp 
```

Agora vamos editar o arquivo para deixá-lo da seguinte forma:
```console
openbsd# vi /var/named/master/db.redes2.comp

$TTL 6h

@       IN      SOA     vm.redes2.comp. nobody.vm.redes2.comp. (
1       ; serial
1h      ; refresh
30m     ; retry 
7d      ; expiration
1h )    ; minimum

NS      vm.redes2.comp.

vm.redes2.comp.         IN      A       192.168.56.111
real.redes2.comp.       IN      A       192.168.56.1
```

Após a edição do arquivo de zone vamos usar o comando ``named-checkzone`` para verificar se não há nada errado com a configuração:

```console
openbsd# named-checkzone redes2.comp /var/named/master/db.redes2.comp  
zone redes2.comp/IN: loaded serial 1
OK
```

##### Criando o arquivo de zona reversa

Da mesma fora que criamos o arquivo de zona do domínio, vamos criar o arquivo de zona reversa. Lembrando que o arquivo de zona rever faz o contrário do arquivo de zona, ou seja, dado o IP devolve o nome do _host_.

Vamos iniciar copiando um arquivo de exemplo, para depois alterá-lo, exemplo:

```console
openbsd# cp /var/named/master/db.redes2.comp  /var/named/master/db.56.168.192
```

Depois disso é só editá-lo para ficar com o seguinte conteúdo:

```console
openbsd# cat /var/named/master/db.56.168.192                                               
$TTL 6h

@       IN      SOA     vm.redes2.comp. nobody.vm.redes2.comp. (
1       ; serial
1h      ; refresh
30m     ; retry
7d      ; expiration
1h )    ; minimum

NS      vm.redes2.comp.

111     IN      PTR     vm.redes2.comp.
1       IN      PTR     real.redes.comp.
```

Também é possível verificar se a configuração do arquivo de zona está correta com o comando ``named-checkzone``. Exemplo:

```console
openbsd# named-checkzone 56.168.192.in-addr.arpa /var/named/master/db.56.168.192  
zone 56.168.192.in-addr.arpa/IN: loaded serial 1
OK
```

Após isso basta reiniciar o servidor DNS. Exemplo:

```console
openbsd# /etc/rc.d/isc_named restart                                                       
isc_named(ok)
isc_named(ok)
```

### Testando o servidor DNS

Para testar o próprio servidor, altere o arquivo ``/etc/resolv.conf`` para este apontar para o próprio servidor. Isso pode ser feito com o comando:

```console
openbsd# echo "nameserver 127.0.0.1" > /etc/resolv.conf 
```

Após isso há várias formas de testar a configuração, exemplos:

* Comando ``ping``

```console
openbsd# ping vm.redes2.comp
PING vm.redes2.comp (192.168.56.111): 56 data bytes
64 bytes from 192.168.56.111: icmp_seq=0 ttl=255 time=0.070 ms
64 bytes from 192.168.56.111: icmp_seq=1 ttl=255 time=0.066 ms
^C
--- vm.redes2.comp ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/std-dev = 0.066/0.068/0.070/0.002 ms
```

```console
openbsd# ping real.redes2.comp
PING real.redes2.comp (192.168.56.1): 56 data bytes
64 bytes from 192.168.56.1: icmp_seq=0 ttl=64 time=0.220 ms
64 bytes from 192.168.56.1: icmp_seq=1 ttl=64 time=0.310 ms
^C
--- real.redes2.comp ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/std-dev = 0.220/0.265/0.310/0.045 ms
```

* Comando ``nslookup``
```console
openbsd# nslookup vm.redes2.comp                        
Server:         127.0.0.1
Address:        127.0.0.1#53

Name:   vm.redes2.comp
Address: 192.168.56.111
```

```console
openbsd# nslookup 192.168.56.1                                                             
Server:         127.0.0.1
Address:        127.0.0.1#53

1.56.168.192.in-addr.arpa       name = real.redes.comp.
```
* Comando ``dig``

```console
openbsd# dig redes2.comp

; <<>> DiG 9.4.2-P2 <<>> redes2.comp
;; global options:  printcmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 40077
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 0

;; QUESTION SECTION:
;redes2.comp.                   IN      A

;; AUTHORITY SECTION:
redes2.comp.            3600    IN      SOA     vm.redes2.comp. nobody.vm.redes2.comp. 1 3600 1800 604800 3600

;; Query time: 1 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Thu Dec 26 14:43:55 2019
;; MSG SIZE  rcvd: 75
```
```console
openbsd# dig vm.redes2.comp

; <<>> DiG 9.4.2-P2 <<>> vm.redes2.comp
;; global options:  printcmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 4562
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 0

;; QUESTION SECTION:
;vm.redes2.comp.                        IN      A

;; ANSWER SECTION:
vm.redes2.comp.         21600   IN      A       192.168.56.111

;; AUTHORITY SECTION:
redes2.comp.            21600   IN      NS      vm.redes2.comp.

;; Query time: 1 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Thu Dec 26 14:44:08 2019
;; MSG SIZE  rcvd: 62

```

## Referências
* <http://www.kernel-panic.it/openbsd/dns/dns4.html>
* <https://www.openbsd.org/faq/index.html>

