---
layout: page
---

# Configuração básica de rede em *hosts* Linux

Uma tarefa muito corriqueira para qualquer administrador de rede é a configuração de *hosts* na rede, de forma que este acesse a rede local e principalmente à Internet.

## O que é necessário configurar para a rede funcionar?

A configuração de um *host* na rede, normalmente se dá por três passos básico, sendo esses:

1. Configuração do **IP e máscara de rede**, isso permite que o *host* acesse a rede local;
2. Configuração da **rota padrão**, que permitirá que o *host* acesse outras redes, tal como a Internet;
3. Configuração do IP do servidor ou **servidores DNS**, essa permite que o *host* acesse *hosts* através de nomes e não endereços IPs - já que é bem mais fácil lembrar de nomes do que IPs.

Com o passo 1, é possível acessar a rede local, com o passo 2 é possível acessar outras redes e com o passo 2 é possível acessar *hosts* utilizando nomes, tal como <www.google.com.br>.

> **Atenção:** O primeiro passo é obrigatório se você quiser acessar a rede local. Já o passo 2 e 3 são opcionais! Executando apenas o passo 1 e passo 2 corretamente, você já pode acessar outras redes, como por exemplo a Internet, mas somente através do uso de endereços IP, o que a maioria das pessoas normalmente não fazem. Assim, é quase obrigatório realizar corretamente também o terceiro passo, para só então as pessoas considerem que o *host* esteja conectado corretamente na rede/Internet.


## Configuração manual ou automática?

Há duas formas de realizar os três passos de configuração de rede citados anteriormente:
1. **Estático**: neste as configurações são feitas manualmente, pelo usuário/administrador do sistema. Então, o usuário/administrador do *host* deve ter um conhecimento prévio da rede, para saber quais endereços utilizar nesta configuração;
2. **Automático**: utilizando esse método o computador será configurado automaticamente por outro computador da rede. Normalmente tal configuração vem via servidor DHCP/BOOTP, pelo roteador da rede ou ponto de acesso sem fio. Neste tipo de configuração o usuário não precisa saber dos endereços de rede, pois isso é feito "magicamente" para ele.

É importante perceber que a maioria dos *hosts* atualmente têm sua configuração de rede feita de forma automática, via DHCP. Entretanto, **bons administradores de rede, devem saber configurar *hosts* manualmente** (não só via DHCP), pois isso pode ser vital durante a resolução de problemas. Além do que, muitos equipamentos quem compõem a infraestrutura das redes são preferencialmente, se não obrigatoriamente configurados com o método manual (devido à questões administrativas, de segurança, etc).

## Configuração permanente ou temporária?

Sistemas UNIX-Like, permitem ainda duas formas de configuração de rede:
1. **Volátil**: nesta, toda configuração feita é perdida se o *host* for reiniciado (ligado/desligado). É uma configuração "temporária", que pode ser mais indicada/utilizada para testes;
2. **Não volátil**: nesta, a configuração persiste mesmo que o *host* seja desligado e religado. Este tipo de configuração é realizado em arquivos que ficam armazenados nos *hosts* da rede.

> A configuração chamada aqui de **não volátil**, também é denominada de estática ou via arquivo, mas ela pode ser utilizada tanto para configurar IPs estáticos, quanto automáticos/dinâmicos. :-p

Atualmente, um problema que existe na configuração **não volátil** em *hosts* Linux, é que cada distribuição Linux pode fazer isso de uma forma diferente da outra e pior, a configuração pode mudar de versão para versão, dentro da mesma distribuição. É claro que essa falta de padronização geralmente causa certa confusão na hora de configurar *hosts* Linux.

Visto as possibilidades de configurações de rede para *hosts* Linux, agora serão apresentados os comandos e arquivos que permitem efetivamente essas configurações.

