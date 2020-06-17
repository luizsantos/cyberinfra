---
layout: page
---

OpenBSD - Servidores FTP, TELNET, SSH e inetd
========================

>**UTFPR - Universidade Tecnológica Federal do Paraná, campus Campo Mourão**  
>Autor: **Prof. Dr. Luiz Arthur Feitosa dos Santos**  
>E-mail: **<luizsantos@utfpr.edu.br>**  

A seguir serão apresentados os comandos necessários para a instalação e configuração do servidor FTP vsftpd no OpenBSD. Também será apresentado o conceito do servidor de servidores inetd, bem como configurar o vsftpd via inetd. Por fim, é apresentado o SSH, que substitui TELNET e FTP, pois é mais seguro.

# FTP


## Introdução

O FTP é um servidor de arquivos, atualmente é mais comum em ambientes WAN, tal como a Internet. Neste caso será instalado, configurado e utilizado o servidor vsftpd.

## Instalação:

O vsftpd já vem instalado por padrão no OpenBSD, então não é necessário instalar.

## Iniciando:

```console
# /etc/rc.d/vsftpd start
```

Depois de iniciar é bom verificar se o servidor está em execução:

```console
# netstat -a -p tcp
Active Internet connections (including servers)
Proto   Recv-Q Send-Q  Local Address          Foreign Address        (state)
tcp          0      0  localhost.9968         localhost.ftp          TIME_WAIT
tcp          0      0  192.168.56.112.ssh     192.168.56.1.41218     ESTABLISHED
tcp          0      0  localhost.smtp         *.*                    LISTEN
tcp          0      0  *.ssh                  *.*                    LISTEN
tcp          0      0  *.ftp                  *.*                    LISTEN
Active Internet connections (including servers)
Proto   Recv-Q Send-Q  Local Address          Foreign Address        (state)
tcp6         0      0  *.ssh                  *.*                    LISTEN
tcp6         0      0  localhost.smtp         *.*                    LISTEN
tcp6         0      0  fe80::1%lo0.smtp       *.*                    LISTEN
```

No caso seguinte  linha, da saída anterior, indica que o servidor está em execução, pois apresenta a porta do FTP no estado de ``LISTEN``:

```console
tcp          0      0  *.ftp                  *.*                    LISTEN
```

## Habilitando no *boot*:

Para que o vsftpd inicie junto com o *boot* da máquina basta executar:

```console
# rcctl enable vsftpd
```

## Arquivo de configuração:

O arquivo de configuração do vsftpd no OpenBSD é o ``/etc/vsftpd.conf``. Há várias opções para se configurar um servidor vsftpd, as principais são:

* **anonymous_enable=YES**: habilita um usuário anonimo para acessar o servidor FTP, sem senha.
* **local_enable=YES**: permite que usuários locais do sistema acessem o servidor FTP, utilizando seus logins/senhas.
* **write_enable=NO**: dá acesso de gravação aos servidor FTP - isso pode ser perigoso.
* **chroot_local_user=YES** e **chroot_list_enable=YES**: deixa o acesso apenas para os usuários que estejam na lista de chroot.
* **listen=YES**: configura se o servidor vai ser executado de forma independente (*standalone*) ou via inetd.

## Teste:

Para testar o servidor FTP, é possível utilizar um navegador Web. Contudo, também é dá para utilizar no próprio OpenBSD ou sistemas UNIX-Like o comando ftp. Exemplo:

```console
# ftp 127.0.0.1        
Connected to 127.0.0.1.
220 (vsFTPd 3.0.3)
Name (127.0.0.1:aluno): aluno
331 Please specify the password.
Password:
500 OOPS: vsftpd: refusing to run with writable root inside chroot()
ftp: Login aluno failed.
421 Service not available, remote server has closed connection.
ftp> exit
```

