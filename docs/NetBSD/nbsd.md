
## Instalar pacotes binários

Primeiro é necessário exportar o caminho (``PATH``) para que o comando ``pkg_add `` encontre os pacotes necessário na Internet. Neste caso está sendo utilizada a versão 9.3 do NetBSD no ``PATH``

```console
nbsd# export PKG_PATH="http://cdn.netbsd.org/pub/pkgsrc/packages/NetBSD/amd64/9.3/All/"
```

>> **Atenção** nos testes não funcionou URL do repositório com HTTPS, só o HTTP. Neste caso basta trocar ``https`` para ``http`` na URL. Também é possível utilizar outros meios que não a Internet, tal como CD-ROM, etc.

Após configurar o caminho do repositório na Internet, vamos instalar o programa ``pkgin``, que seria o equivalente a um ``apt-get`` do NetBSD.

```console
nbsd# pkg_add pkgin

pkg_add: Warning: package `pkgin-22.10.0nb1' was built for a platform:
pkg_add: NetBSD/x86_64 9.0 (pkg) vs. NetBSD/x86_64 9.3 (this host)
pkg_add: Warning: package `pkg_install-20211115' was built for a platform:
pkg_add: NetBSD/x86_64 9.0 (pkg) vs. NetBSD/x86_64 9.3 (this host)
pkgin-22.10.0nb1: copying /usr/pkg/share/examples/pkgin/repositories.conf.example to /usr/pkg/etc/pkgin/repositories.conf
```

Com o ``pkgin`` instalado agora é possível utilizá-lo para por exemplo procurar algum pacote, tal como no exemplo a seguir:

```console
nbsd# pkgin search apache
...
apache-2.4.56        Apache HTTP (Web) server, version 2.4
apache-ant-1.10.13nb1  Apache Project's Java-Based make(1) replacement
apache-ant-1.9.13    Java make(1) replacement
apache-ant-1.5.4nb2  "Apache Project's Java-Based make(1) replacement"
apache-cassandra-3.11.2nb3  Highly scalable, distributed structured key-value store
apache-cassandra-2.2.12nb3  Highly scalable, distributed structured key-value store
apache-ivy-2.5.0     "Apache Project's Java-Based agile dependency manager"
apache-maven-3.8.6   Apache Project's software project management and comprehension tool
apache-roller-5.1.2nb1  Full-featured, multi-user and group-blog server
apache-solr-8.11.1   High performance search server built using Lucene Java
apache-tomcat-9.0.62  Implementation of Java Servlet and JavaServer Pages technologies
apache-tomcat-8.5.61  Implementation of Java Servlet and JavaServer Pages technologies
apache-tomcat-8.0.53nb1  Implementation of Java Servlet and JavaServer Pages technologies
apache-tomcat-7.0.106  Implementation of Java Servlet and JavaServer Pages technologies
apache-tomcat-6.0.45nb1  Implementation of Java Servlet and JavaServer Pages technologies
apache-tomcat-5.5.35  The Apache Project's Java Servlet 2.4 and JSP 2.0 server
...
```
>> Partes da saída do comando forma omitidas.

Anterior mente foi pesquisado se há algum pacote com o nome ``apache``, na intenção de instalar o servidor HTTP Apache. Tal busca resulta em vários pacotes. A seguir é utilizado a opção ``install`` para instalar um desses pacotes:

```console
nbsd# pkgin install apache-2.4.56
calculating dependencies...done.

12 packages to install:
  apache-2.4.56 readline-8.2nb1 pcre2-10.42 nghttp2-1.52.0 libxml2-2.10.4 brotli-1.0.9 apr-util-1.6.3 apr-1.7.2 xmlcatmgr-2.2nb1 python310-3.10.10
  libuuid-2.32.1nb1 libffi-3.4.4

0 to refresh, 0 to upgrade, 12 to install
25M to download, 147M to install

proceed ? [Y/n]
```

## Redes

### Verificando conexões de redes

```console
nbsd# sockstat -4ln
USER     COMMAND    PID   FD PROTO  LOCAL ADDRESS         FOREIGN ADDRESS
root     dhcpcd     181   11 udp    *.68                  *.*
root     sshd       340    4 tcp    *.22                  *.*
_httpd   httpd      3822   5 tcp    *.80                  *.*
```

```console
nbsd# netstat -f inet
Active Internet connections
Proto Recv-Q Send-Q  Local Address          Foreign Address        State
tcp        0      0  192.168.56.21.ssh      192.168.56.1.52060     ESTABLISHED
```

```console
nbsd# netstat -f inet -r
Routing tables

Internet:
Destination        Gateway            Flags    Refs      Use    Mtu Interface
default            10.0.2.2           UGS         -        -      -  wm0
10.0.2/24          link#1             UC          -        -      -  wm0
10.0.2.15          link#1             UHl         -        -      -  lo0
127/8              localhost          UGRS        -        -  33624  lo0
localhost          lo0                UHl         -        -  33624  lo0
192.168.56/24      link#2             UC          -        -      -  wm1
192.168.56.21      link#2             UHl         -        -      -  lo0
192.168.56.1       0a:00:27:00:00:00  UHL         -        -      -  wm1
192.168.56.2       08:00:27:1c:1b:63  UHL         -        -      -  wm1
10.0.2.2           52:54:00:12:35:02  UHL         -        -      -  wm0
```



