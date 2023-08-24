# Configuração básica de roteadores Juniper


# Acessando o sistema

Inicialmente ele vai pedir um login, tal login é ``root`` e não há senha. Depois é só acessar o terminal cliente, com o comando ``cli`` e ai, por exemplo é possível acessar a configuração, tal como no exemplo a seguir:

```console
juniper (ttyd0)

login: root
Password:

--- JUNOS 14.1R1.10 built 2014-06-07 09:37:07 UTC

root@juniper%
root@juniper% cli
root@juniper>
```

Provavelmente o sistema vai pedir para você setar a senha do sistema (mudar a senha padrão) isso é feito na configuração com o comando:

```console
root@juniper> configure
Entering configuration mode

[edit]
root@juniper# set system root-authentication plain-text-password
New password:
Retype new password:

[edit]
root@juniper# commit
commit complete

[edit]
```
>> para sair de um ambiente, tal como da configuração é possível utilizar o ``exit`` ou o ``quit``, sendo que o último leva ao ´ultimo nível.

## Configurando IP estático em uma interface

```console
root@juniper> configure
Entering configuration mode

[edit]
root@juniper# set interfaces em2 unit 0 family inet address 10.0.0.1/24

[edit]
root@juniper# set interfaces em3 unit 0 family inet address 192.168.122.100/24

[edit]
root@juniper# set interfaces em4 unit 0 family inet address 10.1.0.1/24

[edit]
root@juniper# commit
commit complete

[edit]
root@juniper#
```

## Configurando rota padrão

```console
root> configure
Entering configuration mode

[edit]
root# set routing-options static route 0.0.0.0/0 next-hop 192.168.122.1

[edit]
root# commit
commit complete

[edit]
```

## Apresentando configurações de interfaces de roteadores

```console
root> show interfaces terse
Interface               Admin Link Proto    Local                 Remote
lc-0/0/0                up    up
lc-0/0/0.32769          up    up   vpls
pfe-0/0/0               up    up
pfe-0/0/0.16383         up    up   inet
                                   inet6
pfh-0/0/0               up    up
pfh-0/0/0.16383         up    up   inet
cbp0                    up    up
demux0                  up    up
dsc                     up    up
em2                     up    up
em2.0                   up    up   inet     10.0.0.1/24
em3                     up    up
em3.0                   up    up   inet     192.168.122.1/24
em4                     up    up
em4.0                   up    up   inet     10.1.0.1/24
em5                     up    down
fxp0                    up    down
gre                     up    up
ipip                    up    up
irb                     up    up
lo0                     up    up
lo0.16384               up    up   inet     127.0.0.1           --> 0/0
lo0.16385               up    up   inet     128.0.0.4           --> 0/0
                                   inet6    fe80::e58:250f:fc1d:0
lo0.32768               up    up
lsi                     up    up
mtun                    up    up
pimd                    up    up
pime                    up    up
pip0                    up    up
pp0                     up    up
tap                     up    up
vtep                    up    up
```

## Apresentando informações de rotas


```console
root@juniper> show route

inet.0: 7 destinations, 7 routes (7 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

0.0.0.0/0          *[Static/5] 00:01:40
                    > to 192.168.122.1 via em3.0
10.0.0.0/24        *[Direct/0] 00:11:51
                    > via em2.0
10.0.0.1/32        *[Local/0] 00:11:51
                      Local via em2.0
10.1.0.0/24        *[Direct/0] 00:11:49
                    > via em4.0
10.1.0.1/32        *[Local/0] 00:11:49
                      Local via em4.0
192.168.122.0/24   *[Direct/0] 00:02:07
                    > via em3.0
192.168.122.100/32 *[Local/0] 00:02:07
                      Local via em3.0

root@juniper>
```

## Configurando OSPF

```console
root@juniper> configure
Entering configuration mode

[edit]
root@juniper# set protocols ospf area 0.0.0.0 interface em2

[edit]
root@juniper# set protocols ospf area 0.0.0.0 interface em4

[edit]

root@juniper# commit
commit complete

[edit]
root@juniper# exit
Exiting configuration mode

root@juniper> show ospf neighbor
Address          Interface              State     ID               Pri  Dead
10.1.0.3         em4.0                  ExStart   3.3.3.3            1    38
```

* <https://www.letsconfig.com/how-to-configure-ospf-on-juniper/>

## Resetando configurações do roteador
```console
root@juniper> configure
Entering configuration mode
The configuration has been changed but not committed

[edit]
root@juniper# load factory-default
warning: activating factory configuration

[edit]
root@juniper# edit system
[edit system]
root@juniper# set root-authentication plain-text-password
New password:
Retype new password:

[edit system]
root@juniper# commit
commit complete

[edit system]
root@juniper# quit
Exiting configuration mode
```

* <https://www.juniper.net/documentation/us/en/software/junos/cli/topics/topic-map/junos-factory-default.html>

