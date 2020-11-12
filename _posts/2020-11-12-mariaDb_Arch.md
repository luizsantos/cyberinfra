Instalando e configurando o MariaDB no Manjaro/Arch Linux
====================================================

Instalação do MariaDB no Manjaro, que é uma derivação do Arch Linux

# Instalação

Comando para instalar:

```console
$ sudo pacman -S mariadb
```

# Configuração

Configuração inicial:
```console
$ sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
```

## Iniciando o MariaDB
Agora é necessário iniciar o banco de dados:

```console
$ sudo systemctl start mariadb
```

Se for para habilitar esse serviço no boot da máquina execute:
```console
$ sudo systemctl enable mariadb
```

# Configuração necessária, com o banco já em execução:

```console
$ sudo mysql_secure_installation
```

Neste comando anterior vai ser pedido a senha do administrador (``root``) e uma nova senha, minha saída/entrada foi:

```console
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none): 
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] 
Enabled successfully!
Reloading privilege tables..
... Success!


You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] 
New password: 
Re-enter new password: 
Password updated successfully!
Reloading privilege tables..
... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] 
... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] n
... skipping.

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] n
... skipping.

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] 
... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

## Configuração se for usar na rede:

Se for usar o MariaDB via rede:

```console
$ sudo vi /etc/my.cnf.d/server.cnf
```

Inclua e ou altere a linha:
```console
bind-address=127.0.0.1
```

>> Ah, se for acessar a partir de outro IP, que não o 127.0.0.1, altere a configuração para ``bind-address=0.0.0.0``, para dar acesso a qualquer IP. Se quiser mais segurança coloque o IP da sua rede local ao invés do endereço 0.0.0.0.

Se fizer essa alteração lembre de reiniciar o MariaDB novamente:

```console
$ sudo systemctl restart mariadb
```

# Teste o banco de dados

Uma forma de testar o banco de dados é realizando o acesso ao mesmo, com o seguinte comando:

```console
$ mysql -h 127.0.0.1 -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \textbackslash\{\}g.
Your MariaDB connection id is 3
Server version: 10.5.6-MariaDB Arch Linux

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\textbackslash\{\}h' for help. Type '\textbackslash\{\}c' to clear the current input statement.

MariaDB [(none)]> quit
Bye
```
Se a saída parecida com essa, significa que a instalação funcionou! ;-)


# Mais uma configuração para acesso à rede

Ainda quanto ao acesso remoto usando IPs que não o 127.0.0.1, pode ser é necessário dar permissões no próprio banco para o usuário acessar de um dado IP. Para isso utilize o comando anterior (``mysql -h 127.0.0.1 -u root -p``) para acessar o banco e depois execute:

```console
GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.%.%' IDENTIFIED BY 'sua_senha' WITH GRANT OPTION;
```
Neste caso estamos deduzindo que o usuário é ``root``, a rede é 192.168.0.0/16 e a senha ``sua_senha``, troque isso conforme seus dados. Então será possível acessar o banco de dados via rede, tal como:

```console
$ mysql -h 192.168.0.1 -u root -p
```
Neste exemplo o servidor é o ``192.168.0.1`` e o usuário é o ``root``.

Bem, é isso... o MariaDB deve estar funcionando.

# Referência

* <https://mariadb.com/kb/en/configuring-mariadb-for-remote-client-access/>.