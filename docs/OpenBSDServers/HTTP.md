---
layout: page
---

OpenBSD - Servidor Apache HTTP
========================

>**UTFPR - Universidade Tecnológica Federal do Paraná, campus Campo Mourão**  
>Autor: **Prof. Dr. Luiz Arthur Feitosa dos Santos**  
>E-mail: **<luizsantos@utfpr.edu.br>**  

## Introdução

O servidor [HTTP Apache](https://httpd.apache.org/) permite compartilhar páginas Web via HTTP, HTTPS, bem como trabalhar com módulos, tais como o PHP, dentre outros.

## Instalação

Procurar o pacote:

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

## Instalar:

Para instalar o servidor HTTP Apache:

```console
dacom# pkg_add apache-httpd-2.4.41
``` 

## Verificando o status do serviço:

Basicamente há duas opções:
1. Com o comando ``netstat``:
```console
# netstat -a -p tcp
Active Internet connections (including servers)
Proto   Recv-Q Send-Q  Local Address          Foreign Address        (state)
tcp          0      0  192.168.56.101.ssh     192.168.56.1.33122     ESTABLISHED
tcp          0      0  *.ssh                  *.*                    LISTEN
tcp          0      0  localhost.smtp         *.*                    LISTEN
Active Internet connections (including servers)
Proto   Recv-Q Send-Q  Local Address          Foreign Address        (state)
tcp6         0      0  *.ssh                  *.*                    LISTEN
tcp6         0      0  fe80::1%lo0.smtp       *.*                    LISTEN
tcp6         0      0  localhost.smtp         *.*                    LISTEN
```
2. Com o comando ``fstat``:

```console
# fstat | grep ':80'
```

Bem, nestes dois casos o servidor Apache não está em execução, pois não há nenhuma porta relacionada com HTTP, na saída do ``netstat`` e principalmente não há processos relacionados com a porta TCP/80 no ``fstat``.

## Iniciando/Parando o servidor:

Para iniciar há várias opções, sendo algumas:
1. Comando ``apachectl``:

```console
# apachectl start                                                                                                                  
AH00557: httpd2: apr_sockaddr_info_get() failed for dacom.utfpr.cm
AH00558: httpd2: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this message
```

2. Utilizando diretamente o *script*:

```console
# /etc/rc.d/apache2 -f start
```

3. Utilizando o comando ``rcctl``:

```console
# rcctl start apache2                                                                                                                
/etc/rc.d/httpd: need -f to force start since httpd_flags=NO
```
> **Atenção**, também é possível parar o servidor utilizando a opção ``stop`` no lugar de ``start``, o mesmo vale para reiniciar o servidor com a opção ``restart``.

Depois disso (de inciar o serviço) deve-se verificar se o servidor está em execução com os comando ``netstat`` ou ``fstat``. Exemplos:

No caso do ``netstat`` deve ser possível observar a porta 80 no estado de ``LISTEN``.
```console
# netstat -nap tcp     
Active Internet connections (including servers)
Proto   Recv-Q Send-Q  Local Address          Foreign Address        (state)
tcp          0      0  192.168.56.101.22      192.168.56.1.44582     ESTABLISHED
tcp          0      0  127.0.0.1.25           *.*                    LISTEN
tcp          0      0  *.22                   *.*                    LISTEN
tcp          0      0  *.80                   *.*                    LISTEN
Active Internet connections (including servers)
Proto   Recv-Q Send-Q  Local Address          Foreign Address        (state)
tcp6         0      0  *.22                   *.*                    LISTEN
tcp6         0      0  ::1.25                 *.*                    LISTEN
tcp6         0      0  fe80::1%lo0.25         *.*                    LISTEN
tcp6         0      0  *.80                   *.*                    LISTEN
```
Já no caso do ``fstat`` deve-se observar o processo ``httpd2`` em execução.

```console
# fstat | grep *:80
www      httpd2     22930    3* internet stream tcp 0xffff8000008e9660 *:80
www      httpd2     22930    4* internet6 stream tcp 0xffff8000008e9440 *:80
www      httpd2     12747    3* internet stream tcp 0xffff8000008e9660 *:80
www      httpd2     12747    4* internet6 stream tcp 0xffff8000008e9440 *:80
www      httpd2     66143    3* internet stream tcp 0xffff8000008e9660 *:80
www      httpd2     66143    4* internet6 stream tcp 0xffff8000008e9440 *:80
www      httpd2     78720    3* internet stream tcp 0xffff8000008e9660 *:80
www      httpd2     78720    4* internet6 stream tcp 0xffff8000008e9440 *:80
www      httpd2     77039    3* internet stream tcp 0xffff8000008e9660 *:80
www      httpd2     77039    4* internet6 stream tcp 0xffff8000008e9440 *:80
root     httpd2     74721    3* internet stream tcp 0xffff8000008e9660 *:80
root     httpd2     74721    4* internet6 stream tcp 0xffff8000008e9440 *:80
```

## Habilitando o servidor no *boot*:

Para habilitar o servidor para iniciar junto com o *boot* da máquina há duas alternativas:

1.  Com o comando rcctl:

```console
# rcctl enable apache2 
```

Para desabilitar basta substituir ``enable`` por ``disable``.

2. Editando o arquivo de configuração ``/etc/rc.conf.local`` e adicionando a linha ``pkg_scripts=apache2``.

```console
# vi /etc/rc.conf.local                                                                                                           
pkg_scripts=apache2
```

Para desabilitar basta excluir a linha ``pkg_scripts=apache2``.

## Arquivos/diretórios de configuração:

No OpenBSD, o arquivo de configuração do Apache fica em:

``/etc/apache2/httpd2.conf``

As principais diretivas para serem alteradas neste arquivos são:
* **ServerName** -  Nome utilizado para identificar o servidor, pode ser atribuído automaticamente, mas é recomendável para evitar problemas na inicialização do Apache. Também pode ser utilizado o IP do servidor. ex. ServerName nome.dominio:80.
* **ServerRoot** - Diretório no qual o servidor armazena arquivos de configurações, *log* e erro.
* **User e Group**	– Nome do usuário e grupo de usuário que serão dadas permissões para a execução do Apache. Ou seja, se o usuário for o administrador o Apache terá permissão de root, o que é muito perigoso. Então, é recomendável que o Apache seja executado com um usuário comum e específico para sua execução.
* **DocumentRoot** - Configura o diretório no qual ficarão os arquivos a serem servidor pelo Apache. No caso do OpenBSD o padrão é: ``/var/www/htdocs``.
* **ErrorLog** – Onde serão armazenados os arquivos de ``log`` de erros.
* **LogLevel** – Nível de ``log`` que será gravado, mais detalhado ou mais resumido. É possível configurar ou personalizar os ``logs`` do Apache. 
* **Listen** - Permite especificar IPs e portas que o Apache irá responder. ex: ``Listen 127.0.0.1:8080``.	
 
## Configurando as portas de rede do Apache:

No arquivo de configuração:
```console
# vi /etc/apache2/httpd2.conf
```

* Executando o Apache nas portas TCP 80 e 8080:

```console
Listen 80
Listen 8080	
```
* Executando o Apache nas portas TCP 80 e 8080, mas especificando IPs que atenderão tais pedidos. Nesse exemplo, só será possível acessar a porta 80 a partir do localhost – não é possível acessar a porta TCP/80 via rede local ou Internet.

```console
Listen 127.0.0.1:80
Listen 192.168.56.101:8080
```
Não esqueça de reiniciar o serviço para as novas configurações começarem a valerem:

```console
# apachectl2 restart 
```

## Configuração de servidores virtuais:

Servidores virtuais, também chamados de *hosts* virtuais, permitem que múltiplos sítios Web sejam armazenados em um único servidor Apache. Esses servidores virtuais são diferenciados por nomes ou IPs distintos e o Apache utiliza o cabeçalho HTTP/1.1 para encontrar para qual host virtual entregar o pedido HTTP enviado.

No Apache há dois tipos de servidores virtuais, também chamados de *hosts* virtuais:	

1. Servidores/*hosts* virtuais que se baseiam no endereço IP ou na porta de rede, sendo que nesse tipo deve ser alocado um endereço IP ou porta diferente para cada sítio.

2. Servidores/hosts virtuais que se baseiam no nome do domínio do servidor Web, já neste tipo, os sítios são diferenciados pelo nome do host enviado pelo cliente HTTP (só funciona na versão 1.1 do HTTP, mas que é bem antiga). Este tipo de servidor/*host* virtual é mais indicada atualmente, devido a falta de endereços IPv4 disponíveis na Internet, contudo é mais complexo, principalmente se os hosts virtuais precisarem ser acessados via HTTPS (que será visto mais a frente).

### Criando Hosts Virtuais:
Descomente a linha a seguir no arquivo de configuração do Apache:

Edite o arquivo de configuração padrão do Apache:

``# vim /etc/apache2/extra/httpd-vhosts.conf``

Procure a linha seguir e descomente:

``#Include /etc/apache2/extra/httpd-vhosts.conf``

ou seja essa deve ficar assim:

``Include /etc/apache2/extra/httpd-vhosts.conf``

Agora edite o arquivo de configuração dos *hosts* virtuais:

``# vim /etc/apache2/extra/httpd-vhosts.conf``

Inclua as seguintes configurações/linhas:

```console
<VirtualHost *:80>
DocumentRoot "/var/www/htdocs/default"
ServerName dacom.utfpr.cm 
</VirtualHost>

<VirtualHost *:80>
DocumentRoot "/var/www/htdocs/redes2"
ServerName www.redes2.info 
</VirtualHost>
```

No primeiro *host* virtual criamos um *host* padrão, caso o usuário não digite nenhum domínio específico. Desta forma, ao digitar apenas o IP, por exemplo, ele entrará no sítio padrão/raiz do servidor. Já caso o cliente digite www.redes2.info, ele irá acessar o sítio disponível em ``/var/www/htdocs/redes2``.



Criar os diretórios e arquivos dos servidores principais:

```console
# mkdir -p /var/www/htdocs/default                                                                                                   
# mkdir -p /var/www/htdocs/redes2  
# echo "bem vindo ao servidor padrao" > /var/www/htdocs/default/index.html                                                           
# echo "bem vindo ao servidor redes2" > /var/www/htdocs/redes2/index.html
```

Após realizar alterações no arquivo de configuração é necessário reinicializar o servidor para que essas tenham efeito:

```console
# apachectl2 restart 
```

> **Atenção**, para testar o *host* virtual é preciso utilizar nomes, para isso o tal nome deve estar disponível no servidor DNS do cliente, ou (para testes) deve estar no arquivo ``/etc/hosts`` do cliente.

## Instalar PHP com Apache:

Procurar o pacote:

```console
# pkg_info -Q php                                                                                                          
php-7.1.33
php-7.2.28
php-7.3.15
php-apache-7.1.33
php-apache-7.2.28
php-apache-7.3.15
php-bz2-7.1.33
php-bz2-7.2.28
```

Instalar o PHP:

```console
# pkg_add php-apache-7.1.33                                                                                                
quirks-3.183 signed on 2020-02-27T12:13:05Z
php-apache-7.1.33:oniguruma-6.9.4: ok
php-apache-7.1.33:femail-1.0p1: ok
php-apache-7.1.33:femail-chroot-1.0p3: ok
php-apache-7.1.33:php-7.1.33: ok
php-apache-7.1.33: ok
The following new rcscripts were installed: /etc/rc.d/php71_fpm
See rcctl(8) for details.
New and changed readme(s):
/usr/local/share/doc/pkg-readmes/femail-chroot
/usr/local/share/doc/pkg-readmes/php-7.1
```

Criar link para o Apache:

```console
# ln -sf /var/www/conf/modules.sample/php-7.1.conf /var/www/conf/modules
```

Reiniciar Apache:

```console
# apachectl restart
```

Criar arquivo PHP de teste:

```console
# echo "<?php phpinfo(); ?>" > /var/www/htdocs/teste.php
```

Testar:

http://servidor/teste.php

## HTTPS

O HTTPS é o protocolo HTTP só que seguro, ou seja, ele envia as informações entre cliente e servidor de forma criptografada e também ajuda a verificar a identidade do servidor.

### Configuração:

#### Criar o diretório:

```console
# mkdir /etc/ssl/certs
```

#### Gerar o certificado:

```console
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key
-out /etc/ssl/certs/selfsigned.crt
```

#### Configurar o arquivo principal do Apache:

Edite o arquivo:
```console
# vi /etc/apache2/httpd2.conf
```

Edite/descomente as seguintes linhas:

```console
Listen 80
Listen 443
LoadModule ssl_module /usr/local/lib/apache2/mod_ssl.so
LoadModule socache_shmcb_module /usr/local/lib/apache2/mod_socache_shmcb.so
Include /etc/apache2/extra/httpd-vhosts.conf
```

#### Configurar o arquivo de *hosts* virtuais do Apache:

```console
# vi /etc/apache2/extra/httpd-vhosts.conf                                          

<VirtualHost *:80>
DocumentRoot "/var/www/htdocs"
ServerName dacom.utfpr.cm 
</VirtualHost>


<VirtualHost *:443>
DocumentRoot "/var/www/htdocs/"
ServerName  dacom.utfpr.cm
SSLEngine on
SSLCertificateFile /etc/ssl/certs/selfsigned.crt
SSLCertificateKeyFile /etc/ssl/private/selfsigned.key
</VirtualHost>

```
#### Reinicie o Apache:

```console
# apachectl restart
```

#### Redirecionando HTTP para HTTPS

No caso de ter o mesmo conteúdo HTTP e HTTPS é interessante disponibilizá-lo utilizando apenas HTTPS. Para isso é possível criar um redirecionamento. Assim, qualquer acesso HTTP irá virar HTTPS, isso é muito utilizado atualmente por grandes sítios.

```console
# vi /etc/apache2/extra/httpd-vhosts.conf

<VirtualHost *:80>
ServerName dacom.utfpr.cm 
Redirect permanent / https://dacom.utfpr.cm/
</VirtualHost>
```

> **Atenção**, pode ser necessário incluir uma entrada para ``127.0.0.1 dacom.utfpr.cm`` no arquivo ``/etc/hosts``, no servidor HTTPS, já que o redirecionamento está utilizando este nome.

Depois é só verificar se o HTTPS está funcionando corretamente verificando o status da rede no servidor e principalmente com um cliente acessando o HTTPS do servidor em questão.



## Referências

* <https://dev.to/nabbisen/setting-up-openbsds-httpd-web-server-4p9f>
* <http://www.h-i-r.net/p/hirs-secure-openbsd-apache-mysql-and.html>

