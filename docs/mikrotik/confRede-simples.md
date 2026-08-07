---
layout: page
---

# Introdução a Roteadores MikroTik

No âmbito da infraestrutura de redes de computadores, a seleção de equipamentos desempenha um papel determinante na estabilidade e na segurança do tráfego de dados. Dentre os componentes essenciais de uma arquitetura de comunicação, sobressaem-se os roteadores, dispositivos cuja principal função é o roteamento de pacotes entre diferentes redes. Em ambientes corporativos, a confiabilidade desses dispositivos é um requisito fundamental para evitar interrupções de serviço. O mercado global conta com diversos fabricantes consolidados nesse segmento — como Cisco Systems, Huawei, Juniper Networks, TP-Link, etc - cada qual com soluções voltadas a diferentes portes de rede e necessidades. Nesse cenário, os equipamentos desenvolvidos pela MikroTik vêm conquistando espaço expressivo em redes de pequeno, médio e grande porte, bem como em provedores de serviços de Internet (ISPs).

Fundada em 1996 na Letônia, a MikroTik iniciou suas atividades com o desenvolvimento de sistemas de software para conectividade sem fio e roteamento, expandindo posteriormente sua atuação para a fabricação de hardware próprio. Uma das principais vantagens da marca reside na relação custo-benefício de seus produtos, somada à ausência de custos de licenciamento por recursos de software avançados - modelo frequentemente adotado por concorrentes como Cisco e Juniper. Por outro lado, como limitações em comparação às marcas tradicionais de grande porte, destacam-se o suporte técnico menos abrangente, a dependência acentuada de suporte comunitário e uma curva de aprendizado inicial, que pode ser mais íngreme na configuração via linha de comando para administradores não familiarizados com a plataforma.

A arquitetura das soluções da fabricante divide-se entre a linha de hardware, denominada RouterBOARD, e o sistema operacional, o RouterOS. **O RouterOS é um sistema proprietário baseado em _kernel_ Linux** que provê um conjunto amplo de recursos de rede, incluindo protocolos de roteamento dinâmico (como OSPF e BGP), gerenciamento de _firewall_, suporte a redes virtuais privadas (VPNs), controle de banda (QoS) e serviços de infraestrutura como DHCP e DNS. A integração entre o hardware dedicado e o RouterOS permite a implantação de roteadores com alto grau de flexibilidade operacional, podendo o software também ser executado em arquiteturas x86 como máquina virtual (_Cloud Hosted Router_ — CHR).

Diante do aumento da visibilidade e da adoção dos roteadores MikroTik no mercado — impulsionados, principalmente pela sua competitividade financeira e robustez de recursos, torna-se estratégico que o administrador de redes expanda suas competências para além dos fabricantes historicamente consolidados. O domínio da configuração em plataformas emergentes e de ampla difusão permite ao profissional compreender com maior clareza as variações de sintaxe, arquitetura e implementação existentes entre os diferentes fornecedores. Sobretudo, essa abordagem comparativa evidencia que, independentemente da interface ou do sistema operacional empregado, os fundamentos operacionais permanecem inalterados, visto que todos os equipamentos devem atender rigorosamente às especificações dos protocolos da pilha TCP/IP, aos padrões de roteamento e aos serviços essenciais que regem as redes de computadores.

## Configuração de uma rede básica

A fim de ilustrar a aplicação prática dos conceitos discutidos anteriormente, este seção apresenta a configuração básica de um roteador MikroTik executando o sistema operacional RouterOS na versão 7.22.1. A abordagem será desenvolvida em um cenário de rede bem simples, concentrando-se fundamentalmente no uso da interface de linha de comando (CLI) nativa do equipamento, sem o recurso a ferramentas gráficas de gerenciamento. O objetivo central é instruir o leitor quanto à sintaxe e à execução dos comandos essenciais para a atribuição de endereços IP e máscaras de rede, o estabelecimento da rota padrão e de rotas estáticas, o processo de exportação e importação de arquivos de configuração, bem como a verificação do estado operacional das interfaces de rede e dos serviços de infraestrutura ativados.

A topologia de rede proposta é apresentada na Figura 1, sendo esta composta por duas redes distintas interconectadas por um roteador central, identificado como **MikroTik-1**:

1. **Rede Local (LAN1 - `10.1.0.0/24`):** Onde estão conectados dois dispositivos finais, **Host-1** e **Host-2**, que se interligam por meio de um concentrador (**Hub1**). A interface do roteador MikroTik associada a este segmento é a **`ether2`**. O roteador utiliza o último endereço host disponível na subnet para suas interfaces (`10.1.0.254`), atuando como o *gateway* padrão dos hosts desta LAN.
2. **Rede Externa / WAN (`192.168.122.0/24`):** Está é a rede de saída para a Internet, interligado via concentrador (**Hub2**) a partir da interface **`ether1`** do roteador MikroTik. Nesta mesma rede encontra-se o **Host-3**, além da nuvem **NAT1**, que abriga o *gateway* de saída para a Internet no endereço `192.168.122.1`. Este *gateway* oculto na nuvem também desempenha os papéis de servidor DHCP e DNS para a interface WAN do MikroTik.

> O cenário de rede descrito foi implementado no simulador GNS3. Nesse ambiente, o elemento NAT1, representado graficamente sob a forma de nuvem, simboliza a interconexão com a rede externa e a Internet. Tecnicamente, essa nuvem mapeia a comunicação para o sistema hospedeiro (host físico ou hipervisor) através da interface virtual no endereço 192.168.122.1. Essa estrutura permite o roteamento e a tradução do tráfego (NAT) vindo da topologia simulada e virtualizada para a interface de rede real do computador, provendo conectividade externa aos dispositivos do laboratório.

| ![rede](imagens/rede-simples.png) |
|:--:|
| Figura 1 - Cenário de rede simples para configuração com Mikrotik

O objetivo principal deste texto é realizar a configuração do roteador **MikroTik-1** via linha de comando para que este estabeleça o roteamento e a tradução de endereços (NAT), provendo acesso à Internet para os dispositivos da **LAN1**. Ressalta-se que o escopo deste documento restringe-se exclusivamente às definições necessárias no roteador MikroTik, não sendo objeto deste texto a apresentação da configuração individual dos demais *hosts* da rede.

A tabela a seguir descreve de forma textual todos os componentes da topologia, detalhando seus papéis, sub-redes, interfaces ativas no roteador e endereços IP completos atribuídos a cada dispositivo.

| Dispositivo / Elemento | Sub-rede de Origem | Interface no MikroTik | Endereço IP Completo | Máscara de Rede / CIDR | Função / Observação |
| --- | --- | --- | --- | --- | --- |
| **Host-1** | `10.1.0.0/24` | — | `10.1.0.1` | `255.255.255.0` (`/24`) | Estação de trabalho na LAN1. |
| **Host-2** | `10.1.0.0/24` | — | `10.1.0.2` | `255.255.255.0` (`/24`) | Estação de trabalho na LAN1. |
| **MikroTik-1 (LAN1)** | `10.1.0.0/24` | `ether2` | `10.1.0.254` | `255.255.255.0` (`/24`) | Interface interna (*Gateway* da LAN1). |
| **MikroTik-1 (WAN)** | `192.168.122.0/24` | `ether1` | `192.168.122.254` | `255.255.255.0` (`/24`) | Interface externa (Conectada ao Hub2/WAN). |
| **NAT1 (Nuvem)** | `192.168.122.0/24` | — | `192.168.122.1` | `255.255.255.0` (`/24`) | *Gateway* Padrão, Servidor DHCP e DNS da WAN. |
| **Host-3** | `192.168.122.0/24` | — | `192.168.122.3` | `255.255.255.0` (`/24`) | Dispositivo pertencente ao segmento WAN. |

> Na verdade a interface `ether1` pode receber um IP dinâmico via DHCP, ou seja, pode ser um IP diferente do apresentada no Tabela 2.

Dessa forma, os **Host-1** e **Host-2** atuam como estações de trabalho da rede local (**LAN1**), permanecendo isolados e sem conectividade externa até a conclusão da configuração do roteador MikroTik. O **Host-3**, por sua vez, representa um nó externo ao segmento da LAN1, para o qual o roteador deverá prover acessibilidade após ser configurado; este host pode ser utilizado para testes de conectividade ou para tarefas de monitoramento de tráfego (como a captura de pacotes via `tcpdump`). Por fim, o **NAT1** viabilizará o acesso de todo o cenário de rede à Internet e a outras redes externas, uma vez estabelecidos o roteamento e a tradução de endereços adequados.

> Note que o Host-3 e o roteador MikroTik, tem como _gateway_ e DNS o host 192.168.122.1. É importante notar que o Host-3 não conseguirá acessar os hosts 1 e 2, principalmente por seu gateway ser o 192.168.122.1 - que não tem rotas para a LAN1 -, mas depois de configurado os hosts 1 e 2 conseguem acessar o Host-3.

## Primeiros Passos e Primeiro Acesso ao MikroTik

Ao inicializar um roteador MikroTik pela primeira vez (ou após uma restauração das configurações de fábrica), o primeiro contato com a interface de linha de comando (CLI) é realizado por meio de credenciais padrão do sistema. O usuário administrativo pré-configurado é o **`admin`**, e, por padrão, o campo de senha permanece **em branco** (sem senha definida). Para efetuar o acesso inicial via console ou terminal, basta preencher o nome de usuário, no caso `admin` e pressionar a tecla `Enter` na solicitação da senha.

```bash
MikroTik 7.22.1 (stable)
   Login: admin                                                                                                                   
   Password:
```

> Atenção, se você digitar alguma senha neste ponto, o acesso será negado.

### Aceite dos Termos de Licenciamento

Após a validação do _login_ inicial, o sistema operacional exibe o _banner_ oficial do RouterOS acompanhado da versão do sistema e solicita a leitura dos termos de licença de software. A confirmação é opcional para prosseguir; ao pressionar a tecla **`n`** (para *No*) ou simplesmente a tecla `Enter`, o processo de autenticação é mantido e a exibição do texto completo da licença é ignorada.

```bash
  MMM                   MMM       KKK                                                            TTTTTTTTTTT        KKK
  MMMM            MMMM       KKK                                                            TTTTTTTTTTT        KKK
  MMM  MMMM   MMM  III  KKK     KKK     RRRRRR          OOOOOO      TTT             III  KKK  KKK
  MMM     MM       MMM  III  KKKKK            RRR      RRR    OOO  OOO     TTT             III  KKKKK
  MMM                   MMM  III  KKK    KKK     RRRRRR          OOO  OOO     TTT             III  KKK   KKK
  MMM                   MMM  III  KKK       KKK  RRR      RRR     OOOOOO      TTT             III  KKK      KKK

  MikroTik RouterOS 7.22.1 (c) 1999-2026       https://www.mikrotik.com/

Do you want to see the software license? [Y/n]: n
```

