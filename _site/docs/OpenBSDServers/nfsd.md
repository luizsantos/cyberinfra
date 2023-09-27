# Servidor de Arquivos NFS no OpenBSD

O Network File System ([NFS](https://pt.wikipedia.org/wiki/Network_File_System)) é um servidor de arquivos dos sistemas [UNIX-Like](https://pt.wikipedia.org/wiki/Sistema_operacional_tipo_Unix). O NFS utiliza Remote Procedure Call ([RPC](https://pt.wikipedia.org/wiki/Chamada_de_procedimento_remoto)), dentre outros serviços (``mountd``, ``statd``, etc) para compartilhar arquivos na rede. Devido à algumas características, tais como utilizar portas aleatórias através do ``portmapper``, o NFS é mais indicado em LANs. Outro problema do NFS é que sua segurança inicialmente é dada apenas através da relação entre IPs dos *hosts* da rede (não por usuário e senha). Entretanto o NFS é um bom sistema para se construir por exemplo, *clusters* de alta performance, tais como o [Beowulf](https://pt.wikipedia.org/wiki/Aglomerado_Beowulf).

# Instalação

No [OpenBSD](https://www.openbsd.org/) o NFS já vem instalado por padrão, então só é necessário configurá-lo.

# Configuração

A configuração inicia com a criação do arquivo ``/etc/exports``, que contém os diretórios que serão compartilhados e suas opções de compartilhamento. Para tal passo podemos inicialmente "iniciar" este arquivo através da cópia de um arquivo de exemplo, tal como:

```console
# cp /etc/examples/exports /etc/exports
```

Após isso é só editá-lo:

```console
# vi /etc/exports

#	$OpenBSD: exports,v 1.1 2014/07/12 03:52:39 deraadt Exp $
#
# NFS exports Database
# See exports(5) for more information.  Be very careful:  misconfiguration
# of this file can result in your filesystems being readable by the world.
/tmp -alldirs
/home -alldirs
```

No exemplo anterior, foram compartilhados os diretórios ``/tmp`` e ``/home``, a opção ``-alldirs`` indicam que é possível "mountar" qualquer ponto dentro do diretório compartilhado. Outras opções do arquivo ``exports`` são:
* ``-ro`` - compartilhar somente como leitura. Para compartilhar com leitura e gravação, basta omitir o ``-ro``;
* ``-network=`` - rede que pode "mountar" o compartilhamento, junto com essa opção pode ser utilizada ``-mask=`` para a máscara de rede.
* ``-maproot=`` - mapeia o usuário remoto para um usuário no servidor de arquivos, por exemplo: ``-maproot=0:1000``, mapeia o compartilhamento para o usuário de ID 0 (o ``root``) e do grupo 1000 (tem que ver no arquivo ``/etc/group`` do servidor NFS, qual é o nome dado a este grupo).

Após a configuração é possível habilitar o NFS no *boot* do servidor (isso é opcional) e ligar o serviço:

```console
# rcctl enable portmap mountd statd nfsd

# rcctl start portmap mountd statd nfsd
```

> Atenção é necessário ligar todos os serviços listados no comando anterior.

Para verificar se o servidor está funcionando é possível utilizar o comando ```rpcinfo`` e ``showmount``, tal como a seguir:

* O comando ``rpcinfo`` apresenta as portas utilizadas por cada serviço no servidor:

```console
# rpcinfo  -p 127.0.0.1
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100005    1   udp    673  mountd
    100005    3   udp    673  mountd
    100005    1   tcp    807  mountd
    100003    2   udp   2049  nfs
    100005    3   tcp    807  mountd
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100024    1   udp    696  status
    100024    1   tcp    713  status
```

* O comando ``showmount`` apresenta os compartilhamentos do servidor:

```console
# showmount -e 127.0.0.1
Exports list on 127.0.0.1:
/tmp                               Everyone
/home                              Everyone
```

Tais comandos podem ser utilizados tanto servidor quanto nos clientes.

Atenção, para que qualquer nova alteração no arquivo ``/etc/exports`` seja refletida no servidor, é necessário executar o comando:

```console
# rcctl reload mountd
mountd(ok)
```

Após isso é possível, por exemplo, acessar novos compartilhamentos de rede, incluídos no servidor NFS.


# "Mountando" o compartilhamento no cliente

O compartilhamento do NFS pode ser "mountado" no cliente, ou seja, utilizamos o comando ``mount`` no cliente para anexar o compartilhamento de rede no sistema de arquivos do cliente. Um exemplo disso é:

```console
# mount -t nfs 127.0.0.1:/home /mnt/
```

Após esse comando dentro do diretório ``/mnt`` do *host* cliente, haverá o conteúdo do diretório ``/home`` do *host* servidor.

É possível executar o comando ``mount`` para ver se a montagem funcionou, tal como:

```console
# mount
/dev/wd0a on / type ffs (local)
...
127.0.0.1:/home on /mnt type nfs (v3, udp, timeo=100, retrans=101)
```

A última linha da saída anterior, mostra que a montagem foi bem sucedida.

> Observação: Nestes exemplos os testes foram feitos no próprio servidor, ou seja, o *host* era o servidor e o cliente. Por isso foi utilizado o IP 127.0.0.1. Mas provavelmente você vai trocar o IP 127.0.0.1 pelo IP do seu servidor no *host* cliente. ;-)

# Referências

* <nfs >

