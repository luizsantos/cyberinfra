---
layout: page
---

# Tarefas comuns em imagens e containers Dockers

A seguir são apresentados alguns exemplos de imagens e criação de
containers. A ideia é apresentar mais em detalhes algumas opções
normalmente utilizadas do mundo Docker, bem como em que tipo de
situações elas podem serem aplicadas.

## Determinando o que será executado por padrão na imagem/container

No Docker, existem duas maneiras de definir o comando principal que será
executado na inicialização do container. Esse comando geralmente
representa a função central do container, ou seja, o propósito para o
qual ele foi criado. Caso esse comando seja interrompido, é provável que
o container também seja finalizado, já que sua função principal não
estará mais em execução.

Na criação de imagens Docker, há duas formas de se determinar qual e
como o comando principal será executado, sendo essas identificadas pelas
instruções: `CMD` e `ENTRYPOINT`. A seguir veremos a diferença entre
essas instruções.

### `CMD`

Utilizando o `CMD` no Dockerfile, é possível determinar o comando que
será executado quando o container for criado, com isso não é necessário
indicar o comando que deve ser executado pelo container quando se
executa o `docker run`. Tal prática facilita a vida de quem for executar
o container, pois a pessoal não precisa digitar tal comando na frente do
`docker run`, o que naturalmente também evita erros.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
    <div class="note">
    <p>Se forem passadas mais de uma linha <code>CMD</code> no Dockerfile,
será executada apenas a última linha.</p></div></div>

A seguir é apresentado um exemplo de um Dockerfile, que cria uma imagem
baseada no Fedora Linux, para executar um servidor Apache HTTP. Então a
principal função desse container é executar o servidor HTTP, desta forma
o comando `CMD`, do Dockerfile, é utilizado justamente para indicar que
deve-se iniciar o processo `/usr/sbin/httpd`, que é responsável pelo
servidor HTTP.

``` console
# Version 0.1
FROM fedora
MAINTAINER Luiz Arthur "luizsantos@utfpr.edu.br"
RUN dnf update -y
RUN dnf install httpd net-tools -y
RUN echo "Olá com <b> build" > /var/www/html/index.html''
CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
```

Após criar/editar o Dockerfile, é necessário gerar a imagem. Feito isso
é possível criar containers a partir dessa imagem, tal como:

1.  Gerar a imagem:

``` console
$ docker build -t="servidor/build_fedora_apache" .
```

2.  Criar container a partir da imagem gerada:

``` console
$ docker run --rm --name servidorFedApache3 -d servidor/build_fedora_apache
```

3.  Verificar se o container está em execução (opcional):

``` console
$ docker ps
CONTAINER ID   IMAGE                          COMMAND                  CREATED         STATUS         PORTS     NAMES
76b72b9eeb8f   servidor/build_fedora_apache   "/usr/sbin/httpd -DF…"   7 seconds ago   Up 7 seconds             servidorFedApache3
```

É importante saber que o comando a ser executado pela instrução `CMD`
pode ser sobreposto no momento da criação do container, ou seja via
linha de comando, por exemplo:

``` console
$ docker run -it --rm --name servidorFedApache3 -d servidor/build_fedora_apache /bin/bash
```

No comando anterior, o container gerado pela a imagem criada executa o
comando inicial `/bin/bash` (note que também foi incluído o `-it`, para
esse exemplo, só para poder acessar o terminal do container). Ou seja,
neste caso não será executado o `/usr/sbin/httpd`, mas sim o
`/bin/bash`, já que isso foi determinado via linha de comando.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    <p>Se você tentar acessar o servidor HTTP no container anterior, você
verá que esse não está em execução, já que foi executado o
<code>bash</code> ao invés do <code>httpd</code>.</p></div></div>

### `ENTRYPOINT`

O comportamento de mudar o comando principal na linha de execução do
Docker, tal como faz o `CMD`, pode ser desejado em alguns casos.
Todavia, quando isso não for desejável é possível utilizar o
`ENTRYPOINT`. Ou seja, o `ENTRYPOINT` não permite que o comando
principal seja alterado facilmente no `docker run`. Para isto basta
trocar o `CMD` por `ENTRYPOINT`, tal como:

``` console
# Version 0.1
FROM fedora
MAINTAINER Luiz Arthur "luizsantos@utfpr.edu.br"
RUN dnf update -y
RUN dnf install httpd net-tools -y
RUN echo "Olá com <b> build" > /var/www/html/index.html''
ENTRYPOINT ["/usr/sbin/httpd", "-DFOREGROUND"]
```

Agora vamos gerar a imagem:

``` console
$ docker build -t="servidor/build_fedora_apache" .
...
Step 6/6 : ENTRYPOINT ["/usr/sbin/httpd", "-DFOREGROUND"]
 ---> Using cache
 ---> 06181e2db3ad
...
```

Com a imagem pronta vamos tentar executar o container passando um
comando via `docker run`:

``` console
$ docker run -it --rm --name servidorFedApache3.1 -d servidor/httpd /bin/bash
7840c93ed7ec50a79764f7ecb0c8ccdf07cf638d340ac4ede1f8368b4382ffbc
```

Agora, com o `ENTRYPOINT`, ao tentar verificar os containers em
execução, não será possível encontrar o container
`servidorFedApache3.1`, pois a instrução `ENTRYPOINT`, não permitiu
executá-lo com o `bash`. Todavia se não for passada nenhum comando no
`docker run` ele será executado com o processo `httpd`.

### Juntando `ENTRYPOINT` e `CMD`