### Definição Obrigatória da Senha de Administrador

Por questões de segurança, o RouterOS exige a alteração da senha do usuário `admin` logo após o aceite dos termos. O sistema solicita a digitação da nova senha e a sua confirmação. Durante a digitação, os caracteres não são exibidos na tela por medidas de segurança. Uma vez efetuada a confirmação, a mensagem `Password changed` ratifica a alteração, e o *prompt* de comando do sistema é devidamente liberado.

```bash
Press F1 for help



Change your password (Ctrl-C to skip)
new password> ********
repeat new password> ********

Password changed
[admin@MikroTik] >
```

### Entendendo a Interface de Linha de Comando (CLI) e Recursos de Navegação

Então após um _login_ realizado com sucesso, será apresentado o *prompt* de comando, sendo esse algo como: 

```bash
[admin@MikroTik] >
```

A estrutura de exibição do exemplo anterior indica o contexto operacional do usuário, sendo esse:

* **`admin`**: O nome da conta autenticada no momento.
* **`MikroTik`**: O nome de identificação do equipamento (*Identity*).
* **`>`**: O nível do menu em que o administrador se encontra (neste caso, a raiz do sistema).

### Ajuda e Recurso de Autocompletar

A CLI do RouterOS foi projetada para facilitar a administração e a descoberta de comandos, dispondo de recursos nativos para navegação e suporte. Assim, é possível obter ajuda das seguintes formas:

1. **Teclas de Ajuda (`F1` ou `?`):** A qualquer momento, pressionar a tecla **`F1`** ou digitar o caractere de interrogação **`?`** exibe um resumo da documentação dos comandos disponíveis para o menu ou contexto atual.
2. **Uso da Tecla `Tab` (Autocompletar e Listagem):** A tecla **`Tab`** desempenha papel fundamental na navegação do RouterOS:
* **Completar Comandos:** Digitar as primeiras letras de um comando e pressionar `Tab` completa automaticamente o parâmetro caso não haja ambiguidade. Caso exista ambiguidade serão apresentadas as possibilidade de comandos com o conjunto de caracteres digitados pelo usuário até então.
* **Listar Opções Disponíveis:** Pressionar a tecla `Tab` com o _prompt_ em branco (ou após qualquer subseção) exibe a lista completa de todos os submenus, comandos e argumentos aceitos naquele nível específico da hierarquia.

Em suma, o domínio da navegação pela interface de linha de comando constitui o alicerce para a administração eficiente do RouterOS. Saber identificar a posição hierárquica atual por meio do _prompt_ e utilizar os recursos nativos de ajuda e autocompletar garante agilidade e precisão operacional. Embora consultas a motores de busca na Internet e o auxílio de assistentes de inteligência artificial sejam ferramentas valiosas no cotidiano, a verificação direta dos comandos disponíveis no próprio equipamento permanece como o método mais confiável, visto que a sintaxe e as funcionalidades podem sofrer alterações significativas entre diferentes versões do sistema operacional. Acima de tudo, o administrador deve ter a plena consciência de que o controle de acesso ao roteador — viabilizado pela gestão rigorosa de usuários e pela definição de senhas robustas — representa a primeira e mais fundamental camada de proteção para a integridade do dispositivo e a segurança de toda a infraestrutura de rede.

## Verificação do Status das Interfaces de Rede

Antes de iniciar a definição dos parâmetros de rede — como a atribuição manual de endereços IP, máscaras de sub-rede e rotas —, é indispensável realizar um diagnóstico preliminar do dispositivo. O administrador deve identificar com clareza quais interfaces físicas e lógicas estão disponíveis no equipamento, suas nomenclaturas operacionais, os endereços MAC associados, o estado físico do enlace (*link*) e a eventual existência de configurações prévias mantidas pelo sistema.

Então, normalmente o primeiro passo consiste em listar as tabelas de endereçamento IP já associadas às interfaces do equipamento por meio do comando `/ip address print`. Tal como é apresentado no exemplo a seguir:

```bash
[admin@MikroTik] > ip address print
Flags: D - DYNAMIC
Columns: ADDRESS, NETWORK, INTERFACE, VRF
#   ADDRESS             NETWORK        INTERFACE  VRF 
0 D 192.168.122.118/24  192.168.122.0  ether1     main
```

Ao analisar o resultado exibido anteriormente, observa-se que a interface **`ether1`** já possui o endereço IP `192.168.122.118/24` atribuído. A presença da _flag_ **`D`** (*Dynamic*) indica que esse endereço não foi configurado manualmente, mas sim obtido dinamicamente por meio de um cliente DHCP ativado por padrão na instalação do RouterOS para a primeira interface de rede. As demais interfaces do equipamento não figuram nessa listagem por não possuírem nenhum endereço IP associado no momento.

> Atenção, o roteador tenta por padrão sempre tenta obter endereços automaticamente via DHCP.

O comando anterior apresentou apenas as interfaces ligadas e que obtiveram IPs, mas pode ser que existam outras placas de rede disponíveis no roteador. Assim, para obter uma visão abrangente de todas as portas físicas e lógicas do dispositivo — independentemente de possuírem IP atribuído ou de estarem fisicamente conectadas —, utiliza-se o comando `/interface print detail`, tal como:

```bash
[admin@MikroTik] > interface print detail   
Flags: D - DYNAMIC; X - DISABLED; I - INACTIVE, R - RUNNING; S - SLAVE; P - PASSTHROUGH 
 0   R   name="ether1" default-name="ether1" type="ether" mtu=1500 actual-mtu=1500 vrf=main mac-address=0C:56:A5:03:00:00 
         last-link-up-time=2026-07-22 17:43:58 link-downs=0 

 1   R   name="ether2" default-name="ether2" type="ether" mtu=1500 actual-mtu=1500 vrf=main mac-address=0C:56:A5:03:00:01 
         last-link-up-time=2026-07-22 17:43:58 link-downs=0 

 2       name="ether3" default-name="ether3" type="ether" mtu=1500 actual-mtu=1500 vrf=main mac-address=0C:56:A5:03:00:02 link-downs=>

 3       name="ether4" default-name="ether4" type="ether" mtu=1500 actual-mtu=1500 vrf=main mac-address=0C:56:A5:03:00:03 link-downs=>

 4       name="ether5" default-name="ether5" type="ether" mtu=1500 actual-mtu=1500 vrf=main mac-address=0C:56:A5:03:00:04 link-downs=>

 5       name="ether6" default-name="ether6" type="ether" mtu=1500 actual-mtu=1500 vrf=main mac-address=0C:56:A5:03:00:05 link-downs=>

 6       name="ether7" default-name="ether7" type="ether" mtu=1500 actual-mtu=1500 vrf=main mac-address=0C:56:A5:03:00:06 link-downs=>

 7       name="ether8" default-name="ether8" type="ether" mtu=1500 actual-mtu=1500 vrf=main mac-address=0C:56:A5:03:00:07 link-downs=0

 8   R   name="lo" type="loopback" mtu=65536 actual-mtu=65536 vrf=main mac-address=00:00:00:00:00:00 
         last-link-up-time=2026-07-22 17:43:58 link-downs=0 
```

O `/interface print detail` lista **todas** as portas de rede físicas (que no exemplo foi da `ether1` a `ether8`) e a interface virtual de *loopback* (`lo`), detalhando propriedades operacionais como Unidade Máxima de Transmissão (MTU), endereço MAC e horário do último estabelecimento de link (*last-link-up-time*).

Em uma análise mais profunda da saída anterior, destaca-se a letra **`R`** (*Running*), que significa:

* As interfaces **`ether1`** e **`ether2`** apresentam a flag **`R`**, confirmando que há um cabo/meio físico conectado a elas e que o enlace (*link*) está ativo no nível da camada física e de enlace.
* A interface **`lo`** (*loopback*) permanece constantemente no estado **`R`** por se tratar de uma interface lógica interna do sistema.
* As interfaces de **`ether3`** a **`ether8`** não apresentam a flag **`R`**, indicando que estão desconectadas (sem enlace ativo), embora permaneçam ativadas administrativamente.
* Nenhuma das interfaces apresenta a flag **`X`** (*Disabled*), o que confirma que todas as portas estão habilitadas para uso no sistema operacional.

O comando anterior, apresenta muitos detalhes, o que pode causar confusão devida a quantidade de dados, então muitas vezes é interessante executar o comando `interface ethernet print`, que apresenta uma saída mais resumida (focada exclusivamente nas portas físicas), tal como:

```bash
[admin@MikroTik] > interface ethernet print 
Flags: R - RUNNING
Columns: NAME, MTU, MAC-ADDRESS, ARP
#   NAME     MTU  MAC-ADDRESS        ARP    
0 R ether1  1500  0C:56:A5:03:00:00  enabled
1 R ether2  1500  0C:56:A5:03:00:01  enabled
2   ether3  1500  0C:56:A5:03:00:02  enabled
3   ether4  1500  0C:56:A5:03:00:03  enabled
4   ether5  1500  0C:56:A5:03:00:04  enabled
5   ether6  1500  0C:56:A5:03:00:05  enabled
6   ether7  1500  0C:56:A5:03:00:06  enabled
7   ether8  1500  0C:56:A5:03:00:07  enabled
```
A saída anterior apresenta de maneira direta apenas as colunas essenciais para o dia a dia da administração de rede: a nomenclatura das interfaces (`NAME`), a Unidade Máxima de Transmissão (`MTU`), o endereço físico gravado na placa (`MAC-ADDRESS`) e o status do protocolo de resolução de endereços (`ARP`). A flag **`R`** (*Running*) destaca rapidamente quais portas físicas possuem enlace estabelecido com o switch, hub ou dispositivo adjacente (neste caso, `ether1` e `ether2`).

Embora a execução dos comandos de verificação de status possa parecer uma tarefa trivial ou redundante em um primeiro momento, esse procedimento é vital para a manutenção da estabilidade da rede e para o diagnóstico de falhas. Durante a configuração de redes, não são raros os episódios em que administradores, por distração, atribuam endereços IP incorretos, definem máscaras inadequadas ou invertem as configurações entre as placas de rede. Nessas situações de inconsistência, os comandos de inspeção e monitoramento de status constituem a principal ferramenta de depuração, permitindo isolar o problema e validar se o comportamento físico e lógico do roteador corresponde exatamente ao planejamento da infraestrutura.

## Atribuição de Endereço IP Estático

Em nosso exemplo, após a verificação do estado das interfaces de rede, o próximo passo na construção da infraestrutura é a atribuição manual de um endereço IP estático para a interface interna do roteador (**`ether2`**). Esse endereço atuará como o *gateway* padrão para os dispositivos pertencentes à rede local **LAN1** (`10.1.0.0/24`).

Para realizar a atribuição estática, acessa-se o menu de endereçamento IP do RouterOS e executa-se o subcomando `add`:

