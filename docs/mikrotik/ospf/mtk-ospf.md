# OSPF em roteadores Mikrotik

O **OSPF** (*Open Shortest Path First*) é um dos protocolos de roteamento dinâmico mais utilizados no mundo corporativo e em provedores de Internet (ISPs). Ao contrário de protocolos mais simples, ele foi desenvolvido para lidar com redes de grande porte, oferecendo convergência rápida, suporte a topologias complexas e gerenciamento eficiente de tráfego.

Para compreender a eficiência do OSPF, é fundamental analisar suas diferenças em relação aos protocolos de **Vetor de Distância**, como o RIP. 

Assim, **no modelo de Vetor de Distância utilizado pelo RIP, o roteador enxerga a rede apenas pelo "olhar dos seus vizinhos"**, sabendo somente qual é a próxima interface e quantos saltos (*hop count*) faltam para atingir determinado destino, sem qualquer visão global da topologia. Em contrapartida, **no modelo *Link-State* do OSPF, cada roteador descobre a topologia completa da rede** (ou da sua área) e constrói um "mapa" interligado. A partir dessa visão ampla, ele utiliza o algoritmo de **Dijkstra** (SPF - *Shortest Path First*) para calcular, de forma totalmente independente, o caminho mais curto para cada destino.

A diferença na comunicação entre vizinhos segue essa mesma lógica estrutural. Enquanto **o RIP envia sua tabela de roteamento inteira para os vizinhos em intervalos fixos a cada 30 segundos - independentemente de ter ocorrido qualquer alteração na rede**, o que gera tráfego desnecessário e lentidão -, o OSPF trabalha de maneira muito mais inteligente. Ele estabelece uma relação formal de vizinhança (*Adjacency*) trocando pacotes leves de *Hello*. Uma vez sincronizada a topologia inicial, **o OSPF só envia atualizações pontuais quando ocorrem mudanças reais na rede** (como a queda ou subida de um enlace) por meio de pacotes LSA (*Link-State Advertisement*), **economizando processamento e largura de banda**.

O OSPF apresenta diversas **vantagens** que o tornam o protocolo ideal para infraestruturas modernas, começando pela sua **convergência rápida**, capaz de detectar falhas e recalcular rotas em questão de milissegundos a poucos segundos. Além disso, sua **métrica é baseada em custo**, levando em consideração a velocidade real do link (Mbps ou Gbps) em vez de apenas contar o número de saltos como faz o RIP. Essa abordagem **elimina o limite rigoroso de saltos, permitindo que o protocolo suporte redes imensas** que ultrapassam a restrição de 15 saltos do RIP, enquanto sua escalabilidade por meio de áreas possibilita dividir a rede em blocos lógicos para otimizar o uso da CPU e o tráfego de controle.

Por outro lado, essa robustez traz algumas **desvantagens** que devem ser consideradas pelo projeto de rede. O OSPF **exige um consumo significativamente maior de recursos**, demandando mais memória RAM e processamento para manter a base de dados do estado do enlace (*LSDB*) e executar o algoritmo SPF continuamente. Por fim, **apresenta uma maior complexidade tanto na configuração** inicial quanto no *troubleshooting*, exigindo um nível de conhecimento técnico mais elevado do administrador de redes para planejar a topologia e diagnosticar eventuais problemas.

## Conceito de área do OSPF

Um dos recursos mais poderosos do OSPF é a capacidade de segmentar a rede em Áreas, onde toda a arquitetura depende de pelo menos uma área central chamada **Área 0 (*Backbone*)**, à qual todas as outras áreas devem se conectar diretamente à medida que a infraestrutura cresce. Essa organização traz ganhos significativos de desempenho e gerenciamento, pois **reduz drasticamente o processamento dos roteadores** ao garantir que, diante de qualquer mudança de topologia dentro de uma área, **o algoritmo SPF seja recalculado apenas pelos roteadores daquela região específica, sem impactar o restante da rede**. Além disso, a divisão em áreas permite a sumarização de rotas - agrupando dezenas de redes menores para anunciá-las como um único bloco IP ao *backbone* - e isola instabilidades, impedindo que o impacto de enlaces oscilantes se propague por toda a empresa.

Saber o momento certo de implementar essa segmentação define a eficiência do projeto de rede. Em redes únicas ou de pequeno porte, com poucos roteadores, a recomendação é manter a simplicidade utilizando exclusivamente a Área 0 (*Backbone*), sem criar divisões desnecessárias. Já em redes de médio a grande porte, como em provedores de Internet (ISPs) e multinacionais, torna-se essencial criar áreas separadas para diferentes regiões geográficas, tal como filiais, mantendo todas devidamente interconectadas e subordinadas à Área 0 central.

## Múltiplos roteadores ligados através de uma rede Ethernet

Em redes OSPF com múltiplos roteadores conectados ao mesmo segmento Ethernet (redes multiacesso), a eleição de um **Roteador Designado (DR - *Designated Router*)** e de um **Roteador Designado de Backup (BDR - *Backup Designated Router*)** é essencial para evitar o excesso de tráfego.

Sem eles, todos os roteadores precisariam trocar informações diretamente entre si (*full mesh*), gerando um volume enorme de adjacências e pacotes duplicados. Assim o OSPF elege os seguintes roteadores:

* **DR (Roteador Principal):** Atua como o ponto central da rede. Todos os outros roteadores comuns (*DROther*) estabelecem adjacência direta apenas com o DR (e o BDR) e enviam suas atualizações LSA para ele usando o endereço _multicast_ `224.0.0.6`. O DR então replica essas informações para o restante dos roteadores via `224.0.0.5`.
* **BDR (Roteador de Backup):** Monitora passivamente a comunicação do DR. Caso o DR falhe ou perca a conectividade, o BDR assume a função de DR instantaneamente, garantindo a continuidade do roteamento sem a necessidade de uma nova eleição demorada.

A escolha do DR e BDR ocorre automaticamente com base na **maior prioridade** configurada na interface ou, em caso de empate, no **maior Router ID** da rede. Em links **Ponto-a-Ponto** (com apenas dois roteadores interconectados), o OSPF desativa essa eleição, pois a relação de vizinhança já é direta.

