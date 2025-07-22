---
layout: page
---

Este material mostrará a configuração básica de uma rede com dois roteadores Mikrotik. Sendo esses os ``router-MTk-1`` e ``router-MTk-2`` da f

| ![rede](imagens/rede.png) |
|:--:|
| Figura 1 - Cenário de rede do Exemplo de configuração com Mikrotik

# Configuração do ``router-MTk-1``

Dado que esse roteador não possuía configuração prévia (exemplo, recém tirado da caixa - ou seja, novo) o Mikrotik inicia questionando um usuário e senha padrão, neste caso é o usuário ``admin`` com a senha em branco (sem senha), tal como:

```console
MikroTik 7.17.1 (stable)
   MikroTik Login: admin                                                                                                                                                                         Password:
```

Após isso ele questiona se o administrador que ver a licença, vamos dizer que não (``N``):


```console
  MMM      MMM       KKK                          TTTTTTTTTTT      KKK
  MMMM    MMMM       KKK                          TTTTTTTTTTT      KKK
  MMM MMMM MMM  III  KKK  KKK  RRRRRR     OOOOOO      TTT     III  KKK  KKK
  MMM  MM  MMM  III  KKKKK     RRR  RRR  OOO  OOO     TTT     III  KKKKK
  MMM      MMM  III  KKK KKK   RRRRRR    OOO  OOO     TTT     III  KKK KKK
  MMM      MMM  III  KKK  KKK  RRR  RRR   OOOOOO      TTT     III  KKK  KKK

  MikroTik RouterOS 7.17.1 (c) 1999-2025       https://www.mikrotik.com/



Do you want to see the software license? [Y/n]:
```

Então o roteador questiona a respeito da nova senha. Após inserir a nova senha duas vezes (para confirmação), um *prompt* de comando será apresentado, tal como:

```console
Press F1 for help

2025-07-21 17:18:42 system,error,critical login failure for user admin via local

Change your password
new password> ********
repeat new password> ********

Password changed
[admin@MikroTik] > 
```

Os passos apresentados anteriormente é realizado apenas na primeira configuração do MikroTik ou caso as configurações sejam reinicializadas.

> Ńeste modelo de roteador é possível reiniciar a configuração com os comandos: ``/system reset-configuration``, ou ``/system reset-configuration no-defaults=no skip-backup=yes``, sendo que o segundo apaga os arquivos de backup também (todos arquivos).


## Configuração das placas de rede ``ether2`` e ``ether3``

A configuração das placas de rede ``ether2`` e ``ether3`` é apenas a configuração tradicional, configurando IP e máscara, sendo:

```console
[admin@MikroTik] > ip address add address=172.16.0.102/24 interface=ether2
[admin@MikroTik] > ip address add address=172.16.1.102/24 interface=ether3
```

Os comandos anteriores atribuíram os IPs 172.16.0.102 para a interface ``ether2`` e 172.16.1.0.102 para a interface de rede ``ether3``, tal como indica os IPs da Figura 1.

## Configuração de placa de rede em VLAN

A interface de rede ``ether1`` do ``router-MTk-1`` está conectada a duas VLANs, sendo uma a VLAN 30 e a outra a VLAN40, que são respectivamente as LAN3 e LAN4.

Essas VLANs estão devidamente configuradas no ``cisco-sw2``, sendo que:

* Porta f0/1 - está na VLAN 30;
* Porta f0/2 - está na VLAN 40;
* Porta f0/0 - é uma porta *trunk* que envia quadros de rede das VLANS 30 e 40 para o roteador ``router-MTk-1``.

Então ``router-MTk-1``, dada que a configuração do *switch* já está pronta, agora basta configurar o roteador MikroTik da seguinte forma:

1. Primeiro iniciamos criando essa relação das VLANs com a placa de rede ``ether1``:

```console
[admin@MikroTik] > interface/ vlan add interface=ether1 name=vlan30 vlan-id=30
[admin@MikroTik] > interface/ vlan add interface=ether1 name=vlan40 vlan-id=40
```

