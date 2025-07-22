---
layout: page
title: DOCS
---


Aqui estão alguns documentos, tal como tutoriais a respeito de como instalar, configurar, executar e testar ativos digitais. Como por exemplo: sistemas operacionais, servidores de redes, firewalls, etc...

A ideia é apresentar mais a prática, mas tentando casar com um pouco de teoria. ;-)

-----------------------


# Sistemas Operacionais
* OpenBSD
	* [Alguns comandos OpenBSD](OpenBSDServers/OpenBSD_comandos)
* NetBSD
    * [Configuração básica do NetBSD](NetBSD/nbsd)
* Outros
	* [Windows acessando o ambiente gráfico do Linux via SSH](VMs/configurarVMWindows)
	* [MacOS acessando o ambiente gráfico do Linux via SSH](VMs/configurarVMMac)
	* [Virtualização Nested](VMs/configurarNestedVM)

* Virtualização
    * [Introdução à virtualização](virtualization/virtualization)
    * Introdução à Docker
		* [Container](docker/docker-container)
		* [Imagens](docker/docker-imagens)
		* [Tarefas](docker/docker-tarefas)
		* [Rede](docker/docker-rede)

# Redes de Computadores
* Configuração básica de rede:
	* [Introdução](confBasicaRedes/introConfRedeHost)
	* [Linux](confBasicaRedes/linux/linuxConfRedeHost)

* IPv6:
    * [Rede básica no Linux](ipv6/ipv6_redeBasica)
    * [Rede OSPF, RIP e BGP](ipv6/ipv6_roteamento)

* Servidores no OpenBSD:
	* [DHCP](OpenBSDServers/dhcp)
    * [Apache HTTP](OpenBSDServers/HTTP)
	* [FTP](OpenBSDServers/FTP)
	* [BIND](DNS/DNS)
	* [NFS](OpenBSDServers/nfsd)
	* [NAT](OpenBSDServers/nat)

	* [QoS](QoS/QoS)

* CISCO
	* [VLAN](cisco/vlan)
	* [Outras configurações em switches](cisco/algumasConfSws)
	* [Configurando acesso remoto](cisco/ativarSSH)
	* [Telnet e SSH em roteador/switch](cisco/exemploSSHTelnet)
	* [DHCP](cisco/dhcp-cisco)
	* [NAT](cisco/exemploNAT)

	* BGP
		* [eBGP](cisco/bgp-egp1)
		* [iBGP](cisco/bgp-igp1)

* Mikrotik
	* [Configuração de rede básica](mikrotik/confRede)

* Juniper
	* [Configuração básica dos roteadores](juniper/router)

# Cibersegurança
* [PenTesting](penTest/pentest)
	* [Escaneamento com Nmap](penTest/nmap)
	* [Ganhando Acesso com Metasploit](penTest/metaexploit)
		* [SQL Injection](penTest/sqli)
		* [Quebrando senhas](penTest/passwordCracking)