```bash
[admin@MikroTik] > ip address add interface=ether2 address=10.1.0.254/24
```

A sintaxe utilizada no comando anterior é dividida em parâmetros específicos que definem a configuração do endereço no RouterOS:

* **`/ip address add`**: Caminho na árvore de comandos do sistema operacional que instrui o RouterOS a adicionar uma nova entrada à tabela de endereçamento do protocolo IPv4.
* **`interface=ether2`**: Especifica a interface física ou lógica à qual o endereço IP será vinculado. Neste caso, associa a configuração à porta física `ether2`.
* **`address=10.1.0.254/24`**: Define o endereço IP do host e a respectiva máscara de sub-rede utilizando a notação CIDR (`/24`, equivalente à máscara decimal pontuada `255.255.255.0`). A partir do momento em que a máscara em notação CIDR é informada, o RouterOS calcula automaticamente a rede (*Network*) correspondente (`10.1.0.0`).

Na administração de redes, a execução de um comando sem mensagens de erro no terminal não garante, por si só, o funcionamento correto da regra. É essencial validar a efetividade do parâmetro recém-adicionado consultando novamente a tabela de endereçamento do dispositivo através do comando `/ip address print`.

```bash
[admin@MikroTik] > ip address print 
Flags: D - DYNAMIC
Columns: ADDRESS, NETWORK, INTERFACE, VRF
#   ADDRESS             NETWORK        INTERFACE  VRF 
0 D 192.168.122.118/24  192.168.122.0  ether1     main
1   10.1.0.254/24       10.1.0.0       ether2     main
```

Analisando o resultado da listagem, é possível confirmar que a configuração foi gravada com sucesso, já que:

1. **Entrada de Índice `1`:** O sistema cadastrou o novo endereço `10.1.0.254/24` na interface `ether2`, calculando automaticamente o campo `NETWORK` como `10.1.0.0`.
2. **Ausência da Flag `D`:** Ao contrário da entrada `0` (atribuída dinamicamente via DHCP na interface `ether1`), a nova entrada não possui a sinalização **`D`** (*Dynamic*), o que confirma que se trata de uma configuração **estática/estável**, mantida de forma permanente na memória do equipamento.


Com essa configuração dos IPs e máscaras nas interfaces de rede do roteador, a LAN1 já consegue enviar dados para fora da rede, mas a comunicação bilateral não vai acontecer, já que as outras redes não conhecem a LAN1, para resolver esse problemas vamos utilizar NAT e deixar o nosso cenário de exemplo 100% funcional.

## Configuração do NAT

Com o endereçamento IP devidamente atribuído às interfaces do roteador, o próximo passo essencial para prover conectividade à rede **LAN1** é a definição de uma regra de NAT (*Network Address Translation* ).

No cenário estudado, os dispositivos **Host-1** e **Host-2** utilizam a sub-rede privada `10.1.0.0/24`. O roteador responsável pela saída da rede virtual para a Internet é o sistema hospedeiro (no endereço `192.168.122.1`). Em um ambiente de produção ou de simulação onde não se possui acesso administrativo ao roteador principal/hospedeiro para incluir uma rota estática de retorno apontando para a sub-rede `10.1.0.0/24`, os pacotes originados na LAN1 até conseguiriam sair, mas as respostas enviadas pelo hospedeiro ou pela Internet seriam descartadas por falta de rota de retorno.

A aplicação do NAT resolve esse problema ao reescrever o endereço IP de origem dos pacotes que saem da rede local. Dessa forma, quando o tráfego da **LAN1** atravessa o MikroTik em direção à WAN, o roteador substitui o IP privado do cliente pelo seu próprio IP na interface externa (`192.168.122.118`). Para o hospedeiro e para a rede externa, todo o tráfego parecerá ter sido gerado pelo próprio MikroTik, permitindo que os pacotes de resposta retornem corretamente.

> **Nota:** No ambiente de simulação no GNS3, seria tecnicamente viável adicionar uma rota estática diretamente no sistema operacional hospedeiro apontando a rede `10.1.0.0/24` para o IP do MikroTik, o que eliminaria a necessidade do NAT (mascaramento) no laboratório. No entanto, optou-se por utilizar o NAT por se tratar do cenário padrão encontrado na interconexão com provedores e redes externas.

### Regra de NAT (Masquerade)

Para implementar essa tradução, utiliza-se a ação de mascaramento (*masquerade*) no subsistema de _firewall_ do RouterOS:

```bash
[admin@MikroTik] > ip firewall nat add action=masquerade chain=srcnat out-interface=ether1
```

Para administradores familiarizados com sistemas GNU/Linux, a estrutura de _firewall_ do RouterOS possui forte equivalência conceitual e sintática com o utilitário `iptables` (e seu sucessor `nftables`), visto que o RouterOS utiliza o próprio subsistema *netfilter* do kernel Linux em sua base, sendo assim o comando fica:

* **`/ip firewall nat add`**: Acessa a tabela de NAT do _firewall_ e insere uma nova regra de manipulação de pacotes (equivalente à tabela `-t nat` no `iptables`).
* **`chain=srcnat`**: Define a cadeia de processamento de NAT de origem (*Source NAT*). Corresponde exatamente à cadeia `POSTROUTING` do `iptables`, na qual os pacotes são inspecionados e alterados logo antes de deixarem o roteador.
* **`out-interface=ether1`**: Condição de correspondência que especifica que a regra só será aplicada ao tráfego que estiver saindo ativamente pela interface WAN (`ether1`).
* **`action=masquerade`**: Ação a ser executada no pacote. Diferente de um *Source NAT* estático (que exige um IP fixo configurado manualmente), a ação `masquerade` obtém e aplica automaticamente o endereço IP atribuído à interface de saída (`ether1`). No `iptables`, isso equivale ao argumento `-j MASQUERADE`.

Após a inserção do comando, é possível inspecionar a tabela de NAT para certificar que a regra foi aceita pelo sistema operacional por meio do comando `/ip firewall nat print`, tal como:

```bash
[admin@MikroTik] > ip firewall nat print
Flags: X - DISABLED, I - INVALID; D - DYNAMIC 
 0    chain=srcnat action=masquerade out-interface=ether1 
```

A saída do comando anterior exibe a regra cadastrada na posição de índice `0`. A ausência das sinalizações **`X`** (*Disabled*) e **`I`** (*Invalid*) confirma que a regra está ativa e operante no sistema. A partir deste momento, todo pacote originado na **LAN1** com destino à rede WAN ou à Internet terá seu endereço de origem traduzido para o IP da interface `ether1`, viabilizando a trafegabilidade bidirecional na rede.

Após a aplicação do endereçamento IP na interface local e o estabelecimento da regra de mascaramento (NAT) na interface WAN, a infraestrutura fica totalmente conexa. Para validar a conectividade de ponta a ponta, o administrador de rede deve realizar testes de verificação a partir das estações de trabalho da **LAN1** (**Host-1** e **Host-2**). Um primeiro teste consiste no envio de requisições ICMP para o nó local adjacente via comando `ping 192.168.122.3` (Host-3), assegurando que o roteamento entre as sub-redes internas está funcional. Em seguida, para homologar a tradução de endereços e a saída efetiva para a rede externa, executa-se o teste de alcance a um servidor público da Internet, como o comando `ping 8.8.8.8`. O sucesso em ambos os testes confirma que os pacotes estão sendo corretamente roteados e mascarados pelo MikroTik.

Em conclusão, a atribuição estática de endereços IP às interfaces físicas aliada à configuração do NAT (*masquerade*) estabelece o conjunto mínimo e fundamental de rotinas para a integração de uma rede local privada à Internet. Embora o RouterOS ofereça uma vasta gama de recursos avançados de filtragem, controle de tráfego e serviços de infraestrutura, a correta execução e validação dessas etapas básicas de camada de rede garantem a base sólida sobre a qual todas as demais políticas de segurança e gerenciamento corporativo serão construídas.

## Importando e exportando configurações do roteador (Backup)

Diferente de outros sistemas operacionais de rede nos quais as alterações ficam armazenadas temporariamente na memória RAM até a execução de um comando explícito de gravação, o MikroTik RouterOS grava todas as alterações **instantaneamente** na sua memória não volátil (_flash_). Isso significa que não há o risco de perder as configurações realizadas em caso de um reinício inesperado do sistema.

Ainda assim, a criação de cópias de segurança é uma prática indispensável na administração de infraestruturas. O gerenciamento de _backups_ permite ao administrador registrar o histórico das alterações, criar documentação auditável e garantir planos de recuperação de desastres (*disaster recovery*), assegurando que o roteador possa retornar rapidamente a um estado operacional consistente após falhas de hardware, erros humanos ou modificações indevidas durante testes.

No RouterOS, existem dois métodos complementares para salvar o estado do equipamento: a **exportação em texto simples (`.rsc`)** e a criação do **backup binário do sistema (`.backup`)**.

### 1. Exportação em Texto Simples (`/export`)

O comando `/export` gera um _script_ em texto simples contendo a lista completa de comandos executados no dispositivo que diferem das configurações de fábrica. Esse método é ideal para fins de documentação, auditoria, migração parcial de regras ou aplicação das mesmas configurações em equipamentos de modelos distintos.

```bash
[admin@MikroTik] > /export 
# 2026-07-24 13:21:24 by RouterOS 7.22.1
# system id = 0dUx1SdluUA
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
/ip address
add address=10.1.0.254/24 interface=ether2 network=10.1.0.0
/ip dhcp-client
add interface=ether1 name=client1
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
```

O resultado exibe de forma legível e estruturada todos os parâmetros configurados nas seções do sistema:

* O cabeçalho detalha a data, a hora, a versão exata do RouterOS e o identificador do sistema (`system id`).
* Em seguida, os blocos de comando refletem exatamente os parâmetros atribuídos anteriormente, tais como a definição do endereço IP na interface `ether2`, o cliente DHCP ativado na `ether1` e a regra de mascaramento (NAT).
* Para salvar essa saída diretamente em um arquivo no roteador, basta utilizar o argumento `file`, como em `/export file=backup_export1`.

### 2. Criação de Backup Binário (`.backup`)

Enquanto a exportação gera um _script_ de comandos, o _backup_ binário cria uma **imagem completa do estado do sistema**. Ele armazena não apenas as configurações de rede, mas também arquivos do sistema, usuários, senhas encriptadas, chaves SSH e identificadores de sistema. Por conter informações sensíveis, é altamente recomendável definir uma senha para a criptografia do arquivo gerado.

Para criar o arquivo de backup binário, executa-se o comando `/system/backup/save`, tal como:

```bash
[admin@MikroTik] > /system/backup/save name=backup1 password="123mudar"
Saving system configuration
Configuration backup saved
```

Sendo que no comandando anterior:

* **`name=backup1`**: Define o nome base do arquivo (o sistema adiciona automaticamente a extensão `.backup`).
* **`password="123mudar"`**: Criptografa o arquivo de _backup_ com a senha especificada, impedindo a leitura indevida por terceiros caso o arquivo seja transferido para fora do equipamento.

### 3. Verificação dos Arquivos Salvos no Sistema

Todos os _backups_ e arquivos exportados ficam armazenados no repositório de arquivos local do MikroTik. Para listar o conteúdo do repositório e confirmar que o arquivo foi gravado corretamente, utiliza-se o comando `/file/print`:

```bash
[admin@MikroTik] > /file/print   
Columns: NAME, TYPE, SIZE, LAST-MODIFIED
# NAME                      TYPE       SIZE     LAST-MODIFIED      
0 backup1.backup            backup     21.7KiB  2026-07-24 13:47:09
1 skins                     directory           2026-07-22 17:43:57
2 auto-before-reset.backup  backup     14.0KiB  2026-07-24 13:42:53
```

A listagem anterior exibe o arquivo `backup1.backup` com seu respectivo tamanho e data de modificação. O arquivo identificado como `auto-before-reset.backup` representa uma imagem gerada automaticamente pelo próprio RouterOS antes de procedimentos de reinicialização ou restauração de fábrica.

### 4. Restauração do Backup Binário

Caso seja necessário reverter o roteador a um estado salvo anteriormente, utiliza-se o comando `/system/backup/load`:

```bash
[admin@MikroTik] > /system/backup/load name=backup1.backup 
password: ********
Restore and reboot? [y/N]:
```
Então o procedimento de restauração é composto dos seguintes passos:

1. O comando deve indicar o nome exato do arquivo cadastrado no repositório (`name=backup1.backup`).
2. Caso o arquivo tenha sido criado com criptografia, o sistema solicitará a senha definida no momento do salvamento.
3. Para garantir que todas as definições de hardware e licenças sejam aplicadas corretamente, a restauração exige a confirmação do usuário (`Restore and reboot? [y/N]`) e força o **reinício automático do roteador**. Após a reinicialização, o equipamento retornará operando estritamente com as configurações armazenadas naquele arquivo de _backup_.

A prática rigorosa de geração e armazenamento de cópias de segurança constitui uma das rotinas mais estratégicas da gestão de infraestrutura de TI. A disponibilidade de um _backup_ atualizado e devidamente testado preserva o trabalho do administrador de rede e minimiza significativamente o tempo de inatividade (*downtime*) em situações críticas. Sobretudo em cenários de desastre ou falha catastrófica — tais como descargas elétricas, curtos-circuitos ou incêndios que comprometam fisicamente o dispositivo —, ter o arquivo de configuração resguardado em um repositório externo permite a substituição do hardware danificado e o restabelecimento integral dos serviços em poucos minutos, garantindo a continuidade do negócio com o mínimo de impacto operacional.

## Serviços de Infraestrutura e Gerenciamento no RouterOS

Além de desempenhar as funções roteamento, um roteador MikroTik com o sistema operacional RouterOS possui a capacidade de executar nativamente diversos servidores e serviços essenciais de rede. Essa integração centraliza a gestão da infraestrutura, otimiza o uso de recursos de hardware e simplifica o fluxo de administração sem a necessidade de implantar servidores dedicados adicionais para tarefas básicas.

Dentre as principais aplicações disponibilizadas diretamente pelo dispositivo, destacam-se:

* **Acesso Remoto Seguro (SSH e SFTP):** O protocolo SSH possibilita o acesso criptografado via linha de comando para a gestão do equipamento. Além disso, o subsistema SSH viabiliza conexões via SFTP/SCP, permitindo que o administrador realize a transferência automatizada e segura dos arquivos de *backup* ou *export* gerados no roteador para um servidor ou computador remoto de armazenamento.
* **Interface de Gerenciamento Web (WebFig / HTTP):** O serviço HTTP (porta 80) disponibiliza o WebFig, uma interface gráfica completa acessível diretamente pelo navegador web para administração e monitoramento do sistema.
* **Servidor DNS Local:** O RouterOS permite ativar um servidor DNS integrando recursos de armazenamento em *cache* e mapeamento estático. Essa funcionalidade proporciona maior agilidade na resolução de nomes para os hosts da LAN, reduz o tráfego externo para a Internet e permite o cadastro de registros DNS locais para equipamentos da rede interna.
* **Servidor DHCP:** A distribuição automática de parâmetros de rede para as estações de trabalho é uma das atribuições mais críticas em uma topologia. Ao atuar como servidor DHCP, o MikroTik atribui dinamicamente aos clientes o endereço IP, a máscara de sub-rede, o *gateway* padrão e os servidores DNS, eliminando a necessidade de configuração manual em cada dispositivo final.

É claro que um roteador, tal como o MikroTik pode ter ainda outras funções, tais como servidor de horas (NTP), SNMP, Firewall, QoS, etc.

### Inspecionando os Serviços de Acesso e Gerenciamento Ativos

Para listar as portas, protocolos e o status operacional dos serviços de rede destinados ao gerenciamento do próprio RouterOS, é possível utilizar o comando `/ip/service/print`, tal como:

```bash
[admin@MikroTik] > ip/service/print 
Flags: D - DYNAMIC; X - DISABLED, I - INVALID
Columns: NAME, PORT, PROTO, CERTIFICATE, VRF, MAX-SESSIONS
 #      NAME           PORT  PROTO  CERTIFICATE  VRF   MAX-SESSIONS
 0      ftp                       21  tcp                 main            20
 1      ssh                     22  tcp                 main            20
 2      telnet                  23  tcp                 main            20
 3 D  dhcpclient          68  udp                                   
 4      www                   80  tcp                 main            20
 5  X www-ssl             443  tcp    none         main            20
 6      reverse-proxy   443  tcp    none         main            20
 7 D  btest                   2000  tcp                                   
 8 D  discover              5678  udp                                   
 9      winbox                8291  tcp                 main            20
10    api                       8728  tcp                 main            20
11    api-ssl                  8729  tcp    none         main            20
```

A listagem anterior fornece um detalhamento completo sobre os pontos de escuta do sistema operacional:

1. **Protocolos de Acesso Padronizados:** O sistema mantém habilitados por padrão serviços como **`ftp`** (porta 21), **`ssh`** (porta 22) e **`www`** (porta 80), permitindo o gerenciamento por múltiplos canais.
2. **Serviços Proprietários e de API:** O serviço **`winbox`** (porta 8291) atende às conexões da ferramenta gráfica proprietária da MikroTik, enquanto as portas de **`api`** (8728) e **`api-ssl`** (8729) permitem a integração e automação com sistemas externos de terceiros.
3. **Sinalização de Estado (*Flags*):**
* A flag **`X`** (*Disabled*) na entrada `5` (**`www-ssl`**) indica que a interface web criptografada via HTTPS está desativada administrativamente no momento (geralmente por falta da importação prévia de um certificado digital válido).
* A flag **`D`** (*Dynamic*) em serviços como **`dhcpclient`** (porta 68) e **`discover`** (porta 5678) indica que estas portas de escuta foram criadas e gerenciadas automaticamente pelo próprio RouterOS para responder a funções dinâmicas do sistema.

Em suma, os serviços listados encontram-se disponíveis no roteador para o gerenciamento e a operação do sistema. A partir dessa estrutura, é possível estabelecer conexões remotas seguras via SSH utilizando o comando `ssh admin@192.168.122.118`, fornecendo a senha configurada no ambiente para administrar o equipamento por linha de comando, além de empregar utilitários como `scp` e `sftp` para a transferência de arquivos. De forma análoga, a interface web pode ser acessada por meio do endereço `[http://192.168.122.118](http://192.168.122.118)`, permitindo a navegação e a alteração dos parâmetros do roteador por navegador, entre outras funcionalidades integradas.

Devido à arquitetura modular do RouterOS, a verificação completa dos serviços e servidores em execução no equipamento exige a inspeção de submenus específicos na árvore de comandos. A Tabela 1 sintetiza as principais instruções para a verificação do estado dos serviços de infraestrutura, gerenciamento e conectividade disponibilizados pelo sistema.

**Tabela 1:** Comandos de inspeção de serviços e servidores no RouterOS.

| Comando | Função / Utilidade |
| --- | --- |
| `/ip/service/print` | Lista os serviços de acesso ao roteador (SSH, Telnet, WinBox, HTTP, HTTPS, API e API-SSL), indicando quais estão habilitados, suas portas e sub-redes permitidas. |
| `/ip/dns/print` | Exibe a configuração do serviço DNS, incluindo os servidores externos consultados e a ativação de respostas a requisições locais (`allow-remote-requests`). |
| `/ip/dhcp-server/print` | Lista os servidores DHCP ativos, indicando a interface de vinculação, o pool de endereços e o status de operação. |
| `/ip/hotspot/print` | Exibe os servidores Hotspot configurados para autenticação e controle de acesso de usuários na rede. |
| `/snmp/print` | Mostra os parâmetros do serviço SNMP, empregado no monitoramento e na coleta de métricas de desempenho do roteador. |
| `/system/ntp/server/print` | Exibe a configuração do servidor NTP, responsável pelo fornecimento de sincronização de horário para os dispositivos da rede. |
| `/interface/pppoe-server/server/print` | Lista os servidores PPPoE ativos para a autenticação e o provimento de acesso a clientes via camada de enlace. |
| `/interface/l2tp-server/server/print` | Exibe o estado e os parâmetros do servidor de VPN baseada no protocolo L2TP (*Layer 2 Tunneling Protocol*). |
| `/interface/sstp-server/server/print` | Apresenta as configurações do servidor de VPN SSTP (*Secure Socket Tunneling Protocol*), operando sobre conexões TLS/HTTPS. |
| `/interface/ovpn-server/server/print` | Exibe a configuração do servidor OpenVPN, detalhando portas, certificados digitais e algoritmos de criptografia aceitos. |
| `/interface/wireguard/print` | Lista as interfaces de túnel VPN baseadas no protocolo WireGuard, indicando as portas de escuta e as chaves públicas associadas. |
| `/ip/smb/print` | Exibe a configuração do serviço SMB, utilizado para o compartilhamento de arquivos armazenados nos dispositivos de memória do roteador. |

Ressalta-se que o aprofundamento em cada um desses serviços excede o escopo deste texto. No entanto, é dever do administrador de redes mapear de forma contínua os processos ativos no equipamento. A manutenção de serviços desnecessários ou indevidamente configurados amplia a superfície de ataque do dispositivo, de modo que a desativação de protocolos não utilizados constitui uma prática fundamental para manter a segurança do roteador e da rede.

## Rede com VLANs

Nas arquiteturas de rede modernas, a segmentação lógica de domínios de difusão (*broadcast*) por meio do uso de **VLANs** (*Virtual Local Area Networks*, padronizadas pelo IEEE 802.1Q) tornou-se uma prática padrão de projeto. Em vez de depender unicamente de infraestruturas físicas separadas para isolar diferentes setores, serviços ou perfis de usuários, as VLANs permitem dividir uma única topologia física em múltiplas redes lógicas independentes.