2. Depois é só atribuir os IPs as interfaces de rede da VLAN correta:

```console
[admin@MikroTik] > ip address add address=192.168.3.102/24 interface=vlan30
[admin@MikroTik] > ip address add address=192.168.4.102/24 interface=vlan40
```

A configuração de rede (IP e máscara) deste roteador está pronta, é possível ver tal configuração da seguinte forma:

* No caso dos IPs e máscaras isso pode ser feito com o comando ``ip address print``:
```console
[admin@MikroTik] > /ip address/ print 
Columns: ADDRESS, NETWORK, INTERFACE
# ADDRESS           NETWORK      INTERFACE
0 172.16.0.102/24   172.16.0.0   ether2   
1 172.16.1.102/24   172.16.1.0   ether3   
2 192.168.3.102/24  192.168.3.0  vlan30   
3 192.168.4.102/24  192.168.4.0  vlan40   
```

* Já para ver as configurações das VLANs:
```console
[admin@MikroTik] > /interface/ vlan/ print 
Flags: R - RUNNING
Columns: NAME, MTU, ARP, VLAN-ID, INTERFACE
#   NAME     MTU  ARP      VLAN-ID  INTERFACE
0 R vlan30  1500  enabled       30  ether1   
1 R vlan40  1500  enabled       40  ether1
```

Também é possível "pingar" o Host-3 e Host-4, se eles já estiverem configurados e ativos na rede, tal como:

```console
[admin@MikroTik] > ping 192.168.3.1
  SEQ HOST                                     SIZE TTL TIME       STATUS                                                                                                                   
    0 192.168.3.1                                56  64 818us     
    1 192.168.3.1                                56  64 1ms14us   
    2 192.168.3.1                                56  64 1ms244us  
    sent=3 received=3 packet-loss=0% min-rtt=818us avg-rtt=1ms25us max-rtt=1ms244us 

[admin@MikroTik] > ping 192.168.4.1 
  SEQ HOST                                     SIZE TTL TIME       STATUS                                                                                                                   
    0 192.168.4.1                                56  64 745us     
    1 192.168.4.1                                56  64 501us     
    2 192.168.4.1                                56  64 1ms259us  
    sent=3 received=3 packet-loss=0% min-rtt=501us avg-rtt=835us max-rtt=1ms259us
```

> Para cancelar o ``ping`` pressione ``Ctrl+C``.

## Configuração do OSPF

Nesta rede de exemplo (ver Figura 1), está sendo utilizado o protocolo OSPF para compartilhar/propagar as rotas dentre os roteadores do cenário. Assim, para realizar tal configuração no MikroTik, basta executar os seguintes comandos:

```console
[admin@MikroTik] > routing ospf instance add name=ospf1 router-id=102.0.0.2                                     
[admin@MikroTik] > routing ospf area add instance=ospf1 name=backbone            
[admin@MikroTik] > routing ospf interface-template add area=backbone networks=192.168.3.0/24            
[admin@MikroTik] > routing ospf interface-template add area=backbone networks=192.168.4.0/24 
[admin@MikroTik] > routing ospf interface-template add area=backbone networks=172.16.0.0/24 
[admin@MikroTik] > routing ospf interface-template add area=backbone networks=172.16.1.0/24 
```

No exemplo anteiro iniciá-se criando uma instância de um processo OSPF chamado ``ospf1``, também o roteador foi identificado na rede OSPF como ``102.0.0.2`` - é um endereço tal como IPv4 (mas não é um IP) utilizado para identificar unicamente o roteador OSPF na rede. O segundo comando cria uma área para a instância ``ospf1``, sendo essa a área 0 (ou 0.0.0.0), que neste caso é identificada pelo MikroTik com o nome ``backbone``. Por fim, são adicionadas às redes: 192.168.3.0/24, 192.168.4.0/24, 10.16.0.0/14 e 10.16.0.0/14, para serem publicadas pelo rotador aos outros roteadores da rede através da área 0/``backbone``.


