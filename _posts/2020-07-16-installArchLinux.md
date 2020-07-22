Trocando de Distro Linux
==========================

Bem, a mais de uma década eu utilizo o [Slackware Linux](http://www.slackware.com/), pois é um Linux muito estável. Todavia, já tem algum tempo que o Slackware vem deixando a desejar nas atualizações. Assim, decidi mudar um pouco de distribuição em minhas máquinas pessoais.

Depois de algumas pesquisas, comecei a utilizar o [Manjaro Linux](ttps://manjaro.org/) no meu _notebook_. Contudo, o Manjaro ficou muito pesado no meu _netbook_. Assim, decidi utilizar o [Arch Linux](https://www.archlinux.org/) no _netbook_, que é a base do Manjado.

O Arch Linux, tal como o Slackware, é um Linux muito estável, mas não é muito "amigável" com iniciantes. Ao meu ver, a grande vantagem do Arch sobre o Slackware, é o seu gerenciador de pacotes (``pacman``) e sua grande comunidade, que gera uma ótima documentação.

Então, vou deixar aqui os passos para a instalação do Arch Linux em um _netbook_ Asus EeePC 1201PN (processador Aton+NVidia ION).

# Preparação

Inicie baixando o Arch Linux x86_64. Exemplo: 

```console
wget http://archlinux.pop-es.rnp.br/iso/2020.07.01/archlinux-2020.07.01-x86_64.iso
```

Copie o arquivo para um _pendrive_. Bem, eu não usei o ``dd``, fiz um ``cp`` direto, isso tem funcionado bem.


```console
cp archlinux-2020.07.01-x86_64.iso /dev/sdX
```

No comando anterior, você deve trocar ``sdX``, pelo nome do dispositivo relacionado com o seu _pendrive_. Uma forma de verificar isso é usando o comando ``lsblk``.

Terminando a cópia é só dar _boot_ pelo _pendrive_/USB.


# Instalação

Agora são apresentados os passos de instalação e algumas configurações:

## Configuração do teclado: 

Dá para iniciar configurando o teclado, mas como o EeePC tem o teclado inglês, isso não é tão necessário.

## Configuração da rede

No meu caso eu usei cabo de rede e quando dei _boot_ o DHCP já atribuiu um IP. Caso isso não aconteça, é possível utilizar o ``wifi-menu``, no caso de utilizar a rede sem fio, ou colocar o cabo e digitar ``dhcpcd``.

## Particionando disco(s)

O próximo passo é particionar o HD/SSD, no meu caso utilizei o ``cfdisk``, e criei pelo menos três partições:

1. 3GiB, para o ``/``;
2. 20GiB, para o ``/usr``;
3. 7GiB, para o ``/home``;
4. 5GiB, para o ``/var``;
5. 8GiB, para o ``/opt``.

	>  Tenho o costume de deixar o HD, com uma partição para cada diretório importante - coisas de segurança. Mas, para uso pessoal, isso não é necessário.
	
	>  __Atenção__, particonar o seu HD irá fazer com que você perca todos os dados das partições em questão, então muito cuidado.

## Formatando as partições

Depois de particionar é necessário formatar, exemplo:

```console
mkfs.ext4 -L boot /dev/sda3
mkfs.ext4 /dev/sda5
mkfs.ext4 /dev/sda6
mkfs.ext4 /dev/sda8
mkfs.ext4 /dev/sda9
```
> __Atenção__, todos os dados nas partições formatadas serão perdidos.

## Adicionando a _swap_


```console
mkswap -L swap /dev/sda2
mkswapon /dev/sda2
```

## Montando as partições para a instalação:

Primeiro temos que montar a partição principal:

```console
mount /dev/sda3
```

Depois é necessário criar diretórios e montar as outras partições, caso você tenha criado várias partições:

```console
mkdir /mnt/usr && mount /dev/sda5 /mnt/usr
mkdir /mnt/home && mount /dev/sda6 /mnt/home
mkdir /mnt/var && mount /dev/sda8 /mnt/var
mkdir /mnt/opt && mount /dev/sda9 /mnt/opt
```


## Instalando o sistema base

Agora vem a parte de copiar os arquivos base para o sistema funcionar. Eu aproveitei e já instalei editor de texto e o cliente DHCP, para facilitar o processo.

```console
pactrap /mnt base base-devel linux linux-firmware vi vim sudo man-db dhcpcd
```

## Gerando o ``fstab``

Com os arquivos de sistema prontos, podemos criar o arquivo que relaciona as partições criadas com os seus respectivos diretórios: 

```console
genfstab -p /mnt >> /mnt/etc/fstab
```

Bem, eu ainda editei e deixei o arquivo deixando o conteúdo da seguinte forma:


```console
/dev/sda3               /               ext4            defaults        0 1
/dev/sda6               /home           ext4            rw,relatime     0 2
/dev/sda5               /usr            ext4            defaults        0 2
/dev/sda8               /var            ext4            rw,relatime     0 2
/dev/sda9               /opt            ext4            rw,relatime     0 2
/dev/sda2               none            swap            defaults        0 0
```

## Preparando o sistema de arquivos novo

Com os passos anteriores terminados, agora é possível acessar o sistema novo, via ``chroot``, isso ajuda a terminar as configurações.

```console
arch-chroot /mnt
```

## Configurando alguns detalhes

Já em ambiente ``chroot``, vamos fazer algumas configurações básicas:

### Criando chaves para verificação de pacotes

Criando as chaves para verificar/manter a integridade dos pacotes instalados:

```console
pacman-key --init
pacman-key populate archlinux
```

### Configurando os acentos:

Como português precisa de acentos, é bom configurar a linguagem:

Edite o arquivo ``/etc/locale.gen``, deixando com o seguinte conteúdo (pode apenas comentar o que tiver e descomentar essa linha):

```console
pt_BR.UTF-8 UTF-8
```

Edite o arquivo ``cat /etc/locale.conf`` e deixe com o seguinte conteúdo:
 
```console
LANG=pt_BR.UTF-8
```

Então execute:

```console
locale-gen
```

### Configurando data/hora

Para ajustar a hora/data do sistema crie o arquivo de fuso horário:

```console
ls -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
```

Sincronize o relógio do computador com o do sistema:

```console
hwclock --systohc
```

### Dando nome ao sistema/host

É bom dar um nome para a máquina, então edite o arquivo ``/etc/hostname``, colocando o nome do computador, no meu caso foi:

```console
fielAsus
```

Edite também o arquivo ``/etc/hosts``, deixando ele mais ou menos assim - troque o último campo pelo nome do seu computador:

```console
127.0.0.1       localhost
::1             localhost
127.0.0.1       fielAsus
```

## Criando um _ramdisk_ inicial

É necessário criar um arquivo _ramdisk_ inicial. Principalmente nesta instalação que utiliza o  ``/usr`` em uma partição diferente do ``/`` - é obrigatória uma configuração especial.

> Atenção, sem essa configuração especial, por causa do ``/usr`` separado, o sistema não dá _boot_.

Edite o arquivo `/etc/mkinitcpio.conf` e altere a linha a seguir incluindo os campos: ``usr`` e ``shutdown`` - o ``fsck`` também deve estar lá.

```console
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck usr shutdown)
```

Depois execute o comando para criar o _ramdisk_:

```console
mkinitcpio -p linux
```

## Instalando o gerenciador de _boot_

É recomendável ter um gerenciador de _boot_, então instale o ``grub`` no sistema:

```console
pacman -S grub
```

Agora instale o grub no HD/SSD:

```console
grub-install --target=i386-pc --recheck --debug /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

## Defina senha do _root_

Para finalizar a instalação básica, não esqueça de colocar uma senha para o usuário _root_

```console
passwd
```


## Reinicie o sistema

Pronto, o sistema está finalizado, agora é só sair do ambiente ``chroot`` (``exit``) e reiniciar o sistema:

```console
reboot
```

Depois disso ele deve dar _boot_ pelo sistema novo, recém instalado! ;-)

------------------

# Instalando driver da placa de vídeo e ambiente gráfico

Aqui são apresentados os passos para a instalação e configuração do ambiente gráfico, caso a instalação seja para um servidor o ambiente gráfico não é necessário. 

## Instalando Xorg

Bem, inicie instalando o Xorg:

```console
pacman -S xorg-server xorg-xinit
```

### Instalando o driver da placa de vídeo ION Nvidia

A placa ION, não está mais no repositório oficial do Arch, mas está no repositório da comunidade, uma boa forma de fazer uso desse repositório é com o comando ``yay``, então vamos instalá-lo:

> Isso deve ser feito com um usuário normal (não _root_), mas tal usuário deve ter permissão de executar o ``sudo``.

```console
sudo pacman -S git go base-devel
git clone https://aur.archlinux.org/yay.git
cd yay/
makepkg -si
yay -S nvidia-340xx
yay -S nvidia-340xx
yay -S nvidia-340xx-utils
yay -S nvidia-340xx-settings
```

### Instalando o gerenciador de janelas - Xfce

Para o _netbook_ não ficar muito pesado, instalamos o Xfce, o gerenciador de _login_ gráfico ``lightdm`` e habilitamos o gerenciador de _login_ no _boot_:

```console
pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter networkmanager network-manager-applet
systemctl enable lightdm
```

### Configurando o Xorg com o _driver_ da placa de rede

O comando a seguir deve criar o arquivo do Xorg e fazer uma cópia de segurança do arquivo anterior:

```console
nvidia-xconfig 
```
### Ativando o gerenciador de rede gráfico

Para ficar com um ambiente mais amigável, vamos ativar o gerenciador de rede:

```console
systemctl enable NetworkManager
```

Pronto, com essa instalação ao iniciar o ambiente gráfico o _netbook_ conseguirá reconhecer monitores e atribuir suas respectivas configurações.

Agora, é só instalar os pacotes extras que você precisa usando o ``pacman``.

# Referências

Segue:

* <https://forum.archlinux-br.org/viewtopic.php?id=3624>;
* <https://serverfault.com/questions/723609/moving-usr-on-archlinux>;
* <https://wiki.archlinux.org/index.php/Mkinitcpio#/usr_as_a_separate_partition>;
* <https://linuxdicasesuporte.blogspot.com/2017/04/instalacao-do-xfce-no-arch-linux.html>.

-----------------------

>**UTFPR - Universidade Tecnológica Federal do Paraná, campus Campo Mourão**  
>Autor: **Prof. Dr. Luiz Arthur Feitosa dos Santos**  
>E-mail: **<luizsantos@utfpr.edu.br>** / **<luiz.arthur.feitosa.santos@gmail.com>**  