A adotação massiva de VLANs nas redes corporativas justifica-se por três fatores fundamentais:

* **Segurança e Isolamento de Tráfego:** Ao criar domínios de *broadcast* isolados, o tráfego de um determinado grupo de trabalho (como a rede administrativa) fica impedido de atingir outros segmentos (como a rede de visitantes ou de servidores) sem autorização prévia.
* **Desempenho e Otimização do Meio:** A delimitação do alcance dos pacotes de *broadcast* reduz o impacto do tráfego de inundação no processamento dos equipamentos e na largura de banda dos links de comunicação.
* **Flexibilidade e Escalabilidade:** Permite alterar a estrutura organizacional e as políticas de acesso dos usuários de forma puramente lógica via software, sem a necessidade de reestruturação do cabeamento estruturado físico.

Por definição, interfaces que pertencem a VLANs distintas operam em sub-redes totalmente isoladas na Camada 2 (Enlace) e não conseguem se comunicar diretamente através de equipamentos de comutação (*switches*) puramente L2. É justamente nesse ponto que a presença do roteador torna-se indispensável.

Em suma, como a segmentação virtual é o modelo predominante no projeto de infraestruturas de TI modernas, é absolutamente comum e esperado que o administrador de redes depare-se com a necessidade de configurar interfaces de VLAN, entroncamentos 802.1Q e políticas de roteamento inter-VLAN em roteadores corporativos, incluindo os equipamentos que executam o RouterOS.

Para exemplificar a aplicação prática de redes locais virtuais e o roteamento inter-VLAN em uma infraestrutura corporativa, o cenário anterior será expandido com a inclusão de um **Switch gerenciável (Switch1)** conectado diretamente à interface **`ether3`** do roteador MikroTik.

Nesta nova topologia, o enlace entre o MikroTik e o Switch1 atuará como um tronco IEEE 802.1Q (*Trunk*), transportando o tráfego marcado de duas novas sub-redes isoladas. O objetivo é configurar o roteador MikroTik para atuar como o *gateway* padrão de ambas as VLANs, realizando o roteamento do tráfego entre elas (roteamento inter-VLAN), bem como provendo a comunicação destas com a **LAN1**, com o **Host-3** e com a Internet via **NAT1**. Tal rede é ilustrada na Figura 2.

| ![rede](imagens/rede-VLAN.png) |
|:--:|
| Figura 2 - Cenário de rede com VLAN para configuração com Mikrotik

Com a expansão da topologia, apresentada na Figura 2, a infraestrutura passa a ser dividida nos segmentos de rede e com os endereçamentos detalhados na Tabela 2.

**Tabela 2:** Mapeamento dos segmentos de rede e subinterfaces do MikroTik.

| Segmento / Nome | Interface no MikroTik | Identificador (VLAN ID) | Sub-rede / Máscara | IP do Gateway (MikroTik) |
| --- | --- | --- | --- | --- |
| **WAN / Externa** | `ether1` | N/A (Física) | `192.168.122.0/24` | `192.168.122.118` |
| **LAN1** | `ether2` | N/A (Física) | `10.1.0.0/24` | `10.1.0.254` |
| **VLAN2** | `ether3` (Subinterface `VLAN2`) | `VLAN ID 2` | `10.2.0.0/24` | `10.2.0.254` |
| **VLAN3** | `ether3` (Subinterface `VLAN3`) | `VLAN ID 3` | `10.3.0.0/24` | `10.3.0.254` |

A Tabela 3 apresenta a distribuição dos novos hosts na infraestrutura, indicando seus respectivos endereços IP, gateways e o elemento de conexão física/lógica no cenário.

**Tabela 3:** Configuração de endereçamento dos novos hosts do laboratório.

| Dispositivo | Endereço IP | Gateway Padrão | Elemento de Conexão | Porta no Switch/Hub |
| --- | --- | --- | --- | --- |
| **Host-4** | `10.2.0.4/24` | `10.2.0.254` | Switch1 (VLAN2) | `e1` (Modo Access) |
| **Host-5** | `10.3.0.5/24` | `10.3.0.254` | Switch1 (VLAN3) | `e2` (Modo Access) |

O Switch1 possui sua porta **`e0`** configurada em modo *Trunk* (802.1Q) e conectada diretamente à porta **`ether3`** do MikroTik. Consequentemente, a porta `ether3` do roteador receberá todos os quadros vindo do Switch1 devidamente etiquetados (*tagged*) com as IDs das VLANs 2 e 3.

A partir dessa estrutura, o MikroTik inspecionará as marcações 802.1Q na porta `ether3`, desempacotará o cabeçalho e encaminhará os pacotes entre as sub-redes **VLAN2**, **VLAN3**, **LAN1** e a rede **WAN**, garantindo a conectividade total entre todos os hosts do laboratório e mantendo o isolamento de camada de enlace entre os domínios de *broadcast*.

### Configuração das Interfaces de VLAN e Endereçamento no MikroTik

Com o planejamento das sub-redes definido, procede-se com a criação das subinterfaces virtuais de VLAN no RouterOS atreladas à porta tronco **`ether3`**, seguidas da atribuição dos seus respectivos endereços IP de *gateway*, isso é feito nos passos a seguir.

#### 1. Configuração da VLAN2 (`VLAN ID 2`)

O primeiro passo consiste na criação da subinterface virtual para a **VLAN2** e no cadastramento do seu endereço IP de *gateway* (`10.2.0.254/24`), o que se dá pelos seguintes comandos:

```bash
[admin@MikroTik] > interface/vlan/add name=vlan2 vlan-id=2 interface=ether3
[admin@MikroTik] > ip address add address=10.2.0.254/24 interface=vlan2
```
Os comandos anteriores realizam em ordem as seguintes tarefas:

* **`/interface/vlan/add`**: Acessa o submenu de gerenciamento de VLANs do RouterOS para adicionar uma nova subinterface lógica de Camada 2 (uma placa de rede virtual).
* **`name=vlan2`**: Define a nomenclatura de identificação da subinterface no sistema.
* **`vlan-id=2`**: Especifica o identificador numérico da VLAN segundo o padrão IEEE 802.1Q. O roteador utilizará esse valor para filtrar e etiquetar (*tag*) os quadros que trafegarem por essa interface virtual - esse valor deve ser o mesmo utilizado para identificar o VLAN no switch.
* **`interface=ether3`**: Associa a subinterface lógica à porta física **`ether3`**, indicando por qual interface física o tráfego marcado (*tagged*) deve ser transmitido.
* **`/ip address add address=10.2.0.254/24 interface=vlan2`**: Atribui o endereço IP `10.2.0.254/24` diretamente à subinterface virtual `vlan2`, estabelecendo o *gateway* de Camada 3 para os dispositivos pertencentes a essa VLAN.

### 2. Configuração da VLAN3 (`VLAN ID 3`)

De forma análoga, realiza-se a criação da subinterface para a **VLAN3** atrelada à mesma interface tronco `ether3`, atribuindo-lhe o endereço de *gateway* `10.3.0.254/24`:

```bash
[admin@MikroTik] > interface/vlan/add name=vlan3 vlan-id=3 interface=ether3  
[admin@MikroTik] > ip address add address=10.3.0.254/24 interface=vlan3

```

Após a criação das subinterfaces e atribuição dos IPs, é possível executar o comando `/ip address print` para validar a tabela de endereçamento do roteador, tal como:

```bash
[admin@MikroTik] > ip address print  
Flags: D - DYNAMIC
Columns: ADDRESS, NETWORK, INTERFACE, VRF
#   ADDRESS            NETWORK        INTERFACE  VRF 
0   10.1.0.254/24       10.1.0.0       ether2     main
1 D 192.168.122.118/24  192.168.122.0  ether1     main
2   10.2.0.254/24       10.2.0.0       vlan2      main
3   10.3.0.254/24       10.3.0.0       vlan3      main

```

A saída confirma a coexistência das quatro redes no equipamento. As entradas estáticas de índice `2` (`vlan2`) e `3` (`vlan3`) apresentam suas respectivas redes calculadas (`10.2.0.0` e `10.3.0.0`), confirmando que o roteador está pronto para realizar o roteamento de Camada 3 entre essas subinterfaces.

Para verificar especificamente o status operacional das subinterfaces de VLAN e a porta física à qual estão vinculadas, utiliza-se o comando `/interface/vlan/print`. Veja o exemplo:

```bash
[admin@MikroTik] > interface/ vlan/ print 
Flags: R - RUNNING
Columns: NAME, MTU, ARP, VLAN-ID, INTERFACE
#   NAME    MTU  ARP      VLAN-ID  INTERFACE
0 R vlan2  1500  enabled        2  ether3   
1 R vlan3  1500  enabled        3  ether3

```

A listagem exibe as interfaces `vlan2` e `vlan3` atreladas à porta `ether3`. A presença da flag **`R`** (*Running*) confirma que a interface física `ether3` possui enlace ativo (*link up*), permitindo que ambas as subinterfaces lógicas entrem imediatamente em estado operacional.

A criação das subinterfaces virtuais aliada ao correto endereçamento IP conclui a etapa de configuração do roteamento inter-VLAN no MikroTik. A partir deste ponto, o roteador possui todas as rotas diretamente conectadas em sua tabela de roteamento, estando apto a encaminhar pacotes entre domínios de *broadcast* distintos.

Para verificar a solução e validar o funcionamento integral da rede, o administrador pode realizar testes práticos de conectividade a partir dos clientes da topologia:

1. **Teste de Conectividade Local (Gateway):** A partir do **Host-4** (`10.2.0.4`), executar `ping 10.2.0.254` para validar a comunicação de camada 2/3 com a subinterface `vlan2`.
2. **Teste de Roteamento Inter-VLAN:** A partir do **Host-4** (`10.2.0.4`), disparar requisições ICMP para o **Host-5** (`ping 10.3.0.5`), confirmando que o MikroTik está recebendo o tráfego com a tag 2 pela `ether3`, realizando o roteamento interno e devolvendo os pacotes com a tag 3 pela mesma interface.
3. **Teste de Roteamento Inter-LAN e Acesso Externo:** Executar testes a partir de qualquer host das VLANs em direção ao **Host-1** (`ping 10.1.0.1`), ao **Host-3** (`ping 192.168.122.3`) e a um destino na Internet (`ping 8.8.8.8`). O sucesso nesses testes valida que as regras de roteamento e a regra de NAT (*masquerade*) previamente aplicada na `ether1` estão cobrindo adequadamente as novas sub-redes `10.2.0.0/24` e `10.3.0.0/24`.