Feito isso e com os outros roteadores já em funcionamento é possível verificar as rotas obtidas via comando:

```
[admin@MikroTik] > ip route print 
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT, o - OSPF; + - ECMP
Columns: DST-ADDRESS, GATEWAY, DISTANCE
     DST-ADDRESS     GATEWAY              DISTANCE
DAo  0.0.0.0/0       172.16.1.103%ether3       110
DAo  10.1.0.0/24     172.16.0.101%ether2       110
DAo  10.2.0.0/24     172.16.0.101%ether2       110
DAc  172.16.0.0/24   ether2                      0
DAc  172.16.1.0/24   ether3                      0
DAo+ 172.16.2.0/24   172.16.1.103%ether3       110
DAo+ 172.16.2.0/24   172.16.0.101%ether2       110
DAc  192.168.3.0/24  vlan30                      0
DAc  192.168.4.0/24  vlan40                      0
```

Note que pela legenda do comando, que as rotas OSPF são identificadas peplo ``o`` na primeira coluna. Tal como: ``DAo  10.1.0.0/24     172.16.0.101%ether2       110``, sendo que ``DAo``, indica em ordem que é uma rota dinâmica, ativa e obtida via OSPF (ver legenda da saída anterior).

> Neste comando já temos todos os roteadores ativos, mas pela sequência desse texto, não haveria talvez as rotas do ``router-MTk-2``, que ainda não foi configurado no papel.


Também é possível verificar a configuração OSPF e o status da conexão entre os roteadores vizinhos com os seguintes comandos:

* Ver as instâncias OSPF no MikroTik:

```console
[admin@MikroTik] > /routing/ ospf/ instance/ print           
Flags: X - disabled, I - inactive 
 0   name="ospf1" version=2 vrf=main router-id=102.0.0.2
```

* Ver as áreas OSPF:

```console
[admin@MikroTik] > /routing/ ospf/ area print                
Flags: X - disabled, I - inactive, D - dynamic; T - transit-capable 
 0    name="backbone" instance=ospf1 area-id=0.0.0.0 type=default
```

* Ver redes que devem ser propagadas via OSPF pelo roteador:

```console
[admin@MikroTik] > /routing/ ospf/ interface-template/ print 
Flags: X - disabled, I - inactive 
 0   area=backbone instance-id=0 networks=192.168.3.0/24 type=broadcast 
     retransmit-interval=5s transmit-delay=1s hello-interval=10s dead-interval=40s 
     priority=128 cost=1 

 1   area=backbone instance-id=0 networks=192.168.4.0/24 type=broadcast 
     retransmit-interval=5s transmit-delay=1s hello-interval=10s dead-interval=40s 
     priority=128 cost=1 

 2   area=backbone instance-id=0 networks=172.16.0.0/24 type=broadcast 
     retransmit-interval=5s transmit-delay=1s hello-interval=10s dead-interval=40s 
     priority=128 cost=1 

 3   area=backbone instance-id=0 networks=172.16.1.0/24 type=broadcast 
     retransmit-interval=5s transmit-delay=1s hello-interval=10s dead-interval=40s 
     priority=128 cost=1 
```

* Verificar os roteadores OSPF vizinhos:

```console
[admin@MikroTik] > /routing/ ospf/ neighbor/ print           
Flags: V - virtual; D - dynamic 
 0  D instance=ospf1 area=backbone address=172.16.0.101 priority=1 router-id=101.0.0.0 
      dr=172.16.0.102 bdr=172.16.0.101 state="Full" state-changes=7 adjacency=34s 
      timeout=36s 

 1  D instance=ospf1 area=backbone address=172.16.1.103 priority=128 router-id=103.0.0.0 
      dr=172.16.1.103 bdr=172.16.1.102 state="Full" state-changes=6 adjacency=16m34s 
      timeout=32s 
```

