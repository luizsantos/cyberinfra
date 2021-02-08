---
layout: page
---

Algumas configurações de *switches*
====================================================

>**UTFPR - Universidade Tecnológica Federal do Paraná, campus Campo Mourão**  
>Autor: **Prof. Dr. Luiz Arthur Feitosa dos Santos**  
>E-mail: **<luizsantos@utfpr.edu.br>**  

-----------------------

Em alguns casos é necessário realizar algumas configurações mais específicas nos *switches*, tais como configuração de velocidade da porta, ativação/desativação da porta, etc.

Então a seguir são apresentadas algumas dessas configurações em *switches* CISCO.

# Velocidade e duplex

Atualmente é comum que *switches* sejam *full-duplex*, ou seja, possuam portas que permitem enviar e receber dados simultaneamente. Todavia, os *switches* mais antigos eram half-duplex, ou seja, suas portas podiam enviar e receber dados, mas só uma coisa de cada vez. Em outras palavras no *half-duplex* ou a porta estava enviando dados ou estava recebendo, mas não os dois ao mesmo tempo. Assim, alguns *switches* permitem configurar suas portas como *half* ou *full-duplex*.

Na figura a seguir, há um cenário de rede, com os *switches* sem nenhum tipo de configuração. No Switch0 foi executado o comando ``show interface f0/2``, que mostra que a interface rede f0/2, que possui como configuração padrão a transmissão *full-duplex* e velocidade de 100Mbps (ver parte marcada na figura).

![fig1](imagens/algunsComandosSw/01.png)

Bem, então dado o cenário anterior os comandos necessários para alterar o tipo de transmissão e a velocidade seriam:

```console
Switch>enable
Switch#configure terminal 
Enter configuration commands, one per line.  End with CNTL/Z.
Switch(config)#interface f0/2
Switch(config-if)#duplex half
%LINK-3-UPDOWN: Interface FastEthernet0/2, changed state to down

%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/2, changed state to down

%LINK-5-CHANGED: Interface FastEthernet0/2, changed state to up

%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/2, changed state to up

Switch(config-if)#speed 10
Switch(config-if)#end
```
No exemplo anterior o Switch0 foi configurado para *half-duplex* com o comando ``duplex half`` e a velocidade foi alterada para 10Mbps com o comando ``speed 10``. Tal alteração é apresentada na figura a seguir.

![fig2](imagens/algunsComandosSw/02.png)

Não foi apresentado aqui, mas o ideal é que em ambos os equipamentos conectados, no caso os dois *switches*, tenham a mesma configuração nas interfaces que os conectam. Assim, pelo menos a interface f0/2 do Switch0 e Switch1 devem ser configurados como *half-duplex* e 10Mbps.

> **Atenção** - aqui foi apresentado a ideia de redução de velocidade e troca de transmissão de *full* para *half* duplex a título de exemplo, é claro que no dia a dia a tendencia é subir a velocidade e que o tipo de transmissão seja *full-duplex*.

A próxima figura ilustra como mudar a velocidade para 100Mbps e o tipo de transmissão para *full-duplex*:

```console
Switch#configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
Switch(config)#interface f0/2
Switch(config-if)#duplex full
%LINK-3-UPDOWN: Interface FastEthernet0/2, changed state to down

%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/2, changed state to down

Switch(config-if)#speed 100
Switch(config-if)#end
```

Como é possível ver na figura anterior basicamente é trocar de ``half`` para ``full`` no comando ``duplex`` e de ``10`` para ``100`` no comando ``speed``.

> **Atenção** - Não adianta tentar colocar uma velocidade que a porta do *switch* não suporta. Por exemplo, trocando de 100Mbps para 1000Mbps (1Gbps) se a porta não é *gigabit*.


### Colocando velocidade, duplex e MDIX automática