Em síntese, a implementação de subinterfaces virtuais de VLAN diretamente atreladas a uma porta tronco do RouterOS consolida uma solução elegante, eficiente e amplamente adotada para o roteamento inter-VLANs. Essa abordagem permite isolar domínios de *broadcast* em nível de camada de enlace nos switches e, simultaneamente, centralizar as políticas de roteamento e segurança no MikroTik. Vale ressaltar que o RouterOS também oferece alternativas mais avançadas para a manipulação de VLANs, como o uso de *Bridges* com a funcionalidade de *VLAN Filtering* ativada — método que viabiliza a comutação de camada 2 diretamente entre as portas do próprio dispositivo. Contudo, essa arquitetura baseada em *bridge* foge ao escopo do presente estudo, visto que o objetivo central desta abordagem consistiu em explorar estritamente a função primária de roteamento de camada 3 entre sub-redes distintas.

# Configuração do Servidor DHCP no MikroTik

O serviço **DHCP** (*Dynamic Host Configuration Protocol*) é um protocolo de camada de aplicação responsável por automatizar a atribuição de parâmetros de rede aos dispositivos clientes. Em vez de exigir que o administrador configure manualmente o endereço IP, a máscara de sub-rede, o *gateway* padrão e os servidores DNS em cada estação de trabalho, o servidor DHCP entrega todas essas informações de forma dinâmica e temporária no momento em que o dispositivo se conecta à rede.

Em roteadores corporativos como os equipamentos MikroTik, a implementação do servidor DHCP é uma das tarefas mais fundamentais. Ela reduz drasticamente a complexidade operacional, evita conflitos de endereçamento IP na rede local e garante que novos dispositivos recebam instantaneamente as definições corretas para navegar na Internet e acessar os recursos internos.

Para ilustrar a criação e a ativação desse serviço via linha de comando no RouterOS, utilizaremos a **LAN1** da nossa rede de exemplo (associada à interface **`ether2`**, na sub-rede `10.1.0.0/24`). Tal configuração é apresentada a seguir.

## 1. Definição do Bloco de Endereços (*IP Pool*)

O primeiro passo para a implementação do serviço consiste na criação de um *pool* de endereços IP. Esse bloco delimita a faixa de IP contínua que o servidor DHCP terá à disposição para distribuir dinamicamente às estações de trabalho da LAN1.

Para criar o bloco de endereços, utiliza-se o comando `/ip pool add`, tal como:

```bash
[admin@MikroTik] > ip pool add name=dhcp_lan1 ranges=10.1.0.10-10.1.0.100
```

O comando anterior tem as seguintes opções, em detalhe:

* **`/ip pool add`**: Caminho no menu do RouterOS destinado ao gerenciamento de intervalos de endereços IP reserváveis para serviços como DHCP, VPNs e Hotspot.
* **`name=dhcp_lan1`**: Define o nome de identificação do bloco de endereços dentro do sistema operacional.
* **`ranges=10.1.0.10-10.1.0.100`**: Especifica o intervalo inicial e final de endereços IPv4 que serão concedidos dinamicamente. Neste caso, reserva 91 endereços para os clientes, mantendo os demais IPs da sub-rede `10.1.0.0/24` (como o `.254` do *gateway*) fora da distribuição automática.


## 2. Configuração dos Parâmetros da Rede (*DHCP Network*)

Após definir o intervalo de IPs a ser distribuído, é necessário indicar ao sistema quais informações complementares de rede devem ser enviadas aos clientes juntamente com o IP individual. Essas informações incluem o endereço da sub-rede, o *gateway* padrão e o servidor de nomes (DNS).

Para declarar as propriedades da rede, executa-se o comando `/ip dhcp-server network add`, veja o comando completo a seguir:

```bash
[admin@MikroTik] > ip dhcp-server network add address=10.1.0.0/24 gateway=10.1.0.254 dns-server=10.1.0.254
```
Então, as opções do comando anterior, do exemplo, fazem o seguinte:

* **`/ip dhcp-server network add`**: Acessa a tabela de definições de escopo do servidor DHCP para vincular parâmetros de rede a um bloco de sub-rede específico.
* **`address=10.1.0.0/24`**: Define a sub-rede de alcance desta regra. Sempre que um cliente solicitar um IP pertencente a esta faixa, receberá os parâmetros associados a esta entrada.
* **`gateway=10.1.0.254`**: Informa aos clientes qual é o endereço IP do roteador que atuará como a saída padrão (*default gateway*) da rede.
* **`dns-server=10.1.0.254`**: Especifica o endereço do servidor DNS que resolverá os nomes para os clientes da LAN1 (neste caso, apontando para o próprio IP da interface `ether2` do MikroTik).

## 3. Ativação do Servidor DHCP

Com o bloco de IPs e as opções de rede definidos, a etapa seguinte é criar a instância do servidor DHCP propriamente dita, vinculando-a à interface física onde as requisições dos clientes serão recepcionadas.

Para criar e habilitar o servidor DHCP na interface `ether2`, executa-se o comando `/ip dhcp-server add`:

```bash
[admin@MikroTik] > ip dhcp-server add name=dhcp_lan1_server interface=ether2 address-pool=dhcp_lan1 lease-time=1d disabled=no
```
Então o comando anterior, que efetivamente habilita o servidor DHCP, tem em detalhes as seguintes opções/parâmetros:

* **`/ip dhcp-server add`**: Adiciona uma nova instância de serviço DHCP vinculada a uma interface de rede específica.
* **`name=dhcp_lan1_server`**: Nome do processo do servidor DHCP registrado no sistema.
* **`interface=ether2`**: Interface de rede onde o servidor ficará escutando as requisições de transmissão (*broadcast*) DHCP enviadas pelos clientes da LAN1.
* **`address-pool=dhcp_lan1`**: Associa a instância do serviço ao bloco de endereços previamente criado no Passo 1.
* **`lease-time=1d`**: Define o tempo de concessão (*lease*) do endereço IP. Neste exemplo, o cliente manterá a posse do IP por até 1 dia (`1d`) antes de requerer a renovação da licença junto ao servidor.
* **`disabled=no`**: Instrução que força a habilitação e o início imediato do serviço no sistema operacional.


## Verificação do DHCP em Execução

Por fim, após concluir os comandos de criação, o administrador deve consultar a tabela de servidores DHCP do RouterOS para verificar se a instância está ativa e associada aos recursos corretos.

A verificação do estado da instância é feita com o comando `/ip dhcp-server print`:

```bash
[admin@MikroTik] > ip dhcp-server print
Columns: NAME, INTERFACE, ADDRESS-POOL, LEASE-TIME
# NAME              INTERFACE  ADDRESS-POOL  LEASE-TIME
0 dhcp_lan1_server  ether2     dhcp_lan1     1d        
```

Desta forma, a saída anterior, exibe a listagem do servidor cadastrado na posição de índice `0`:

* O processo **`dhcp_lan1_server`** encontra-se atrelado à interface física **`ether2`**.
* O campo **`ADDRESS-POOL`** confirma a utilização do bloco de endereços **`dhcp_lan1`**.
* O campo **`LEASE-TIME`** confirma a concessão válida pelo período de **`1d`** (24 horas).
* A ausência da sinalização **`X`** (*Disabled*) indica que o servidor DHCP está totalmente ativo e pronto para responder às solicitações dos clientes na **LAN1**.


Em suma, a sequência de comandos apresentada demonstra a construção de um serviço DHCP essencial, configurado de forma funcional para prover o endereçamento dinâmico e as opções de rede para uma sub-rede privada, como a **LAN1**.

Para validar o serviço recém-criado, daremos início aos testes práticos de atribuição. O primeiro passo consiste em consultar o estado da tabela de concessões do RouterOS para verificar se já existe algum dispositivo na rede que tenha obtido parâmetros de rede por meio do nosso servidor DHCP.

```bash
[admin@MikroTik] > ip dhcp-server lease print
```
O resultado do comando anterior provavelmente será "nada", já que não temos nenhum cliente utilizando o servidor DHCP até o momento. Assim, para forçar uma requisição de rede via DHCP, utilizaremos o **Host-2** (uma estação de trabalho com sistema operacional Linux pertencente à **LAN1** - ver Figura 1 ou Figura 2). Desta forma, a partir do terminal do cliente, executa-se o utilitário `dhcpcd` na interface de rede `eth0` para solicitar um novo endereço ao servidor, tal como:

```bash
root@Host-2:/# dhcpcd eth0
DUID 00:04:4c:4c:45:44:00:36:32:10:80:34:b3:c0:4f:35:34:32
eth0: IAID 8c:e3:24:00
eth0: soliciting an IPv6 router
eth0: soliciting a DHCP lease
eth0: offered 10.1.0.100 from 10.1.0.254
eth0: probing address 10.1.0.100/24
eth0: leased 10.1.0.100 for 86400 seconds
eth0: adding route to 10.1.0.0/24
eth0: adding default route via 10.1.0.254
forked to background, child pid 504
```

Analisando a saída do comando no Host-2, observa-se o fluxo completo do protocolo: o cliente solicita a concessão (`soliciting a DHCP lease`), recebe a oferta do IP **`10.1.0.100`** vinda do servidor **`10.1.0.254`** (`offered 10.1.0.100 from 10.1.0.254`) e confirma o contrato pelo período de 86.400 segundos (equivalente a 1 dia). Em seguida, o próprio cliente aplica automaticamente a rota para a rede local (`10.1.0.0/24`) e a rota padrão (*default gateway*) apontando para o IP do MikroTik (`10.1.0.254`), finalizando o processo em segundo plano.

Após a conclusão da solicitação no cliente, podemos executar novamente o comando de verificação no MikroTik, para confirmar o registro do aluguel de IP, ativo na tabela do roteador, tal como:

```bash
[admin@MikroTik] > ip dhcp-server lease print
Flags: D - DYNAMIC
Columns: ADDRESS, MAC-ADDRESS, HOST-NAME, SERVER, STATUS, LAST-SEEN
#   ADDRESS      MAC-ADDRESS        HOST-NAME  SERVER            STATUS  LAST-SEEN
0 D 10.1.0.100  02:42:8C:E3:24:00  Host-2     dhcp_lan1_server  bound   35s
```

A saída do comando confirma o sucesso da operação: a entrada de índice `0` exibe o IP `10.1.0.100` associado ao endereço físico (`MAC-ADDRESS`) e ao nome de host `Host-2`. O estado **`bound`** na coluna *STATUS* indica que a concessão está estabelecida e ativa no servidor `dhcp_lan1_server`, enquanto a flag **`D`** (*Dynamic*) ratifica que a atribuição de IP foi realizada dinamicamente.

A automação desse processo evidencia a enorme praticidade na utilização de servidores DHCP no dia a dia da administração de redes. Em vez de exigir a intervenção manual em cada estação de trabalho — procedimento sujeito a erros e de difícil escala —, a centralização do serviço em um roteador robusto como o MikroTik assegura a distribuição rápida, precisa e padronizada de todas as configurações de rede, garantindo maior controle, agilidade e produtividade no gerenciamento da infraestrutura.