> **Atenção!!!** todas as tarefas de configuração de rede requer acesso como usuário administrador do *host*, ou seja **root**. Ou é necessário que o usuário comum tenha algum privilégio, o que pode ser obtido com o comando ``sudo``, por exemplo.

### Comando ``ifconfig`` (IP/Máscara)

Tradicionalmente sistemas Like-UNIX utilizam o comando ``ifconfig``, para configurar o endereço IP e máscara de rede de uma dada placa de rede. Os parâmetros e opções mais comuns do comando ``ifconfig`` são:
* ``ifconfig`` - apresenta a configuração de todas as placas de rede ativas do *host*.
* ``ifconfig -a`` - apresenta a configuração de todas as placas de rede do *host*, inclusive as que não estiverem ativas.
* ``ifconfig eth0`` - apresenta a configuração apenas da placa de rede, neste caso foi utilizada como exemplo a ``eth0``, mas pode ser outra placa. A descoberta do nome das placas de rede pode ser feita utilizando o comando ``ifconfig``, sem nenhuma opção ou com ``-a``.
* ``ifconfig eth0 172.16.1.1 netmask 255.255.255.0`` - atribui um IP e máscara de rede à placa de rede. No exemplo é atribuído o IP 172.16.1.1 com máscara classe C à placa ``eth0``. Atenção, se a máscara a ser utilizada tiver a mesma classe do IP, não é necessário incluir ``netmask`` e a máscara, ou seja, o ``ifconfig`` fará isso automaticamente para você.
* ``ifconfig eth0 172.16.1.1/24`` - mesmo que o anterior, mas utilizando notação CIDR. Alguns sistemas não suportam essa forma.
* ``ifconfig eth0 down`` - desliga a placa de rede. Isso pode ser necessário durante alguma tarefa administrativa.
* ``ifconfig eth0 up`` - liga a placa de rede.

Há outras opções e parâmetros possíveis para o ``ifconfig``, mas o básico que queremos por enquanto é isso.

> O comando ``ifconfig`` foi descontinuado no Linux, todavia é muito comum ainda encontrar ele por ai e principalmente sistemas como os BSDs ainda utilizam o ``ifconfig``, por isso é muito importante saber como utilizá-lo.

### Comando ``route`` (Rota)

Depois de configurar o endereço IP é comum adicionar uma rota padrão, para que o *host* consiga acessar outras redes (Internet), isso pode ser feito com o comando ``route``. Para configuração básica de rotas, as opções e parâmetros mais utilizados para o comando ``route`` são:
* ``route`` - apresenta as rotas presente no *host*.
* ``route -n`` - mesmo que o anterior, mas apresenta números e não nomes, ou seja, não tenta converter IPs de *hosts* e nomes, nem dá nome as portas ativas no *host*, isso normalmente dá uma saída mais rápida, já que não é necessário esperar essa conversão de números em nomes.
* ``route add default gw 172.16.1.254`` - adiciona uma rota padrão, neste exemplo o IP do roteador padrão é o 172.16.1.254.
* ``route del default`` - apaga a rota padrão. Caso mais de uma rota padrão esteja presente, é possível complementar o comando informando qual rota será deletada, tal como: ``route del default gw 172.16.1.254``.

O comando ``route``, também permite adicionar rotas para rede (``--net``) e *hosts* (``--host``), mas não abordaremos isso aqui.

> O comando ``route`` foi descontinuado no Linux. Todavia, é muito comum encontrá-lo por ai e assim como o ``ifconfig``, os BSDs ainda utilizam o ``route``.

### Comando ``ip`` (IP, máscara e rota)

Como mencionado anteriormente os comandos ``ifconfig`` e ``route`` foram descontinuados no Linux - mas não nos BSDs. Atualmente o comando padrão para configuração de IP, máscara de rede e rotas no Linux é o comando ``ip``. Então, o ``ip`` substitui os comandos ``ifconfig`` e ``route``, entretanto o ``ip`` não é utilizado para configurar o DNS.

