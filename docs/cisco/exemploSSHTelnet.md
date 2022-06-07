 
# Ativando SSH ou Telnet em dispositivos CISCO

Após realizar as configurações básicas (endereço IP, máscara,  gateway,  etc) em roteadores ou *switches*, localmente via cabo console,  é bem provável que o administrador de rede queira ativar algum tipo de serviço que permita realizar configuração/manutenção remota, via rede local ou Internet.

Esse acesso remoto à roteadores e *switches* é possível graças a serviços como Telnet ou SSH. Assim,  ativar serviços como SSH ou telnet,  são ações muito comuns para administradores de rede.

A seguir são apresentados exemplos de comandos utilizados para configurar SSH em um modelo de roteador CISCO 7200 e Telnet em um *switch* CISCO 3640. O cenário de rede apresentado na Figura 1 será utilizado para ilustrar e como base para esse exemplo.

| ![dhcp1](imagens/sshTelnet) |
|:--:|
| **Figura 1- Rede com roteador 7200 com SSH e 3640 com Telnet** |


> Na verdade o CISCO 3640 é um switch camada 3, mas aqui estava levando em conta que ele é apenas um switch comum.

## Configuração do servidor SSH no CISCO 7200

A seguir são apresentados os comandos necessários para configurar um roteador CISCO 7200 como servidor SSH. E desta forma acessá-lo remotamente via rede TCP/IP.

### O primeiro passo é configurar a interface de rede:

Aqui é dado o IP 192.168.0.254, que será utilizado para acessar o roteador via SSH da rede local.

```console
R1#configure terminal
R1(config)#interface f0/0
R1(config-if)#ip address 192.168.0.254 255.255.255.0
R1(config-if)#no shutdown
```

> Aqui é não é apresentado como configurar a interface de rede da Internet, que teria provavelmente a configuração do *gateway* padrão e DNS. Todavia isso seria necessário para que o roteador seja acessado de outras redes.

### O segundo passo é configurar a chave criptográfica

O SSH utiliza criptografia para transmissão de dados segura, assim neste passo é necessário configurar/criar chaves criptográficas para essa conexão segura entre roteador e clientes. Isso é feito com o comando ``crypto key generate rsa``, todavia para essa chave ser criada é necessário dar um nome ao roteador, bem como domínio (respecitvamente os comandos ``hostname`` e ``ip domain name``).

```console
R1(config-if)#hostname R1
R1(config)#ip domain name teste.com.info
R1(config)#crypto key generate rsa
  The name for the keys will be: R1.teste.com.info
  Choose the size of the key modulus in the range of 360 to 2048 for your
  General Purpose Keys. Choosing a key modulus greater than 512 may take
  a few minutes.

  How many bits in the modulus [512]: 2048
  % Generating 2048 bit RSA keys, keys will be non-exportable...[OK]
  *Jun  7 18:24:51.371: %SSH-5-ENABLED: SSH 1.99 has been enabled
R1(config)#
```
### O terceiro passo é criar usuários e senhas

O SSH é antes de mais nada um servidor de terminal remoto, para acesso a esse terminal é necessário usuário e senha. Assim, é necessário utilizar o comando ``#username`` para, neste exemplo, criar o usuário *admin* com a senha *123mudar*. Também é altamente recomendável criar uma senha para que um usuário altere para o usuário administrador (terminal com o ``#``), isso é feito com o comando ``enable password``.

```console
R1(config)#enable password 123mudar
R1(config)#username admin password 123mudar
```

> Note que nestes exemplos utilizamos usuários como *admin* e senhas como *123mudar*, é claro que em equipamentos em produção não devemos utilizar usuários tão conhecidos como *admin* e muito menos senhas fracas como *123mudar*.

### O quarto passo é ativar o SSH na versão 2

Agora só resta ativar o SSH versão 2 (a versão padrão aqui foi a versão 1.9 - ver saída do passo 2), isso é feito com o comando ``ip ssh version 2``. Depois é necessário atrelar o SSH as linhas de terminal do roteador CISCO, com os comandos seguintes:

```console
R1(config)#ip ssh version 2
R1(config)#line vty 0 15
R1(config-line)#transport input ssh
R1(config-line)#login local
R1(config-line)#end
R1#
```

Feita as configurações dos passos anterior o servidor SSH do roteador 7200 da CISCO deve estar funcional.