É possível utilizar em conjunto o `ENTRYPOINT` com o `CMD`, neste caso
primeiro deve ser determinado via `ENTRYPOINT` o comando que
obrigatoriamente deve ser utilizado ao se criar o container, e o que for
passado via `CMD`, serão as opções do comando no `ENTRYPOINT`. Desta
forma, se não for passada nenhum comando/opção no `docker run` será
executado o comando do `ENTRYPOINT` com as opções passadas do `CMD`.
Caso for passado algum comando via `CMD`, esse ou esses, serão na
verdade opções para o comando do \``ENTRYPOINT`. Ou seja, o comando não
pode ser alterado, mas as opções/parâmetros sim. Vamos ver o exemplo a
seguir:

``` console
# Version 0.1
FROM fedora
MAINTAINER Luiz Arthur "luizsantos@utfpr.edu.br"
RUN dnf update -y
RUN dnf install httpd net-tools -y
RUN echo "Olá com <b> build" > /var/www/html/index.html''
ENTRYPOINT ["/usr/sbin/httpd"]
CMD ["-DFOREGROUND"]
```

Exemplos de criação de containers utilizando essa imagem:

1.  Sem nenhum comando/parâmetros:

``` console
$ docker run --name servidorFedApache3.3 -d servidor/httpd
```

Vai executar `/usr/sbin/httpd -DFOREGROUND`.

2.  Passando parâmetros:

``` console
$ docker run --name servidorFedApache3.3 -d servidor/httpd -v
```

Vai executar Vai executar `/usr/sbin/httpd -v`. Neste exemplo o servidor
HTTP, vai mostrar a versão do servidor (não vai executar tal servidor),
isso poderá ser visto com o `log`, tal como:

``` console
$ docker logs  servidorFedApache3.3
Server version: Apache/2.4.62 (Fedora Linux)
Server built:   Aug  1 2024 00:00:00
```

3.  Tentando executar o comando `echo`:

``` console
$ docker run --name servidorFedApache3.3 -d servidor/httpd echo -v
```

Devido ao `ENTRYPOINT` não será executado o `echo`, mas sim o `echo`
será passado como um parâmetro para o `httpd`, como tal parâmetro não
existe no `httpd` será retornado um erro, que pode ser visto no `log`.

Por fim, é possível substituir o `ENTRYPOINT`, no `docker run`, mas para
isso é necessário utilizar a opção `--entrypoint`, ou seja, é necessário
explicitar a intenção de trocar o comando principal. Exemplo:

``` console
$ docker run --name servidorFedApache3.3 --entrypoint /bin/bash -d servidor/httpd
```

## Copiando arquivos do *host* para a a imagem 

Outra tarefa corriqueira no mundo dos containers é copiar arquivos para
dentro da imagem, isso permite personalizar as imagens e pode facilitar
a tarefa de configuração ou customização. No Docker há duas instruções
que permitem copiar arquivos para a imagem, sendo essas: `COPY` e `ADD`.

Assim, para entender melhor como funciona esse processo de cópia para a
imagem e o motivo de seu uso, vamos criar outro Dockerfile/imagem. Neste
Dockerfile, utilizaremos:

-   A imagem `servidor/build_fedora_apache` feita no exemplo anterior;
-   Em seguida será instalado os pacotes `php` e o `procps` (o `procps`
    não é necessário para o servidor, mas pode ser útil para testes,
    caso algo dê errado, pois esse fornece o comando `ps`);
-   Depois de instalar o PHP, vamos criar um *script* para iniciar o PHP
    e o Apache;
-   Por fim, vamos criar uma página PHP para testar o servidor.

Para efetivar na prática os passos citados anteriormente, da seguinte
forma:

1.  Iniciamos criando o arquivo Dockerfile e para esse exemplo **não
    vamos utilizar o nome padrão** (`Dockerfile`):

``` console
vi Dockerfile-php
```

2.  Editamos o conteúdo para atender o que foi determinado
    anteriormente:

``` console
FROM servidor/build_fedora_apache
MAINTAINER Luiz Arthur "luizsantos@utfpr.edu.br"
RUN dnf update -y
RUN dnf install -y php procps
RUN mkdir /run/php-fpm/
RUN mkdir -p /var/www/html/php
RUN echo -e "#!/bin/bash \n/sbin/php-fpm &\n/sbin/httpd -DFOREGROUND \n/bin/read"  > /sbin/startServer.sh
RUN chmod a+x /sbin/startServer.sh
RUN echo "<?php phpinfo(); ?>" > /var/www/html/php/teste.php
CMD ["/sbin/startServer.sh"]
```

Neste caso, tal arquivo tem basicamente seguintes instruções
(resumidas):

-   `FROM ...`: para indicar que vamos utilizar a imagem com o servidor
    HTTP criando anteriormente;
-   `RUN dnf ...`: para realizar uma atualização do sistema e então
    atualizar e instalar os pacotes necessários (PHP e procps);
-   `RUN mkdir ...`: cria diretórios necessários para o PHP;
-   `RUN echo ... startServer.sh`: que está criando um *script* para
    iniciar o PHP e depois o Apache;
-   `RUN chmod ...`: dá permissão de execução ao *script*;
-   `RUN echo ... teste.php`: cria um arquivo com uma página PHP básica,
    só para testar se o PHP está funcionando;
-   `CMD ...`: comando que vai ser executado quando o container for
    criado.

3.  Criamos a imagem, apontando para o arquivo Dockerfile:

``` console
$ docker build -f Dockerfile-php -t="servidor/build_fedora_apache_php" .
```

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
    <div class="note">
    <p>Tem que utilizar o <code>-f</code>, já que não foi utilizado o nome
padrão de arquivo Dockerfile.</p></div></div>

4.  Agora é possível criar um container utilizando a imagem nova:

``` console
$ docker run --rm --name servidorFedApache_PHP -d servidor/build_fedora_apache_php
```

5.  Depois desses passos, o container criado deve aparecer na listagem
    do comando `docker ps`. Bem como, será possível acessar a página PHP
    no servidor sendo executado no container, tal como mostra a
    Figura 9.

![Figura 9: Navegador acessando PHP do container criado a partir do
Dockerfile-php](imagens/navegador3.png)

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    <p>Para acessar a página PHP, você deve descobrir o IP do container (tal
como fizemos anteriormente) e acessar o
<code>http://ip_container/php/teste.php</code> - que é o caminho que
configuramos, onde está a página PHP.</p></div></div>

Uma **importante observação** deve ser feita aqui: Para a criação desta
imagem, **utilizamos o `RUN` para criar o *script***, isso foi feito com
a seguinte instrução:

``` console
RUN echo -e "#!/bin/bash \n/sbin/php-fpm &\n/sbin/httpd -DFOREGROUND \n/bin/read"  > /sbin/startServer.sh
```

Então é possível utilizar o `RUN` para criar o *script*, mas **isso pode
deixar o entendimento confuso** (muita coisa em uma linha só), então há
grandes chances de erro. Outra questão ainda relacionada à isso é: "e se
o administrador precisar criar um *script* ainda maior e mais
complexo?". Bem uma possível solução é apresentada a seguir com o `COPY`
e o `ADD`.

### Copiando arquivos para imagem com o `COPY`

Desta forma, para melhorar o Dockerfile anterior, é possível utilizar a
instrução `COPY`, para copiar um *script* do *host* para a imagem que
está sendo criada. Assim, é possível utilizar um editor de textos para
criar mais facilmente o *script* e depois o `COPY` vai copiá-lo para a
imagem.

Então vamos alterar o Dockerfile anterior, para que este utilize o
`COPY`, tal como:

1.  Editamos o arquivo Dockerfile e adicionamos a instrução `COPY`, tal
    como a seguir:

``` console
$ vi Dockerfile-php

FROM servidor/build_fedora_apache
MAINTAINER Luiz Arthur "luizsantos@utfpr.edu.br"
RUN dnf update -y
RUN dnf install -y php procps
RUN mkdir /run/php-fpm/
RUN mkdir -p /var/www/html/php
COPY startServer.sh /sbin/startServer.sh
RUN chmod a+x /sbin/startServer.sh
RUN echo "<?php phpinfo(); ?>" > /var/www/html/php/teste.php
CMD ["/sbin/startServer.sh"]
```

2.  Após isso, criamos o arquivo `startServer.sh` no *host* hospedeiro,
    tal arquivo será copiado para a imagem:

``` console
$ vi startServer.sh

#!/bin/bash
/sbin/php-fpm &
/sbin/httpd -DFOREGROUND
/bin/read
sleep infinity
```

Alguns pontos importantes devem ser destacados aqui:

-   No arquivo Dockerfile foi utilizado o **caminho relativo** do
    arquivo `startServer.sh`. Desta forma, esperá-se que tal arquivo
    esteja no mesmo diretório do arquivo Dockerfile. Todavia, pode ser
    recomendável utilizar o caminho absoluto, principalmente se o
    arquivo não estiver no mesmo local que o Dockerfile.

-   É muito importante que no inicio do Bash *script* tenha o
    ***shebang*** (`#!/bin/bash`), para informar quem vai executar os
    comandos, caso contrário o *script* não será executado no inicio do
    container e tudo vai falhar;

-   No final do *script* criado aqui, foram inseridas duas formas de
    **impedir que o *script* execute e depois termine**, sendo essas
    formas: `/bin/read` e o `sleep infinity`. Contudo isso seria
    desnecessário, já que teoricamente o comando
    `/sbin/httpd -DFOREGROUND`, fica executando indefinidamente.
    Entretanto é preciso ter em mente que é necessário que o *script*
    deve ficar em execução, pois caso contrário o container vai parar -
    dependendo o caso dá a impressão que ele nem foi executado.

-   Em caso de problemas na hora de executar o container lembre-se de
    utilizar o **`log`** ou entrar no container utilizando o `bash`,
    para verificar o que está causando o problema (qual o motivo do
    container não ficar em execução?);

3.  Geramos a imagem:

``` console
$ docker build -f Dockerfile-php -t="servidor/build_fedora_apache_php" .
```

4.  Criamos um container baseada nessa imagem:

``` console
$ docker run --rm --name servidorFedApache_PHP2 -d servidor/build_fedora_apache_php
```

5.  Agora é só verificar se está tudo correto, tal como:

``` console
$ docker ps
CONTAINER ID   IMAGE                              COMMAND                  CREATED          STATUS          PORTS     NAMES
9fde9bf8d3dd   servidor/build_fedora_apache_php   "/sbin/startServer.sh"   10 minutes ago   Up 10 minutes             servidorFedApache_PHP2
aff8a1b1d139   05fe3484d188                       "/sbin/startServer.sh"   44 minutes ago   Up 44 minutes             servidorFedApache_PHP
```

Assim, utilizamos o `COPY` para facilitar o processo de criação de
arquivos dentro da imagem Docker. A seguir é apresentado como fazer o
mesmo, mas utilizando o `ADD` em contextos um pouco diferentes.

### Utilizando o ADD

O ADD é similar ao `COPY`, todavia ele permite copiar arquivos de URL
(ex. Internet) e descompactar arquivos que estão no *host* hospedeiro
para a imagem.

Para ver a diferença, vamos pegar o exemplo anterior e substituir o
`COPY` por `ADD`, tal como:

