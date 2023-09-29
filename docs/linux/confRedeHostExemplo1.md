---
layout: page
---

## Exemplo prático

A seguir, são apresentadas algumas possibilidades de configurações voláteis e não voláteis para *hosts* Linux. Isso será feito com utilizando-se como exemplo o cenário de rede da Figura 1:

| ![rede](/docs/linux/img/cenarioRede.png) |
|:--:|
| Figura 1 - Cenário de rede |



## Configurando o Host-1 utilizando ifconfig/route {#host1}

Iniciamos verificando a configuração de rede do Host-1, com o comando ``ifconfig``:

```console
root@Host-1:/# ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::e09c:58ff:fe14:c687  prefixlen 64  scopeid 0x20<link>
        ether e2:9c:58:14:c6:87  txqueuelen 1000  (Ethernet)
        RX packets 16  bytes 1312 (1.3 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 8  bytes 656 (656.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

No comando anterior, observa-se que não há configurações de endereço IPv4 (``inet``).

Na sequência foi atribuído o endereço 10.0.0.1/24 à interface ``eth0``:

```console
root@Host-1:/# ifconfig eth0 10.0.0.1/24

root@Host-1:/# ifconfig eth0
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.0.1  netmask 255.255.255.0  broadcast 10.0.0.255
        inet6 fe80::e09c:58ff:fe14:c687  prefixlen 64  scopeid 0x20<link>
        ether e2:9c:58:14:c6:87  txqueuelen 1000  (Ethernet)
        RX packets 112  bytes 8338 (8.3 KB)
        RX errors 0  dropped 2  overruns 0  frame 0
        TX packets 60  bytes 4452 (4.4 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
Quando se atribui um IP a uma placa de rede, aparece automaticamente uma rota para a rede do IP atribuído. Isso pode ser visto com o comando ``route`` a seguir:

```console
root@Host-1:/# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.0.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
```
Da forma que está este *host* consegue acessar a rede local, mas não outras redes. O uso do comando ``ping`` a seguir mostra que é possível acessar o host 10.0.0.254, que está na rede local, mas não o IP do Google (8.8.8.8), que está em outra rede:

```console
root@Host-1:/# ping 10.0.0.254 -c 2
PING 10.0.0.254 (10.0.0.254) 56(84) bytes of data.
64 bytes from 10.0.0.254: icmp_seq=1 ttl=64 time=0.194 ms
64 bytes from 10.0.0.254: icmp_seq=2 ttl=64 time=0.241 ms

--- 10.0.0.254 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1020ms
rtt min/avg/max/mdev = 0.194/0.217/0.241/0.023 ms
root@Host-1:/# ping 8.8.8.8 -c 2
ping: connect: Network is unreachable
```

Então, agora, para acessar outras redes é necessário configurar a rota padrão, tal como:

```console
root@Host-1:/# route add default gw 10.0.0.254

root@Host-1:/# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.0.0.254      0.0.0.0         UG    0      0        0 eth0
10.0.0.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
```

A saída do comando ``route -n``, apresentada anteriormente, mostra que agora há duas rotas, sendo uma a rota padrão.

Bem, agora já acessamos a Internet, mas não por nomes, veja a saída do comando ``ping`` a seguir:

```console
root@Host-1:/# ping 8.8.8.8 -c 2
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=16.0 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=117 time=16.0 ms

--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 15.985/15.995/16.006/0.010 ms
root@Host-1:/# ping www.google.com.br
ping: www.google.com.br: Temporary failure in name resolution
```
A saída anterior, mostra que é possível acessar o 8.8.8.8, mas não o www.google.com.br. Neste caso, isso provavelmente significa que não há um IP de servidor DNS configurado cliente (o problema poderia ser outro). Isso é resolvido editando-se o arquivo ``/etc/resolv.conf``, veja:

```console
root@Host-1:/# echo "nameserver 1.1.1.1" > /etc/resolv.conf

root@Host-1:/# ping www.google.com.br -c 2
PING www.google.com.br (142.250.218.67) 56(84) bytes of data.
64 bytes from gru06s61-in-f3.1e100.net (142.250.218.67): icmp_seq=1 ttl=117 time=15.2 ms
64 bytes from gru06s61-in-f3.1e100.net (142.250.218.67): icmp_seq=2 ttl=117 time=14.0 ms

--- www.google.com.br ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 13.963/14.578/15.193/0.615 ms
```
Na saída anterior, o *host* é configurado para utilizar o 1.1.1.1 como servidor DNS e logo na sequência, já é possível "pingar" o www.google.com.br.

Assim, com esses passos temos o Host-1, configurado e acessando a rede via comandos ``ifconfig``, ``route`` e ``/etc/resolv.conf``.

Note que é extremamente importante saber utilizar o comando ``ping``, para analisar possíveis problemas na rede, tal como problemas de configurações básicas de IP, máscara, rota padrão e DNS. Também, é muito importante saber analisar as saída obtidas nos comandos ``ifconfig``, ``route``, ``ip`` e do arquivo ``/etc/resolv.conf``, para ver se há algo de errado na configuração. Atenção, não vamos nos aprofundar nisso neste texto, mas faremos isso durante nossas as aulas de redes!

## Configurando o Host-2 utilizando o comando ``ip`` {#host2}

Vamos iniciar vendo as configurações atuais do *host*:

```console
root@Host-2:/# ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
14: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 1000
    link/ether 3a:7b:6e:85:16:c8 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::387b:6eff:fe85:16c8/64 scope link
       valid_lft forever preferred_lft forever
```

Como não há IP configurado, vamos fazer isso:

```console
root@Host-2:/# ip address add 10.0.0.2/24 dev eth0
root@Host-2:/# ip address show dev eth0
14: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 1000
    link/ether 3a:7b:6e:85:16:c8 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.2/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::387b:6eff:fe85:16c8/64 scope link
       valid_lft forever preferred_lft forever
```
Neste caso foi adicionado o IP 10.0.0.2/24 à interface eth0, depois verificou-se se tal configuração foi aplicada na interface.

Agora, para o *host* conseguir acessar outras redes será configurada a rota padrão, via host 10.0.0.254:

```console
root@Host-2:/# ip route add default via 10.0.0.254

root@Host-2:/# ip route show
default via 10.0.0.254 dev eth0
10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.2
```
A saída anterior, mostra que a rota padrão está presente no *host* depois do comando ``ip route add default via 10.0.0.254``.

Por fim basta, configurar o IP do servidor de nomes e testar com um ``ping`` para um *host* da Internet, veja:

```console
root@Host-2:/# echo "nameserver 8.8.8.8" > /etc/resolv.conf
root@Host-2:/# ping www.google.com.br
PING www.google.com.br (142.250.219.195) 56(84) bytes of data.
64 bytes from gru06s64-in-f3.1e100.net (142.250.219.195): icmp_seq=1 ttl=117 time=15.4 ms
64 bytes from gru06s64-in-f3.1e100.net (142.250.219.195): icmp_seq=2 ttl=117 time=17.8 ms
^C
--- www.google.com.br ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 15.354/16.563/17.772/1.209 ms
```

## Configurando o Host-3 utilizando dhcpd ``ip`` {#host3}

O Host-3 será configurado via DHCP, pois no cenário de rede há um servidor DHCP dentro da nuvem da Internet (tal host não aparece no cenário, está estondido). Assim, o Host-3 e o LinuxRouter-1 (na interface ``eth1``), podem receber configuração automática. Todavia, note, que Host-1 e Host-2, não podem receber configuração via DHCP, pois o servidor DHCP está em outro enlace de rede (LAN2), e a princípio pacotes DHCP não passam de uma rede para outra.

Assim, para a configuração automática do Host-3, vamos iniciar verificando que após o *boot* do *host* esta inicialmente não possui nenhuma configuração de rede. Isso será feito com os comandos ``ifconfig`` e ``route``, tal como é apresentado a seguir:

```console
root@Host-3:/# ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::8ce0:e3ff:fe4b:23da  prefixlen 64  scopeid 0x20<link>
        ether 8e:e0:e3:4b:23:da  txqueuelen 1000  (Ethernet)
        RX packets 613  bytes 45704 (45.7 KB)
        RX errors 0  dropped 5  overruns 0  frame 0
        TX packets 13  bytes 1006 (1.0 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@Host-3:/# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
root@Host-3:/# cat /etc/resolv.conf
root@Host-3:/#
```

Agora, para que o Host-3 obtenha automaticamente suas configurações de rede, vamos executar o comando ``dhcpcd``, veja a saída deste comando:

```console
root@Host-3:/# dhcpcd eth0
DUID 00:04:4c:4c:45:44:00:36:32:10:80:34:b3:c0:4f:35:34:32
eth0: IAID e3:4b:23:da
eth0: soliciting a DHCP lease
eth0: soliciting an IPv6 router
eth0: offered 192.168.122.205 from 192.168.122.1
eth0: probing address 192.168.122.205/24
eth0: leased 192.168.122.205 for 3600 seconds
eth0: adding route to 192.168.122.0/24
eth0: adding default route via 192.168.122.1
forked to background, child pid 114
```

A saída do comando ``dhcpcd`` apresentada anteriormente, já apresenta algumas informações que foram obtidas do servidor DHCP. Por exemplo, o endereço oferecido, a principio foi o 172.168.122.205/24 e o roteador padrão é o 192.168.122.1. Isso pode ser constatado com os comandos ``ifconfig`` e ``route``, ver a seguir:

```console
root@Host-3:/# ifconfig eth0
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.122.205  netmask 255.255.255.0  broadcast 192.168.122.255
        inet6 fe80::8ce0:e3ff:fe4b:23da  prefixlen 64  scopeid 0x20<link>
        ether 8e:e0:e3:4b:23:da  txqueuelen 1000  (Ethernet)
        RX packets 673  bytes 50676 (50.6 KB)
        RX errors 0  dropped 5  overruns 0  frame 0
        TX packets 27  bytes 2527 (2.5 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@Host-3:/# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.122.1   0.0.0.0         UG    213    0        0 eth0
192.168.122.0   0.0.0.0         255.255.255.0   U     213    0        0 eth0
root@Host-3:/# cat /etc/resolv.conf
# Generated by resolvconf
nameserver 192.168.122.1
```
O saída anterior, mostra todas as configurações, inclusive que o servidor DNS utilizado é o 192.168.122.1. Assim, vamos testar a conectividade da rede com a Internet, fazendo um ``ping`` em www.google.com.br.

```console
root@Host-3:/# ping www.google.com.br
PING www.google.com.br (142.250.219.35) 56(84) bytes of data.
64 bytes from gru14s28-in-f3.1e100.net (142.250.219.35): icmp_seq=1 ttl=118 time=13.9 ms
64 bytes from gru14s28-in-f3.1e100.net (142.250.219.35): icmp_seq=2 ttl=118 time=14.7 ms
^C
--- www.google.com.br ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 13.918/14.306/14.695/0.388 ms
```
Como a saída do comando ``ping`` executada anteriormente foi realizada com sucesso, podemos presumir que a rede foi configurada corretamente pelo servidor DHCP.

## Configurando o Host-4 {#host4}

```console
# Static config for eth0
auto eth0
iface eth0 inet static
	address 10.0.0.3
	netmask 255.255.255.0
	gateway 10.0.0.254
	up echo nameserver 8.8.8.8 > /etc/resolv.conf
```

## Configurando o Host-5 {#host5}

```console
# DHCP config for eth0
auto eth0
iface eth0 inet dhcp
	hostname Host-5
```

## Configurando o LinuxRouter-1 {#LinuxRouter-1}

Para este *host*, que é um roteador, temos que configurar os IPs e máscara de duas interfaces de rede, bem como configurar a rota padrão, que neste caso é o roteador 192.168.122.1 (que está escondido na nuvem). Isso foi feito utilizando os comandos ``ip`` e ``ifconfig``, só para título de ilustração. Também foi configurado o servidor DNS, para ser o 8.8.8.8. Ver comandos a seguir:

```console
root@LinuxRouter-1:/# ifconfig eth0 10.0.0.254/24
root@LinuxRouter-1:/# ip address add 192.168.122.254/24 dev eth1
root@LinuxRouter-1:/# ip route add default via 192.168.122.1
root@LinuxRouter-1:/# echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

Não faz parte do escopo desta explicação, mas para o cenário de rede funcionar, também foi ativado o roteamento e foi habilitado o NAT, de forma que todos pacotes que saem da LAN1, para LAN2/Internet recebam o IP que está na interface ``eth1`` do LinuxRouter-1. Tais comandos forma:

```console
root@LinuxRouter-1:/# echo 1 > /proc/sys/net/ipv4/ip_forward
root@LinuxRouter-1:/# iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
```

Assim, o cenário de rede está completo! ;-)
