---
layout: page
---

Guia rápido de comandos de VLAN/CISCO
====================================================

>**UTFPR - Universidade Tecnológica Federal do Paraná, campus Campo Mourão**  
>Autor: **Prof. Dr. Luiz Arthur Feitosa dos Santos**  
>E-mail: **<luizsantos@utfpr.edu.br>**  

-----------------------

Uma função muito utilizada e importante dentro do conceito de [swithing](https://youtu.be/dfuVBQsghJM) é a de  [VLAN](https://pt.wikipedia.org/wiki/Virtual_LAN). De forma resumida as VLANs aumentam o poder de organização e segmentação das redes em nível de enlace, melhorando seu desempenho e segurança. Os vídeos a seguir apresentam em mais detalhes tanto a ideia de VLAN, quanto os conceitos de *switch*, que são primordiais para entender VLAN:

Vídeo a respeito de conceitos de *switchig*:

[![VLAN](http://img.youtube.com/vi/dfuVBQsghJM/0.jpg)](http://www.youtube.com/watch?v=dfuVBQsghJM "Switching")

Vídeo a respeito de VLAN:

[![VLAN](http://img.youtube.com/vi/puZToHD-F8o/0.jpg)](http://www.youtube.com/watch?v=puZToHD-F8o "VLAN")

Como apresentado no vídeo anterior, de forma geral, VLAN é a capacidade de subdividir um *switch* em várias LANs virtuais, pois fisicamente todas as portas do *switch* formam uma única LAN física, mas através do software/algoritmo empregado no *switch*, é possível separar as portas para formar mais que uma rede - só que virtualmente. Isso é muito útil, principalmente para organizar redes (ex. separar setores de empresas), por questões de segurança e desempenho.


# Guia VLAN/CISCO:

A seguir é apresentado um guia rápido de comandos para realizar configurações básicas em VLANs com *switches* CISCO. 

> Tal guia já apresenta os comandos com valores preenchidos, é claro que esses valores provavelmente mudam para cada rede.

## Criar VLAN e adicionar portas:

Provavelmente as operações mais básicas no gerenciamento de VLAN é criar novas VLAN (além da VLAN padrão) e atribuir/atrelar portas do *switch* à essas VLANs.

### Criando VLAN:

Para criar uma VLAN em *switches* CISCO, basta utilizar o comando ``vlan``, no terminal de administração do *switch*.

```console
Switch>enable
Switch#conf t
Enter configuration commands, one per line. End with CNTL/Z.
Switch(config)#vlan 20
Switch(config-vlan)#name estudantes
Switch(config-vlan)#end
Switch#
```

### Adicionando portas para uma VLAN:

```console
Switch#conf t
Enter configuration commands, one per line. End with CNTL/Z.
Switch(config)#interface f0/1
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan 20
Switch(config-if)#interface f0/2
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan 20
Switch(config-if)#end
Switch#
```

## Remover:

### Removendo portas de uma VLAN:

```console
Switch#conf t
Enter configuration commands, one per line. End with CNTL/Z.
Switch(config)#int f0/1
Switch(config-if)#no switchport access vlan
Switch(config-if)#end
Switch#
```

### Removendo porta de uma VLAN específica:

```console
Switch#conf t
Enter configuration commands, one per line. End with CNTL/Z.
Switch(config)#int f0/1
Switch(config-if)#no switchport access vlan 20
Switch(config-if)#end
Switch#
```


### Removendo uma LAN:

```console
Switch#conf t
Enter configuration commands, one per line. End with CNTL/Z.
Switch(config)#no vlan 30
Switch(config)#end
Switch#
```

## Status das VLANs:

### Mostrar portas das VLANs:
```console
>show vlan brief
```

### Apresentando dados de uma VLAN:

```console
Switch#show vlan name estudantes
```

## Comandos avançados:

### Colocando uma porta no modo trunk:

```console
Switch#conf t
Switch(config)#interface f0/5
Switch(config-if)#switchport mode trunk
Switch(config-if)#switchport trunk native vlan 99
Switch(config-if)#switchport trunk allowed vlan 20,30
```

### Configurando roteamento inter-vlan em um único link de roteamento (router-on-a-stick):

No Switch:

```console
Switch(config)#int f0/6
Switch(config-if)#switchport mode trunk
```

No roteador:

```console
Router>enable
Router#conf t
Enter configuration commands, one per line. End with CNTL/Z.
Router(config)#int f0/1.20
Router(config-subif)#encapsulation dot1q 20
Router(config-subif)#ip address 10.0.0.254 255.0.0.0
Router(config-subif)#int f0/1.30
Router(config-subif)#encapsulation dot1q 30
Router(config-subif)#ip address 11.0.0.254 255.0.0.0
Router(config-subif)#int f0/1
Router(config-if)#no shut
```