Isso demonstra que o servidor está funcionando, mas não foi possível acessá-lo, pois o usuário ``aluno`` não está configurado para acessar um ambiente chroot. Bem, há várias formas de se "corrigir" isso, por hora vamos apenas tornar o servidor funcional - **não** vamos fazer isso da forma mais segura (que era configurar o chroot).

Para que funcione o acesso ao servidor FTP para os usuários do sistema, basta ir no arquivo de configuração do vsftpd e comentar a seguinte linha:

``# vi /etc/vsftpd.conf ``

```console
#chroot_list_enable=YES
```

Após a alteração é possível acessar o servidor FTP:

```console
# ftp 127.0.0.1        
Connected to 127.0.0.1.
220 (vsFTPd 3.0.3)
Name (127.0.0.1:aluno): aluno
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp>
ftp> ls /
150 Here comes the directory listing.
drwxr-xr-x    2 root     wheel         512 Oct 12 16:34 altroot
drwxr-xr-x    2 root     wheel        1024 Oct 12 16:34 bin
-rw-r--r--    1 root     wheel       85968 Mar 02 16:52 boot
-rwx------    1 root     wheel    18677541 Mar 02 16:56 bsd
-rwx------    1 root     wheel    18688757 Mar 02 16:52 bsd.booted
-rw-------    1 root     wheel    10299545 Mar 02 13:50 bsd.rd
drwxr-xr-x    3 root     wheel       19456 Mar 02 16:55 dev
drwxr-xr-x   23 root     wheel        1536 Mar 02 18:41 etc
drwxr-xr-x    4 root     wheel         512 Mar 02 17:00 home
drwxr-xr-x    2 root     wheel         512 Oct 12 16:34 mnt
drwx------    3 root     wheel         512 Mar 02 16:52 root
drwxr-xr-x    2 root     wheel        1536 Oct 12 16:34 sbin
lrwxrwx---    1 root     wheel          11 Oct 12 16:34 sys -> usr/src/sys
drwxrwxrwt    6 root     wheel         512 Mar 02 18:43 tmp
drwxr-xr-x   17 root     wheel         512 Mar 02 18:09 usr
drwxr-xr-x   23 root     wheel         512 Oct 12 17:28 var
226 Directory send OK.
```

O servidor FTP é consideramo muito inseguro, assim quando se dá acessar a usuários via servidor FTP é altamente recomendável deixar esses usuários enjaulados (*jail*) dentro de seu diretório *home*, assim fica mais difícil de hackers conseguirem informações sensíveis, caso haja quebra de segurança do servidor FTP. Pois o hacker só terá acesso ao diretório *home* do usuário que ele invadiu. Isso é o conceito de chroot, que foi ignorado na configuração anterior.


## Configurando o acesso anônimo:

Atualmente o acesso via FTP se dá por um usuário anonimo e não com usuários do sistema, por mais estranho que pareça isso é mais seguro do que deixar os usuários acessarem o servidor FTP utilizando usuário/senha, já que o FTP passa essas via texto puro, então podem ser interceptadas e utilizadas por *hackers* para invadir o sistema.

Assim, vamos configurar o acesso do FTP por usuário anonimo. Para isso basta:


* Editar o arquivo de configuração e descomentar a linha que habilita o usuário anonimo:

```console
# vi /etc/vsftpd.conf
anonymous_enable=YES
```

* Reinicializar o servidor:

```console
# /etc/rc.d/vsftpd restart 
```

* Criar o usuário ftp no servidor OpenBSD:

```console
# adduser 
Use option ``-silent'' if you don't want to see all warnings and questions.

Reading /etc/shells
Check /etc/master.passwd
Check /etc/group

Ok, let's go.
Don't worry about mistakes. There will be a chance later to correct any input.
Enter username []: ftp
Enter full name []: 
Enter shell csh ksh nologin sh [nologin]: 
Uid [1001]: 
Login group ftp [ftp]: 
Login group is ``ftp''. Invite ftp into other groups: guest no 
[no]: 
Login class authpf bgpd daemon default pbuild staff unbound 
[default]: 

Name:        ftp
Password:    ****
Fullname:    ftp
Uid:         1001
Gid:         1001 (ftp)
Groups:      ftp 
Login Class: default
HOME:        /home/ftp
Shell:       /sbin/nologin
OK? (y/n) [y]: y
```