> **Nota:** Além do método passo a passo detalhado via linha de comando, o RouterOS disponibiliza o assistente interativo `/ip dhcp-server setup`, que guia o administrador simplificadamente através do processo de criação do *pool*, da rede e da instância do servidor em uma única sequência de perguntas.

Aqui está a seção redigida mantendo o mesmo padrão formal, técnico, didático e impessoal adotado ao longo do seu documento.

## Atribuição de Endereços IP Estáticos via DHCP (*Static Leases*)

Por padrão, o comportamento convencional de um servidor DHCP é distribuir endereços IP de forma puramente dinâmica a partir de um bloco de endereços (*pool*). Nesse modelo, os endereços atribuídos às estações de trabalho possuem um tempo de vida delimitado (*lease time*) e podem se alterar periodicamente.

Embora a dinamicidade e aleatoriedade seja ideal para computadores pessoais, notebooks e dispositivos móveis, existem elementos na infraestrutura cujo endereço IP deve permanecer estritamente inalterado e conhecido. É o caso de servidores de arquivos, impressoras de rede, roteadores e equipamentos de gerenciamento. Se o endereço IP de uma impressora ou servidor mudasse dinamicamente, os usuários e serviços da rede perderiam o acesso ao recurso.

Para conciliar a facilidade do gerenciamento centralizado via DHCP com a necessidade de ter endereços IP imutáveis, o administrador de redes pode utilizar o recurso de **reserva de IP estático via DHCP** (*Static Lease*). Esse mecanismo funciona associando de forma permanente o endereço físico de camada de enlace (**MAC Address**) da placa de rede do dispositivo a um endereço IP específico cadastrado no servidor. Dessa forma, toda vez que aquele equipamento solicitar um IP via DHCP, o servidor reconhecerá o seu endereço MAC e entregará sempre o mesmo IP reservado, mantendo a centralização da configuração sem a necessidade de configurar manualmente os parâmetros de rede na interface do cliente.

No MikroTik RouterOS, a transformação de uma concessão dinâmica em estática (ou a criação manual de uma reserva) é realizada no submenu `/ip dhcp-server lease`.

Para ilustrar o procedimento, utilizaremos como exemplo novamente o **Host-2**, atribuindo de forma fixa o IP `10.1.0.100` ao seu endereço físico de rede (`02:42:8C:E3:24:00`). Para isso executamos o comando a seguir:

```bash
[admin@MikroTik] > ip dhcp-server lease add address=10.1.0.100 mac-address=02:42:8C:E3:24:00 server=dhcp_lan1_server comment="IP Fixo do Host-2"
```

* **`/ip dhcp-server lease add`**: Acessa a tabela de concessões do servidor DHCP e insere uma nova regra manual de mapeamento.
* **`address=10.1.0.100`**: Define o endereço IP específico que será reservado e entregue exclusivamente ao dispositivo.
* **`mac-address=02:42:8C:E3:24:00`**: Especifica o endereço físico (MAC) de camada de enlace da placa de rede do cliente. É essa informação que garante a unicidade da associação.
* **`server=dhcp_lan1_server`**: Associa a reserva à instância do servidor DHCP que atende à interface onde o dispositivo está conectado (`ether2`).
* **`comment="IP Fixo do Host-2"`**: Campo de texto livre destinado à identificação e documentação do dispositivo na tabela do sistema.

> **Nota:** Caso o dispositivo já tenha obtido um IP dinâmico anteriormente e conste na tabela de concessões do MikroTik, o administrador pode simplificar esse procedimento executando o comando `/ip dhcp-server lease make-static números_do_índice`, o que converterá a entrada dinâmica existente em estática automaticamente.

Feito o comando anterior, podemos executar o comando `dhcpcd` no Host-2:

```bash
root@Host-2:/# dhcpcd eth0 -k
sending signal ALRM to pid 504
waiting for pid 504 to exit

root@Host-2:/# dhcpcd eth0   
DUID 00:04:4c:4c:45:44:00:36:32:10:80:34:b3:c0:4f:35:34:32
eth0: IAID 8c:e3:24:00
eth0: soliciting a DHCP lease
eth0: offered 10.1.0.100 from 10.1.0.254
eth0: probing address 10.1.0.100/24
eth0: soliciting an IPv6 router
eth0: leased 10.1.0.100 for 86400 seconds
eth0: adding route to 10.1.0.0/24
eth0: adding default route via 10.1.0.254
forked to background, child pid 618
```
> Note que anteriormente foi primeiro executado o comando `dhcpcd eth0 -k`, para desligar o cliente DHCP, executado no exemplo anterior, e depois o comando foi executado novamente, para garantir que o cliente DHCP pegue as novas configurações de rede.

Para confirmar o cadastro do IP fixo e verificar o seu status na tabela do RouterOS, executa-se o comando `/ip dhcp-server lease print`:

```bash
[admin@MikroTik] > ip dhcp-server lease print
Columns: ADDRESS, MAC-ADDRESS, HOST-NAME, SERVER, STATUS, LAST-SEEN
# ADDRESS     MAC-ADDRESS        HOST-NAME  SERVER            STATUS  LAST-SEEN
;;; IP Fixo do Host-2
0 10.1.0.100  02:42:8C:E3:24:00  Host-2     dhcp_lan1_server  bound   59s
```

Diferente da listagem anterior, a entrada de índice `0` **não exibe mais a flag `D**` (*Dynamic*). A ausência dessa flag ratifica que a concessão foi convertida com sucesso em uma reserva **estática e permanente**. A partir deste momento, mesmo que o *lease time* expire ou o Host-2 seja reiniciado, o servidor DHCP do MikroTik garantirá a entrega exclusiva do IP `10.1.0.100` a essa estação.

Saber discernir quando aplicar a alocação dinâmica ou a atribuição estática de endereços IP é uma competência fundamental para o planejamento e a manutenção de qualquer infraestrutura de rede. Enquanto a distribuição dinâmica provê escalabilidade, otimização do espaço de endereçamento e menor esforço de manutenção para estações de trabalho convencionais, a reserva estática via DHCP assegura a previsibilidade, a auditabilidade e a alta disponibilidade necessárias aos servidores e serviços essenciais da organização, mantendo o controle centralizado de toda a topologia em um único ponto no roteador.

## DHCP Relay

O DHCP Relay (ou retransmissor DHCP) é um agente ou funcionalidade de camada de rede responsável por interceptar as mensagens de solicitação DHCP enviadas em _broadcast_ pelos clientes locais e reencaminhá-las via _unicast_ para um servidor DHCP centralizado localizado em outra sub-rede. A sua utilização é indicada em arquiteturas de redes corporativas segmentadas em múltiplas VLANs ou sub-redes físicas, nas quais não é viável ou desejável implantar uma instância de servidor DHCP dedicada para cada segmento. Ao adotar o DHCP Relay nos roteadores das pontas, a organização centraliza toda a administração de escopos, reservas de IP e políticas de rede em um único servidor principal, reduzindo a complexidade de gerenciamento e garantindo maior consistência na alocação de endereços da infraestrutura.

Desta forma, no MikroTik RouterOS, a função de **DHCP Relay** (retransmissor DHCP), para configurar a retransmissão na interface local (por exemplo, `ether2`), apontando para um servidor DHCP remoto (como o IP `192.168.100.10`), utiliza-se o comando:

```bash
[admin@MikroTik] > ip dhcp-relay add name=relay_lan1 interface=ether2 dhcp-server=192.168.100.10 local-address=10.1.0.254 disabled=no
```
Em detalhes tal comando faz o seguinte:

* **`name=relay_lan1`**: Identificação do serviço de retransmissão no sistema.
* **`interface=ether2`**: Interface local onde os clientes enviarão as solicitações DHCP.
* **`dhcp-server=192.168.100.10`**: Endereço IP do servidor DHCP central/remoto que processará e responderá às concessões.
* **`local-address=10.1.0.254`**: Endereço IP da interface do próprio MikroTik nessa rede local. Esse IP é incluído no pacote retransmitido (campo *giaddr*) para que o servidor DHCP remoto saiba exatamente qual bloco/pool de IPs deve entregar para essa sub-rede.

> Important: Para a implementação prática do DHCP Relay em um ambiente de testes como o nosso, é indispensável desativar previamente o servidor DHCP local configurado na interface (por exemplo, executando /ip dhcp-server set [find interface=ether2] disabled=yes). Como o objetivo deste capítulo é consolidar a operação do MikroTik atuando diretamente como o servidor de endereçamento da rede local, não executaremos os testes práticos do modo Relay neste cenário.

Quando um *host* na **LAN1** inicia sua interface de rede e dispara uma mensagem de solicitação DHCP via *broadcast* (`DHCPDISCOVER`), o pacote é recebido pela interface local do MikroTik (ex.: `ether2`). Como a função de **DHCP Relay** está ativa nessa interface, o roteador captura essa requisição, insere o seu próprio IP local de *gateway* (`local-address`) no cabeçalho do pacote para indicar a qual sub-rede o cliente pertence e reencaminha a mensagem via *unicast* diretamente ao servidor DHCP centralizado no endereço `192.168.100.10`. Ao receber o pacote, o servidor central processa o escopo correspondente àquela sub-rede, seleciona um endereço IP disponível com suas opções de rede e responde via *unicast* ao MikroTik (`DHCPOFFER`). Por fim, o MikroTik recebe a resposta do servidor e a retransmite diretamente ao *host* solicitante na LAN1, finalizando com sucesso o processo de negociação do endereço.

Entre as principais **vantagens** desse método, destacam-se a centralização completa da gestão de escopos e reservas em um único servidor principal, o que facilita auditorias, backups e a aplicação de políticas padronizadas em grandes infraestruturas corporativas com múltiplas VLANs. Em contrapartida, as principais **desvantagens** envolvem a criação de um ponto único de falha (*single point of failure*) — caso o servidor DHCP centralizado ou o link de comunicação com ele fique indisponível, nenhuma sub-rede remota conseguirá obter novos endereços IP —, além de um ligeiro aumento na latência no processo de concessão, decorrente do tráfego adicional roteado até o servidor central.

Concluindo, a correta implementação e o gerenciamento de um servidor DHCP representam um pilar essencial para a eficiência operacional e a escalabilidade de qualquer infraestrutura de rede. A combinação entre a alocação dinâmica de IP para os clientes convencionais e a reserva estática (*static lease*) para os dispositivos críticos de infraestrutura garante um ambiente organizado, auditável e livre de conflitos de endereçamento. Ao centralizar esse serviço em um roteador robusto como o MikroTik, o administrador assegura a entrega precisa e automatizada das configurações de rede aos *hosts*, simplificando o suporte técnico e otimizando o tempo de implantação de novos dispositivos na organização.

## Configuração do Serviço de DNS Cache no MikroTik