## Configuração completa to ``router-MTk-1``

A configuração completa do ``router-MTk-1`` é apresentada através do comando ``/export`` e apresentada a seguir:

```console
# 2025-07-21 17:14:33 by RouterOS 7.17.1
# system id = SgoERsT1erM
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
set [ find default-name=ether6 ] disable-running-check=no
set [ find default-name=ether7 ] disable-running-check=no
set [ find default-name=ether8 ] disable-running-check=no
/interface vlan
add interface=ether1 name=vlan30 vlan-id=30
add interface=ether1 name=vlan40 vlan-id=40
/port
set 0 name=serial0
/routing ospf instance
add disabled=no name=ospf1 originate-default=always router-id=102.0.0.2
/routing ospf area
add disabled=no instance=ospf1 name=backbone
/ip address
add address=172.16.0.102/24 interface=ether2 network=172.16.0.0
add address=172.16.1.102/24 interface=ether3 network=172.16.1.0
add address=192.168.3.102/24 interface=vlan30 network=192.168.3.0
add address=192.168.4.102/24 interface=vlan40 network=192.168.4.0
/ip dhcp-client
add interface=ether1
/routing ospf interface-template
add area=backbone disabled=no networks=192.168.3.0/24
add area=backbone disabled=no networks=192.168.4.0/24
add area=backbone disabled=no networks=172.16.0.0/4
add area=backbone disabled=no networks=172.16.1.0/4
/system note
set show-at-login=no
```

# Configuração do ``router-MTk-2``

Esse roteador é idêntico ao configurado anteriormente, com a diferença de não estar conectados a nenhuma VLAN.

## Configuração das interfaces de rede

A configuração das placas de rede do ``router-MTk-2`` são tais como a do roteadores anterior. Os comandos necessários são apresentados a seguir:

```console
ip address add address=172.16.1.103/24 interface=ether1
ip address add address=172.16.2.103/24 interface=ether2
ip dhcp-client add interface=ether3
```

A única diferença da configuração do ``router-MTk-2`` em relação ao ``router-MTk-1``, fora as VLANs, é que foi ativado a obtenção de configuração de rede via DHCP na interface de rede ``ether3``, isso permite a configuração automática do: IP, máscara de rede, rota padrão e DNS.

> Na verdade neste caso nem é necessário o comando ``ip dhcp-client add..`` isso já fica habilitado por padrão no MikroTik. Então em alguns casos o que seria necessário desativar e não ativar a obtenção de IPs via DHCP.


## Habilitando NAT (máscaramento)

No cenário de rede da Figura 1, o ``router-MTk-2`` é o roteador que dá acesso à Internet, pois temos a Internet conectada à interface de rede ``ether3``. Desta forma, para que os outros hosts da rede tenham acesso a Internet, será necessário neste caso configurar um NAT, para que ao sair dessa rede que estamos configurando, que os outros hosts desta rede recebam como IP de origem o IP que está na interface de rede ``ether3``. 

> Note que isso é necessário pois o cenário de rede que estamos utilizando utiliza IPs privados e também que a estrutura de rede que está dentro da rede que simboliza a Internet não tem conhecimento das redes/rotas que estamos criando.

Para realizar um SNAT no MikroTik é necessário o seguinte comando:

```console
ip firewall nat add action=masquerade chain=srcnat out-interface=ether3
```

O comando anterior basicamente adiciona uma regra de NAT dizendo que tudo que sair pela interface de rede ``ether3`` deve ser mascarado (ter o endereço IP de origem alterado).

## Configuração do OSPF

A configuração do OSPF no ``router-MTk-2`` segue a mesma lógica da configuração OSPF do ``router-MTk-1``. Todavia com a diferença de também publicar a rota padrão (0.0.0.0/0), já que este já o roteador padrão de toda a rede OSPF em questão. 