Ao contrário do OSPF, o RIP não conta com um nó centralizador como o Roteador Designado (DR), fazendo com que todos os roteadores operem de forma totalmente descentralizada em segmentos Ethernet e anunciem periodicamente suas tabelas completas para a rede. Essa falta de coordenação gera sérios problemas de escalabilidade e estabilidade, pois provoca uma inundação desnecessária de tráfego a cada 30 segundos, exige que cada equipamento processe individualmente as tabelas de todos os vizinhos — gerando um crescimento quadrático de carga de processamento — e aumenta drasticamente o risco de _loops_ de roteamento e contagem ao infinito diante de falhas. Embora recursos como *Split Horizon* e *Poison Reverse* tentem conter essas falhas, eles atuam apenas como soluções paliativas que desaceleram a convergência e não impedem a lentidão e a ineficiência do RIP em redes Ethernet complexas.

Então, apesar de a configuração do RIP ser tentadora por sua extrema simplicidade (praticamente "ligar e usar"), **o OSPF deve ser a escolha padrão para qualquer infraestrutura moderna**.

O RIP é obsoleto e incapaz de responder com eficiência às exigências de redes atuais, onde enlaces gigabit, redundância e tempo de resposta instantâneo são vitais. A complexidade adicional do OSPF se paga rapidamente no primeiro incidente de rede: o tempo de reconvergência do OSPF garante que serviços sensíveis (como chamadas VoIP e sistemas em tempo real) continuem operando sem interrupções percebidas pelos usuários.

### OSPF no MikroTik RouterOS v7

No **RouterOS versão 7**, a MikroTik reformulou completamente a sua pilha de roteamento dinâmico (*routing engine*), assim a configuração e o desempenho do OSPF atingiram um novo patamar de estabilidade e eficiência, se comparado com versões anteriores. Sendo as principais características:

* **Suporte Nativo Dual-Stack (IPv4 e IPv6):** O OSPFv2 (IPv4) e o OSPFv3 (IPv6) agora utilizam uma estrutura de configuração unificada, tornando o gerenciamento do IPv6 tão simples quanto o do IPv4.
* **Processamento Multi-thread:** O motor de roteamento do v7 aproveita múltiplos núcleos de processamento nos roteadores das linhas CCR e RB, acelerando drasticamente o cálculo da tabela de roteamento em grandes redes.
* **Sintaxe Atualizada e Simplificada:** A estrutura de instâncias, áreas e _templates_ foi organizada de forma muito mais clara no menu `/routing ospf`, facilitando a automação e a manutenção via linha de comando (CLI) ou WinBox.

O MikroTik RouterOS v7 consolida o OSPF como uma ferramenta madura, robusta e pronta para atender desde redes corporativas expansivas até infraestruturas complexas de provedores de acesso.

### Estrutura da rede utilizada neste exemplo

Para exemplificar e testar a configuração do protocolo **OSPF** em roteadores MikroTik, utilizaremos a topologia triangular ilustrada na Figura 1, que é composta por três roteadores (Router-MTk-1, Router-MTk-2 e Router-MTk-3), suas respectivas redes locais (LANs), enlaces de ponto a ponto (WANs) e uma saída para a Internet.

| ![rede](../rip/img/mtk-cenario1-rip.png) |
|:--:|
| Figura 1 - Cenário de rede do exemplo

Cada roteador atende a uma sub-rede de rede local diferente, responsável por conectar um *host* individual:

* **Router-MTk-1:**
    * **LAN1:** Sub-rede `172.16.1.0/24` conectada à interface `ether1`.
    * **Host:** `Host-1` conectado via interface `eth0`.

* **Router-MTk-2:**
    * **LAN2:** Sub-rede `172.16.2.0/24` conectada à interface `ether1`.
    * **Host:** `Host-2` conectado via interface `eth0`.


* **Router-MTk-3:**
    * **LAN3:** Sub-rede `172.16.3.0/24` conectada à interface `ether1`.
    * **Host:** `Host-3` conectado via interface `eth0`.

Os três roteadores estão interconectados em uma topologia redundante em anel/triângulo, permitindo testar caminhos alternativos e a alternância de rotas do OSPF, isso e a conexão com a Internet é feito através das seguintes WANs:

* **WAN1 (`192.168.1.0/24`):** Interconecta o **Router-MTk-1** (interface `ether3`) ao **Router-MTk-2** (interface `ether3`).
* **WAN2 (`192.168.2.0/24`):** Interconecta o **Router-MTk-2** (interface `ether2`) ao **Router-MTk-3** (interface `ether2`).
* **WAN3 (`192.168.3.0/24`):** Interconecta o **Router-MTk-1** (interface `ether4`) ao **Router-MTk-3** (interface `ether4`).
* **WAN0 (`192.168.122.0/24`):** O **Router-MTk-1** atua como roteador de borda da topologia, conectando sua interface `ether2` (endereço IP final `.101`) ao *Gateway* (`192.168.122.1`) da nuvem **NAT1**. Essa conexão proverá o acesso à Internet para toda a topologia, permitindo também testar a redistribuição de rota padrão no OSPF.

A tabela a seguir apresenta os IPs e máscaras utilizadas em cada roteador do cenário de exemplo:

| Equipamento | Interface | Endereço IP / Sub-rede | Descrição / Conexão |
| --- | --- | --- | --- |
| **Router-MTk-1** | `ether1` | `172.16.1.1/24` | Rede Local (LAN1) |
|  | `ether2` | `192.168.122.101/24` | Saída WAN0 / NAT1 (Gateway `.1`) |
|  | `ether3` | `192.168.1.101/24` | Link WAN1 para Router-MTk-2 |
|  | `ether4` | `192.168.3.101/24` | Link WAN3 para Router-MTk-3 |
| **Router-MTk-2** | `ether1` | `172.16.2.1/24` | Rede Local (LAN2) |
|  | `ether2` | `192.168.2.102/24` | Link WAN2 para Router-MTk-3 |
|  | `ether3` | `192.168.1.102/24` | Link WAN1 para Router-MTk-1 |
| **Router-MTk-3** | `ether1` | `172.16.3.1/24` | Rede Local (LAN3) |
|  | `ether2` | `192.168.2.103/24` | Link WAN2 para Router-MTk-2 |
|  | `ether4` | `192.168.3.103/24` | Link WAN3 para Router-MTk-1 |

Com esse cenário montado, o objetivo nos passos seguintes será:

