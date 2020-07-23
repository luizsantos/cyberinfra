Comandos de rede úteis
======================

Atualmente muitas distribuições Linux descontinuaram os comandos ``ifconfig``, ``route`` e ``netstat``.
Assim, aqui irei apresentar alguns comandos de rede úteis, principalmente relacionados aos novos comandos, apresentados nas distribuições Linux mais atuais. 

## Desligando o gerenciador de rede 

As vezes é necessário desligar o gerenciador de rede ``NetworkManager``, para realizar algumas operações ou teste mais incomuns na rede. Para desligar o gerenciador de rede no Arch Linux, execute:

```console
# systemctl stop NetworkManager
```

Para ligar, reiniciar, habilitar no _boot_  ou desabilitar no _boot_, basta substituir respectivamente o ``stop``, por: ``start``, ``restart``, ``enable`` e ``disable``.

## Fazendo _scan_ em interfaces WiFi

Para fazer _scan_ eu recomendo desativar o ``NetworkManager``:

```console
# systemctl stop NetworkManager
```
> Recomendo desligar o ``NetworkManager``, pois as configurações do gráfico podem sobrepor automaticamente as configurações que você está fazendo no texto. Isso pode gerar grandes transtornos. Só deixe o ``NetworkManager`` ligado se você espera utilizar as configurações do ambiente gráfico.

Algumas vezes, após desligar o ``NetworkManager``, a placa de rede pode ficar desligada, não permitindo o uso desta, isso pode ser revertido via linha de comando, com o ``rfkill``.

Exemplo: Tentando ativar a placa de rede sem fio, com o comando ``ip link`` com a placa desligada a saída seria algo assim:

```console
# ip link set wlp2s0 up
RTNETLINK answers: Operation not possible due to RF-kill
```
É possível verificar se a placa de rede está desligada utilizando o comando ``rfkill``:

```console
# rfkill list all
0: hci0: Bluetooth
        Soft blocked: no
        Hard blocked: no
1: phy0: Wireless LAN
        Soft blocked: yes
        Hard blocked: no
```

Observe a penúltima linha ``Soft blocked: yes``, isso indica que a placa está desligada. Neste caso é necessário ligar a placa de rede da seguinte forma:

```console
rfkill unblock 1
```

Sendo ``1`` o número referente a placa de rede sem fio, da saída do comando ``rfkill list``.

Feito isso agora é só ativar a placa de rede com o comando ``ip link``:

```console
ip link set wlp2s0 up
```

Finalmente é possível listar as redes sem fio, com o comando ``iwlist``:

```console
iwlist wlp2s0 scan
```

## Referências

* <https://bbs.archlinux.org/viewtopic.php?pid=1324810#p1324810>