Os principais exemplos de uso de opções e parâmetros utilizados com o comando ``ip``, são:
* ``ip address`` ou ``ip address show`` - apresenta a configuração de todas as placas de rede do *host*.
* ``ip route`` ou ``ip route show`` - apresenta as rotas presente no *host*. Neste também é possível utilizar a opção ``-N``, para mostrar número ao invés de nomes, tal como: ``ip -N route``.
* ``ip address add 172.16.1.1/24 dev eth0`` - atribui um IP e máscara de rede à placa de rede. No exemplo é atribuído o IP 172.16.1.1 com máscara classe C à placa ``eth0``.
* ``ip address show dev eth0`` - apresenta a configuração apenas da placa de rede, neste caso foi utilizada como exemplo a ``eth0``, mas pode ser outra placa.
* ``ip address del 172.16.1.1/24 dev eth0`` - Apaga um IP que foi atribuído a uma dada placa de rede. No exemplo foi deletado o IP 172.16.1.1/24 que havia sido atribuído à placa de rede ``eth0``. **Atenção**, o comando ``ip`` não substitui os IPs atribuídos previamente à uma placa de rede (que era o comportamento do ``ifconfig``). Então, se você atribuir um IP e depois o outro, vão ficar os dois IPs atribuídos naquela placa de rede, por isso é importante a opção ``del``, assim é possível remover um IP indesejado/incorreto. Exemplo: ``ip a a 172.16.1.1/24 dev eth0; ip a a 192.168.1.2/24 dev eth0; ip a a 172.16.1.2/24 dev eth0;``, o *host* onde foram executados esses comando, terá três IPs: 172.16.1.1, 172.16.1.2 e 192.168.1.2, para evitar isso utilize o ``del`` (utilizar vários IPs em uma placa de rede não é comum).
* ``ip route add default via 172.16.1.254`` - adiciona uma rota padrão, neste exemplo o IP do roteador padrão é o 172.16.1.254.
* ``ip route del default``

### Arquivo de configuração ``/etc/resolv.conf`` (DNS)

Por fim, para que o *host* consiga acessar a rede da forma que se espera, principalmente a Internet, é necessário informar ao *host* qual é o IP do servidor de nomes (DNS), que vai ser utilizado. Tal tarefa é realizada através do arquivo ``/etc/resolv.conf``, para isso basta editar esse arquivo e incluir dentre dele, principalmente a opção ``nameserver`` seguida do IP do servidor DNS, tal como:

* ``echo nameserver 8.8.8.8 > /etc/resolv.conf`` - informa para o *host* utilizar como servidor de nomes o Google (8.8.8.8). Tal comando sobrescreve o conteúdo do arquivo ``/etc/resolv.conf``.
* ``echo nameserver 172.16.1.254 >> /etc/resolv.conf`` - mesmo que o anterior, mas não sobrescreve o arquivo, mas sim adiciona o conteúdo no final do arquivo. Note que com esse comando apenas, não é possível saber quem é o servidor DNS primário, já que a principio não sabemos o que há no arquivo anteriormente. Assim, é bem comum realizar a primeira opção de configuração apresentada aqui, e depois essa, assim o servidor primário seria o 8.8.8.8 e o secundário o 172.16.1.254.

> Há outras configurações/opções possíveis para o arquivo ``/etc/resolv.conf``, mas não vamos abordá-las aqui.

Também é possível editar esse arquivo utilizando um editor como o ``vi`` ou o ``nano``.

> Atenção, todos os sistemas operacionais like-UNIX utilizam o mesmo arquivo/método para configurar o servidor DNS, isso é padrão!



A seguir, são apresentadas algumas possibilidades de configurações voláteis e não voláteis para *hosts* Linux. Isso será feito com utilizando-se como exemplo o cenário de rede da Figura X a seguir:

| ![rede](img/cenarioRede.png) |
|:--:|
| Figura 1 - Cenário de rede |

# ifconfig/route

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