Neste ponto já seria possível acessar o ftp anonimamente, se não fosse o sistema de segurança do OpenBSD/vsftpd que por padrão só permite que o usuário ftp/anonimo acesse o servidor utilizando o ambiente chroot. Neste caso, ao contrário do que fizemos com os outros usuários não é recomendável permitir que usuários anônimos fiquem navegando pelo sistema de arquivos do servidor, então vamos deixar o usuário ftp configurado para acessar o servidor enjaulado (via chroot). 

Então sem nenhuma outra configuração o acesso via anonimo não é permitido e fica assim:

```console
# ftp 127.0.0.1        
Connected to 127.0.0.1.
220 (vsFTPd 3.0.3)
Name (127.0.0.1:aluno): ftp
331 Please specify the password.
Password:
500 OOPS: vsftpd: refusing to run with writable root inside chroot()
ftp: Login ftp failed.
421 Service not available, remote server has closed connection.
```

Para que o usuário ftp possa usar o vsftpd dentro do chroot é necessário o próximo passo:

* Mudar a permissão de gravação do diretório home do usuário ftp:

```console
# chmod a-w /home/ftp/
```

Após essa configuração, que remove o direito gravação/escrita é possível acessar o servidor vsftpd com o usuário anonimo/ftp.

```console
# ftp 127.0.0.1
Connected to 127.0.0.1.
220 (vsFTPd 3.0.3)
Name (127.0.0.1:aluno): ftp
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
150 Here comes the directory listing.
226 Directory send OK.
ftp> ls ../
150 Here comes the directory listing.
226 Directory send OK.
ftp> ls /
ftp> cd /
250 Directory successfully changed.
ftp> ls
150 Here comes the directory listing.
226 Directory send OK.
```

Na saída anterior, foram dadas alguns comandos tentando acessar outras partes do sistema de arquivos do servidor FTP, mas essas não tiveram sucesso devido ao chroot.


# Inetd

## Instalação:

O inetd já vem instalado por padrão no OpenBSD.

## Arquivo de configuração:

O OpenBSD não traz um arquivo de configuração de exemplo, assim é preciso criar um do zero.
Para este caso vamos colocar o vsfstpd (instalado anteriormente) para ser executado via inetd.

```console
# cat /etc/inetd.conf                                                                                                      
ftp stream tcp nowait root /usr/local/sbin/vsftpd -olisten=NO
```
No arquivo de configuração no vsftpd:

```console
# vi /etc/vsftpd.conf
listen=NO
```

## Iniciando:

```console
# /etc/rc.d/inetd -f start
```

# TELNET

O TELNET é um servidor de terminal, ou seja, muito utilizado para utilizar e/ou controlar máquinas remotamente. O TELNET ainda é muito utilizado em ambientes de rede, todavia é altamente recomendado substituí-lo pelo SSH (visto mais adiante) por questões de segurança, pois o TELNET passa os dados texto puro na rede e fica muito vulnerável para ataques de captura de pacotes.

> **Atenção**, a principio o servidor TELNET não está sendo disponibilizado para o OpenBSD, provavelmente por motivos de segurança - pelo menos o professor não achou o telnetd nem com o ``pkg_info`` nem no ``ports``.


# SSH

# Referências

* <https://www.liquidweb.com/kb/error-500-oops-vsftpd-refusing-to-run-with-writable-root-inside-chroot-solved/>
* <https://www.linuxquestions.org/questions/linux-newbie-8/500-oops-could-not-read-chroot-list-file-etc-vsftpd-chroot_list-4175426540/>