# OSPF entre roteadores Juniper e Cisco (problema)

Durante a interligação entre roteadores Juniper e CISCO, ou entre roteadores de fabricantes diversos, pode ocorrer das interfaces de rede que interligam os roteadores serem configuradas

```console
*Aug 24 21:06:46.435: OSPF: Killing nbr 10.2.0.11 on GigabitEthernet1/0 due to excessive (25) retransmissions
*Aug 24 21:06:46.435: OSPF: 10.2.0.11 address 10.8.0.11 on GigabitEthernet1/0 is dead, state DOWN
*Aug 24 21:06:46.435: %OSPF-5-ADJCHG: Process 1, Nbr 10.2.0.11 on GigabitEthernet1/0 from EXSTART to DOWN, Neighbor Down: Too many retransmissions
```

```console
R1#debug ip ospf adj
OSPF adjacency events debugging is on
R1#
*Aug 24 21:06:36.667: OSPF: Send DBD to 10.2.0.11 on GigabitEthernet1/0 seq 0x1BAA opt 0x52 flag 0x7 len 32
*Aug 24 21:06:36.667: OSPF: Retransmitting DBD to 10.2.0.11 on GigabitEthernet1/0 [24]
*Aug 24 21:06:36.671: OSPF: Rcv DBD from 10.2.0.11 on GigabitEthernet1/0 seq 0x1BAA opt 0x52 flag 0x0 len 92  mtu 1986 state EXSTART
*Aug 24 21:06:36.671: OSPF: Nbr 10.2.0.11 has larger interface MTU
R1#
*Aug 24 21:06:41.579: OSPF: Send DBD to 10.2.0.11 on GigabitEthernet1/0 seq 0x1BAA opt 0x52 flag 0x7 len 32
*Aug 24 21:06:41.579: OSPF: Retransmitting DBD to 10.2.0.11 on GigabitEthernet1/0 [25]
*Aug 24 21:06:41.587: OSPF: Rcv DBD from 10.2.0.11 on GigabitEthernet1/0 seq 0x1BAA opt 0x52 flag 0x0 len 92  mtu 1986 state EXSTART
*Aug 24 21:06:41.587: OSPF: Nbr 10.2.0.11 has larger interface MTU
R1#
*Aug 24 21:06:46.435: OSPF: Killing nbr 10.2.0.11 on GigabitEthernet1/0 due to excessive (25) retransmissions
*Aug 24 21:06:46.435: OSPF: 10.2.0.11 address 10.8.0.11 on GigabitEthernet1/0 is dead, state DOWN
*Aug 24 21:06:46.435: %OSPF-5-ADJCHG: Process 1, Nbr 10.2.0.11 on GigabitEthernet1/0 from EXSTART to DOWN, Neighbor Down: Too many retransmissions
R1#
*Aug 24 21:06:46.435: OSPF: GigabitEthernet1/0 Nbr 10.2.0.11: Clean-up dbase exchange
*Aug 24 21:06:46.435: OSPF: Neighbor change Event on interface GigabitEthernet1/0
*Aug 24 21:06:46.435: OSPF: DR/BDR election on GigabitEthernet1/0
*Aug 24 21:06:46.435: OSPF: Elect BDR 13.13.13.13
*Aug 24 21:06:46.435: OSPF: Elect DR 13.13.13.13
*Aug 24 21:06:46.435: OSPF: Elect BDR 0.0.0.0
*Aug 24 21:06:46.435: OSPF: Elect DR 13.13.13.13
*Aug 24 21:06:46.435:        DR: 13.13.13.13 (Id)   BDR: none
*Aug 24 21:06:46.435: OSPF: Reset GigabitEthernet1/0 flush timer
*Aug 24 21:06:46.435: OSPF: Remember old DR 10.2.0.11 (id)
R1#
*Aug 24 21:06:46.935: OSPF: No full nbrs to build Net Lsa for interface GigabitEthernet1/0
*Aug 24 21:06:46.935: OSPF: Reset old DR on GigabitEthernet1/0
R1#
*Aug 24 21:06:49.651: OSPF: OSPF: Nbr 10.2.0.11 10.8.0.11 GigabitEthernet1/0 is currently ignored
```

```console
R1(config)#interface g1/0
R1(config-if)#ip mtu 1500
R1(config-if)#
```

```console
R1(config)#interface g1/0
R1(config-if)#ip ospf mtu-ignore
```

Juniper:
```console
root@j11# set interfaces em4 mtu 1500

[edit]
root@j11# commit
```
* <https://www.cisco.com/c/en/us/support/docs/ip/open-shortest-path-first-ospf/119384-technote-ospf-00.html>
* <https://www.cisco.com/c/en/us/support/docs/ip/open-shortest-path-first-ospf/119433-technote-ospf-00.html>
* <https://www.cisco.com/c/en/us/support/docs/ip/open-shortest-path-first-ospf/116119-technote-ospf-mtu-00.html>