```console
root@Host-1:/# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.0.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
```

```console
root@Host-1:/# route add default gw 10.0.0.254
root@Host-1:/# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.0.0.254      0.0.0.0         UG    0      0        0 eth0
10.0.0.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
```

```console
root@Host-1:/# ping 10.0.0.254
PING 10.0.0.254 (10.0.0.254) 56(84) bytes of data.
64 bytes from 10.0.0.254: icmp_seq=1 ttl=64 time=0.567 ms
64 bytes from 10.0.0.254: icmp_seq=2 ttl=64 time=0.370 ms
^C
--- 10.0.0.254 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1017ms
rtt min/avg/max/mdev = 0.370/0.468/0.567/0.098 ms
root@Host-1:/# ping www.google.com.br
ping: www.google.com.br: Temporary failure in name resolution
root@Host-1:/# echo "nameserver 8.8.8.8" > /etc/resolv.conf
root@Host-1:/# ping www.google.com.br
PING www.google.com.br (142.250.219.195) 56(84) bytes of data.
64 bytes from gru06s64-in-f3.1e100.net (142.250.219.195): icmp_seq=1 ttl=117 time=14.5 ms
64 bytes from gru06s64-in-f3.1e100.net (142.250.219.195): icmp_seq=2 ttl=117 time=17.2 ms
^C
--- www.google.com.br ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 14.457/15.812/17.167/1.355 ms
```

```console
root@Host-1:/# ifconfig eth0
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.0.1  netmask 255.255.255.0  broadcast 10.0.0.255
        inet6 fe80::e09c:58ff:fe14:c687  prefixlen 64  scopeid 0x20<link>
        ether e2:9c:58:14:c6:87  txqueuelen 1000  (Ethernet)
        RX packets 20  bytes 1592 (1.5 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 10  bytes 796 (796.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

```console
root@Host-1:/# ifconfig eth0 down
root@Host-1:/# ifconfig
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