``` console
$ vi Dockerfile-php

FROM servidor/build_fedora_apache
MAINTAINER Luiz Arthur "luizsantos@utfpr.edu.br"
RUN dnf update -y
RUN dnf install -y php procps
RUN mkdir /run/php-fpm/
RUN mkdir -p /var/www/html/php
ADD https://raw.githubusercontent.com/luizsantos/aulasDocker/main/startServer.sh /sbin/startServer.sh
RUN chmod a+x /sbin/startServer.sh
ADD php.tar.gz /var/www/html/php/
CMD ["/sbin/startServer.sh"]
```

Neste novo Dockerfile, note que agora temos duas instruções `ADD`, sendo
a função dessas em ordem:

-   Copiar o *script* `startServer.sh` do GitHub, pela URL:
    <https://raw.githubusercontent.com/luizsantos/aulasDocker/main/startServer.sh>
    para o `/sbin/startServer.sh` da imagem;
-   Extrair o [arquivo
    `php.tar.gz`](https://github.com/luizsantos/aulasDocker/raw/main/testePHP.tar.gz)
    do *host* hospedeiro para o diretório `/var/www/html/php/` do
    container.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
    <div class="note">
    <p>Não serão apresentados os procedimentos para gerar a imagem e
container utilizando o <code>ADD</code>, mas basicamente é só repetir o
que foi feito anteriormente.</p></div></div>

Bem, o funcionamento é similar ao `COPY`, mas o `ADD` dá mais
possibilidades, já que permite copiar de *links* e extrair arquivos.
Todavia, a literatura em geral, não recomenda utilizar o `ADD` como se
fosse o `COPY`, ou seja, **só utilize o `ADD` se você estiver copiando
de URL ou extraindo arquivos, caso contrário recomenda-se utilizar o
`COPY`**.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    <p>Durante os testes para a confecção deste material, observou-se que o
<code>ADD</code> não descompacta arquivos provindos de URLs, ou seja,
para utilizar sua função de descompactar arquivos, tal arquivo deve
estar localmente no <em>host</em> hospedeiro. Também, alguns sítios Web
e Fóruns relatam problemas em descompactar arquivos <code>.zip</code>,
neste caso sugere-se baixar o arquivo na imagem e depois descompactar
utilizando algum programa a ser executado com o <code>RUN</code>.</p></div></div>

## Compartilhando dados entre *host*/containers

O compartilhamento de arquivos é uma tarefa geralmente necessária entre
computadores e o mesmo ocorre com os containers. Assim, o Docker fornece
formas de se compartilhar dados entre:

-   *Host* hospedeiro e containers;
-   Entre os containers.

Veremos tais técnicas a seguir.

### Opção VOLUME do Dockerfile

A opção `VOLUME` permite criar um ponto de montagem compartilhado entre
o container e o `host`. Isso facilita o compartilhamento de informações
entre ambos, bem como permite que os dados do container sejam
**persistidos** (ou seja, não se apaguem quando o container for
removido).

Então, continuando o exemplo do servidor PHP anterior, vamos deixar o
conteúdo PHP compartilhado entre container e *host*. Assim por exemplo,
seria mais fácil criar/alterar o conteúdo dos sítios PHP mantidos nos
containers. Então vamos alterar o arquivo Dockerbuild em questão, tal
como:

``` console
# Version 0.1
FROM servidor/build_fedora_apache
MAINTAINER Luiz Arthur "luizsantos@utfpr.edu.br"
RUN dnf update -y
RUN dnf install -y php procps
RUN mkdir /run/php-fpm/
RUN mkdir -p /var/www/html/php
COPY startServer.sh /sbin/startServer.sh
RUN chmod a+x /sbin/startServer.sh
VOLUME /var/www/html/php/
CMD ["/sbin/startServer.sh"]
```

No exemplo anterior, estamos informando através da instrução `VOLUME`,
que iremos criar dentro do container um ponto de montagem no diretório
`/var/www/html/php/`, que poderá ser acessado a partir do `host`
hospedeiro do container.

Feito isso vamos criar um container a partir dessa imagem:

``` console
$ docker run --rm --name servidorFedApache_PHP2 -d servidor/build_fedora_apache_php
24961fed96566b522ae6a3a9f91c5a4b99768b7eea7d246365dbafbf33b4003a
```

Agora, para acessar o compartilhamento no container Docker, basta
acessar o diretório `/var/www/html/php/`. Já para acessar tal
compartilhamento no `host`, é necessário descobrir em qual diretório o
Docker relacionou esse compartilhamento no `host`, para isso podemos,
por exemplo, utilizar a opção `inspect` e procurar por `Mounts`, tal
como:

``` console
$ docker inspect servidorFedApache_PHP2
...
        "Mounts": [
            {
                "Type": "volume",
                "Name": "51f493146da5b7db6d6f766e476bc1ecd2e6912e29 f51fd3c3534f433318aaf2",
                "Source": "/var/lib/docker/volumes/51f493146da5b7db 6d6f766e476bc1ecd2e6912e29f51fd3c3534f433318aaf2/_data",
                "Destination": "/var/www/html/php",
                "Driver": "local",
                "Mode": "",
                "RW": true,
                "Propagation": ""
            }
        ],
...
```

Dada a saída anterior, é possível verificar que o compartilhamento do
`servidorFedApache_PHP2` pode ser acessado no *host* hospedeiro no
diretório
`/var/lib/docker/volumes/51f493146da5b7db6d6f766e476bc1ecd2e6912e29f51fd3c3534f433318aaf2/_data`.
Ou seja, é o `Source` que determina o ponto de montagem/compartilhamento
no *host*.

Sabendo o diretório compartilhando entre container e *host*, podemos
criar/alterar o seu conteúdo e isso será refletido imediatamente no
container e vice-versa. Por exemplo vamos criar uma página PHP no
diretório
`/var/lib/docker/volumes/51f493146da5b7db6d6f766e476bc1ec d2e6912e29f51fd3c3534f433318aaf2/_data`
do *host* e ver o resultado desta no container `servidorFedApache_PHP2`.
Tal como:

``` console
$ sudo -i
# vi /var/lib/docker/volumes/51f493146da5b7db6d6f766e476bc1ecd2e6912e29f51fd3c3534f433318aaf2/_data/index.php

<!DOCTYPE html>
<html>
    <head>
        <title>Teste PHP</title>
    </head>
    <body>
        <?php echo '<p>Olá PHP no container!</p>'; ?>
    </body>
</html>
```

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    <p>Observe que utilizamos o <code>sudo</code>, pois os usuários comuns
não têm acesso aos compartilhamentos no <code>host</code>. Então criando
compartilhamentos/volumes desta forma, pode ser necessário configurar
permissões no <em>host</em> ou no container para que determinados
usuários consigam manipular e criar arquivos e diretórios desses
compartilhamentos.</p></div></div>

Agora podemos acessar a nova página PHP no container, tal como apresenta
a Figura 10.

![Figura 10: Navegador acessando PHP utilizando
VOLUME](imagens/navegador4.png)

### Opção `-v` do `run`.

Desta forma, tudo que for feito no diretório do *host* aparecerá no
diretório do container, o que pode facilitar muito a vida do
administrador. Entretanto há outra maneira de trabalhar com volumes, que
não utilizando o Dockerfile. É possível compartilhar volumes via linha
de comando, na hora de criar o container, e na verdade faz mais sentido
criar os volumes desta forma, já que assim é possível informar qual é o
diretório específico que vai aparecer o conteúdo do container dentro do
*host*, com isso, por exemplo podemos utilizar um diretório no *host*
que permita a gravação de um dado usuário e evitamos utilizar, por
exemplo o comando `sudo`, tal como foi feito anteriormente.

Dito isso vamos ver um exemplo de como criar volumes via linha de
comando, para isso vamos:

1.  Criar o diretório que será compartilhado do *host* hospedeiro com o
    container:

``` console
$ mkdir /tmp/site
echo "<?php phpinfo(); ?>" > /tmp/site/teste.php
```

Junto com a criação do diretório também foi criado um conteúdo PHP, no
caso o arquivo `/tmp/site/teste.php`.

2.  Agora vamos criar o container, com a opção `-v`:

``` console
$ docker run --rm --name servidorFedApache_PHP3 -v /tmp/site:/var/www/html/php -d servidor/build_fedora_apache_php
7a7578cda0fb18d2d4addd30362296fea04898689dbebb954e063cf125f729c1
```

No exemplo anterior, estamos criando o container
`servidorFedApache_PHP3`, que compartilha o diretório `/tmp/site` no
*host*, com o diretório `/var/www/html/php` do container. Assim, fica
bem claro quais são os diretórios compartilhados entre ambas máquinas, o
que não acontecia utilizando-se apenas a opção `VOLUME` do Dockerfile.

Outra forma de ver tal compartilhamento seria:

``` console
$ docker inspect -f {{.Mounts}} servidorFedApache_PHP3
[{bind  /tmp/site /var/www/html/php   true rprivate}]
```

O comando anterior mostra primeiro o compartilhamento no *host*
(`/tmp/site`) e do container (`/var/www/html/php`).

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    <p>Na verdade faz mais sentido criar o volume compartilhado via linha de
comando e não via Dockerfile.</p></div></div>

### Compartilhando dados entre containers

Também é possível utilizar os volumes para compartilhar dados entre os
container, bem como o *host*. O compartilhamento de volume entre os
containers é feita através da opção `--volumes-from`.

Para uma melhor explicação vamos criar um compartilhamento entre o
*host* hospedeiro e um container, depois vamos compartilhar esse mesmo
volume do container com outro container, tal como:

1.  No *host*, primeiro criamos um diretório, que será compartilhado com
    um container:

``` console
$ mkdir /tmp/share
```

2.  Ainda no *host* criamos um Dockerfile (vamos usar uma mais simples):

``` console
$ vi Dockerfile

# Version 0.1
FROM fedora
MAINTAINER Luiz Arthur "luizsantos@utfpr.edu.br"
RUN dnf update -y
CMD /bin/bash
```

3.  Geramos a imagem nova:

``` console
$ docker build -t="fedora/data"
```

4.  Agora vamos criar um container e relacioná-lo com o diretório
    `/tmp/share` do *host*:

``` console
$ docker run -ti --name container1 -v /tmp/share:/comp -d fedora/data
```

5.  Com o primeiro container criado, vamos criar outro container, que
    será relacionado com o compartilhamento do primeiro container, tal
    como:

``` console
$ docker run -ti --name container2 --volumes-from container1 -d fedora/data
```

Feito isso temos um diretório compartilhado entre o *host*, `container1`
e `container2`, desta forma tudo que for feito no diretório `/comp` dos
containers será refletido para os outros containers e para o diretório
`/tmp/share` do *host*, veja só:

-   Agora podemos conectar ao `container2`, criar um arquivo, tal como
    `echo "ola do container2" > /comp/container2.txt`, tal como:

``` console
$ docker attach container2
[root@648f9a9d64e0 /]# echo "ola do container2" > /comp/container2.txt
```

-   Vamos agora verificar se tal arquivo está no `container1` e também
    vamos criar um arquivo lá:

``` console
$ docker attach container1
[root@22d1729f5c88 /]# cat /comp/container2.txt
ola do container2
[root@22d1729f5c88 /]# vi /comp/teste.txt
[root@22d1729f5c88 /]# cat /etc/hostname > /comp/container1.txt
```

-   Por fim, vamos acessar tais arquivos a partir do *host* hospedeiro:

``` console
$ cat /tmp/share/container1.txt
22d1729f5c88
$ cat /tmp/share/container2.txt
ola do container2
```

É possível verificar os volumes sendo compartilhados com o comando
`docker volume ls`, bem como verificar os detalhes de um volume com o
comando `docker volume inspect` seguido da identificação do volumes
(descoberta com o comando anterior). Há outras opções, que podem ser
vistas na documentação do Docker.

Então, o Docker através do `VOLUME`, `-v` e `--volumes-from`, cria uma
forma bem fácil de compartilhar diretórios entre containers e *host*.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    <p>Outra forma de compartilhar dados entre containers e <em>host</em>
seria via rede, mas isso normalmente é bem mais trabalhoso do que
utilizar essa técnica de VOLUME utilizada pelo Docker.</p></div></div>

## Relacionando portas de container com o *host* hospedeiro 

Normalmente ao criar-se um container, esse é ligado à uma rede privada
relacionada ao Docker. Tal rede normalmente fica trás de um NAT (Network
Address Translation), significando que os serviços de rede executados
pelo container não podem ser acessados por outros computadores externos
à rede Docker.

Por exemplo, na Figura 11, a rede 172.17.0.0/24 é uma rede privada que
somente o *host* hospedeiro e os containers deste *host* podem acessar.
Assim, outros *hosts* tal como o Host A, não conseguem acessar por
padrão tal rede dos containers.

![Figura 11: Rede Docker -
172.17.0.0/24](imagens/redeDocker1.svg)

Todavia, existem casos em que é necessário expor para fora da rede
Docker, os serviços de rede de alguns containers Docker. Sendo assim, há
algumas formas de fazer isso, mas talvez a forma mais prática e fácil, é
a fornecida pelo próprio Docker, que permite relacionar a porta do
container com alguma porta do *host* hospedeiro. Desta forma, ao se
tentar acessar tal porta relacionada do hospedeiro, será na verdade
acessado o container.

No Docker, essa tarefa de acessar o container através do IP do *host*
hospedeiro é chamada de "expor" (***expose***) ou publicar
(***publish***) a porta do container. Assim, para expor/publicar a porta
de um container, ou melhor para relacionar a porta do container com
alguma porta do *host* hospedeiro, é possível utilizar no `docker run`,
uma das seguintes opções:

-   **`-P`** ou **`--publish-all`**: expõem todas as portas declaradas
    no Dockerfile pela instrução **`EXPOSE`**;
-   **`-p`** ou **`--publish`**: expõem apenas uma porta de um dado
    protocolo do container.

Então, ao se utilizar o `-P` (menos "P" maiúsculo), é necessário dizer
de forma explicita via Dockerfile, quais serviços de rede estão
disponíveis do container e a relação porta do hospedeiro, com a porta do
container, será feita de forma automática. Já com a opção `-p` (menos
"p" minúsculo), é necessário indicar qual porta do container será
exposta, todavia neste caso, não é necessário que esta esteja declarada
no Dockerfile via `EXPOSE`.

A seguir são apresentadas alguns exemplos de uso dessas opções, bem como
do uso prático da técnica de *expose*/*publish* do Docker.

### Expondo as portas do container via `-P` e `EXPOSE`

Para entender como funciona o `-P`, vamos criar uma imagem via
Dockerfile, sendo que essa imagem terá os servidores HTTP e SSH. Assim,
será possível acessar tal container via HTTP e gerenciá-lo via SSH. Tal
arquivo Dockerfile fica da seguintes forma:

``` console
$ vi Dockerfile

FROM servidor/build_fedora_apache
MAINTAINER Luiz Arthur "luizsantos@utfpr.edu.br"
RUN dnf update -y
RUN dnf install -y openssh-server
RUN mkdir /run/php-fpm/
RUN mkdir -p /var/www/html/php
RUN echo -e "#!/bin/bash \n/sbin/sshd & \n/sbin/httpd -DFOREGROUND \n/bin/read"  > /sbin/startServer.sh
RUN chmod a+x /sbin/startServer.sh
RUN ssh-keygen -A
RUN adduser -ms /bin/bash admin
RUN echo "admin:123mudar" | chpasswd
EXPOSE 22 80
CMD ["/sbin/startServer.sh"]
```

O arquivo Dockerfile anterior, é bem similar ao servidor HTTP que já
havíamos criado anteriormente (utiliza a imagem base
`servidor/build_fedora_apache`), mas neste agora foi:

-   Instalado o SSH (`RUN dnf install -y openssh-server`);
-   O *script* foi alterado para iniciar o servidor SSH
    (`.../sbin/sshd...`);
-   Gerada a chave criptográfica utilizada pelo SSH
    (`RUN ssh-keygen -A`);
-   Criado um usuário chamado `admin` (`adduser -ms /bin/bash admin`);
-   Foi definida a senha do `admin`, como sendo `123mudar`
    (`echo "admin:123mudar" | chpasswd`);
-   Por fim, foi informado ao Docker para expor as portas do SSH
    (TCP/22) e HTTP (TCP/80).

Com o Dockerfile anterior, geramos a imagem do servidor em questão:

``` console
$ docker build -t="servidor/http" .
```

Criamos um container a partir da imagem gerada:

``` console
$ docker run --rm --name container1 -P -d servidor/http
```

Note que no comando anterior, foi utilizada a opção `-P`, que cria uma
relação com as portas do `EXPOSE` do container, com portas do *host*
hospedeiro. Tal relação pode ser vista com o comando `docker ps` (ver a
seguir) ou via comando `iptables`:

``` console
$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED         STATUS         PORTS                                                                              NAMES
fb0673258719   servidor/http   "/sbin/startServer.sh"   7 seconds ago   Up 6 seconds   0.0.0.0:32770->22/tcp, :::32770->22/tcp, 0.0.0.0:32771->80/tcp, :::32771->80/tcp   container1
```

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
    <div class="note">
    <p>As portas relacionadas com o <code>-P</code> no <em>host</em>
hospedeiros são normalmente altas e aleatórias, tal como a 32770 do
exemplo anterior. Também aparecem na listagem IPv4 e IPv6.</p></div></div>

Assim, feita a relação entre portas do container chamado `container1` e
o *host*, podemos agora acessar, por exemplo o servidor SSH do
container, através do IP de *localhost* do próprio *host* hospedeiro,
tal como:

``` console
[luiz@fielDell expose]$ ssh admin@127.0.0.1 -p 32770
...
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[127.0.0.1]:32770' (ED25519) to the list of known hosts.
admin@127.0.0.1's password:
[admin@fb0673258719 ~]$ cat /etc/hosts
127.0.0.1   localhost
...
172.17.0.2  fb0673258719
```

O teste anterior foi feito a partir do próprio *host* hospedeiro, mas já
seria possível acessar o container a partir do *host* hospedeiro
utilizando o IP da rede Docker (sem usar a técnica de expor portas, ou
seja acessando por exemplo o IP 172.17.0.2 do container). Todavia o
leitor tem que ter em mente que isso não seria possível de *hosts*
externos, mas agora utilizando a prática de expor portas do Docker, é
possível acessar o container através do IP do *host* hospedeiro.

Por exemplo, imagine que o *host* hospedeiro tem o IP 200.0.0.1
(disponível na Internet). Qualquer *host* da Internet que executar o
comando `ssh admin@200.0.0.1 -p 32770`, estará na verdade acessando o
container `container1` e não o *host* hospedeiro, tal como é ilustrado
na Figura 11.

### Expondo as portas do container via `-p`

Como visto anteriormente, a opção `-P` precisa da instrução `EXPOSE` da
imagem Docker, mas é possível expor uma porta do container, sem utilizar
o `EXPOSE` da imagem. Isso é feito com a opção `-p`, assim basta criar
um container com `docker run` passando como parâmetro o `-p`, seguido da
porta que será exposta (é claro que o container tem que fornecer algum
serviço de rede na porta em questão). Tal como:

``` console
[luiz@fielDell expose]$ docker run --rm --name container2 -p 80 -d servidor/http
d37c43975129a683e32430910140bf8e07b3f30b8864d9988246c2b05d10ca29
```

O comando anterior cria um container chamado `container2`, e expõem a
porta 80/TCP, tal como pode ser visto da saída a seguir:

``` console
[luiz@fielDell expose]$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED          STATUS          PORTS                                                                              NAMES
d37c43975129   servidor/http   "/sbin/startServer.sh"   41 seconds ago   Up 40 seconds   22/tcp, 0.0.0.0:32775->80/tcp, :::32775->80/tcp                                    container2
013b8cb020ca   servidor/http   "/sbin/startServer.sh"   46 seconds ago   Up 45 seconds   0.0.0.0:32773->22/tcp, :::32773->22/tcp, 0.0.0.0:32774->80/tcp, :::32774->80/tcp   container1
```

Conforme a saída anterior, a porta 80/TCP do `container2`, ficou
disponível na porta 32775 do *host* hospedeiro. É importante notar que
devido ao `EXPOSE` do Dockerfile dessa imagem, a porta 22/TCP também
aparece na listagem, mas ela não está acessível via *host* hospedeiro.

Como visto no exemplo anterior com o `-P` e aqui com o `-p`, a porta
relacionada com o *host* hospedeiro é alta e aleatória, todavia com o
`-p` é possível determinar qual é a porta que será utilizada no *host*
hospedeiro, tal como:

``` console
[luiz@fielDell expose]$ docker run --rm --name container3 -p 80:80 -d servidor/http
487bafe91e7567e91c79bf6c69039d468486ed0695e6c3169f559fac85d291ef
```

O comando anterior informa na opção `-p` a
`<porta do host>:<porta do container>`, isso pode ser visto com o
`docker ps`, tal como:

``` console
[luiz@fielDell expose]$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED         STATUS         PORTS                                                                              NAMES
487bafe91e75   servidor/http   "/sbin/startServer.sh"   5 seconds ago   Up 5 seconds   22/tcp, 0.0.0.0:80->80/tcp, :::80->80/tcp                                          container3
d37c43975129   servidor/http   "/sbin/startServer.sh"   7 minutes ago   Up 7 minutes   22/tcp, 0.0.0.0:32775->80/tcp, :::32775->80/tcp                                    container2
```

Desta forma, agora quem tentar acessar a porta 80/TCP do *host*
hospedeiro, na verdade vai acessar o HTTP do `container3`.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
    <div class="note">
    <p>Poder relacionar a porta do container com uma porta específica do
<em>host</em> hospedeiro é muito importante na prática, pois é possível
deixar um serviço em execução em um Docker responder como se fosse o
<em>host</em> hospedeiro, sem muitas complicações.</p></div></div>

Ainda é possível fazer outras combinações de parâmetros para expor
portas no Docker, tais como:

-   `docker run -p 53/udp <imagem>`: expõem a porta 53/UDP - ou seja, é
    possível expor portas TCP (que são o padrão caso não se especifique
    o protocolo UDP, sendo que essas devem ser declaradas explicitamente
    com o `<porta>/udp`;
-   `docker run -p 22/tcp -p 53/udp <imagem>`: É possível passar mais de
    uma porta para ser exposta via `-p`;
-   `docker run -p 192.168.0.1:722:22/tcp <imagem>`: Caso o *host* tenha
    vários IPs, é possível informar qual desses IPs vai servir a porta
    exposta do container. Note que caso não seja passado o IP, o Docker
    vai assumir que o serviço responde por qualquer IP do *host*
    hospedeiro (0.0.0.0 - IP *this host*). Determinar o IP pode ser útil
    para garantir a segurança de alguns serviços, por exemplo, o SSH
    pode ser acessível por um IP local, mas não para IPs da Internet;
-   `EXPOSE 53/UDP`: Também é possível expor uma porta UDP via
    Dockerfile, e depois publicá-la via `-P`.

## Utilizando variáveis para fazer configurações mais dinâmicas

O Dockerfile permite inserir variáveis dentro da imagem e container
sendo criados, isso é feito com a instrução `ENV`. Desta forma, é
possível criar imagens com configurações mais dinâmicas.

Por exemplo, vamos incrementar o Dockerfile da seção anterior, para que
esse permita alterar a porta do servidor Apache HTTP, isso pode ser
feito da seguinte forma:

``` console
$ vi Dockerfile

FROM servidor/build_fedora_apache
MAINTAINER Luiz Arthur "luizsantos@utfpr.edu.br"
RUN dnf update -y
RUN dnf install -y openssh-server
RUN mkdir -p /var/www/html/php
RUN echo -e "#!/bin/bash \n/sbin/sshd &\n/sbin/httpd -DFOREGROUND \n/bin/read"  > /sbin/startServer.sh
ENV HTTP_PORT 81
COPY httpd.conf /etc/httpd/conf/httpd.conf
RUN chmod a+x /sbin/startServer.sh
RUN ssh-keygen -A
RUN adduser -ms /bin/bash admin
RUN echo "admin:123mudar" | chpasswd
CMD ["/sbin/startServer.sh"]
```

Neste novo Dockerfile foram incluídas as seguintes instruções/linhas:

-   `ENV HTTP_PORT 81`, que será uma variável utilizada para determinar
    a porta do servidor HTTP;
-   `COPY httpd.conf /etc/httpd/conf/httpd.conf`, está copiando o
    arquivo de configuração do servidor HTTP alterado. A alteração
    consistem apenas em trocar `Listen 80` por `Listen ${HTTP_PORT}`,
    sendo que`${HTTP_PORT}` será substituído pelo conteúdo da variável
    `HTTP_PORT` determinado pela instrução `ENV` anterior (para obter o
    arquivo `httpd.conf` foi feito um `scp` para um container desta
    imagem).

Agora ao se criar um container a partir dessa imagem, o servidor HTTP
estará por padrão na porta 81, tal como:

``` console
$ docker run --name server1 -p 81:81 -d servidor/http
eeec6fb36a47ecb80f52d601e82fa3c34837a657f5951276bab4b8a1460b0c5b

$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED         STATUS         PORTS                               NAMES
eeec6fb36a47   servidor/http   "/sbin/startServer.sh"   7 seconds ago   Up 6 seconds   0.0.0.0:81->81/tcp, :::81->81/tcp   server1
```

Também é possível alterar essas variáveis na execução do `docker run`,
com a opção `-e` ou `--env`, veja o exemplo a seguir:

``` console
$ docker run --rm --name server2 -e HTTP_PORT=8080 -p 82:8080 -d servidor/http
bd9e590d78834d35ad85f5eb68dc5c803fa402d527ccc26adaf56c2e1507d861

$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED          STATUS          PORTS                                   NAMES
bd9e590d7883   servidor/http   "/sbin/startServer.sh"   6 seconds ago    Up 5 seconds    0.0.0.0:82->8080/tcp, :::82->8080/tcp   server2
eeec6fb36a47   servidor/http   "/sbin/startServer.sh"   48 seconds ago   Up 47 seconds   0.0.0.0:81->81/tcp, :::81->81/tcp       server1
```

No exemplo anterior o container foi criando com o servidor HTTP sendo
executado na porta 8080 (`-e HTTP_PORT=8080`) e foi exposta no *host*
hospedeiro na porta 82 (`-p 82:8080`).

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
    <div class="note">
    <p>É possível alterar variáveis com o <code>-e</code>, sem que a
variável exista no Dockerfile pela instrução <code>ENV</code>.</p></div></div>

Ainda quanto as variáveis, é possível passar as variáveis através de um
arquivo chamado `.env` utilizando a opção `--env-file`. Também é
possível passar mais de uma variável no `docker run` para isso basta
utilizar mais de uma vez o `-e`.

### Verificando as variáveis do container

Para verificar quais variáveis temos em um container, é possível
executar os seguintes comandos:

-   Inspecionando os eventos de um container em execução:

``` console
$ docker inspect server1 --format='{{json .Config.Env}}'
["HTTP_PORT=8080","PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","DISTTAG=f40container","FGC=f40","FBR=f40"]
```

-   Executando o comando `printenv` em um container em execução:

``` console
$ docker exec server1 printenv
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=dd0de51f4289
HTTP_PORT=8080
DISTTAG=f40container
FGC=f40
FBR=f40
HOME=/root
```

-   Criando um container para executar o `printenv` e deletando ele na
    sequência, lembrando que aqui ele provavelmente só vai executar o
    `printenv`, vai parar e por consequência será deletado pela opção
    `--rm`:

``` console
$ docker run --rm servidor/http printenv
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=08929852c21d
DISTTAG=f40container
FGC=f40
FBR=f40
HTTP_PORT=81
HOME=/root
```

As variáveis podem ser muito úteis para criar configurações mais
dinâmicas e personalizadas.

## Utilizando o `supervisor`

Como observado anteriormente, pode ser uma tarefa relativamente complexa
executar vários serviços simultaneamente em um único container. Assim,
uma forma de facilitar tal tarefa é utilizando o
[`supervisor`](https://supervisord.org/).

```{=html}
<!--
O ``supervisor``, na verdade pode orquestrar e gerenciar múltiplos containers utilizando um arquivo de configuração (``docker-compose.yml``), no qual são definidos serviços e outras configurações de containers. Todavia, mesmo que não seja muito recomendável, 
-->
```
O `supervisord` tem como objetivo controlar múltiplos processos em
sistemas UNIX-like, então ele pode ser utilizado para iniciar e
monitorar processos dentro de containers Docker.

Desta forma, neste exemplo vamos ver o uso do `supervisor` para
controlar serviços. Para isso vamos utilizar como base os exemplos
apresentados no livro [Docker
Cookbook](https://www.amazon.com.br/Docker-Cookbook-S-Goasguen/dp/149191971X).
Então, para este exemplo serão colocados em um único container os
seguintes serviços: HTTP, PHP e MYSQL, tudo isso para disponibilizar o
[WordPress](https://wordpress.org/), que é um sistema Open Source de
gerenciamento de conteúdo no estilo *blog*.

Desta forma, iniciamos o exemplo criando o arquivo Dockerfile:

``` console
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install \
    apache2 \
    php \
    php-mysql \
    supervisor \
    wget

RUN echo 'mysql-server mysql-server/root_password password root' | \
    debconf-set-selections && \
    echo 'mysql-server mysql-server/root_password_again password root' | \
    debconf-set-selections

RUN apt-get install -qqy mysql-server

RUN wget https://wordpress.org/wordpress-6.7.1.tar.gz && \
    tar vzxf  wordpress-6.7.1.tar.gz && \
    cp -R ./wordpress/* /var/www/html && rm /var/www/html/index.html

RUN (/usr/bin/mysqld_safe &); sleep 5; mysqladmin -u root -proot create wordpress

COPY wp-config.php /var/www/html/wp-config.php
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord"]
```

Este arquivo Dockerfile basicamente:

-   Utiliza a imagem do Ubuntu 22.02 (`FROM`);
-   Instala os seguintes serviços (`apt`):
    -   Apache 2 - será o servidor HTTP;
    -   PHP - fornece suporte PHP ao servidor HTTP e também instalar o
        módulo Mysql do PHP;
    -   Supervisor - vai ditar quais serviços iniciar com o container;
    -   Wget - será utilizado para fazer download do código fonte do
        Wordpress.
-   Configura o Mysql (`mysql-server` passa/configura previamente as
    entradas pedidas pelo `apt` para a instalação do Mysql);
-   Instala do Mysql (`apt`);
-   Faz o download do Wordpress (`wget`);
-   Cria o banco de dados que será utilizado pelo Wordpress (`wget`);
-   Copia o arquivo de configuração do Wordpress (`wp-config.php`);
-   Copia o arquivo de configuração do `supervisor`
    (`supervisord.conf`);
-   Exporta a porta TCP/80 (`EXPOSE`);
-   Executa o `supervisor` quando o container for inicializado (`CMD`).

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    <p>O arquivo anterior foi alterado para ser executado com o Wordpress e
Ubuntu mais atual, em relação ao exemplo do livro - o fonte do Wordpress
não funcionava mais com o exemplo do livro.</p></div></div>

O arquivo `wp-config.php` que será copiado via comando `COPY`, terá o
seguinte conteúdo:

``` console
<?php


define( 'DB_NAME', 'wordpress' );

define( 'DB_USER', 'root' );

define( 'DB_PASSWORD', 'root' );

define( 'DB_HOST', '127.0.0.1' );

define( 'DB_CHARSET', 'utf8mb4' );

define( 'DB_COLLATE', '' );

define( 'AUTH_KEY',         '={cp+g1h:|a/?S34nA<u70MoZHW_eJYO-QI3]Vk[)^/Mln' );
define( 'SECURE_AUTH_KEY',  '<[c|C{xsGt<g2GbMw[-.}IYq9>$b{(`kIZ}QH8#+vIr?J/6h a5<yn];Jkr4a>UE' );
define( 'LOGGED_IN_KEY',    '6Lr|- P}N`qq>*~)Xq3/Z4;z{2:=E^D2dq*%/}Fi^BK(4i!^uq* : x-KFmif~Ry' );
define( 'NONCE_KEY',        'C2BCz43k]0O3DEVfc;MOHSX]kkb&B%_~1bnmOTxr,szJ<c.L@eeKUtk7FPD.tzBc' );
define( 'AUTH_SALT',        '|OZ=2OLNW|h3gl2B9(kVi1/JDZNfGH;O6H!Di$}sH$*II<1G*XU&+$]XoW~= qxb' );
define( 'SECURE_AUTH_SALT', 'C!j`J!MxEGE6JoITB4*to{lYuoR_]jgBl/FdK/ktSF/Wg6-SsfJvjHQ,C_cFGht7' );
define( 'LOGGED_IN_SALT',   'q]-<g{SKHHuvYL!i220z^:$R@Um8O6(:jseem]0Lg$[PN0CR12eu_i2_FSos9)x}' );
define( 'NONCE_SALT',       'uU/I`_vljJoKFWjL ]1G@ry<^DeaJgyoy,.:`G!leF*wUh.j-sBR}xr{N@N8i<=?' );


$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
```

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    <p>Essa parte do arquivo <code>wp-config.php</code>, pode ser opcional.
Se não for feito o <code>COPY</code> do arquivo
<code>wp-config.php</code>, o container vai pedir essa configuração ao
ser iniciado via interface Web.</p></div></div>

Já o arquivo `supervisord.conf` terá o seguinte conteúdo:

``` console
[supervisord]
nodaemon=true

[program:mysqld]
command=/usr/bin/mysqld_safe
autostart=true
autorestart=true
user=root

[program:httpd]
command=/bin/bash -c "rm -rf /run/httpd/* && /usr/sbin/apachectl -D FOREGROUND"
```

O arquivo `supervisord.conf` inicia com a configuração do próprio
`supervisor`, que por padrão inicia como *daemon*, ou seja, em plano de
fundo. Então, para que o `supervisor` cumpra seu papel no container, é
passada a opção `nodaemon=true`, que impede que o processo vá para
*background*, o que evita que o container pare de ser executado logo de
inicio - já que não haveria processo para "prender" a execução do
container.

Ainda no arquivo `supervisord.conf` temos a configuração dos
processos/serviços que ele vai iniciar e monitorar, esses são feitos
pelos blocos:

-   `[program:mysqld]`;
-   `[program:httpd]`;

Note que no bloco `[program:mysqld]` são passadas as seguintes opções
respectivamente:

-   `command` - comando que será executado para iniciar o serviço;
-   `autostart` - ligar o serviço ao iniciar o container;
-   `autorestart` - reiniciar o serviço caso ele venha parar;
-   `user` - nome do usuário que vai executar tal serviço.

O bloco `[program:httpd]`, só possui a opção `command`, que informa qual
comando deve ser executado.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    <p>Para mais informações a respeito das opções do
<code>supervisor</code> acesse: <a
href="https://supervisord.org/introduction.html"
class="uri">https://supervisord.org/introduction.html</a></p></div></div>

Após essas configurações é possível cria a imagem:

``` console
$ docker build -t wordpress .

Sending build context to Docker daemon   7.68kB
Step 1/11 : FROM ubuntu:22.04
...
Step 3/11 : RUN apt-get update && apt-get -y install     apache2     php     php-mysql     supervisor     wget
...
Step 8/11 : COPY wp-config.php /var/www/html/wp-config.php
Step 11/11 : CMD ["/usr/bin/supervisord"]
...
```

Depois é possível utilizar tal imagem para criar um container:

``` console
$ docker run --name wp1 -d -p 80:80 wordpress
```

Com o container em execução, é possível acessar o Wordpress que estará
disponível na porta 80 do próprio hospedeiro (<http://127.0.0.1>), tal
como pode ser visto na Figura 12.

![Figura 12: WordPress em execução no container
criado](imagens/wordpress1.png)

Isso mostra como colocar em execução vários serviços de forma simultânea
em um mesmo container. Todavia, uma das filosofias em torno do uso de
container é utilizar os serviços de forma isolada, utilizando-se o
conceito de microsserviços.

## Linkando container

Neste método vamos realizar a mesma tarefa feita anteriormente, ou seja,
deixar em execução o serviço do WordPress, só que agora vamos utilizar
dois containers, sendo esses:

1.  Um exclusivo para o banco de dados, que no caso será o MYSQL;
2.  Outro para o servidor Web, com Apache HTTP e PHP, para executar o
    WordPress.

Isso de isolar serviços diferentes em containers distintos caracteriza
mais a ideia de microsserviço. Tal prática por exemplo, dá uma maior
segurança aos serviços e aos dados armazenados nos containers, pois caso
um invasor comprometa o container do WordPress, não terá necessariamente
acesso ao container do MySQL.

Para isso vamos utilizar as últimas imagens Dockers do
[WordPress](https://hub.docker.com/_/wordpress) e do
[MySQL](https://hub.docker.com/_/mysql), disponíveis no Docker Hub:

-   Obtendo a imagem do WordPress:

``` console
$ docker pull wordpress:latest

latest: Pulling from library/wordpress
fd674058ff8f: Pulling fs layer 
...
Status: Downloaded newer image for wordpress:latest
docker.io/library/wordpress:latest
```

-   Obtendo a imagem do MySQL:

``` console
$ docker pull mysql:latest

latest: Pulling from library/mysql
...
Status: Downloaded newer image for mysql:latest
docker.io/library/mysql:latest
```

Com as imagens já baixadas, vamos gerar os containers:

-   Gerando o container para o banco de dados:

``` console
$ docker run --name my1 -e MYSQL_ROOT_PASSWORD=123mudar -e MYSQL_DATABASE=wordpress -d mysql
```

Para essa imagem são passadas duas variáveis:

-   **`MYSQL_ROOT_PASSWORD=123mudar`** - essa que informa a senha para
    para acessar o banco de dados. Neste caso o usuário é o `root` e a
    senha é `123mudar`.
-   **`MYSQL_DATABASE=wordpress`** - essa variável cria um banco de
    dados chamado `wordpress`, que será justamente o banco de dados
    utilizado pelo outro container.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    <p>As variáveis da Imagem Docker do MySQL podem ser vistas em: <a
href="https://hub.docker.com/_/mysql"
class="uri">https://hub.docker.com/_/mysql</a>.</p></div></div>

É importante notar aqui que o nome deste container é `my1`, isso será
necessário no passo a seguir.

-   Gerando um container com o WordPress:

``` console
$ docker run -ti --rm --name wp1 --link my1 -p 80:80 -d wordpress
```

No exemplo anterior é gerado um container chamado `wp1`, que compartilha
a porta 80 com o *host* hospedeiro. Principalmente para essa tarefa,
utiliza-se a opção **`--link`** que relaciona o IP obtido
automaticamente, via DHCP do Docker, com o nome `my1`. Assim, utilizando
a opção `--link` é criada automaticamente, dentro do container, uma
relação entre o nome do container e o IP obtido - isso fica armazenado
no arquivo `/etc/hosts` do container.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
    <div class="note">
    <p>Nesta tarefa é importante perceber que é necessário primeiro criar o
container do banco de dados para só depois criar a do WordPress, já que
o último mantém uma relação/dependência com o primeiro.</p></div></div>

Agora com os dois containers em execução, é possível acessar a interface
Web fornecida pelo WordPress e terminar a configuração do WordPress com
o banco de dados. Neste exemplo as informações necessárias podem ser
vistas na Figura 13 (é claro que elas também estão presentes nos
comandos anteriores).

![Figura 13: Criando conexão para o banco de dados via
WordPress](imagens/wordpress2.png)

Como pode ser visto na Figura 13, o Wordpress foi configurado para
acessar um banco de dados chamado `wordpress`, o nome do usuário do
banco de dados é `root`, a senha é `123mudar` e o nome do
computador/servidor/container que mantém o banco de dados é `my1`. Feito
isso basta submeter essas informações ao WordPress, que ele vai ser
conectar ao banco de dados e apresentar o *dashboard* para iniciar os
trabalhos no WordPress.

## Utilizando a network ao invés de linkar containers

Anteriormente utilizamos a opção `--link`, para relacionar os containers
que compartilham um mesmo serviço, mas isso é atualmente considerado
obsoleto. Atualmente o mais recomendável é criar uma rede isolada para
os containers que compartilham serviços. Assim, por exemplo, se alguém
comprometer um container de uma rede não vai chegar facilmente aos
containers de outra rede. Também o uso de rede, reduz a quantidade de
comandos digitados via linha de comando para se criar um container, o
que pode evitar erros. Também nesta técnica é utilizado um DNS interno
do Docker para manter os nomes dos containers e seus respectivos IPs,
isso ajuda também a manter a escalabilidade com ferramentas como Docker
Compose e Docker Swarm.

Então para utilizar essa nova técnica que é mais recomendável, é
possível iniciar criando-se uma rede no Docker, tal como:

``` console
$ docker network create rede1
```

No exemplo anterior, foi criada uma rede chamada `rede1`. Agora vamos
relacionar os containers com essa rede, tal como:

``` console
$ docker run --name my2 --network rede1 -e MYSQL_ROOT_PASSWORD=123mudar -e MYSQL_DATABASE=wordpress -d mysql

$ docker run -ti --rm --name wp2 --network rede1 -p 81:80 -d wordpress
```

Nas linhas anteriores foram, criados respectivamente um container para o
MySQL e outro para o WordPress e eles conseguem se acessar via nome.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
    <div class="note">
    <p>É importante notar que no exemplo com <code>--link</code> o container
do MySQL não conseguiria acessar por nome o container do WordPress (não
havia esse relacionamento). Também agora se for criado um terceiro
container, na rede <code>rede1</code>, ele saberá acessar esses dois
containers pelo nome e o contrário também.</p></div></div>

A Figura 14 apresenta como fica a configuração do WordPress para acessar
o banco de dados nesta nova configuração, utilizando o `network`.

![Figura 14: Conexão do WordPress com o banco de dados utilizando
network](imagens/wordpress3.png)

Como pode-ser ver na Figura 14, para o WordPress basicamente não há
diferença entre acessar via `--link` ou via `--network`, mas os
benefícios do segundo método são reais e portanto esse método deve ser
priorizado.

O Capítulo 5 apresenta mais informações a respeito da rede Docker.

## Utilizando Docker Compose

Até agora fizemos todas as configurações via linha de comando, mas há
ferramentas que auxiliam na criação e gerenciamento dos containers, uma
delas é o [Docker Compose](https://docs.docker.com/compose/).

O Docker Compose é uma ferramenta que permite definir, criar e gerenciar
múltiplos containers Docker. Para isso o Docker Compose utiliza um
arquivo de configuração chamado `docker-compose.yml`, para determinar os
serviços, redes, armazenamento, variáveis, etc. Ou seja, o arquivo
declara tudo que é necessário para compor o container ou múltiplos
containers, o que pode facilitar a manutenção e automação,
principalmente em ambientes complexos.

Para utilizar o Docker Compose, é necessário primeiramente instalá-lo,
tal como:

``` console
$ yay -S docker-compose
Sync Explicit (1): docker-compose-2.32.1-1
...
Tamanho total download:   12,71 MiB
Tamanho total instalado:  54,71 MiB
...
```

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    <p>Anteriormente foi utilizado o exemplo de instalação do Arch Linux,
mas isso pode ser feito com outro gerenciador de pacote, tal como
<code>apt</code>, se a distribuição Linux for outra.</p></div></div>

Para entender o básico do Docker Compose, vamos continuar com o exemplo
anterior do WordPress, só que agora gerenciando tal ambiente via Docker
Compose. Então para isso começamos criando o arquivo
`docker-compose.yml`, com o seguinte conteúdo:

``` console
services:
  app:
    image: wordpress
    networks:
      - rede2
    ports:
      - "82:80"
  db:
    image: mysql
    networks:
      - rede2
    environment:
      MYSQL_ROOT_PASSWORD: 123mudar
      MYSQL_DATABASE: wordpress

networks:
  rede2:
```

A ideia do arquivo YAML é que ele seja intuitivo, mas de forma geral tal
arquivo do Docker Compose é composto das seguintes seções:

-   **`services`** - Define os containers que compõem a aplicação, sendo
    que cada serviço/container pode ter várias configurações, tais como:
    -   `image` - Imagem Docker que será utilizada;
    -   `build` - Caminho para construir uma imagem Docker
        personalizada;
    -   `ports` - Mapeia portas entre os container e o hospedeiro;
    -   `environment` - Define variáveis de ambiente para o container;
    -   `volumes` - Monta volumes para persistência de dados;
    -   `networks` - Conecta o container a uma ou mais redes;
    -   `depends_on` - Define dependências de outros serviços;
    -   `command` - Substitui o comando padrão executado no container.
-   **`networks`** - Define as redes para os containers;
-   **`configs`** - É opcional e permite gerenciar configurações
    especiais, como arquivos ou informações sensíveis;
-   **`secrets`** - É opcional e dados que devem ser mantidos sob
    segredo, tais como senhas.

Há mais opções para o Docker Compose, mas não é intenção deste material
contemplar todas essas, para isso busque materiais como livros ou acesse
<https://docs.docker.com/compose/>.

Apresentadas as opções mais comuns de um arquivo Docker Compose, é
possível notar que o arquivo `docker-compose.yml` anterior tem dois
containers, sendo um chamado `app` e outro chamado `db`, também há uma
rede chamada `rede2`. Os containers estão configurados da seguintes
forma:

-   O container `app`, tem como imagem o WordPress, está conectado à
    rede `rede2` e compartilha a porta 80 com o hospedeiro;
-   O container `db`, tem como imagem o MySQL, também está conectado à
    `rede2` e utiliza de variáveis para configurar a senha do `root` e
    cria um banco de dados chamado `wordpress`.

Com o arquivo `docker-container.yml` pronto, agora basta iniciar
ambiente com o Docker Compose, tal como:

``` console
$ docker-compose up

[+] Running 3/3
 * Network dockercompose_rede2    Created                                                                                         0.1s 
 * Container dockercompose-db-1   Created                                                                                         0.1s 
 * Container dockercompose-app-1  Created
 ...
 app-1  | 172.19.0.1 - - [06/Jan/2025:23:00:06 +0000] "GET /wp-admin/load-scripts.php?c=0&load%5Bchunk_0%5D=clipboard,jquery-core,jquery-migrate,zxcvbn-async,wp-hooks&ver=6.7.1 HTTP/1.1" 200 39121 "http://127.0.0.1:82/wp-login.php" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
app-1  | 172.19.0.1 - - [06/Jan/2025:23:00:10 +0000] "POST /wp-login.php HTTP/1.1" 200 2391 "http://127.0.0.1:82/wp-login.php" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
app-1  | 127.0.0.1 - - [06/Jan/2025:23:00:18 +0000] "OPTIONS * HTTP/1.0" 200 126 "-" "Apache/2.4.62 (Debian) PHP/8.2.27 (internal dummy connection)"
```

Então, tal como apresentado anteriormente, o comando `docker-compose up`
é utilizado para iniciar o ambiente configurado no arquivo Docker
Compose. Note na saída anterior, que ele apresenta a criação dos
componentes do ambiente (containers e rede) e depois ele continua
apresentando as saídas/*logs* dos containers criados, inclusive por
padrão o Docker Compose deixará o terminal preso com a sua execução.

<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    <p>Se for necessário parar o Docker Compose, basta pressionar
<code>Ctrl+C</code>.</p></div></div>

Como dito anteriormente não intenção desse material cobrir tudo que há a
respeito do Docker Compose, mas as principais opções desse são:

-   **`up`** - Inicia todos os serviços definidos no arquivo
    `docker-compose.yml`. Neste, no modo padrão exibe o os *logs* dos
    containers no terminal do hospedeiro. Utilizando a opção `-d`
    (*detached*), executa em segundo plano;
-   **`down`** - Encerra todos os serviços e remove os containers,
    redes, etc criados pelo `up`;
-   **`start`** - Inicia container previamente criados e que estejam
    parados (apenas reinicia, sem criá-los);
-   **`stop`** - Para temporariamente os containers em execução, mas sem
    removê-los, depois é possível reiniciá-los com o `start`;
-   **`restart`** - Reinicia os containers;
-   **`ps`** - Exibe o status dos containers;
-   **`logs`** - Exibe os *logs* dos serviços gerenciados pelo Docker
    Compose, por exemplo, `docker-compose logs db`, mostrá os *logs* do
    container chamado `db`;
-   **`exec`** - Executa um comando em um container que já está ativo.
    Exemplo: `docker-compose exec db bash`, neste caso executa um `bash`
    no container chamado `db`;
-   **`config`** - Valida e exibe o conteúdo do arquivo
    `docker-compose.yml`;
-   **`build`** - Constrói as imagens Docker para os serviços definidos
    com a diretiva `build`. Recria imagens quando o código-fonte ou
    Dockerfile é alterado;
-   **`rm`** - Remove containers parados, a ideia é remover containers
    antigos sem afetar os volumes de armazenamento ou redes.

Bem, com o ambiente em execução via Docker Compose, agora é possível
acessar o WordPress via hospedeiro através da porta 82 e configurar a
conexão como banco de dados, tal como mostra a Figura 15.

![Figura 15: Conexão do WordPress com o banco de dados utilizando Docker
Compose](imagens/wordpress4.png)

O Docker Compose é muito mais poderoso do que foi apresentado aqui, a
ideia deste texto é apenas mostrar o seu funcionamento básico. Todavia,
quem for gerenciar ambientes complexos deve ir mais a fundo neste tipo
de ferramenta, pois isso pode trazer benefícios tais como a redução da
complexidade em manter múltiplos serviços utilizando-se vários
containers.
