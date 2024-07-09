---
layout: page
---

Segue a configuração dos IPs na placas de rede dos roteadores CISCO do exemplo:

> Note que a identificação das placas de rede estão ao lado de cada enlace (linha) nos desenhos que representam os roteadores.


# Configuração do Exemplo 1

## Configuração de IPs em R1

```console
R1>enable
R1#configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
R1(config)#interface f0/0
R1(config-if)#ip address 10.10.1.10 255.255.255.0
R1(config-if)#no shutdown
R1(config-if)#interface g1/0
R1(config-if)#ip address 10.10.2.10 255.255.255.0
R1(config-if)#no shutdown
R1(config-if)#interface g2/0
R1(config-if)#ip address 172.16.1.10 255.255.255.0
R1(config-if)#no shutdown
```
## Configuração de IPs em R2

```console
R2>enable
R2#configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
R2(config)#interface f0/0
R2(config-if)#ip address 10.20.3.20 255.255.255.0
R2(config-if)#no shutdown
R2(config-if)#interface g1/0
R2(config-if)#ip address 172.16.2.20 255.255.255.0
R2(config-if)#no shutdown
R2(config-if)#interface g2/0
R2(config-if)#ip address 172.16.1.20 255.255.255.0
R2(config-if)#no shutdown
```

## Configuração de IPs em R3

```console
R3>enable
R3#configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
R3(config-if)#interface f0/0
R3(config-if)#ip address 10.30.4.30 255.255.255.0
R3(config-if)#no shutdown
R3(config-if)#interface g1/0
R3(config-if)#ip address 10.30.5.30 255.255.255.0
R3(config-if)#no shutdown
R3(config-if)#interface g2/0
R3(config-if)#ip address 10.30.6.30 255.255.255.0
R3(config-if)#no shutdown
R3(config-if)#interface g3/0
R3(config-if)#ip address 172.16.2.30 255.255.255.0
R3(config-if)#no shutdown
```

# Configuração do Exemplo 1

Lembrando que é necessário realizar as configurações do Exemplo 1 para que o cenário do Exemplo 2 fique completo, pois o Exemplo 2 é uma expansão do Exemplo 1.


## Configuração de IPs em R1

```console
R1#configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
R1(config)#interface g3/0
R1(config-if)#ip address 172.16.4.10 255.255.255.0
R1(config-if)#no shutdown
```

## Configuração de IPs em R3

```console
R3#configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
R3(config)#interface g4/0
R3(config-if)#ip address 172.16.3.30 255.255.255.0
R3(config-if)#no shutdown
```
## Configuração de IPs em R3

```console
R4>enable
R4#configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
R4(config)#interface g1/0
R4(config-if)#ip address 172.16.3.40 255.255.255.0
R4(config-if)#no shutdown
R4(config-if)#interface g2/0
R4(config-if)#ip address 172.16.4.40 255.255.255.0
R4(config-if)#no shutdown
```