```console
root@Host-1:/# ifconfig -a
eth0: flags=4098<BROADCAST,MULTICAST>  mtu 1500
        inet 10.0.0.1  netmask 255.255.255.0  broadcast 10.0.0.255
        ether e2:9c:58:14:c6:87  txqueuelen 1000  (Ethernet)
        RX packets 20  bytes 1592 (1.5 KB)
        RX errors 0  dropped 2  overruns 0  frame 0
        TX packets 10  bytes 796 (796.0 B)
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

```console
root@Host-1:/# ifconfig eth0 10.0.0.1 netmask 255.255.255.0 broadcast 10.0.0.255 up
root@Host-1:/# ifconfig eth0
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.0.1  netmask 255.255.255.0  broadcast 10.0.0.255
        inet6 fe80::e09c:58ff:fe14:c687  prefixlen 64  scopeid 0x20<link>
        ether e2:9c:58:14:c6:87  txqueuelen 1000  (Ethernet)
        RX packets 20  bytes 1592 (1.5 KB)
        RX errors 0  dropped 2  overruns 0  frame 0
        TX packets 16  bytes 1312 (1.3 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

```console
root@Host-1:/# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.0.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
```

```console
root@Host-1:/# route add default gw 10.0.0.254
root@Host-1:/# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.0.0.254      0.0.0.0         UG    0      0        0 eth0
10.0.0.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
```


# ip

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

```console
root@Host-2:/# ip route show
10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.2
```

```console
root@Host-2:/# ip route add default via 10.0.0.254

root@Host-2:/# ip route show
default via 10.0.0.254 dev eth0
10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.2
```

```console
root@Host-2:/# ip route del default
root@Host-2:/# ip route
10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.2
```

```console
root@Host-2:/# ip address add 172.16.2.1/24 dev eth0

root@Host-2:/# ip address show dev eth0
14: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 1000
    link/ether 3a:7b:6e:85:16:c8 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.2/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet 172.16.2.1/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::387b:6eff:fe85:16c8/64 scope link
       valid_lft forever preferred_lft forever
```
```console
root@Host-2:/# ip address show dev eth0
14: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 1000
    link/ether 3a:7b:6e:85:16:c8 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.2/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::387b:6eff:fe85:16c8/64 scope link
       valid_lft forever preferred_lft forever
```

```console
root@Host-2:/# ip address del 172.16.2.1/24 dev eth0
root@Host-2:/# ip address show dev eth0
14: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 1000
    link/ether 3a:7b:6e:85:16:c8 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.2/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::387b:6eff:fe85:16c8/64 scope link
       valid_lft forever preferred_lft forever
```

```console
root@Host-2:/# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
14: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 3a:7b:6e:85:16:c8 brd ff:ff:ff:ff:ff:ff
```

```console
root@Host-2:/# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
14: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN mode DEFAULT group default qlen 1000
    link/ether 3a:7b:6e:85:16:c8 brd ff:ff:ff:ff:ff:ff
```

```console
root@Host-2:/# ip link set dev eth0 up
root@Host-2:/# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
14: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 3a:7b:6e:85:16:c8 brd ff:ff:ff:ff:ff:ff
root@Host-2:/# ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
14: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 1000
    link/ether 3a:7b:6e:85:16:c8 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.2/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::387b:6eff:fe85:16c8/64 scope link
    valid_lft forever preferred_lft forever
```

```console
root@Host-2:/# ping 10.0.0.254
PING 10.0.0.254 (10.0.0.254) 56(84) bytes of data.
64 bytes from 10.0.0.254: icmp_seq=1 ttl=64 time=0.292 ms
64 bytes from 10.0.0.254: icmp_seq=2 ttl=64 time=0.317 ms
^C
--- 10.0.0.254 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1014ms
rtt min/avg/max/mdev = 0.292/0.304/0.317/0.012 ms
root@Host-2:/# ping 192.168.122.1
ping: connect: Network is unreachable
root@Host-2:/# route add default gw 10.0.0.254
root@Host-2:/# ping 192.168.122.1
PING 192.168.122.1 (192.168.122.1) 56(84) bytes of data.
64 bytes from 192.168.122.1: icmp_seq=1 ttl=63 time=0.543 ms
64 bytes from 192.168.122.1: icmp_seq=2 ttl=63 time=0.643 ms
^C
--- 192.168.122.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1022ms
rtt min/avg/max/mdev = 0.543/0.593/0.643/0.050 ms
root@Host-2:/# ping www.google.com.br
ping: www.google.com.br: Temporary failure in name resolution
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

## dhcp

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

```console
root@Host-3:/# dhcpcd -k eth0
sending signal ALRM to pid 114
waiting for pid 114 to exit
root@Host-3:/# ifconfig eth0
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::8ce0:e3ff:fe4b:23da  prefixlen 64  scopeid 0x20<link>
        ether 8e:e0:e3:4b:23:da  txqueuelen 1000  (Ethernet)
        RX packets 697  bytes 52142 (52.1 KB)
        RX errors 0  dropped 5  overruns 0  frame 0
        TX packets 28  bytes 2869 (2.8 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@Host-3:/# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
root@Host-3:/# cat /etc/resolv.conf

root@Host-3:/#
```


```console
root@LinuxRouter-1:/# ifconfig eth0 10.0.0.254/24
root@LinuxRouter-1:/# ip address add 192.168.122.254/24 dev eth1
root@LinuxRouter-1:/# ip route add default via 192.168.122.1
root@LinuxRouter-1:/# echo "nameserver 8.8.8.8" > /etc/resolv.conf
root@LinuxRouter-1:/# echo 1 > /proc/sys/net/ipv4/ip_forward
root@LinuxRouter-1:/# iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

```

# Referências

* <https://tldp.org/HOWTO/Linux+IPv6-HOWTO/ch05s02.html>
