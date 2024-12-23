---
layout: post
---

## Verificando se o Docker está instalado

Para iniciar os trabalhos com o Docker, é bom primeiro verificar se o
mesmo está devidamente instalado.

Isso pode ser feito de várias formas, mas vamos fazer verificando a
versão do Docker instalado, com o seguinte comando:

``` console
$ docker --version
Docker version 27.0.3, build 7d4bcd863a
```

Caso o comando não exista, será necessário instalar o Docker em seu
sistema. Nenhuma instalação será abordada aqui neste material,
recomenda-se buscar informações a respeito de como proceder tal
instalação no sítio oficial do
[Docker](https://docs.docker.com/engine/install/), já que a instalação
pode variar de sistema para sistema.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>No caso do Linux veja como instalar em <a
href="https://docs.docker.com/desktop/install/linux-install/"
class="uri">https://docs.docker.com/desktop/install/linux-install/</a>.</p></div></div>

Além do comando `docker --version`, é comum executar os comandos:

-   `docker version`, que apresenta mais informações do que o comando
    que foi digitado anteriormente;
-   `docker info`, que traz mais informações ainda, informações a
    respeito do cliente, servidor, etc.

Para ver se o servidor está em execução em sistemas Linux, é possível
utilizar o comando `ps`, tal como:

``` console
$ ps ax | grep dockerd
    791 ?        Ssl    0:00 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
   8748 pts/0    S+     0:00 grep dockerd
```

Neste exemplo são retornados dois processos com o termo `dockerd`, sendo
esses:

-   8748, é do `grep`, utilizado para filtrar as saídas no comando `ps`
    (esse não interessa).
-   791, é o processo em execução do Docker (`/usr/bin/dockerd`), ou
    seja, era o que estávamos procurando e se ele não estivesse ai, algo
    estaria errado com a execução do Docker neste sistema.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>Lembrando que os números dos processos provavelmente vão mudar em
cada sistema, já que são aleatórios.</p></div></div>

Bem, mas só executamos esses comandos para ter certeza que o Docker está
instalado - isso não é obrigatório. Agora vamos para o próximo passo,
que é realmente utilizar o Docker para fazer alguma coisa.

## Executando containers (`run`)

Vamos executar um container Docker simples para efetivamente verificar
se tudo está funcionando no Docker.

Para isso, vamos utilizar o comando `docker run`. Nesta primeira
execução será iniciada uma imagem do Ubuntu Linux, com interação de um
*shell*, para este sistema. Para tanto vamos executar o seguinte
comando:

``` console
$ docker run -i -t ubuntu /bin/bash
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
9c704ecd0c69: Pull complete
Digest: sha256:2e863c44b718727c860746568e1d54afd13b2fa71b160f5cd9058fc436217b30
Status: Downloaded newer image for ubuntu:latest
root@ebfc7d73bf3a:/#
```

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
    <div>
    <p>Pode ser necessário utilizar o comando <code>sudo</code> para
executar o <code>docker</code>. Como exemplo, o comando anterior ficaria
<code>sudo docker run -i -t ubuntu /bin/bash</code>.</p></div></div>

O comando anterior, bem como sua saída, apresentam várias "coisas"
interessantes do Docker. Assim, vamos dissecar primeiro o comando
executado (docker run -i -t ubuntu /bin/bash), vendo as seguintes opções
e parâmetros:

-   `-i`, mantém a saída padrão (STDIN) do container no console do
    hospedeiro, ou seja, todas as saídas geradas pelo container serão
    apresentadas na tela na qual o comando foi digitado;
-   `-t`, informa para o Docker associar um console virtual
    (*pseudo-tty*) para o container criado. Isso vai permitir interagir
    como container, através da execução de comandos;
-   `ubuntu`, é o nome da imagem utilizada para criar o container.
    Outras imagens poderiam ser utilizadas, essas podem estar disponível
    localmente ou na Internet, por exemplo no [Docker
    Hub](https://hub.docker.com/). Depois, em [Imagens](docker-imagens), vamos ver
    melhor como listar e utilizar essas imagens.
-   `/bin/bash`, esse é o comando a ser executado no container que está
    sendo criado. Mais especificamente, neste exemplo, estamos pedindo
    para o container executar o `bash`, que é normalmente o *shell*
    padrão de ambientes Linux. Neste caso, como esperamos interagir com
    o container, via comandos (dadas as opções `-i` e `-t`), vamos fazer
    isso via console. Ou seja, isso vai permitir interagir com o
    container através de um console texto, no qual será possível digitar
    comandos no container.

### Interagindo com o `bash` do container

Bem, com o resultado do comando anterior, estamos dentro de um
container, pronto para interagir com ele através do *prompt* de comando.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
    <div>
    <p>Os comandos apresentados a seguir podem variar de container para
container dependendo da distribuição e da versão da mesma, bem como das
configurações já realizadas em um container pré-configurado. Tais
comandos são do Linux e não do Docker.</p></div></div>

Então vamos por exemplo executar alguns comandos Linux neste container.

#### Verificando o nome do container:

Podemos utilizar o comando `hostname` do Linux, para ver o nome do
*host*/container.

``` console
root@ebfc7d73bf3a:/# hostname
ebfc7d73bf3a
```

A saída anterior, mostra que o nome do *host* é ebfc7d73bf3a.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
    <div>
    <p>Neste exemplo o nome ebfc7d73bf3a é o ID do container, ou seja, é um
valor que identifica o container de forma única dentro do Docker.</p></div></div>

#### Verificando detalhes de redes do container:

Atualmente, para verificar as configurações de rede do Linux é comum
utilizar o comando `ip`. Todavia se tentarmos utilizar o comando `ip`
neste container, o resultado será o seguinte:

``` console
root@ebfc7d73bf3a:/# ip
bash: ip: command not found
```

Ou seja, o comando `ip` não está instalado por padrão neste container,
mas é possível instalar pacotes neste container, conforme é abordado a
seguir.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>Neste caso, seria possível ver o IP do container sem instalar o
comando <code>ip</code>, isso pode ser feito com o comando
<code>hostname -I</code>.</p></div></div>

#### Atualizando o Ubuntu do container:

Para atualizar o Ubuntu do container basta fazer um `atp update`, tal
como seria em um computador normal (sem container):

``` console
root@ebfc7d73bf3a:/# apt update
Get:1 http://archive.ubuntu.com/ubuntu noble InRelease [256 kB]
...
Reading state information... Done
2 packages can be upgraded. Run 'apt list --upgradable' to see them.
```

#### Instalando pacotes do Ubuntu do container:

Agora com o `apt` atualizado, é possível instalar o comando `ip`, no
caso ele é disponibilizado através do pacotes `iproute2`, então vamos
instalar esse:

``` console
root@ebfc7d73bf3a:/# apt install iproute2
Reading package lists... Done
...
Do you want to continue? [Y/n]
Get:1 http://archive.ubuntu.com/ubuntu noble/main amd64 libelf1t64 amd64 0.190-1.1build4 [57.6 kB]
...
Processing triggers for libc-bin (2.39-0ubuntu8.2) ...
```

A saída anterior mostra que o `iproute2` foi instalado com sucesso.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>Se o container não for derivado do Debian, como é o caso do Ubuntu,
pode ser que o comando <code>apt</code> não exista, ai será necessário
utilizar outras formas para instalar pacotes - isso pode variar de
distribuição para distribuição.</p></div></div>

#### Verificando as configurações de rede com o comando `ip`:

Com o pacote `iproute2` instalado, agora é possível utilizar o comando
`ip`, tal como:

``` console
root@ebfc7d73bf3a:/# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
6: eth0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

A saída anterior, mostra que no container existem as seguintes
interfaces de rede:

-   `lo`, com o IP 127.0.0.1/8;
-   `eth0`, com o IP 172.17.0.2/16.

Daria para explorar mais informações, tal como a rota padrão através do
comando `ip route`.

#### Verificando os processos em execução no container:

Para verificar os processos em execução no container, podemos utilizar o
comando `ps`, tal como:

``` console
root@ebfc7d73bf3a:/# ps ax
    PID TTY      STAT   TIME COMMAND
      1 pts/0    Ss     0:00 /bin/bash
    339 pts/0    R+     0:00 ps ax
```

A saída do comando anterior mostra que há dois processos no container em
questão. Sendo esses representados pelos seguintes PIDs:

-   `1`, para o processo `bash`, que é o *shell* que pedimos para
    executar no comando que criou o container;
-   `339`, para o processo `ps`, que é o último comando que foi
    executado.

Daria para ficar interagindo com o container, tal como em um sistema
normal, mas vamos parar por aqui.

### Saindo do console do container (`exit`)

Para sair do console do container, basta digitar `exit`, tal como:

``` console
root@ebfc7d73bf3a:/# exit
exit
$
```

Conforme a saída do comando anterior, veja que saímos do container
`ebfc7d73bf3a`, no qual estávamos com o usuário `root`, e no exemplo,
voltamos para o *host* `fielDell`, com o usuário `luiz`.

Bem, mas o que aconteceu com o container que estava em execução? A
resposta é: ele parou de ser executado! Isso acontece, pois o Docker
iniciou o container para executar o comando `/bin/bash`, e quando
digitamos `exit`, o comando `/bin/bash` para de ser executado e assim o
container inteiro para.

## Listando containers

Uma tarefa extremamente comum é listar os containers que estão em
execução, bem como os que estão parados. Veja como fazer isso a seguir.

### Listar containers parados (`ps -a`)

Para ver os containers parados, execute o comando `docker ps -a`:

``` console
$ docker ps -a
CONTAINER ID   IMAGE                               COMMAND                  CREATED             STATUS                        PORTS     NAMES
ebfc7d73bf3a   ubuntu                              "/bin/bash"              About an hour ago   Exited (0) 47 minutes ago               strange_jang
06d326091537   luizarthur/cyberinfra:hostDeb11     "/gns3/init.sh bash"     6 weeks ago         Exited (137) 6 weeks ago                admiring_burnell
```

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>A saída infelizmente pode extrapolar o tamanho da página, e por isso
as colunas ficam em posições ruins de mostrar o resultado - isso também
pode acontecer em um terminal de computador.</p></div></div>

No exemplo da saída anterior temos dois containers parados, sendo esses:

-   `ebfc7d73bf3a`, que tem o nome `strange_jang`, derivado de uma
    imagem chamada `ubuntu`, sendo esse o container deste exemplo.
-   `06d326091537`, com o nome `admiring_burnell`, criado da imagem
    `luizarthur/cyberinfra:hostDeb11`.

Note ainda na saída anterior, que dá para ver os comandos de iniciação
desses containers (`COMMAND`), bem como algumas informações de tempo
(`CREATED`), estado do container (`STATUS`), etc.

A princípio o nome do container é gerado automaticamente, mas é possível
informar um nome para o container utilizando a opção `--name`. Os nomes
devem ser únicos. Assim, na hora de criar o container, informe o nome
deste container, tal como:

``` console
$ docker run --name meuContainer -i -t ubuntu /bin/bash
```

No exemplo anterior seria criado um container chamado `meuContainer`.

### Listar containers em execução (`ps`)

Para listar containers em execução, basta executar o comando
`docker ps`, ou seja, é apenas tirar o `-a` do comando anterior. Veja o
exemplo:

``` console
$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

No exemplo da saída anterior, não há nenhum container em execução.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
    <div>
    <p>Note que o comando <code>ps</code> dentro de sistemas Unix-Like,
apresentam os processos em execução. Já o <code>ps</code> passado como
parâmetro para o comando <code>docker</code>, apresenta containers em
execução ou parados. Ou seja, eles não são equivalentes.</p></div></div>

Para listagens, há duas opções úteis:

-   `-n` seguida de um número inteiro, mostrará os últimos *x*
    containers (não importa o estado do container - em execução ou
    parado), sendo que *x* é o número digitado na frente de `-n`;
-   `-l`, mostrará apenas o último container (não importa o estado).

As opções `-n` e `-l` são importantes, pois podem haver vários
containers na lista retornada pelo comando `ps`. Assim tais opções vão
filtrar e mostrar os mais recentes, que normalmente são os que estamos
trabalhando no momento.

## Iniciando containers parados (`start`)

É possível iniciar um container que está parado, isso é feito com o
comando `docker start` seguido do ID do container ou nome.

Então vamos iniciar o container que criamos anteriormente, através de
seu ID (visto na listagem dos containers parados):

``` console
$ docker start ebfc7d73bf3a
ebfc7d73bf3a
```

Feito isso, agora se listarmos os containers em execução, teremos o
seguinte resultado:

``` console
$ docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED       STATUS         PORTS     NAMES
ebfc7d73bf3a   ubuntu    "/bin/bash"   2 hours ago   Up 3 seconds             strange_jang
```

Ou seja, o container ebfc7d73bf3a, saiu de parado para em execução
(`Up`).

## Acessando containers em execução (`attach`)

Bem, mas e agora? Como interagir com o console deste container que
acabamos de ligar novamente, no exemplo anterior? Para isso é possível
utilizar a opção `attach`, tal como:

``` console
$ docker attach ebfc7d73bf3a
root@ebfc7d73bf3a:/#
```

Assim estamos novamente no console do container que voltou à execução
pela opção `start`.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>Atenção, para sair de um console de um container, sem parar o
processo, é possível pressionando as teclas <code>Ctrl+p</code> seguido
de <code>Ctrl+q</code>. Então, pressione a tecla <code>ctrl</code> e a
tecla <code>p</code>. Depois, sem soltar o <code>ctrl</code>, solte o
<code>p</code> e pressione <code>q</code>.</p></div></div>

## Parando containers em execução (`stop`)

Para parar um container que está em execução podemos utilizar a opção
`stop`. Então, normalmente você vai listar os containers em execução com
o comando `docker ps`, vai pegar o ID ou nome deste e executar o comando
`docker`, com a opção `stop`, tal como:

-   Verificando os containers em execução:

``` console
$ docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED       STATUS         PORTS     NAMES
ebfc7d73bf3a   ubuntu    "/bin/bash"   2 hours ago   Up 3 seconds             strange_jang
```

Neste caso vamos utilizar ID ebfc7d73bf3a.

-   Parando o container:

``` console
$ docker stop ebfc7d73bf3a
ebfc7d73bf3a
```

-   Verificando se realmente o container parou:

``` console
$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

Como observa-se na última saída, o container `ebfc7d73bf3a` não está
mais em execução. É claro que os passos de verificação apresentados
aqui, não são obrigatórios, mas é comum executá-los no dia a dia, para
ter certeza do que estamos fazendo.

A opção `stop` do Docker, envia um sinal SIGTERM para o container.
Todavia é possível enviar o sinal SIGKILL, com a opção **`kill`**.

Desta forma, com o `stop`, o container é fechado de forma elegante,
encerrando o processo corretamente. Já com o `kill`, o processo do
container é fechado abruptamente, por exemplo, sem salvar conteúdos em
disco - se for o caso. Então, o `kill` só deve ser utilizado em casos
extremos, nos quais o container pode comprometer a integridade do
sistema como um todo, ou por estar travado (não responde de forma
alguma).

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>As opções <code>stop</code> e <code>kill</code> do Docker fazem mais
sentido para containers que rodam processos em plano de fundo, no estilo
<em>daemon</em> (veremos esse a seguir). Se o container for executado de
forma interativa, utilizando por exemplo o <code>/bin/bash</code>, é
possível pará-lo com o <code>exit</code>, via console.</p></div></div>

## Criando containers no estilo *daemon* (`-d`)

Da forma que utilizamos container até o momento, eles ficam bastante
parecidos com VMs completas, utilizados no VirtualBox ou VMWare.
Entretanto, na prática, não se espera que os containers funcionem assim,
de forma interativa - mesmo que eles possam ser utilizados desta forma.

Atualmente, esperá-se que os containers executem pequenas partes de um
serviço maior, no estilo microsserviço. Por exemplo, um container pode
executar um servidor de banco de dados, outro executa um serviço Web,
tal como JavaScript, outro PHP e assim por diante. Lembre-se que o
Docker, ao contrário das VMs completas, compartilham recursos do
computador hospedeiro, então os containers não consomem recursos em
demasia se comparados às VMs completas e por isso, são uma boa opção
para segmentar serviços, isolando ambientes diferentes e assim
fornecendo mais segurança, escalabilidade, etc.

Dito isso, é comum executar containers sem interagir diretamente com
eles. Desta forma, o administrador basicamente vai configurar qual
serviço ou serviços o container deve executar quando for iniciado, e
depois, só vai interagir com os serviços providos pelo container - não
vai ficar interagindo com o container via *shell*. Então, normalmente
será necessário "daemonizar" os serviços que o container vai executar,
ou seja, é necessário deixar os processos executados pelo container
rodando em plano de fundo (*backgroud*), já que simplesmente não haverá
uma tela por padrão esperando a interação do usuário. Em outras
palavras, a ideia é colocar serviço/processo, bem como o container como
*daemon*.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>Normalmente serviços de rede são executados em servidores como
<em>daemons</em>, tais como: HTTP, SSH, SMB, NFS, etc.</p></div></div>

Para iniciar processos em *backgroud* no Docker, utiliza-se a opção
**`-d`**. Uma curiosidade é que o `-d` significa *detach* e não
*daemon*, mas ela serve para deixar o processo como se fosse um
*daemon*. Desta forma, com a opção *detach*, espera-se que não exista um
console acoplado para interação, tal como:

``` console
$ docker run --name cont1 -d ubuntu /bin/sh -c "while true; do echo Olá mundo; date; sleep 10; done"
7b4b0a3be0b58fdfa7f8e0e4674bc38a400c564ec969a853ae6ee0add9796010
```

No comando anterior, estamos basicamente informando o seguinte para o
Docker:

-   `run`: inicie o container;
-   `--name cont1`: atribuir o nome cont1 ao container;
-   `-d`: ele vai ser executado em plano de fundo (no estilo *daemon*);
-   `ubuntu`: utiliza a imagem do Ubuntu;
-   `/bin/sh`: vai executar um *script*.

Em resumo, iniciamos um container para executar um *shell script* que
fica apresentando na saída do container o seguinte: texto "Olá mundo",
seguido da data/hora do container, repedindo isso a cada 10 segundos.
Tudo isso foi feito através dos comandos que estão na frente de
`/bin/sh -c`.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>Note que o comando passado para esse container é o
<code>/bin/sh</code>, tudo que vêm após tal comando
(<code>-c "while true; do echo Olá...</code>), são opções e parâmetros
do <code>sh</code> e não do comando <code>docker</code>.</p></div></div>

Se tudo correr bem, após iniciar o container utilizando a opção `-d`,
não haverá nenhuma saída do container na tela do computador hospedeiro.
Desta forma, para ver o status do container é possível utilizar o `ps`,
tal como:

``` console
$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS     NAMES
7b4b0a3be0b5   ubuntu    "/bin/sh -c 'while t…"   9 seconds ago   Up 9 seconds             cont1
```

O comando anterior, mostra pelo status, que o container está em
execução, à 9 segundos (`Up 9 seconds`). Todavia, o status não mostra o
que está acontecendo dentro do container, para ter mais detalhes vamos
ver o comando `logs` na seção a seguir.

## Verificando as saídas dos containers (`logs`)

Com o container sendo executado tal como um *daemon*, ou seja, em plano
de fundo, o resultado da execução do container não aparecerá por padrão
na tela do hospedeiro.

Todavia, é possível utilizar o comando `docker logs` para ver a saída de
containers Docker que estão sendo executados como *daemons*.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
    <div>
    <p>O <code>docker logs</code> apenas apresenta a saída do container, ele
não permite a interação com o mesmo (ex. digitar comandos no
container).</p></div></div>

Desta forma, para ver o que está acontecendo no terminal do container do
exemplo anterior, que está em *background*, podemos executar o seguinte
comando:

``` console
$ docker logs cont1
Olá mundo
Tue Jul 16 18:56:51 UTC 2024
Olá mundo
Tue Jul 16 18:57:01 UTC 2024
Olá mundo
Tue Jul 16 18:57:11 UTC 2024
Olá mundo
Tue Jul 16 18:57:21 UTC 2024
Olá mundo
Tue Jul 16 18:57:31 UTC 2024
Olá mundo
Tue Jul 16 18:57:41 UTC 2024
```

A saída anterior mostra que o *script* executado no container do exemplo
anterior, está funcionando corretamente, pois está apresentando na tela
o texto "Olá mundo", seguido da data/hora do container, a cada 10
segundos, tal como programado no *script*.

O comando `docker logs`, sem nenhuma opção, vai apresentar uma prévia da
saída do container e parar. Caso seja necessário monitorar as saídas do
container de forma continua, dá para utilizar a opção **`-f`**. Desta
forma, as saídas do container ficam aparecendo na tela do hospedeiro,
até o administrador pressionar `Ctrl+c`, para sair. Então para ter esse
resultado o comando anterior ficaria da seguinte forma:

``` console
$ docker logs -f cont1
Olá mundo
Tue Jul 16 18:56:51 UTC 2024
Olá mundo
Tue Jul 16 18:57:01 UTC 2024
Olá mundo
Tue Jul 16 18:57:11 UTC 2024
...
```

O comando `docker logs -f` é muito utilizado no dia a dia, pois permite
o monitoramento continuo do container que está sendo executado no estilo
*daemon*.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>A opção <code>docker logs -f</code> é similar ao comando
<code>tail -f</code>, utilizada para monitorar arquivos de <em>log</em>
de sistemas Unix-Like. Lembre que é utilizado o <code>Ctrl+c</code> para
sair desses comandos.</p></div></div>

## Reiniciando automaticamente containers (`--restart`)

Os containers podem parar de funcionar por causa de algum erro
inesperado e se ele tiver sendo executado em plano de fundo, você
provavelmente não verá tal problema.

Então é possível iniciar o container informando, por exemplo, que se
algo der errado, ele deve se auto reiniciar e isso é feito com a opção
**`--restart`**. Desta forma, caso o programa executado pelo container
termine normalmente ou termine devido à algum erro, o container vai
reiniciar sozinho.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
    <div>
    <p>É importante perceber que o container sai do status de “em execução”
para “parado”, devido à basicamente duas situações:</p>
<ul>
<li>O programa que ele executa simplesmente terminou normalmente;</li>
<li>Houve algum erro com o programa e por isso ele foi abortado.</li>
</ul></div></div>

Exitem algumas opções para o reinicio automático para containers Docker,
sendo as mais comuns:

-   `always`: com esta opção, o container sempre será reinicializado,
    não importa o motivo (terminou normalmente ou por erro). Mesmo se o
    computador hospedeiro for reinicializado, o Docker vai iniciar
    novamente o container.
-   `unless-stopped`: similar ao `always`, mas neste caso o container
    não é reinicializado se estiver no estado de "parado" (ex. alguém
    parou o container com `docker stop`). Todavia, se o processo do
    Docker for reinicializado (ex. reinicializaram o computador
    hospedeiro), o container será religado.
-   `on-failure`: com esta opção, o container é reinicializado apenas se
    tiver um erro (`exit` diferente de zero). Nesta opção ainda dá para
    determinar o número de vezes que o container vai tentar religar,
    caso essa quantidade seja atingida ele desiste de religar.

Para exemplificar o uso dessas funções do `restart`, vamos alterar um
pouco o *script* utilizado no `cont1` (exemplo anterior). Vamos criar um
novo container chamado `cont2`, que basicamente tem o mesmo *script* do
`cont1`, só que adicionado um `exit 1`, após o "Olá mundo" e o resto
continua como era antes. O objetivo aqui é simular um erro no *script*,
já que quando o código chegar a linha do `exit 1`, ele determina que o
*script* deve ser interrompido, e é retornado um 1 para o sistema (que
representa um erro). Desta forma, o *script* nunca vai mostrar a
data/hora, tal como fazia antes, já que o `exit` é executado antes.

A seguir são apresentados exemplos de opções para o uso do `restart` com
esse novo *script* alterado:

### Opção `always`

No exemplo a seguir é utilizada a opção `always` do `restart`, de forma
que o container seja reinicializada toda vez que ele for encerrado (por
erro ou porque o programa terminou normalmente):

``` console
$ docker run --restart=always --name cont2 -d ubuntu /bin/sh -c "while true; do echo Olá mundo; exit 1; date; sleep 10; done"
6a17852229690344c0931d3fdcdd44775a17a79902d53bb70805b2ba43b7bd69
```

O comando anterior, mostra como utilizar a opção `--restart=always`. No
comando também determinamos que o nome do container é `cont2`, que este
deve ser executado em plano de fundo (`-d`), é criado a partir da imagem
`ubuntu`, e principalmente está com o *script* alterado, que é abortado
ao chegar no `exit`.

Assim, vamos utilizar a opção `log`, para ver a saída deste exemplo:

``` console
$ docker logs -f cont2
Olá mundo
Olá mundo
Olá mundo
Olá mundo
Olá mundo
Olá mundo
Olá mundo
```

Dada a saída anterior, observa-se que o container `cont2` apresenta o
texto "Olá mundo", várias vezes, mas nunca a data/hora do sistema. Isso
significa que o *script* é executado até o `echo Olá mundo` e é
abortado. Desta forma, sem a opção `restart` o container seria
encerrado, mas como estamos utilizando a opção `--restart=always`, o
container é reiniciado toda vez que o *script* é finalizado pelo `exit`,
esse comportamento vai se repetir indefinidamente.

### Opção `on-failure`

O exemplo a seguir mostra como é utilizada a opção `on-failure` do
`restart`. Tal opção só reinicializa o container se o processo for
finalizado com um `exit` maior que zero, ou seja, se o container for
finalizado por causa de erros do programa sendo executado. Desta forma,
se o programa terminar normalmente, o container não será reinicializado.

Para esse exemplo, foi criado um container chamado `cont3`, que fora o
nome do container, a única diferença do exemplo anterior (`cont2`) é que
foi utilizado a opção `--restart=on-failure:3`. Sendo que esse `:3`, na
frente da opção, significa que ele só será reinicializado três vezes. Se
for utilizado apenas o `--restart=on-failure`, sem nada na frente (ex.
`:3`), ele será reinicializado de forma indefinida.

``` console
$ docker run --restart=on-failure:3 --name cont3 -d ubuntu /bin/sh -c "while true; do echo Olá mundo; exit 1; date; sleep 10; done"
857022977d13473202ce0ac1988a124ff76375dfc1326ff7c5eb4f50b24949c4
```

Depois de executar o comando para criar o container chamado `cont3`,
vamos ver sua saída com o `logs`:

``` console
$ docker logs -f cont3
Olá mundo
Olá mundo
Olá mundo
Olá mundo
```

Dada a saída anterior, note que há quatro vezes o texto "Olá mundo",
então o container foi executado pela primeira vez, ai saiu com um
`exit 1`, depois isso aconteceu mais três vezes e o container foi
abortado (ficou no estado de parado).

Vamos executar os comandos para verificar o status dos containers
criados até aqui, primeiro vamos ver os containers ativos:

``` console
$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED              STATUS                          PORTS     NAMES
6a1785222969   ubuntu    "/bin/sh -c 'while t…"   About a minute ago   Restarting (1) 48 seconds ago             cont2
7b4b0a3be0b5   ubuntu    "/bin/sh -c 'while t…"   40 hours ago         Up 27 hours                               cont1
```

Note que estão ativos os containers `cont1` e `cont2`, ou seja, o
`cont2` está em execução, mesmo que o seu processo esteja retornando
erro em toda execução. Perceba que não há o container `cont3` na saída
anterior, então vamos ver se esse se encontra parado com o comando
`docker ps -l`, já que este foi o último container que trabalhamos:

``` console
$ docker ps -l
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS                      PORTS     NAMES
857022977d13   ubuntu    "/bin/sh -c 'while t…"   58 seconds ago   Exited (1) 56 seconds ago             cont3
```

A saída anterior, demonstra mais uma vez que a opção
`--restart=on-failure:3` foi executada com sucesso, já que o `cont3` foi
abortado/parado, depois de algumas execuções.

<div style="display: block; align-items: center; margin: 0 auto; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>No comando anterior utilizamos <code>docker ps -l</code> para ver
apenas o último container que foi abortado pelo Docker, pois como não há
outros containers sabíamos que provavelmente o <code>cont3</code> era o
último container que foi abortado.</p></div></div>

## Deletando containers (`rm`)

Como descrito até aqui, uma vez que você execute um container, ele vai
estar na lista de containers ativos ou parados, tal como pode ser visto
a seguir, com os container que trabalhamos neste material:

``` console
$ docker ps -a
CONTAINER ID   IMAGE                               COMMAND                  CREATED        STATUS                          PORTS     NAMES
857022977d13   ubuntu                              "/bin/sh -c 'while t…"   6 hours ago    Exited (1) 6 hours ago                    cont3
6a1785222969   ubuntu                              "/bin/sh -c 'while t…"   6 hours ago    Restarting (1) 55 seconds ago             cont2
7b4b0a3be0b5   ubuntu                              "/bin/sh -c 'while t…"   46 hours ago   Up 33 hours                               cont1
ebfc7d73bf3a   ubuntu                              "/bin/bash"              2 days ago     Exited (137) 47 hours ago                 strange_jang
06d326091537   luizarthur/cyberinfra:hostDeb11     "/gns3/init.sh bash"     7 weeks ago    Exited (137) 6 weeks ago                  admiring_burnell
```

Todavia, em alguns momentos vão haver containers que não vamos mais
utilizar, como por exemplo containers de testes ou defasados. Assim, é
possível remover esses containers utilizando o comando `rm` do Docker.

Por exemplo, vamos remover o container chamado `cont3`, para isso
podemos utilizar o seguinte comando:

``` console
$ docker rm cont3
cont3
```

O resultado do comando será apenas uma saída com o nome do container,
neste caso foi `cont3`. Neste exemplo anterior, utilizamos o nome do
container para removê-lo, mas é possível utilizar o ID, vamos remover o
primeiro container que criamos utilizando o ID dele, tal como:

``` console
$ docker rm ebfc7d73bf3a
ebfc7d73bf3a
```

Depois de remover o `cont3`, vamos tentar remover o `cont2`, entretanto
o resultado para essa deleção será o seguinte:

``` console
$ docker rm cont2
Error response from daemon: cannot remove container "/cont2": container is restarting: stop the container before removing or force remove
```

A saída anterior informa que o `cont2` está configurado para reiniciar,
assim é necessário primeiro pará-lo e depois removê-lo, tal como:

``` console
$ docker stop cont2
cont2
$ docker rm cont2
cont2
```

Agora que os containers foram removidos, é possível constatar tal tarefa
utilizando o comando `docker ps -a`:

``` console
$ docker ps -a
CONTAINER ID   IMAGE                               COMMAND                  CREATED        STATUS                     PORTS     NAMES
7b4b0a3be0b5   ubuntu                              "/bin/sh -c 'while t…"   47 hours ago   Up 33 hours                          cont1
06d326091537   luizarthur/cyberinfra:hostDeb11     "/gns3/init.sh bash"     7 weeks ago    Exited (137) 6 weeks ago             admiring_burnell
```

A saída anterior mostra que foram removidos: o primeiro container que
criamos; `cont2` e `cont3`, ou seja, chegamos no resultado que queríamos
para esses exemplos de remoção de containers.

Em alguns casos especiais é necessário **remover todos os containers**,
mas não há um comando específico do Docker para tal tarefa. Assim, é
possível combinar comandos, no estilo *shell script* para conseguir tal
resultado, neste caso um possível comando no Linux seria:

``` console
$ docker rm -f $(docker ps -aq)
```

No comando anterior, foram combinados os comandos `docker ps -aq`, que
gera uma lista de ID (`-q`) de containers do Docker, depois cada item
desta lista é executada pelo comando `docker rm`, é claro que esse
comando deve ser utilizado com cautela, pois apaga todos os containers
do sistema.

Também dá para iniciar um container com a opção **`--rm`**, desta forma
o container é executado uma única vez, e quando o programa que ele está
executando terminar, o container é imediatamente removido do sistema. Um
exemplo de comando utilizando o `--rm` é:

``` console
$ docker run --rm --name cont5 -d ubuntu /bin/sh -c "echo Olá mundo"
060e1626cd5e460ff6a9270da00ab350b9fbaea5d73841d5c50bfc6a5067fc09
```

Utilize o comando `docker ps -l` e você notará que o container `cont5`,
criando anteriormente, não aparecerá na listagem de containers do
sistema.

A opção `--rm` é muito útil durante a criação de containers de teste,
pois assim que o container for encerrado o mesmo será removido e não vai
ficar ocupando recursos dentro do sistema hospedeiro.

## Rótulos nos containers (`-l`)

Como uma das ideias principais de containers é utilizar vários desses,
cada um provendo determinados serviços, é natural que exista algum tipo
de recurso mínimo para ajudar à organizar os containers.

Bem, um desses recursos são os rótulos (*labels*), que servem como
metadados que podem ajudar a identificar os containers, por exemplo,
quais containers são de uma dada organização, ou quais containers estão
relacionados a um dado serviço. Então para utilizar os *labels* no
Docker basta utilizar a opção **`-l`**. Veja o exemplo a seguir:

``` console
$ docker run --rm -l teste -d ubuntu /bin/sh -c "while true; do echo Olá mundo; date; sleep 10; done"
937619dfdf891ef84a98ac94c3d60d1edae2cd0cc596ba8459b2afeaaa815d8b

$ docker run --rm -l teste -d ubuntu /bin/sh -c "while true; do echo Olá mundo; date; sleep 10; done"
```

Anteriormente são criados dois containers, esses basicamente executam o
primeiro *script* que utilizamos de exemplo, não foram passados nomes
para esses, utilizam a opção `--rm` para serem removidos quando forem
desligados e principalmente para estes exemplo, utilizam uma *label*
chamada "teste" (`-l teste`).

Desta forma, agora é possível utilizar tal *label* para localizar os
containers, tal como:

``` container
$ docker ps -a -f label=teste
CONTAINER ID   IMAGE     COMMAND                  CREATED              STATUS              PORTS     NAMES
496d3dc5d3dd   ubuntu    "/bin/sh -c 'while t…"   57 seconds ago       Up 56 seconds                 cranky_hodgkin
937619dfdf89   ubuntu    "/bin/sh -c 'while t…"   About a minute ago   Up About a minute             goofy_agnesi
```

Graças a esse rótulo, também é possível criar comandos mais complexos,
tal como desligar todas os containers que tenham a *label* "teste". O
comando a seguir realiza essa tarefa:

``` console
$ docker stop $(docker ps -q --filter "label=teste")
496d3dc5d3dd
937619dfdf89
```

Como foi utilizada a opção `--rm`, esses container também foram
removidos da lista de containers do sistema.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>É comum utilizar <em>labels</em> com mais de uma palavra separada por
<code>=</code>, tal como <code>desenvolvimento=maria</code>.</p></div></div>

## Criando Containers (`create`)

Para criar um container é possível utilizar o comando `run`, tal como já
fizemos no início deste texto, ou utilizar o comando `create`.

A grande diferença é que o `create` só cria o container e não coloca ele
em execução. Então, após criar tal container é bem provável que o
administrador execute o comando `start`. Desta forma, ao executar o
comando `run`, ele internamente está executando um `create` seguido do
`start`.

O comando a seguir é um exemplo do uso do comando `create` para criar um
container chamado `cont6`:

``` console
$ docker create --name cont6 ubuntu /bin/sh -c "while true; do echo Olá mundo; date; sleep 10; done"
```

Após executar o comando anterior, o status do container será de criado
(`Created`), veja:

``` console
$ docker ps -l
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS    PORTS     NAMES
931b22bca56f   ubuntu    "/bin/sh -c 'while t…"   10 seconds ago   Created             cont6
```

Todavia, o container do exemplo anterior, foi criado mas não está em
execução, ou seja, está parado. Assim, para mudar o seu estado para em
execução, é necessário executar um `start`, tal como:

``` console
$ docker start cont6
cont6
```

Desta forma o container irá para o estado de "executando" (`Up`), tal
como apresentado na saída a seguir do comando `docker ps -l`, deste
exemplo:

``` console
$ docker ps -l
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS     NAMES
931b22bca56f   ubuntu    "/bin/sh -c 'while t…"   2 minutes ago   Up 5 seconds             cont6
```

É possível utilizar o `create` e `start` do Docker para criar
containers, entretanto se for para criar o container e imediatamente
colocá-lo em execução, é mais fácil/prático utilizar o comando `run`.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 50px; height: 50px;"></div>
 <div>
    <p>Após criar um container com o comando <code>create</code> do Docker,
não é possível utilizar o comando <code>run</code>, para executar um
container com o mesmo nome do container criado. Neste caso, será
reportado um erro dizendo que o container já existe.</p></div></div>

## Informações dos containers (`inspect`)

Comando `inspect` do Docker, permite verificar a configuração completa
do container. O `inspect`, mostrará as mais diversas informações do
container, tal como: nome, configurações de rede, armazenamento, estado,
imagem, comando, etc. Isso pode ser muito útil, por exemplo, para a
depuração de erros, identificação ou criação de containers similares.

Para inspecionar um container utilizando o `inspect` é necessário apenas
executar `docker inspect` seguido do nome ou ID do container, tal como:

``` console
$ docker inspect cont6
[
    {
        "Id": "931b22bca56f04add7b383e12a862cd3cd9ef1c582cb8136e5b5afb0a8f4b935",
        "Created": "2024-07-19T14:56:22.519662813Z",
        "Path": "/bin/sh",
        "Args": [
            "-c",
            "while true; do echo Olá mundo; date; sleep 10; done"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            ...
        },
        "Image": "sha256:35a88802559dd2077e584394471ddaa1a2c5bfd16893b829ea57619301eb3908",
        "ResolvConfPath": "/var/lib/docker/containers/931b22bca56f04add7b383e12a862cd3cd9ef1c582cb8136e5b5afb0a8f4b935/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/931b22bca56f04add7b383e12a862cd3cd9ef1c582cb8136e5b5afb0a8f4b935/hostname",
        ...
        "Name": "/cont6",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        ...
            "NetworkMode": "bridge",
            "PortBindings": {},
           ...
        "Config": {
            "Hostname": "931b22bca56f",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": true,
            "AttachStderr": true,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": [
                "/bin/sh",
                "-c",
                "while true; do echo Olá mundo; date; sleep 10; done"
            ],
            "Image": "ubuntu",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {
                "org.opencontainers.image.ref.name": "ubuntu",
                "org.opencontainers.image.version": "24.04"
            }
        },
        "NetworkSettings": {
            "Bridge": "",
            ...
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.4",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:04",
            ...
            }
        }
    }
]
```

Como é possível ver na saída anterior, que inclusive teve partes
omitidas, o `inspect` traz muitas informações a respeito do container.
Neste exemplo, verificamos as informações do `cont6`, que foi criando na
seção anterior. Por exemplo, no final da saída, é possível ver muitas
configurações de rede do container, tais como: IP, *gateway* padrão,
endereço MAC, etc.

Todas as informações do `inspect` são apresentadas no formato JSON, o
que facilita a automação de extração dessas informações, inclusive
utilizando-se *scripts*. Na verdade o próprio Docker fornece meios para
filtrar as informações que podem ser obtidas do `inspect` (a quantidade
de informações pode atrapalhar a visão e análise em determinadas
tarefas). Por exemplo, para obter o endereço IP do container, é possível
executar o seguinte comando:

``` console
$ docker inspect --format '{{.NetworkSettings.IPAddress}}' cont6
172.17.0.4
```

Isso mostra que o `cont6` tem o IP 172.17.0.4. Com o comando anterior,
note que foi utilizado `docker inspect`, com a opção `--format`, seguido
da estrutura JSON que armazena a informação que estamos querendo, e no
final o nome ou ID do container. Para encontrar essa estrutura você deve
dar realizar o `inspect` e analisar a hierarquia do JSON, no exemplo
anterior o `IPAddress` está sob `NetworkSettings`, assim ficou
`.NetworkSettings.IPAddress`.

Vamos obter do container `cont6` qual é o comando que ele está
executando, tal informação está em `Path` (ver primeira saída que
geramos do `inspect`). Assim a busca por tal informação seria o seguinte
comando:

``` console
$ docker inspect --format '{{.Path}}' cont6
/bin/sh
```

Repare na saída do `inspect` apresentada no início da seção, que
basicamente a mesma informação a respeito do comando executado, também
está em `Cmd`, que está dentro de `Config`, ai a busca seria com o
seguinte comando:

``` console
$ docker inspect --format '{{.Config.Cmd}}' cont6
[/bin/sh -c while true; do echo Olá mundo; date; sleep 10; done]
```

Também é possível pedir para o `inspect` retornar mais de uma informação
na consulta, bem como fazer isso para mais de um container, tal como:

``` console
$ docker inspect --format '{{.Name}} {{.State.Status}} {{.Config.Image}}' cont1 cont4
/cont1 exited ubuntu
/cont4 exited ubuntu
```

Na saída anterior, o `inspect` foi instruído para buscar nos containers
`cont1` e `cont4`, as seguintes informações:

-   Nome do container (`{{.Name}}`);
-   Estado (`{{.State.Status}}`);
-   Imagem que está sendo utilizada (`{{.Config.Image}}`).

Novamente, este tipo de busca por informações específicas a respeito de
containers, pode ser extremamente útil no dia a dia do administrador de
sistemas, em processos como a criação de telas que mostram o status dos
sistemas para identificação de falhas, etc. Então, entender o `inspect`
e como utilizar seus filtros é muito importante, principalmente em
ambientes com diversos containers.

## Conclusão

Neste texto foram apresentados os comandos básicos para a criação e
gerenciamento de containers Docker. Então, este texto abordou como
realizar tarefas simples, como: criar containers, listar,
parar/executar, remover, inspecionar, etc. Lembrando que apesar dessas
tarefas serem rotineiras, conhecer bem como realizá-las é fundamental
para o bom funcionamento do sistema.

Todavia ainda não aprendemos como trabalhar com as imagens Dockers, que
são a base para a criação dos containers, isso será feito em no texto de [Imagens](docker-imagens).