```console
routing ospf instance add name=ospf1 originate-default=always router-id=103.0.0.0
routing ospf area add instance=ospf1 name=backbone
routing ospf interface-template add area=backbone networks=172.16.1.0/24
routing ospf interface-template add area=backbone networks=172.16.2.0/24
```

Assim, os comandos anteriores fazem em ordem:

* Cria uma instância e essa diz que deve compartilhar a rota padrão (``originate-default=always``);
* Cria a área ``backbone``;
* Adiciona as redes à serem publicadas: 172.16.1.0/24, 172.16.2.0/24.

Feito isso toda a rede deve estar conectada e já com acesso a Internet.

É possível ver a relação entre os vizinhos OSPF, tal como:

```console
[admin@MikroTik] > /routing/ ospf/ neighbor/ print 
Flags: V - virtual; D - dynamic 
 0  D instance=ospf1 area=backbone address=172.16.2.101 priority=1 router-id=101.0.0.0 
      dr=172.16.2.101 bdr=172.16.2.103 state="Full" state-changes=6 adjacency=12m25s 
      timeout=36s 

 1  D instance=ospf1 area=backbone address=172.16.1.102 priority=128 router-id=102.0.0.2 
      dr=172.16.1.103 bdr=172.16.1.102 state="Full" state-changes=5 adjacency=11m40s 
      timeout=36s 
```

Bem como a tabela de roteamento com as rotas OSPF obtidas:

```console
[admin@MikroTik] > /ip/ route/ print
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT, o - OSPF, d - DHCP; + - ECMP
Columns: DST-ADDRESS, GATEWAY, DISTANCE
     DST-ADDRESS     GATEWAY              DISTANCE
DAd  0.0.0.0/0       192.168.1.1                 1
DAo  10.1.0.0/24     172.16.2.101%ether2       110
DAo  10.2.0.0/24     172.16.2.101%ether2       110
DAo+ 172.16.0.0/24   172.16.1.102%ether1       110
DAo+ 172.16.0.0/24   172.16.2.101%ether2       110
DAc  172.16.1.0/24   ether1                      0
DAc  172.16.2.0/24   ether2                      0
DAc  192.168.1.0/24  ether3                      0
DAo  192.168.3.0/24  172.16.1.102%ether1       110
DAo  192.168.4.0/24  172.16.1.102%ether1       110
```

## Configuração completa do ``router-MTk-2``

A configuração completa do ``router-MTk-2`` é apresentada através a seguir:

```console
[admin@MikroTik] > /export 
# 2025-07-22 14:04:05 by RouterOS 7.17.1
# system id = SXGpSZcujKJ
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
set [ find default-name=ether6 ] disable-running-check=no
set [ find default-name=ether7 ] disable-running-check=no
set [ find default-name=ether8 ] disable-running-check=no
/port
set 0 name=serial0
/routing ospf instance
add disabled=no name=ospf1 originate-default=always router-id=103.0.0.0
/routing ospf area
add disabled=no instance=ospf1 name=backbone
/ip address
add address=172.16.2.103/24 interface=ether2 network=172.16.2.0
add address=172.16.1.103/24 interface=ether1 network=172.16.1.0
/ip dhcp-client
add interface=ether1
add interface=ether3
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether3
/routing ospf interface-template
add area=backbone disabled=no networks=172.16.2.0/24
add area=backbone disabled=no networks=172.16.1.0/24
/system note
set show-at-login=no
```

## Arquivos de configuração dos outros hosts

Os outros *hosts* do cenário da Figura 1 não são MikroTik, então não é intenção deste material detalhar tal configuração.

* Hosts Linux:
  * [Host-1](Host-1.txt);
  * [Host-2](Host-2.txt);
  * [Host-3](Host-3.txt);
  * [Host-4](Host-4.txt);
* Switches CISCO:
  * [cisco-sw1](cisco-sw1.txt);
  * [cisco-sw2](cisco-sw2.txt);
* Router CISCO:
  * [R1](R1.txt);
