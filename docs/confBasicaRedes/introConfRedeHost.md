---
layout: page
---

# Configuração básica de rede em *hosts*

Uma tarefa muito corriqueira para qualquer administrador de rede é a configuração de *hosts* na rede, de forma que este acesse a rede local e principalmente à Internet.

## O que é necessário configurar para a rede funcionar?

A configuração de um *host* na rede, normalmente se dá por três passos básico, sendo esses:

1. Configuração do **IP e máscara de rede**, isso permite que o *host* acesse a rede local;
2. Configuração da **rota padrão**, que permitirá que o *host* acesse outras redes, tal como a Internet;
3. Configuração do IP do servidor ou **servidores DNS**, isso possibilitará que o *host* acesse *hosts* através de nomes e não endereços IPs - já que é bem mais fácil lembrar de nomes do que IPs.

Com o passo 1, é possível acessar a rede local, com o passo 2 é possível acessar outras redes e com o passo 3 é possível acessar *hosts* utilizando nomes, tal como www.google.com.br.

> **Atenção:** O primeiro passo é obrigatório se você quiser acessar a rede local. Já o passo 2 e 3 são opcionais! Executando apenas o passo 1 e passo 2 corretamente, você já pode acessar outras redes, como por exemplo a Internet, mas somente através do uso de endereços IP, o que a maioria das pessoas normalmente não fazem. Assim, é quase obrigatório realizar também o terceiro passo, para só então as pessoas considerem que o *host* esteja conectado corretamente na rede/Internet.


## Configuração manual ou automática?

Há duas formas de realizar os três passos de configuração de rede citados anteriormente:
1. **Manual/Estática**: neste as configurações são feitas manualmente, pelo usuário/administrador do sistema. Então, o usuário/administrador do *host* deve ter conhecimento prévio da rede, para saber quais endereços utilizar durante a configuração do *host*. Este tipo de configuração também é considerada estática, pois os endereços atribuídos não mudam a menos que o administrador altere esses;
2. **Automática**: utilizando esse método o computador será configurado automaticamente por outro computador da rede. Normalmente tal configuração vem via servidor [DHCP/BOOTP](https://pt.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol), pelo roteador da rede ou ponto de acesso sem fio. Neste tipo de configuração o usuário não precisa saber dos endereços de rede, pois isso é feito "magicamente" para ele. Além disso, os endereços de rede podem mudar de forma dinâmica ao longo do tempo.

> O termo "automática" e "estática, utilizado anteriormente, pode levar à algumas confusões, pois por exemplo, tem como o endereço IP ser conseguido de forma automática, mas mesmo assim ser um endereço estático (sempre o *host* receberá o mesmo IP). Todavia não vamos nos aprofundar nesta discussão agora! :-p

É importante perceber que a maioria dos *hosts* atualmente têm sua configuração de rede feita de forma automática, via DHCP. Entretanto, **bons administradores de rede, devem saber configurar *hosts* manualmente** (não só via DHCP), pois isso pode ser vital durante a resolução de problemas. Além do que, muitos equipamentos quem compõem a infraestrutura das redes são preferencialmente, se não obrigatoriamente configurados com o método manual (devido à questões administrativas, de segurança, etc).

## Configuração permanente ou temporária?

Sistemas UNIX-Like, permitem ainda duas formas de configuração de rede:
1. **Volátil**: nesta, toda configuração feita é perdida se o *host* for reiniciado (ligado/desligado). É uma configuração "temporária", que pode ser mais indicada/utilizada para testes;
2. **Não volátil**: nesta, a configuração persiste mesmo que o *host* seja desligado e religado. Este tipo de configuração é realizada em arquivos que ficam armazenados nos *hosts* da rede.

> A configuração chamada aqui de **não volátil**, também é denominada de estática ou via arquivo, mas ela pode ser utilizada tanto para configurar IPs estáticos, quanto automáticos/dinâmicos. Cuidado com a confusão nos termos... ;-)

Normalmente a configuração em ambiente grágico é não volátil, por isso em sistemas operacionais como no caso do Microsoft Windows, a configuração que você fizer para a rede vai normalmente persistir. O mesmo se aplica para configuração de rede em ambiente gráfico utilizando o Linux, ou seja, a configuração de rede realizada no ambiente gráfico do Linux ou da maioria dos sistemas Like-UNIX, vai persistir, já que se entende que ambiente gráfico normalmente é para usuário leigo (não administrador), assim esperá-se que a configuração feita no ambiente gráfico persista.

Visto as possibilidades de configurações de rede para *hosts* Linux, agora serão apresentados os comandos e arquivos que permitem efetivar essas configurações nos seguintes sistemas:

* [Linux](linux/linuxConfRedeHost)