## Acesso do cliente ao roteador com SSH

Com o servidor SSH ativo no roteador CISCO 7200 é possível utilizar programas como o [PUTTY](https://www.putty.org/)no Windows ou o comando ``ssh`` do Linux para realizar acesso e gerenciar esse roteador remotamente.

No caso do Linux, para esse modelo de roteador (7200), foi necessário utilizar o comando ``ssh`` com alguns parâmetros extras. Veja a seguir o comando executado do Host-1 do cenário apresentado na Figura 1.

```console
root@Host-1:/# ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -c aes256-cbc admin@192.168.0.254
The authenticity of host '192.168.0.254 (192.168.0.254)' can't be established.
RSA key fingerprint is SHA256:igOk2UFDsxWSOuASFpPR/F4mnzhbiVPGG4rCS8g2CNk.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.0.254' (RSA) to the list of known hosts.
Password:

R1>enable
Password:
R1#
```
> Os parâmetros extras são necessários, pois o roteador CISCO em questão apresenta um conjunto de opções de configuração SSH, que é diferente do padrão utilizado pelo ``ssh`` do Linux utilizado no exemplo.

## Configuração do servidor Telnet no CISCO 3640

O Telnet é um protocolo legado, que não deve ser utilizado por enviar dados via texto puro para a rede - e isso é um grande problema de segurança. Por isso **devemos utilizar o SSH ao invés do Telnet**. Todavia, há casos em que o SSH não está disponível - sistemas legados - como é o caso do CISCO 3640 do exemplo em questão, que só possui Telnet.

> Neste caso, para melhorar a segurança, é altamente recomendável criar redes isoladas (VLAN), só para acessar esses equipamentos via Telnet.

Os passo para ativar o CISCO 3640 são bem similares aos passo do SSH do CISCO 7200. Só que não é necessário criar chaves criptográfica, já que o Telnet não utiliza. Assim, vamos ver os comandos necessário no exemplo a seguir:

### O primeiro passo é configurar interface de rede

Como estamos utilizando o CISCO 3640 como se fosse um *switch* comum (não camada 3), devemos atribuir IP a uma VLAN, neste caso foi escolhida a VLAN padrão (que é a VLAN 1) e nesta foi atribuída o IP 192.168.0.253:

```console
L3_Sw1#enable
L3_Sw1#configure terminal
Enter configuration commands, one per line.  End with CNTL/Z.
L3_Sw1(config)#interface vlan 1
L3_Sw1(config-if)#ip address 192.168.0.253 255.255.255.0
L3_Sw1(config-if)#no shutdown
```

### O segundo passo é criar usuários/senhas

O Telnet é um protocolo de acesso remoto baseado em usuário e senha. Assim, o comando ``user`` deve ser utilizado para criar usuári e senha no *switch*. Também é altamente recomendável criar uma senha para alterar de usuário comum para usuário administrador (``enable password``):

```console
L3_Sw1(config-if)#enable password 123mudar
L3_Sw1(config)#user admin password 123mudar
```

### O quarto passo é ativar o Telnet

Por fim, é necessário atrelar o Telnet aos terminais de acesso do *switch*:

```console
L3_Sw1(config)#line vty 0 15
L3_Sw1(config-line)#transport input telnet
L3_Sw1(config-line)#login local
L3_Sw1(config-line)#end
L3_Sw1#
```
Feitos esses passos o *switch* pode ser administrador via rede utilizando-se o protocolo Telnet.


## Acesso do cliente ao roteador com SSH

Com o servidor Telent ativo no *switch* CISCO 36400 é possível utilizar programas como o [PUTTY](https://www.putty.org/)no Windows ou o comando ``telnet`` do Linux para realizar acesso e gerenciar esse *switch* remotamente.

No caso do Linux, o acesso via telnet do Host-2 (ver Figura 1) é feito tal como:

```console
root@Host-2:/# telnet 192.168.0.253
Trying 192.168.0.253...
Connected to 192.168.0.253.
Escape character is '^]'.

User Access Verification

Username: admin
Password:
L3_Sw1>enable
Password:
L3_Sw1#
```

> **Atenção**, novamente é válido lembrar que só devemos utilizar o telnet em último caso, pois é um protocolo inseguro e deve ser substituído pelo SSH.