1. Configurar o **OSPF** nos três roteadores para que anunciem suas redes `LAN` e `WANs`.
2. Verificar a convergência das tabelas de roteamento dinâmicas e o alcance entre os hosts (`Host-1`, `Host-2` e `Host-3`).
3. Redistribuir a rota padrão no **Router-MTk-1** para que os outros dois roteadores e hosts aprendam o caminho para a Internet via OSPF.
4. Testar a tolerância a falhas derrubando um dos links (por exemplo, a WAN1) para observar o OSPF recalculando a rota através da WAN3 e WAN2.

Todos os passos demonstrados neste exemplo: configuração das interfaces de rede, configuração do OSPF e testes - estão registrados no vídeo a seguir, bem como neste texto.

<div style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; margin-bottom: 1rem;">
  <iframe src="https://www.youtube.com/embed/pFuFgsQ4Kz0" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; border:0;" allowfullscreen title="Demonstração Prática no YouTube"></iframe>
</div>


## Configuração dos Hosts das Redes Locais

Para executar corretamente o exemplo é necessário, além de configurar os roteadores, preparar os *hosts* clientes para validar o roteamento e a comunicação na rede proposta. Assim, cada rede local conta com um *host* de teste (`Host-1`, `Host-2` e `Host-3`). A atribuição de rede nos *hosts* é feita utilizando a suíte moderna `iproute2` do Linux através de dois comandos básicos:

* **`ip address add <IP>/24 dev eth0`:** Atribui o endereço IP e a máscara de sub-rede na interface de rede principal (`eth0`).
* **`ip route add default via <IP-Router>`:** Define a rota padrão (*default gateway*) apontando para o endereço IP do seu respectivo roteador MikroTik.

Desta forma, seguem os comandos que devem ser executados em cada um dos *hosts* clientes:

* Host 1 (LAN1)

```bash
root@Host-1:/# ip address add 172.16.1.1/24 dev eth0
root@Host-1:/# ip route add default via 172.16.1.101
```

* Host 2 (LAN2)

```bash
root@Host-2:/# ip address add 172.16.2.1/24 dev eth0
root@Host-2:/# ip route add default via 172.16.2.102
```

* Host 3 (LAN3)

```bash
root@Host-3:/# ip address add 172.16.3.1/24 dev eth0
root@Host-3:/# ip route add default via 172.16.3.103
```

Com as configurações de IP e *gateway* devidamente aplicadas em todos os *hosts* clientes, garantimos que os dispositivos finais estejam prontos para se comunicar com as suas respectivas redes locais. A partir deste ponto, avançamos para a implementação e o ajuste do protocolo OSPF nos roteadores MikroTik RouterOS v7, onde o roteamento dinâmico e a convergência da infraestrutura serão de fato estabelecidos.

## Configuração do Roteador Mtk3 com OSPF

Para o terceiro nó da topologia (**mtk3**), realizamos primeiro a definição da identidade do dispositivo e a atribuição dos endereços IP nas suas interfaces.

Assim, é necessário executar os seguintes comandos para nomear o equipamento e configurar as interfaces `ether1` (LAN3), `ether2` (WAN2 para `mtk2`) e `ether4` (WAN3 para `mtk1`):

```routeros
[admin@MikroTik] > /system/identity/set name=mtk3
[admin@mtk3] > /ip/address/add address=172.16.3.103/24 interface=ether1
[admin@mtk3] > /ip/address/add address=192.168.2.103/24 interface=ether2       
[admin@mtk3] > /ip/address/add address=192.168.3.103/24 interface=ether4 
```

### Estruturação do OSPF no RouterOS v7

A configuração do OSPF no RouterOS v7 exige três etapas lógicas interconectadas: **Instância**, **Área** e **Modelo de Interface**.

#### 1. A Instância OSPF (`/routing/ospf/instance`)

A **instância** representa o processo principal do protocolo dentro do roteador. Ao explorar as opções do menu no terminal com a tecla **Tab**:

```routeros
[admin@mtk3] > /routing/ospf/instance/add 
comment          domain-id           mpls-te-address     originate-default     redistribute      use-dn    
copy-from        domain-tag          mpls-te-area        out-filter-chain      router-id         version   
disabled         in-filter-chain     name                out-filter-select     routing-table     vrf       
```

Destacam-se os seguintes parâmetros essenciais:

* **`name`:** Nome identificador do processo OSPF local.
* **`router-id`:** Endereço único de 32 bits utilizado para identificar este roteador dentro do domínio OSPF (ex: `103.103.103.103`).
* **`redistribute`:** Define quais tipos de rotas locais serão importadas e anunciadas ao domínio OSPF. As opções comuns incluem:
    * `connected`: Sub-redes das interfaces ativas diretamente conectadas.
    * `static`: Rotas criadas manualmente em `/ip/route`.
    * `ospf`: Rotas de outras instâncias OSPF locais.

Sendo assim iniciamos com o seguinte comando para configurar a instância:

```routeros
[admin@mtk3] > /routing/ospf/instance/add name=ospf1 router-id=103.103.103.103 redistribute=static,connected,ospf
```
Com isso podemos criar uma área, tal como é apresentado a seguir.

#### 2. A Área OSPF (`/routing/ospf/area`)

O OSPF exige a associação da instância a pelo menos uma área funcional. A área de *backbone* é obrigatoriamente identificada pelo ID `0.0.0.0` (ou `0`).

Ao consultar os atributos (TAB) de criação de área , temos as seguintes opções:

```routeros
[admin@mtk3] > /routing/ospf/area/add 
area-id     comment     copy-from     default-cost     disabled     instance     name     no-summaries     nssa-translator     type   
```

As principais opções para áreas são:

* **`instance`:** Vincula a área à instância criada anteriormente (`ospf1`).
* **`name`:** Nome amigável para a área (ex: `backbone`).
* **`area-id`:** O identificador numérico da área (ex: `0.0.0.0`).

Sendo assim executamos o seguinte comando para esse exemplo:

```routeros
[admin@mtk3] > /routing/ospf/area/add instance=ospf1 name=backbone area-id=0.0.0.0
```

É importante destacar que os nomes atribuídos à instância (`ospf1`) e à área (`backbone`) são rótulos locais e meramente descritivos, servindo apenas para organizar e identificar os processos dentro do próprio RouterOS — portanto, poderiam ser substituídos por qualquer outra nomenclatura de sua preferência (como `instancia-principal` ou `area-central`) sem impactar o funcionamento do protocolo. 

