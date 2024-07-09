---
layout: page
---

# Teste com iperf

Vamos testar o controle de banda usando o [Iperf](https://iperf.fr/). O Iperf é um software que testa a largura de banda/taxa de transferência de dados entre *hosts*.

Com o Iperf já instalado no OpenBSD com o controle de banda e em outro *host* qualquer:
1. **No OpenBSD**, execute um servidor ``iperf3`` com o seguinte comando:

```console
openbsd# iperf3 -s -p 8080
```

2. **Em outra máquina da rede** (não no OpenBSD com controle de banda), execute o cliente ``iperf3`` com o seguinte comando:

```console
cliente:~$ iperf3 -p 8080 -c 192.168.56.111 -t 30
```

> Neste exemplo o servidor (OpenBSD) tem o IP 192.168.56.111.

Para visualizar o resultado, durante o teste com o Iperf, a rede foi monitorada com o [Wireshark](https://www.wireshark.org/), que é um analisador de tráfego de rede. Neste caso foi criado um filtro para que o Wireshark só mostre tráfego TCP/8080 (``tcp.port==8080``).