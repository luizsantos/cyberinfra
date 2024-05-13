---
layout: page
---

# Configuração do Exemplo 3

A seguir são apresentadas as configurações de IPs nas interfaces do roteadores CISCO do cenário do Exemplo 3 a respeito de BGP.

Também são apresentadas as configurações OSPF nos roteadores R9, R10 e R11.

> Atenção: realize tais configurações com extremo cuidado, caso contrário o cenário de rede não vai funcionar ou apresentará erros inesperados! :-p

## Configuração de IPs em R1

```configure
R1#configure terminal
R1(config)#interface f0/0
R1(config-if)#ip address 10.2.0.101 255.255.255.0
R1(config-if)#no shutdown
R1(config-if)#interface g1/0
R1(config-if)#ip address 10.1.100.101 255.255.255.0
R1(config-if)#no shutdown
R1(config-if)#interface g2/0
R1(config-if)#ip address 10.1.103.101 255.255.255.0
R1(config-if)#no shutdown
```

## Configuração de IPs em R2

```configure
R2#configure terminal
R2(config)#interface f0/0
R2(config-if)#ip address 10.1.3.102 255.255.255.0
R2(config-if)#no shutdown
R2(config-if)#interface g1/0
R2(config-if)#ip address 10.1.4.102 255.255.255.0
R2(config-if)#no shutdown
R2(config-if)#interface g2/0
R2(config-if)#ip address 192.168.0.102 255.255.255.0
R2(config-if)#no shutdown
R2(config-if)#interface g3/0
R2(config-if)#ip address 10.1.100.102 255.255.255.0
R2(config-if)#no shutdown
R2(config-if)#interface g4/0
R2(config-if)#ip address 10.1.101.102 255.255.255.0
R2(config-if)#no shutdown
```


## Configuração de IPs em R3

```configure
R3#configure terminal
R3(config)#interface f0/0
R3(config-if)#ip address 10.1.1.103 255.255.255.0
R3(config-if)#no shutdown
R3(config-if)#interface g1/0
R3(config-if)#ip address 10.1.2.103 255.255.255.0
R3(config-if)#no shutdown
R3(config-if)#interface g2/0
R3(config-if)#ip address 10.1.102.103 255.255.255.0
R3(config-if)#no shutdown
R3(config-if)#interface g3/0
R3(config-if)#ip address 10.1.103.103 255.255.255.0
R3(config-if)#no shutdown
R3(config-if)#interface g4/0
R3(config-if)#ip address 172.16.0.103 255.255.255.0
R3(config-if)#no shutdown
```

## Configuração de IPs em R4

```configure
R4#configure terminal
R4(config)#interface g1/0
R4(config-if)#ip address 10.1.101.104 255.255.255.0
R4(config-if)#no shutdown
R4(config-if)#interface g2/0
R4(config-if)#ip address 10.1.102.104 255.255.255.0
R4(config-if)#no shutdown
```

## Configuração de IPs em R5

```configure
R5#configure terminal
R5(config)#interface f0/0
R5(config-if)#ip address 10.2.5.105 255.255.255.0
R5(config-if)#no shutdown
R5(config-if)#interface g1/0
R5(config-if)#ip address 10.2.6.105 255.255.255.0
R5(config-if)#no shutdown
R5(config-if)#interface g2/0
R5(config-if)#ip address 10.2.0.105 255.255.255.0
R5(config-if)#no shutdown
```
## Configuração de IPs em R6

```configure
R6#configure terminal
R6(config)#int f0/0
R6(config-if)#ip address 172.16.2.106 255.255.255.0
R6(config-if)#no shutdown
R6(config-if)#int g1/0
R6(config-if)#ip address 172.16.1.106 255.255.255.0
R6(config-if)#no shutdown
R6(config-if)#int g2/0
R6(config-if)#ip address 172.16.0.106 255.255.255.0
R6(config-if)#no shutdown
```

## Configuração de IPs em R7