Já o **Router ID** (`router-id`) é o identificador único e global de 32 bits de um roteador dentro de todo o domínio OSPF. Embora ele utilize a sintaxe de um endereço IPv4 (como `103.103.103.103`), ele não precisa ser um IP roteável ou configurado em uma interface física. Contudo, é uma boa prática de engenharia de rede utilizar o endereço IP de uma interface *Loopback* do próprio roteador para facilitar a identificação visual, a gerência da topologia e evitar duplicidades na rede.

Feito esse comando vamos para o próximo passo.

#### 3. O Modelo de Interface (`/routing/ospf/interface-template`)

O **interface-template** especifica em quais portas físicas o OSPF irá enviar/receber pacotes do protocolo (como mensagens de *Hello*) para formar vizinhanças de roteamento. Assim,  executamos o comando para configurar o modelo de interface, tal como:

```routeros
[admin@mtk3] > /routing/ospf/interface-template/add area=backbone interfaces=ether2,ether4
```
O comando anterior configura as seguintes opções:

* **`area`:** Aponta para a área OSPF responsável por essas interfaces (`backbone`).
* **`interfaces`:** Lista de portas físicas participantes do processo. No `mtk3`, selecionamos as interfaces de tráfego entre roteadores (`ether2` e `ether4`).

Após a aplicação dos comandos de endereçamento e de OSPF no `mtk3`, consulta-se a tabela de roteamento com o comando `/ip/route/print`:

```routeros
[admin@mtk3] > /ip/route/print 
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT
Columns: DST-ADDRESS, GATEWAY, ROUTING-TABLE, DISTANCE
    DST-ADDRESS     GATEWAY  ROUTING-TABLE  DISTANCE
DAc 172.16.3.0/24   ether1   main                   0
DAc 192.168.2.0/24  ether2   main                   0
DAc 192.168.3.0/24  ether4   main                   0
```
A saída anterior apresenta os seguintes resultados:

* **`DAc` (Dynamic, Active, Connect):** As redes `172.16.3.0/24`, `192.168.2.0/24` e `192.168.3.0/24` estão devidamente ativas como diretamente conectadas com Distância Administrativa `0`.
* **Ausência de Rotas OSPF no Momento:** Enquanto os demais roteadores vizinhos (`mtk1` e `mtk2`) não tiverem o protocolo OSPF ativo e configurado na mesma área `0.0.0.0`, não haverá formação de adjacência (vizinhança). À medida que o OSPF for habilitado nos outros roteadores, as redes remotas aprendidas passarão a figurar nesta tabela com a flag **`DAo`** (Dynamic, Active, OSPF) e com Distância Administrativa padrão do OSPF (**`110`** no RouterOS).

Com o nome e o endereçamento IP devidamente atribuídos às interfaces `ether1`, `ether2` e `ether4`, além da estruturação da instância OSPF, da área *backbone* e dos modelos de interface, o roteador **mtk3** encontra-se completamente preparado e pronto para trocar informações de topologia. A tabela de roteamento atual reflete com precisão todas as suas redes diretamente conectadas, mas para observarmos a formação de adjacência, o cálculo das métricas de custo pelo algoritmo de Dijkstra e o aprendizado dinâmico das rotas remotas na prática, avançaremos agora para a configuração do seu vizinho OSPF na rede.

## Configuração do Roteador mtk2

Para o segundo nó da topologia (**mtk2**), realizaremos as configurações de identificação, endereçamento de IP, OSPF e, em seguida, a verificação do estabelecimento de vizinhança e aprendizado de rotas.

Então vamos iniciar com a definição do nome do equipamento e inclusão dos endereços IP nas interfaces `ether1` (LAN2), `ether2` (WAN2) e `ether3` (WAN1), tal como:

```routeros
[admin@MikroTik] > /system/identity/set name=mtk2
[admin@mtk2] > /ip/address/add address=172.16.2.102/24 interface=ether1
[admin@mtk2] > /ip/address/add address=192.168.2.102/24 interface=ether2       
[admin@mtk2] > /ip/address/add address=192.168.1.102/24 interface=ether3 
```

Feito isso passamos para configuração do OSPF com a criação da instância, associação da área *backbone* e vinculação dos modelos de interface nas portas `ether2` e `ether3`, veja os comandos a seguir:

```routeros
[admin@mtk2] > /routing/ospf/instance/add name=ospf1 router-id=102.102.102.102 redistribute=connected,static,ospf 
[admin@mtk2] > /routing/ospf/area/add instance=ospf1 area-id=0.0.0.0 name=backbone 
[admin@mtk2] > /routing/ospf/interface-template/add area=backbone interfaces=ether2,ether3
```

Após habilitar o OSPF nas portas ativas do **mtk2**, verificamos o estabelecimento da vizinhança com o **mtk3** (`103.103.103.103`) através do comando de impressão de vizinhos:

```routeros
[admin@mtk2] > /routing/ospf/neighbor/print 
Flags: V - VIRTUAL; D - DYNAMIC 
 0  D instance=ospf1 area=backbone interface=ether2 address=192.168.2.103 priority=128 router-id=103.103.103.103 dr=192.168.2.103 
     bdr=0.0.0.0 state="Full" state-changes=6 adjacency=5s timeout=35s 
```

Na saída anterior, o status **`state="Full"`** indica que a adjacência OSPF foi estabelecida com sucesso e as bases de dados de estado de enlace (LSDB) foram sincronizadas entre os roteadores.

Em seguida, consultamos a tabela de roteamento para checar o aprendizado dinâmico das redes do **mtk3**:

```routeros
[admin@mtk2] > /ip/route/print 
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT, o - OSPF
Columns: DST-ADDRESS, GATEWAY, ROUTING-TABLE, DISTANCE
    DST-ADDRESS     GATEWAY               ROUTING-TABLE  DISTANCE
DAc 172.16.2.0/24   ether1                main                   0
DAo 172.16.3.0/24   192.168.2.103%ether2  main                 110
DAc 192.168.1.0/24  ether3                main                   0
DAc 192.168.2.0/24  ether2                main                   0
DAo 192.168.3.0/24  192.168.2.103%ether2  main                 110
```

