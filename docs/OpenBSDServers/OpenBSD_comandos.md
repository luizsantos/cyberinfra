---
layout: page
---

OpenBSD - Comandos básicos
========================

>**UTFPR - Universidade Tecnológica Federal do Paraná, campus Campo Mourão**  
>Autor: **Prof. Dr. Luiz Arthur Feitosa dos Santos**  
>E-mail: **<luizsantos@utfpr.edu.br>**  

## Introdução

O Sistema Operacional [OpenBSD](https://www.openbsd.org/) é considerado um dos sistemas operacionais mais seguros do mundo, por isso sempre é uma ótima escolha para servidores e principalmente *firewalls*.

Aqui são apresentados comandos úteis para a utilização do OpenBSD, para a instalação/configuração de alguns servidores de rede.

## Instalação de pacotes no OpenBSD

Normalmente a instalação de pacotes consiste basicamente em procurar o pacote para ser instalado e depois instalá-lo. Bem, no OpenBSD é possível instalar através do seu gerenciador de pacotes ``pkg_add``, compilando pacotes, dentre outros métodos. Aqui vamos nos concentrar no gerenciador de pacotes.

### Procurar por pacotes

Para procurar pacotes para serem instalados no OpenBSD, é possível utilizar o comando ``pkg_add -Q``, seguido do termo/pacote que estamos procurando. Exemplo:

```console
# pkg_info -Q httpd
apache-httpd-2.4.41
bozohttpd-20190228
darkhttpd-1.12
libmicrohttpd-0.9.66
lighttpd-1.4.54
lighttpd-1.4.54-ldap
lighttpd-1.4.54-ldap-mysql
lighttpd-1.4.54-mysql
p5-HTTPD-Log-Filter-1.08p2
sthttpd-2.26.4p4
```
Neste exemplo foram listados todos os pacotes que possuem o termo ``http``.

### Instalando pacotes

Para instalar pacotes basta utilizar o comando ``pkg_add``, seguido do nome do pacote - neste caso podemos usar o pacote encontrado ``pkg_info -Q``. Exemplo:

```console
# pkg_add apache-httpd-2.4.41
quirks-3.183 signed on 2020-02-27T12:13:05Z
apache-httpd-2.4.41:brotli-1.0.7: ok
apache-httpd-2.4.41:pcre-8.41p2: ok
apache-httpd-2.4.41:nghttp2-1.39.2: ok
apache-httpd-2.4.41:curl-7.66.0: ok
apache-httpd-2.4.41:xz-5.2.4: ok
apache-httpd-2.4.41:libxml-2.9.9: ok
apache-httpd-2.4.41:db-4.6.21p7v0: ok
apache-httpd-2.4.41:apr-1.6.5p0: ok
apache-httpd-2.4.41:apr-util-1.6.1p2: ok
apache-httpd-2.4.41:jansson-2.12: ok
apache-httpd-2.4.41: ok
Running tags: ok
The following new rcscripts were installed: /etc/rc.d/apache2
See rcctl(8) for details.
```

Neste caso foi instalado o servidor HTTP Apache na versão 2.4.41.

## Problemas na instalação de pacotes:

### Erro SSL write

Esse erro apresenta a seguinte saída:

```console
# pkg_info -Q php                                                                                                          
https://cdn.openbsd.org/pub/OpenBSD/6.6/packages-stable/amd64/: ftp: SSL write error: ocsp verify failed: ocsp response not current
https://cdn.openbsd.org/pub/OpenBSD/6.6/packages/amd64/: ftp: SSL write error: ocsp verify failed: ocsp response not current
https://cdn.openbsd.org/pub/OpenBSD/6.6/packages/amd64/: empty
```

Neste caso a solução é:  (i) atualizar o data/hora do sistema ou (ii) reiniciar a máquina.


## Referências

* <https://www.openbsd.org/faq/faq15.html>