Anteriormente foi comentado como configurar a velocidade manualmente, todavia é possível configurar para que a velocidade seja negociada automaticamente pelos *hosts*/*switches*. 

Também é possível configurar o auto-MDIX (*automatic medium-dependent interface crossover*), que faz o cruzamento do cabo de forma automática, caso seja necessário. Ou seja, se for necessário um cabo crossover e o usuário utilizar um cabo comum (*straight-through*) a porta do host irá fazer o ajuste automático (cruzamento dos pares do cabo), para que a conexão seja possível. Em outras palavras é possível utilizar o cabo errado e a rede funciona.

A seguir são apresentados os comandos necessários para que funcione o MDIX, bem como a configuração automática da velocidade e tipo de transmissão:

```console
Switch>enable 
Switch#configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
Switch(config)#interface f0/2
Switch(config-if)#duplex auto
%LINK-5-CHANGED: Interface FastEthernet0/2, changed state to up

%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/2, changed state to up

Switch(config-if)#speed auto
Switch(config-if)#mdix auto
Switch(config-if)#end
```
Assim, para configurar o auto-MDIX é necessário o comando ``mdix auto``. Já para a configuração automática do tipo de transmissão e da velocidade basta utilizar ``auto`` tanto para o comando ``duplex`` quanto para o comando ``speed``.

# Desabilitando/habilitando portas

É comum imaginar que todas as portas dos *switches* devam estar ligadas (prontas para uso). Todavia, por questões de segurança pode ser interessante desabilitar portas de *switches* que não serão utilizadas. Isso é feito com o comando ``shutdown``.  

Usando a rede dos exemplos anteriores,  imagine um cenário no qual ninguém deve utilizar, por motivos de segurança, nenhuma porta que não a f0/1 e f0/2, tanto do Switch0 quanto do Switch1. Ou seja, nesta rede só é permitida a conexão entra switches, PC0 e PC1. Para desabilitar as outras portas é necessário executar em cada porta os seguintes comandos:

```console
Switch#configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
Switch(config)#interface f0/3
Switch(config-if)#shutdown

%LINK-5-CHANGED: Interface FastEthernet0/3, changed state to administratively down
Switch(config-if)#
```
Dado o comando ``shutdown`` da figura anterior, é possível utilizar o comando ``show interface status``, para verificar se a porta está desabilitada (``disabled``), tal como ilustra a figura a seguir:

```console
Switch#show interface status
Port      Name               Status       Vlan       Duplex  Speed Type
Fa0/1                        connected    1          auto    auto  10/100BaseTX
Fa0/2                        connected    1          auto    auto  10/100BaseTX
Fa0/3                        disabled 1          auto    auto  10/100BaseTX
Fa0/4                        notconnect   1          auto    auto  10/100BaseTX
Fa0/5                        notconnect   1          auto    auto  10/100BaseTX
Fa0/6                        notconnect   1          auto    auto  10/100BaseTX
Fa0/7                        notconnect   1          auto    auto  10/100BaseTX
```

Bem, para atingir o máximo de segurança é interessante desabilitar todas as portas que não foram planejadas para serem utilizadas. Todavia, fazer ``shutdown`` porta por porta irá ocupar muito tempo e pode gerar erros de configuração. Então uma opção interessante é passar uma faixa de portas de uma só vez, isso é possível utilizando o comando a seguir:

```console
Switch#configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
Switch(config)#interface range fastethernet 0/3 - 7
Switch(config-if-range)#shutdown

%LINK-5-CHANGED: Interface FastEthernet0/4, changed state to administratively down

%LINK-5-CHANGED: Interface FastEthernet0/5, changed state to administratively down

%LINK-5-CHANGED: Interface FastEthernet0/6, changed state to administratively down

%LINK-5-CHANGED: Interface FastEthernet0/7, changed state to administratively down

Switch(config-if-range)#
```

O comando ``interface range fastethernet 0/1 - 7`` habilita a configuração para uma faixa de portas do switch. Desta forma, é só digitar uma vez o comando que ese será replicado para todas as portas. No exemplo foi utilizado o comando ``shutdown``, mas pode ser qualquer outro (não só para habilitar e desabilitar portas). A seguir é apresentado o status de cada porta, também foi colocado um *host* novo, simulando uma pessoa não autorizada tentando acessar a rede, Na figura dá para ver que o *link* para esse novo PC (PC2) está em vermelho, ou seja, esse computador não está na rede, pois ele está em uma porta desabilitada.

![fig3](imagens/algunsComandosSw/03.png)

É claro que um invasor poderia remover o cabo de uma porta que funciona e tentar acessar a rede, mas isso pode gerar um alerta na rede já que essa pode parar de funcionar corretamente (algum PC pode parar ou a comunicação entre o *switch*.

A proteção apenas pela porta não funciona em 100% dos casos, pois o invasor pode tentar achar uma porta habilitada ou remover um PC idôneo para conectar o seu. Entretanto, o ato de desabilitar portas já é uma medida de segurança interessante para bloquear pessoas leigas (não *hackers*) que tentam usar a rede sem permissão.