Como resultado, as redes **`172.16.3.0/24`** (LAN do `mtk3`) e **`192.168.3.0/24`** (enlace WAN3) foram adicionadas automaticamente com a flag **`DAo`** (Dynamic, Active, OSPF), via *gateway* `192.168.2.103` e Distância Administrativa `110`.

Com o **mtk2** devidamente configurado, a adjacência OSPF no estado `Full` confirma que o protocolo está operando perfeitamente e sincronizando a tabela de roteamento de forma dinâmica entre os dois nós. Com essa comunicação estabelecida com sucesso entre os dois primeiros equipamentos, avançaremos agora para a configuração do **mtk1**, o último roteador do nosso cenário, para fechar o anel e concluir o domínio OSPF de toda a topologia.

<!--
[admin@mtk2] > /ip/route/print 
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT, o - OSPF; + - ECMP
Columns: DST-ADDRESS, GATEWAY, ROUTING-TABLE, DISTANCE
     DST-ADDRESS       GATEWAY               ROUTING-TABLE  DISTANCE
DAo  0.0.0.0/0         192.168.1.101%ether3  main                110
DAo  172.16.1.0/24     192.168.1.101%ether3  main                110
DAc  172.16.2.0/24     ether1                main                  0
DAo  172.16.3.0/24     192.168.2.103%ether2  main                110
DAc  192.168.1.0/24    ether3                main                  0
DAc  192.168.2.0/24    ether2                main                  0
DAo+ 192.168.3.0/24    192.168.2.103%ether2  main                110
DAo+ 192.168.3.0/24    192.168.1.101%ether3  main                110
DAo  192.168.122.0/24  192.168.1.101%ether3  main                110
-->


## Configuração do Roteador mtk1

Para a conclusão da topologia no primeiro nó (**mtk1**), realizaremos as configurações de identificação, endereçamento de IP, OSPF e testes de vizinhança. Cabe destacar que este roteador possui um papel fundamental na borda da rede: além de se conectar aos vizinhos OSPF, ele é o ponto de saída para a Internet, exigindo a criação de uma **rota padrão estática** e a ativação do **NAT (*Masquerade*)** — configurações exclusivas deste equipamento na topologia.

Iniciaemos com a definição do nome, atribuição de IPs nas interfaces `ether1` (LAN1), `ether2` (WAN/Internet), `ether3` (WAN1) e `ether4` (WAN3), juntamente com o encaminhamento de borda:

```routeros
[admin@MikroTik] > /system/identity/set name=mtk1
[admin@mtk1] > /ip/address/add address=172.16.1.101/24 interface=ether1
[admin@mtk1] > /ip/address/add address=192.168.122.101/24 interface=ether2        
[admin@mtk1] > /ip/address/add address=192.168.1.101/24 interface=ether3    
[admin@mtk1] > /ip/address/add address=192.168.3.101/24 interface=ether4 
[admin@mtk1] > /ip/route/add gateway=192.168.122.1
[admin@mtk1] > /ip/firewall/nat/add action=masquerade chain=srcnat out-interface=ether2
```

> **Destaque:** A rota estática (`0.0.0.0/0`) para o gateway `192.168.122.1` garante a saída para a rede externa, enquanto o mascaramento de NAT (`srcnat action=masquerade`) na interface de saída `ether2` permite que as sub-redes internas naveguem na Internet.


Com os endereços, rotas e NAT configurados vamos para a criação da instância OSPF, associação da área *backbone* e ativação do modelo de interface nas portas `ether3` e `ether4`, isso pode ser feito da seguinte forma:

```routeros
[admin@mtk1] > /routing/ospf/instance/add name=ospf1 router-id=101.101.101.101 redistribute=connected,static,ospf 
[admin@mtk1] > /routing/ospf/area/add instance=ospf1 name=backbone area-id=0.0.0.0
[admin@mtk1] > /routing/ospf/interface-template/add area=backbone interfaces=ether3,ether4
```

Com o OSPF ativo em suas interfaces internas, verificamos o estabelecimento de vizinhança simultânea com o **mtk3** (`103.103.103.103`) e o **mtk2** (`102.102.102.102`):

```routeros
[admin@mtk1] > /routing/ospf/neighbor/print 
Flags: V - VIRTUAL; D - DYNAMIC 
 0  D instance=ospf1 area=backbone interface=ether4 address=192.168.3.103 priority=128 router-id=103.103.103.103 dr=192.168.3.103 
     bdr=192.168.3.101 state="Full" state-changes=6 adjacency=27s timeout=33s 

 1  D instance=ospf1 area=backbone interface=ether3 address=192.168.1.102 priority=128 router-id=102.102.102.102 dr=192.168.1.102 
     bdr=192.168.1.101 state="Full" state-changes=6 adjacency=29s timeout=31s 

```

O status **`state="Full"`** em ambas as sessões confirma que o anel foi fechado e que os bancos de dados LSDB foram completamente sincronizados.

Por fim, consultamos a tabela de roteamento final:

```routeros
[admin@mtk1] > /ip/route/print 
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT, s - STATIC, o - OSPF; + - ECMP
Columns: DST-ADDRESS, GATEWAY, ROUTING-TABLE, DISTANCE
#      DST-ADDRESS       GATEWAY               ROUTING-TABLE  DISTANCE
0  As  0.0.0.0/0         192.168.122.1         main                  1
   DAc 172.16.1.0/24     ether1                main                  0
   DAo 172.16.2.0/24     192.168.1.102%ether3  main                110
   DAo 172.16.3.0/24     192.168.3.103%ether4  main                110
   DAc 192.168.1.0/24    ether3                main                  0
   DAo+ 192.168.2.0/24   192.168.1.102%ether3  main                110
   DAo+ 192.168.2.0/24   192.168.3.103%ether4  main                110
   DAc 192.168.3.0/24    ether4                main                  0
   DAc 192.168.122.0/24  ether2                main                  0
```
A saída anterior, apresenta as seguintes rotas:

* **`As` (Active, Static):** Rota padrão (`0.0.0.0/0`) configurada manualmente apontando para a Internet via gateway `192.168.122.1`.
* **`DAo` (Dynamic, Active, OSPF):** As redes remotas `172.16.2.0/24` (LAN do `mtk2`) e `172.16.3.0/24` (LAN do `mtk3`) foram aprendidas via OSPF.
* **`DAo+` (Equal-Cost Multi-Path - ECMP):** A rede `192.168.2.0/24` (enlace de interconexão entre `mtk2` e `mtk3`) possui a sinalização `+` indicando balanceamento de carga de custo equivalente (ECMP). O OSPF identificou que ambos os caminhos (via `ether3` e via `ether4`) possuem exatamente a mesma métrica total de custo, permitindo dividir o tráfego de forma simétrica entre as rotas.

Com as sessões OSPF estabelecidas no status `Full` com ambos os vizinhos e a tabela de roteamento devidamente preenchida com as rotas dinâmicas e o balanceamento ECMP, tudo indica que a topologia foi configurada com absoluto sucesso. Todos os enlaces de interconexão e sub-redes locais estão visíveis e integrados ao domínio do protocolo. A seguir, realizaremos os testes práticos de conectividade e redundância para validar o funcionamento do ambiente em produção.

## Validação da Redundância e Testes de Conectividade

Para validar o correto funcionamento da topologia, os testes a seguir foram realizados a partir da máquina de teste **Host-2** (localizada na LAN2, conectada ao `mtk2`).

### 1. Teste de Conectividade BÁSICA

Inicialmente, executam-se testes de alcance ICMP (`ping`) direcionados aos *gateways* das LANs remotas e a um endereço público da Internet:

```bash
root@Host-2:/# ping 172.16.1.1
PING 172.16.1.1 (172.16.1.1) 56(84) bytes of data.
64 bytes from 172.16.1.1: icmp_seq=1 ttl=62 time=1.20 ms
64 bytes from 172.16.1.1: icmp_seq=2 ttl=62 time=1.50 ms
^C
--- 172.16.1.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 1.199/1.350/1.501/0.151 ms

root@Host-2:/# ping 172.16.3.1
PING 172.16.3.1 (172.16.3.1) 56(84) bytes of data.
64 bytes from 172.16.3.1: icmp_seq=1 ttl=62 time=1.23 ms
64 bytes from 172.16.3.1: icmp_seq=2 ttl=62 time=0.838 ms
^C
--- 172.16.3.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.838/1.035/1.232/0.197 ms

root@Host-2:/# ping 8.8.8.8    
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=14.5 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=14.3 ms
```

A saída dos comandos anteriores fornecem os seguintes status:

* **`172.16.1.1` (LAN1 - `mtk1`):** Resposta imediata sem perda de pacotes, confirmando o roteamento dinâmico via OSPF até o `mtk1`.
* **`172.16.3.1` (LAN3 - `mtk3`):** Comunicação estabelecida com sucesso com a sub-rede do `mtk3`.
* **`8.8.8.8` (Internet):** Resposta positiva confirmando que a rota estática do `mtk1` e o mascaramento de NAT (*Masquerade*) estão funcionando perfeitamente para os hosts da rede interna.

### 2. Teste de Redundância e Failover (*Traceroute*)

Para avaliar a capacidade de convergência do OSPF diante de falhas de enlace, simulou-se a interrupção da rota principal inserindo uma falha no enlace direto WAN1 entre **`mtk2`** e **`mtk1`** (endereço `192.168.1.101`).

#### A. Mapeamento do Caminho Nominal (Rede Normal)

Antes da falha, o rastreamento de rotas para o destino de Internet (`8.8.8.8`) e para o *gateway* remoto (`172.16.1.1`) exibe a utilização do enlace direto via WAN1:

```bash
root@Host-2:/# traceroute -n 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  172.16.2.102  1.593 ms  1.322 ms  1.291 ms
 2  192.168.1.101  2.914 ms  2.892 ms  3.138 ms
 3  192.168.122.1  3.104 ms  3.633 ms  3.606 ms
...
14  8.8.8.8  13.910 ms  13.911 ms  14.060 ms

root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.502 ms  1.492 ms  1.481 ms
 2  192.168.1.101  2.603 ms  2.602 ms  2.593 ms
 3  172.16.1.1  4.072 ms  4.495 ms  5.195 ms

```

> **Caminho Padrão:** Host-2 -> **`172.16.2.102`** (`mtk2`) -> **`192.168.1.101`** (`mtk1` via WAN1) -> Destino.


#### B. Simulação de Falha e Re-roteamento Dinâmico (Failover)

No momento em que o enlace WAN1 (`192.168.1.0/24`) é desativado (ver Figura 2), o OSPF detecta a perda de adjacência, recalcula a árvore de caminhos mais curtos através do algoritmo de Dijkstra e passa a redirecionar o tráfego alternativamente pelo roteador **`mtk3`** (`192.168.2.103`):

| ![rede](../rip/img/mtk-cenario1-rip-disable.png) |
|:--:|
| Figura 2 - Cenário de rede do exemplo com o link WAN1 desativado


```bash
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  0.982 ms  0.917 ms  0.863 ms
 2  192.168.2.103  1.956 ms  2.104 ms  2.752 ms
 3  192.168.3.101  5.729 ms  6.097 ms  9.475 ms
 4  172.16.1.1  12.647 ms  12.652 ms  13.477 ms

root@Host-2:/# traceroute -n 8.8.8.8    
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  172.16.2.102  1.977 ms  1.956 ms  1.945 ms
 2  192.168.2.103  5.314 ms  5.324 ms  6.314 ms
 3  192.168.3.101  13.082 ms  13.236 ms  14.908 ms
 4  192.168.122.1  16.828 ms  17.538 ms  17.541 ms
...
15  8.8.8.8  14.300 ms  14.199 ms  13.978 ms
```

> **Novo Caminho (Redundante):** Host-2 -> **`172.16.2.102`** (`mtk2`) -> **`192.168.2.103`** (`mtk3` via WAN2) -> **`192.168.3.101`** (`mtk1` via WAN3) -> Destino.

#### C. Restabelecimento do Enlace (_Fallback_)

Durante o período de reconexão do enlace WAN1 (entre 18:46:12 UTC e 18:46:30 UTC), observa-se momentaneamente uma oscilação na tabela enquanto os LSAs são recalculados, até que a rota primária é restaurada e o tráfego volta a fluir diretamente entre `mtk2` e `mtk1`:

```bash
root@Host-2:/# date
Thu Sep 24 18:46:12 UTC 2026
...
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.072 ms  2.160 ms  2.049 ms
 2  192.168.1.101  5.824 ms  6.370 ms  6.367 ms
 3  172.16.1.1  8.497 ms * *

root@Host-2:/# date
Thu Sep 24 18:46:30 UTC 2026
root@Host-2:/# traceroute -n 8.8.8.8    
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  172.16.2.102  2.379 ms  2.363 ms  2.348 ms
 2  192.168.1.101  4.032 ms  4.066 ms  4.054 ms
 3  192.168.122.1  5.687 ms  5.749 ms  5.742 ms
...
14  8.8.8.8  14.878 ms  14.842 ms  14.752 ms

```

## Conclusão

Os testes comprovam que o protocolo OSPF assegura alta disponibilidade (*High Availability*) e alta tolerância a falhas na infraestrutura, convergindo as rotas em questão de segundos sem a necessidade de intervenção manual.

O OSPF (*Open Shortest Path First*) consolida-se como um dos protocolos de roteamento dinâmico mais vitais e amplamente empregados em redes corporativas e de provedores modernos. Para qualquer administrador ou engenheiro de rede, dominar seus conceitos em comparação com protocolos legados, como o RIP (*Routing Information Protocol*), é um divisor de águas: enquanto o RIP se limita a métricas simples baseadas apenas em contagem de saltos e sofre com convergência lenta e limitações de escala, o OSPF utiliza o algoritmo de Dijkstra (SPF), considera a largura de banda dos enlaces para calcular o melhor caminho e reage a mudanças de topologia em questão de segundos.

Saber aplicar esses conceitos na prática em plataformas de mercado como o RouterOS da MikroTik é uma habilidade indispensável para garantir ambientes resilientes, de alta disponibilidade e com suporte a balanceamento de carga (ECMP). Vale ressaltar que este laboratório apresentou apenas uma introdução fundamentada no uso do OSPF em uma única área (*backbone*). O protocolo possui um ecossistema extremamente rico e avançado, que inclui a divisão da rede em múltiplas áreas (*Multi-Area OSPF*), sumarização de rotas, tipos especiais de áreas (como *Stub* e *NSSA*) e integração com engenharia de tráfego — recursos essenciais para a expansão e otimização de grandes infraestruturas.

## Referências

