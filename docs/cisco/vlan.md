---
layout: page
---

Resumo de comandos de VLAN em equipamentos CISCO
====================================================

>**UTFPR - Universidade Tecnológica Federal do Paraná, campus Campo Mourão**  
>Autor: **Prof. Dr. Luiz Arthur Feitosa dos Santos**  
>E-mail: **<luizsantos@utfpr.edu.br>**  

-----------------------

Uma função muito utilizada e importante dentro do conceito de [swithing](https://youtu.be/dfuVBQsghJM) é a de  [VLAN](https://pt.wikipedia.org/wiki/Virtual_LAN). O vídeo a seguir apresenta os conceitos de VLAN:

[![VLAN](http://img.youtube.com/vi/puZToHD-F8o/0.jpg)](http://www.youtube.com/watch?v=puZToHD-F8o "VLAN")

Como apresentado no vídeo anterior, de forma geral, VLAN é a capacidade de subdividir um *switch* em várias LANs virtuais, pois fisicamente todas as portas do *switch* formam uma única LAN física, mas através do software/algoritmo empregado no *switch*, é possível separar as portas para formar mais que uma rede - só que virtualmente. Isso é muito útil, principalmente para organizar redes (ex. separar setores de empresas), por questões de segurança e desempenho.

# Criando e gerenciando VLANs

Switches
VLAN

Mostrar portas das VLANs:
>show vlan brief


Criando VLAN:
Switch>enable
Switch#conf t
Enter configuration commands, one per line. End with CNTL/Z.
Switch(config)#vlan 20
Switch(config-vlan)#name estudantes
Switch(config-vlan)#end
Switch#

Adicionando portas para uma VLAN:
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


Removendo portas de uma VLAN:
Switch#conf t
Enter configuration commands, one per line. End with CNTL/Z.
Switch(config)#int f0/1
Switch(config-if)#no switchport access vlan
Switch(config-if)#end
Switch#

Removendo porta de uma VLAN específica:
Switch#conf t
Enter configuration commands, one per line. End with CNTL/Z.
Switch(config)#int f0/1
Switch(config-if)#no switchport access vlan 20
Switch(config-if)#end
Switch#


Removendo uma LAN:
Switch#conf t
Enter configuration commands, one per line. End with CNTL/Z.
Switch(config)#no vlan 30
Switch(config)#end
Switch#


Apresentando dados de uma VLAN:
Switch#show vlan name estudantes

Colocando uma porta no modo trunk:
Switch#conf t
Switch(config)#interface f0/5
Switch(config-if)#switchport mode trunk
Switch(config-if)#switchport trunk native vlan 99
Switch(config-if)#switchport trunk allowed vlan 20,30

Configurando roteamento inter-vlan em um único link de roteamento (router-on-a-stick):
No Switch:
Switch(config)#int f0/6
Switch(config-if)#switchport mode trunk

No roteador:
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
