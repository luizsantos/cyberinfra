---
layout: page
---

1. No servidor OpenBSD onde estão as filas criadas anteriormente:
	* Instalar o Apache:
	```console
	
	```
	* Configurar o Apache para responder em três portas distintas:
	```console
	openbsd# vi /etc/apache2/httpd2.conf
	...
	Listen 8080
	Listen 8081
	Listen 8
	...
	```
	* Criar um arquivo no HTTP para que o cliente faça o download desse durante os testes:
	```console
	openbsd# truncate -s 100M /var/www/htdocs/100.txt
	```
	* Iniciar o servidor:
	```console
	openbsd# /etc/rc.d/apache2 restart
	```
	ou
	```console
	openbsd# apachectl2 restart                                                           
	AH00557: httpd2: apr_sockaddr_info_get() failed for openbsd.dacom
	AH00558: httpd2: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this message
	```
	* Verificar se o servidor e as portas estão funcionado:
	```console
	openbsd# netstat -a -p tcp -n 
	Active Internet connections (including servers)
	Proto   Recv-Q Send-Q  Local Address          Foreign Address        (state)
	tcp          0      0  192.168.56.111.22      192.168.56.1.54010     ESTABLISHED
	tcp          0      0  *.22                   *.*                    LISTEN
	tcp          0      0  *.8081                 *.*                    LISTEN
	tcp          0      0  127.0.0.1.25           *.*                    LISTEN
	tcp          0      0  *.80                   *.*                    LISTEN
	tcp          0      0  *.8080                 *.*                    LISTEN
	```
	Note tem quemos como ``LISTEN``, as portas 8081, 80 e 8080 (as portas que configuramos anteriormente) o que mostra que o apache está funcionando corretamente.

2. No cliente:
	* O teste pode ser feito via navegador (Firefox, Chrome, lynx, etc). Aqui nós foi utilizado o ``wget``:
	```console
	$ wget http://192.168.56.111:8080/100.txt
	--2020-01-03 16:14:23--  http://192.168.56.111:8080/100.txt
	Conectando-se a 192.168.56.111:8080... conectado.
	A requisiÃ§Ã£o HTTP foi enviada, aguardando resposta... 200 OK
	Tamanho: 104857600 (100M) [text/plain]
	Salvando em: â100.txt.2â
	
	100.txt.2             100%[========================>] 100,00M  52,9MB/s    em 1,9s    
	
	2020-01-03 16:14:25 (52,9 MB/s) - â100.txt.2â salvo [104857600/104857600]
	```
	
	Neste caso note que o download do arquivo criado foi feito com sucesso. O ``wget`` também mostra o processo do download e a taxa média de transmissão de dados. Após isso dá para listar o arquivo no diretório onde foi feito o ``wget``, exemplo:
	```console
	$ ls 100.txt*
	100.txt  100.txt.1  100.txt.2
	```

	
	> Atenção - note na saída anterior que há vários arquivos ``100.txt``, o ``wget`` tem esse comportamento, cada vez que vc executar o mesmo comando, fazendo o download do arquivo ``100.txt``, caso o arquivo já exista ele vai renomear para um nome similar, tal como: ``100.txt.1``, etc... Caso vc queira seria bom apagar esses arquivos de vez em quando, isso pode ser feito com o comando:
	```console
	$ rm 100.txt*
	```
	>Cuidado que este comando vai apagar todo que iniciar com o nome ``100.txt``.