**CISCO SYSTEMS**. *OSPF Design Guide*. San Jose: Cisco Systems, 2020. Disponível em: [https://www.cisco.com/c/en/us/support/docs/ip/open-shortest-path-first-ospf/7039-1.html](https://www.google.com/search?q=https://www.cisco.com/c/en/us/support/docs/ip/open-shortest-path-first-ospf/7039-1.html&utm_source=gemini). Acesso em: 24 set. 2026.

**KUROSE**, James F.; **ROSS**, Keith W. *Redes de Computadores e a Internet: Uma Abordagem Top-Down*. 8. ed. São Paulo: Pearson Education do Brasil, 2021.

**MIKROTIK**. *Documentation: OSPF*. Riga: MikroTik, 2025. Disponível em: [https://help.mikrotik.com/docs/display/ROS/OSPF](https://help.mikrotik.com/docs/display/ROS/OSPF?utm_source=gemini). Acesso em: 24 set. 2026.

**MOY**, John T. *OSPF: Anatomy of an Internet Routing Protocol*. Reading: Addison-Wesley, 1998.

**RFC 2328**. *OSPF Version 2*. Editor: John T. Moy. Network Working Group, 1998. Disponível em: [https://datatracker.ietf.org/doc/html/rfc2328](https://datatracker.ietf.org/doc/html/rfc2328?utm_source=gemini). Acesso em: 24 set. 2026.

<!--
## teste conectividade

root@Host-2:/# ping 172.16.1.1
PING 172.16.1.1 (172.16.1.1) 56(84) bytes of data.
64 bytes from 172.16.1.1: icmp_seq=1 ttl=62 time=1.20 ms
64 bytes from 172.16.1.1: icmp_seq=2 ttl=62 time=1.50 ms
^C
--- 172.16.1.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 1.199/1.350/1.501/0.151 ms
root@Host-2:/# ping 172.16.3.1
PING 172.16.3.1 (172.16.3.1) 56(84) bytes of data.
64 bytes from 172.16.3.1: icmp_seq=1 ttl=62 time=1.23 ms
64 bytes from 172.16.3.1: icmp_seq=2 ttl=62 time=0.838 ms
^C
--- 172.16.3.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.838/1.035/1.232/0.197 ms
root@Host-2:/# ping 8.8.8.8   
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=14.5 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=14.3 ms



## teste de redundância - failover

root@Host-2:/# traceroute -n 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  172.16.2.102  1.593 ms  1.322 ms  1.291 ms
 2  192.168.1.101  2.914 ms  2.892 ms  3.138 ms
 3  192.168.122.1  3.104 ms  3.633 ms  3.606 ms
 4  192.168.18.1  3.566 ms  4.188 ms  4.158 ms
 5  177.125.210.5  9.129 ms  9.302 ms  9.466 ms
 6  177.125.214.213  16.444 ms  15.624 ms  15.718 ms
 7  10.216.16.45  35.176 ms  33.462 ms  28.390 ms
 8  10.216.6.0  16.132 ms  16.068 ms  15.696 ms
 9  10.5.17.222  21.822 ms  21.824 ms  21.453 ms
10  * * *
11  10.5.20.66  14.330 ms  13.965 ms  14.195 ms
12  * * *
13  * * *
14  8.8.8.8  13.910 ms  13.911 ms  14.060 ms
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.502 ms  1.492 ms  1.481 ms
 2  192.168.1.101  2.603 ms  2.602 ms  2.593 ms
 3  172.16.1.1  4.072 ms  4.495 ms  5.195 ms
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  0.982 ms  0.917 ms  0.863 ms
 2  192.168.2.103  1.956 ms  2.104 ms  2.752 ms
 3  192.168.3.101  5.729 ms  6.097 ms  9.475 ms
 4  172.16.1.1  12.647 ms  12.652 ms  13.477 ms
root@Host-2:/# traceroute -n 8.8.8.8   
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  172.16.2.102  1.977 ms  1.956 ms  1.945 ms
 2  192.168.2.103  5.314 ms  5.324 ms  6.314 ms
 3  192.168.3.101  13.082 ms  13.236 ms  14.908 ms
 4  192.168.122.1  16.828 ms  17.538 ms  17.541 ms
 5  192.168.18.1  17.533 ms  17.523 ms  17.514 ms
 6  * 177.125.210.5  94.596 ms  94.583 ms
 7  177.125.214.213  88.813 ms  84.717 ms  84.690 ms
 8  10.216.16.45  22.591 ms  18.759 ms  21.200 ms
 9  10.216.6.0  20.313 ms  18.270 ms  21.789 ms
10  10.5.17.222  17.692 ms  18.915 ms  18.917 ms
11  * * *
12  10.5.20.66  14.266 ms  14.917 ms  14.917 ms
13  * * *
14  * * *
15  8.8.8.8  14.300 ms  14.199 ms  13.978 ms
root@Host-2:/# 
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  0.687 ms  0.670 ms  0.654 ms
 2  192.168.2.103  1.218 ms  1.295 ms  1.374 ms
 3  192.168.3.101  2.205 ms  2.721 ms  3.023 ms
 4  172.16.1.1  4.152 ms  4.814 ms  4.807 ms
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.101 ms  1.091 ms  1.081 ms
 2  192.168.2.103  1.942 ms  2.289 ms  2.361 ms
 3  192.168.3.101  2.997 ms  3.085 ms  3.197 ms
 4  172.16.1.1  6.268 ms  6.270 ms  6.261 ms
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.099 ms  1.082 ms  1.067 ms
 2  192.168.2.103  2.185 ms  2.996 ms  5.965 ms
 3  192.168.3.101  7.821 ms  7.818 ms  8.218 ms
 4  172.16.1.1  8.216 ms  8.204 ms  8.189 ms
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.001 ms  0.989 ms  0.947 ms
 2  192.168.2.103  1.674 ms  1.816 ms  1.880 ms
 3  192.168.3.101  3.937 ms  3.930 ms  4.001 ms

 4  * * *
 5  * * *
 6  * * *
 7  * * *
 8  * * *
 9  * 172.16.1.1  4.525 ms  4.443 ms
root@Host-2:/# 
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.245 ms  1.350 ms  1.439 ms
 2  192.168.2.103  4.446 ms  5.629 ms  5.709 ms
 3  192.168.3.101  6.460 ms  6.602 ms  7.148 ms
 4  172.16.1.1  8.158 ms  8.207 ms *
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.604 ms  1.589 ms  1.575 ms
 2  192.168.2.103  4.703 ms  4.787 ms  4.942 ms
 3  192.168.3.101  6.144 ms  8.889 ms  8.400 ms
 4  172.16.1.1  9.884 ms * *
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.046 ms  1.114 ms  1.075 ms
 2  192.168.2.103  2.272 ms  2.815 ms  4.484 ms
 3  192.168.3.101  8.537 ms  8.529 ms  8.513 ms
 4  172.16.1.1  8.497 ms * *
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.220 ms  1.034 ms  0.947 ms
 2  192.168.2.103  2.184 ms  3.247 ms  3.739 ms
 3  192.168.3.101  5.344 ms  5.580 ms  5.581 ms
 4  172.16.1.1  6.084 ms * *
root@Host-2:/# date
Thu Sep 24 18:46:10 UTC 2026
root@Host-2:/# date
Thu Sep 24 18:46:11 UTC 2026
root@Host-2:/# date
Thu Sep 24 18:46:12 UTC 2026
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  0.553 ms  0.643 ms  0.635 ms
 2  192.168.2.103  1.382 ms  1.607 ms  1.763 ms
 3  192.168.3.101  3.124 ms  3.144 ms  3.314 ms
 4  172.16.1.1  5.531 ms  5.626 ms  5.794 ms
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  0.874 ms  1.326 ms  1.416 ms
 2  192.168.2.103  3.252 ms  3.255 ms  3.244 ms
 3  192.168.3.101  4.272 ms  4.836 ms  5.170 ms
 4  172.16.1.1  5.277 ms  6.214 ms  6.200 ms
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.129 ms  1.176 ms  1.163 ms
 2  192.168.2.103  3.530 ms  5.169 ms  5.199 ms
 3  192.168.3.101  7.098 ms  8.721 ms  9.592 ms
 4  172.16.1.1  13.907 ms  15.522 ms *
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.583 ms  1.493 ms  1.436 ms
 2  192.168.2.103  2.629 ms  2.685 ms  3.000 ms
 3  192.168.3.101  11.257 ms  11.410 ms  11.462 ms
 4  172.16.1.1  11.707 ms * *
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.323 ms  1.251 ms  1.215 ms
 2  192.168.2.103  2.919 ms  2.889 ms  2.862 ms
 3  192.168.3.101  4.803 ms  4.792 ms  4.776 ms
 4  * * *
 5  * * *
 6  * * *
 7  * * *
 8  * * *
 9  * 172.16.1.1  4.759 ms  4.800 ms
root@Host-2:/# traceroute -n 172.16.1.1
traceroute to 172.16.1.1 (172.16.1.1), 30 hops max, 60 byte packets
 1  172.16.2.102  1.072 ms  2.160 ms  2.049 ms
 2  192.168.1.101  5.824 ms  6.370 ms  6.367 ms
 3  172.16.1.1  8.497 ms * *
root@Host-2:/# date
Thu Sep 24 18:46:30 UTC 2026
root@Host-2:/# traceroute -n 8.8.8.8   
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  172.16.2.102  2.379 ms  2.363 ms  2.348 ms
 2  192.168.1.101  4.032 ms  4.066 ms  4.054 ms
 3  192.168.122.1  5.687 ms  5.749 ms  5.742 ms
 4  192.168.18.1  5.726 ms  5.810 ms  5.452 ms
 5  177.125.210.5  9.184 ms  9.244 ms  9.211 ms
 6  177.125.214.213  18.253 ms  16.372 ms  16.765 ms
 7  10.216.16.45  20.004 ms  16.876 ms  18.393 ms
 8  10.216.6.0  16.808 ms  14.836 ms  19.647 ms
 9  10.5.17.222  16.201 ms  16.203 ms  16.136 ms
10  * * *
11  10.5.20.66  15.995 ms  14.654 ms  14.709 ms
12  * * *
13  * * *
14  8.8.8.8  14.878 ms  14.842 ms  14.752 ms
-->