```configure
R7#configure terminal
R7(config)#interface f0/0
R7(config-if)#ip address 172.16.7.107 255.255.255.0
R7(config-if)#no shutdown
R7(config-if)#interface g1/0
R7(config-if)#ip address 172.16.8.107 255.255.255.0
R7(config-if)#no shutdown
R7(config-if)#interface g2/0
R7(config-if)#ip address 172.16.2.107 255.255.255.0
R7(config-if)#no shutdown
R7(config-if)#interface g3/0
R7(config-if)#ip address 172.16.3.107 255.255.255.0
R7(config-if)#no shutdown
R7(config-if)#end
```

## Configuração de IPs em R8

```configure
R8#configure terminal
R8(config)#interface f0/0
R8(config-if)#ip address 172.16.9.108 255.255.255.0
R8(config-if)#no shutdown
R8(config-if)#interface g1/0
R8(config-if)#ip address 172.16.3.108 255.255.255.0
R8(config-if)#no shutdown
R8(config-if)#interface g2/0
R8(config-if)#ip address 172.16.1.108 255.255.255.0
R8(config-if)#no shutdown
```

## Configuração de IPs e OSPF em R9

```configure
R9#configure terminal
R9(config)#int f0/0
R9(config-if)#ip address 192.168.0.109 255.255.255.0
R9(config-if)#no shutdown
R9(config-if)#int g1/0
R9(config-if)#ip address 192.168.1.109 255.255.255.0
R9(config-if)#no shutdown
R9(config-if)#int g2/0
R9(config-if)#ip address 192.168.2.109 255.255.255.0
R9(config-if)#no shutdown
R9(config-if)#exit

R9(config)#router ospf 1
R9(config-router)#network 192.168.0.0 0.0.0.255 area 0
R9(config-router)#network 192.168.1.0 0.0.0.255 area 0
R9(config-router)#network 192.168.2.0 0.0.0.255 area 0
R9(config-router)#passive-interface f0/0
```

## Configuração de IPs OSPF em R10

```configure
R10(config)#interface f0/0
R10(config-if)#ip address 192.168.10.110 255.255.255.0
R10(config-if)#no shutdown
R10(config-if)#interface g1/0
R10(config-if)#ip address 192.168.3.110 255.255.255.0
R10(config-if)#no shutdown
R10(config-if)#interface g1/0
R10(config-if)#ip address 192.168.1.110 255.255.255.0
R10(config-if)#no shutdown
R10(config-if)#interface g2/0
R10(config-if)#ip address 192.168.3.110 255.255.255.0
R10(config-if)#no shutdown
R10(config-if)#end

R10#configure terminal
R10(config)#router ospf 1
R10(config-router)#network 192.168.1.0 0.0.0.255 area 0
R10(config-router)#network 192.168.10.0 0.0.0.255 area 0
R10(config-router)#network 192.168.3.0 0.0.0.255 area 0
```

## Configuração de IPs e OSPF em R11

```configure
R11#configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
R11(config)#interface f0/0
R11(config-if)#ip address 192.168.11.111 255.255.255.0
R11(config-if)#no shutdown
R11(config-if)#interface g1/0
R11(config-if)#ip address 192.168.12.111 255.255.255.0
R11(config-if)#no shutdown
R11(config-if)#interface g2/0
R11(config-if)#ip address 192.168.2.111 255.255.255.0
R11(config-if)#no shutdown
R11(config-if)#interface g3/0
R11(config-if)#ip address 192.168.3.111 255.255.255.0
R11(config-if)#no shutdown
R11(config-if)#exit

R11(config)#router ospf 1
R11(config-router)#network 192.168.3.0 0.0.0.255 area 0
R11(config-router)#network 192.168.2.0 0.0.0.255 area 0
R11(config-router)#network 192.168.11.0 0.0.0.255 area 0
R11(config-router)#network 192.168.12.0 0.0.0.255 area 0
```