O **DNS** (*Domain Name System*) é um serviço fundamental da infraestrutura de redes, responsável por traduzir nomes de domínio legíveis por humanos (como `exemplo.com.br`) em endereços IP numéricos compreendidos pelos roteadores e computadores. Em uma rede corporativa ou de laboratório, disponibilizar um servidor DNS local — ou um roteador atuando como *DNS Cache* — traz vantagens significativas de desempenho e eficiência. Ao responder diretamente às consultas dos computadores locais, o roteador armazena as respostas em sua memória RAM (*cache*), reduzindo a latência nas requisições subsequentes para os mesmos domínios e diminuindo o consumo de banda no enlace de Internet.

Por padrão, o RouterOS possui a funcionalidade de DNS ativada internamente, porém configurada estritamente para atender às demandas do próprio sistema operacional do equipamento. Para que o MikroTik passe a responder às consultas de nomes vindas dos clientes das redes locais (como as estações da **LAN1** e das **VLANs**), é necessário alterar seus parâmetros globais e habilitar explicitamente a recepção de requisições remotas.

Para este exemplo, antes de realizar as alterações para ativar o DNS, podemos utilizar o comando `/ip dns print` para verificar a configuração corrente do serviço no roteador, tal como:

```bash
[admin@MikroTik] > ip dns print
  servers:              
  dynamic-servers: 192.168.122.1
  use-doh-server:              
  verify-doh-cert: no           
  doh-max-server-connections: 5            
  doh-max-concurrent-queries: 50           
  doh-timeout: 5s           
  allow-remote-requests: no           
  max-udp-packet-size: 4096         
  query-server-timeout: 2s           
  query-total-timeout: 10s          
  max-concurrent-queries: 100          
  max-concurrent-tcp-sessions: 20           
  cache-size: 2048KiB      
  cache-max-ttl: 1w           
  address-list-extra-time: 0s           
  vrf: main         
  mdns-repeat-ifaces:              
  cache-used: 36KiB        
```

Observa-se na saída anterior que o parâmetro **`allow-remote-requests`** encontra-se definido como **`no`**, o que impede os clientes da rede local de utilizarem o IP do MikroTik como seu servidor DNS. O campo **`dynamic-servers`** exibe o IP `192.168.122.1`, obtido automaticamente via cliente DHCP na interface WAN (`ether1`).

Agora para efetivamente transformar o MikroTik em um servidor *DNS Cache* funcional para os hosts da rede interna, executa-se o comando `/ip dns set`, definindo explicitamente os servidores de consulta primários e autorizando o atendimento aos clientes.

```bash
[admin@MikroTik] > ip dns set servers=8.8.8.8,1.1.1.1 allow-remote-requests=yes
```
O comando anterior tem a seguinte restrutura e funções:

* **`/ip dns set`**: Acessa o submenu de parâmetros globais do serviço de resolução de nomes do RouterOS para modificar suas variáveis de funcionamento.
* **`servers=8.8.8.8,1.1.1.1`**: Define a lista de servidores DNS públicos e recursivos de destino (neste exemplo, os serviços de DNS do Google e da Cloudflare). Caso o MikroTik receba uma consulta de um host local cuja resposta ainda não esteja armazenada em seu *cache*, ele repassará a requisição para esses endereços IP externos.
* **`allow-remote-requests=yes`**: Habilita o roteador a escutar e responder às solicitações de resolução de nomes enviadas por outros dispositivos da rede (abertura do serviço de escuta na porta 53 UDP/TCP).

> **Nota de Segurança:** Ao ativar a opção de resposta a requisições remotas (`allow-remote-requests=yes`), o serviço de DNS do MikroTik passa a escutar consultas na porta 53 (UDP/TCP) em todas as suas interfaces. Se a interface WAN estiver exposta diretamente à Internet sem a devida proteção de firewall, o equipamento poderá ser explorado em ataques externos de amplificação de DNS (*DNS Amplification Attacks*). Portanto, em ambientes de produção, é imprescindível criar regras no `/ip firewall filter` (na *chain* `input`) bloqueando o acesso externo à porta 53 vindo da interface WAN.

Após a aplicação da instrução, podemos executar novamente o comando `/ip dns print` para verificar se as alterações foram feitas no sistema, e a saída deve ser algo como:

```bash
[admin@MikroTik] > ip dns print                                                 
  servers: 8.8.8.8      
                  1.1.1.1      
  dynamic-servers: 192.168.122.1
  use-doh-server:              
  verify-doh-cert: no           
  doh-max-server-connections: 5            
  doh-max-concurrent-queries: 50           
  doh-timeout: 5s           
  allow-remote-requests: yes          
  max-udp-packet-size: 4096         
  query-server-timeout: 2s           
  query-total-timeout: 10s          
  max-concurrent-queries: 100          
  max-concurrent-tcp-sessions: 20           
  cache-size: 2048KiB      
  cache-max-ttl: 1w           
  address-list-extra-time: 0s           
  vrf: main         
  mdns-repeat-ifaces:              
  cache-used: 38KiB        
```

Analisando a saída do exemplo é possível ver os campos que confirmam o sucesso da operação, sendo esses:

* O campo **`servers`** agora lista os IPs **`8.8.8.8`** e **`1.1.1.1`** como resolvedores primários de saída.
* O parâmetro **`allow-remote-requests`** exibe o valor **`yes`**, confirmando que a porta do serviço está ativa para atender às requisições da rede local.
* O parâmetro **`cache-size`** indica a alocação de **`2048KiB`** (2 MB) de memória RAM dedicada ao armazenamento temporário de nomes resolvidos, otimizando o tempo de resposta para as próximas consultas efetuadas pelos clientes da infraestrutura.

Com o serviço de DNS ativado e configurado no MikroTik, um procedimento essencial de validação consiste em realizar consultas de nomes a partir dos clientes da rede local apontando diretamente para o IP do roteador. No **Host-2**, por exemplo, pode-se redefinir temporariamente o resolvedor do sistema operacional com o comando `echo "nameserver 10.1.0.254" > /etc/resolv.conf` e, em seguida, disparar um teste de resolução com o utilitário `nslookup [www.google.com](https://www.google.com).br`. Como demonstrado no exemplo a seguir

```bash
# nslookup www.google.com.br
Server:		10.1.0.254
Address:	10.1.0.254#53

Non-authoritative answer:
Name:	www.google.com.br
Address: 142.250.78.131
Name:	www.google.com.br
Address: 2800:3f0:4001:801::2003
```
O resultado apresentado na saída anterior exibe o servidor `10.1.0.254` respondendo na porta 53 e retornando com sucesso os endereços IPv4 (`142.250.78.131`) e IPv6 (`2800:3f0:4001:801::2003`) do domínio solicitado, confirmando o funcionamento correto do *DNS Cache* e da conectividade de saída do roteador.

Em suma, a ativação do serviço de *DNS Cache* no roteador centralizado constitui uma prática fundamental para otimizar o desempenho, reduzir a latência de navegação e garantir a eficiência na resolução de nomes para todos os dispositivos da infraestrutura. Além da função de cache e do encaminhamento de consultas externas, o MikroTik RouterOS também oferece o recurso de DNS estático (`/ip dns static`), que permite mapear nomes de domínio personalizados para endereços IP locais — funcionalidade extremamente útil para o acesso a servidores, impressoras e serviços internos da organização. Contudo, a criação e o gerenciamento de registros de nomes estáticos locais fogem ao escopo deste texto, no qual focamos estritamente na habilitação do serviço de resolução recursiva e no provimento de *cache* para a rede.

## Considerações Finais

A trajetória percorrida neste texto consolidou a construção de uma infraestrutura de rede completa e funcional a partir do zero. Ao longo das seções, exploramos desde a atribuição de endereços IP e a habilitação do **NAT** (*Masquerade*) para conectividade com a Internet, até a segmentação avançada da Camada 2 via **VLANs (802.1Q)** para o roteamento inter-VLANs. Adicionalmente, implementamos serviços essenciais de suporte à aplicação, como a automatização da distribuição de parâmetros de rede via **DHCP** (com concessões dinâmicas e reservas estáticas) e a otimização da resolução de nomes por meio de um servidor **DNS Cache**.

A fusão desses elementos representa o alicerce fundamental para a operação de qualquer rede de computadores moderna, servindo como uma ponte indispensável para a implementação de cenários mais avançados — como a aplicação de políticas estritas de *Firewall/MANGLE*, o estabelecimento de túneis VPN e o gerenciamento de qualidade de serviço (*QoS*). Compreender a mecânica por trás desses protocolos e saber como instanciá-los em diferentes ecossistemas (como soluções baseadas em Linux, o padrão de mercado Cisco IOS ou a crescente arquitetura do RouterOS da MikroTik) é uma competência crucial para o administrador de redes. Esse domínio técnico garante a versatilidade necessária para projetar, gerenciar e manter infraestruturas seguras, eficientes e escaláveis em qualquer ambiente corporativo.

Aqui está a seção de referências bibliográficas formatada de acordo com as normas da **ABNT (NBR 6023)**, contemplando tanto a literatura clássica de redes de computadores quanto a documentação oficial da MikroTik e materiais de apoio recomendados.


## Referências

COMER, Douglas E. **Redes de computadores e internet**. 6. ed. Porto Alegre: Bookman, 2016.

KUROSE, James F.; ROSS, Keith W. **Redes de computadores e a internet: uma abordagem top-down**. 7. ed. São Paulo: Pearson Education do Brasil, 2021.

MIKROTIK. **MikroTik Documentation**. 2026. Disponível em: [https://help.mikrotik.com/docs/](https://help.mikrotik.com/docs/). Acesso em: 07 ago. 2026.

MIKROTIK. **RouterOS Manual: IP/DHCP Server**. 2026. Disponível em: [https://help.mikrotik.com/docs/display/ROS/DHCP](https://help.mikrotik.com/docs/display/ROS/DHCP). Acesso em: 07 ago. 2026.

MIKROTIK. **RouterOS Manual: IP/DNS**. 2026. Disponível em: [https://help.mikrotik.com/docs/display/ROS/DNS](https://help.mikrotik.com/docs/display/ROS/DNS). Acesso em: 07 ago. 2026.

MIKROTIK. **RouterOS Manual: IP/Firewall/NAT**. 2026. Disponível em: [https://help.mikrotik.com/docs/display/ROS/NAT](https://help.mikrotik.com/docs/display/ROS/NAT). Acesso em: 07 ago. 2026.

MIKROTIK. **RouterOS Manual: VLAN (VLANs in RouterOS)**. 2026. Disponível em: [https://help.mikrotik.com/docs/display/ROS/VLAN](https://help.mikrotik.com/docs/display/ROS/VLAN). Acesso em: 07 ago. 2026.

TANENBAUM, Andrew S.; WETHERALL, David. **Redes de computadores**. 5. ed. São Paulo: Pearson Clinical, 2011.
