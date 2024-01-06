---
layout: page
---

Virtualização
=============

No contexto da informática, a virtualização tem ganhado grande notoriedade ao longo das últimas décadas. Isso se deve ao fato da virtualização trazer muitos benefícios, tais como: 
* A facilidade de executar de forma isolada vários sistemas operacionais, dentro de um único computador físico; 
* Executar sistemas criados para determinado hardware/sistema operacional em outro sistema distinto e até mesmo incompatível; 
* Permitir a fácil migração de sistemas de um hardware de computador para outro, com um simples copiar de arquivo. Isso facilita, por exemplo, o gerenciamento de *datacenter* e ajuda na criação do conceito de nuvem (*cloud computer*).

Ao longo do tempo, a virtualização utilizou e ainda utiliza de várias técnicas, o que pode gerar alguma confusão na hora de definir o que é virtualização. Assim, a seguir, são apresentadas algumas definições para virtualização:  

* Segundo HUMBLE (2016), virtual significa algo que não é real, já na computação, virtual significa um ambiente de hardware que não é real. Assim, neste contexto da computação, a virtualização pode ser por exemplo, a execução de algum software em um hardware que é na verdade é um software fingindo ser um hardware.

* Já segundo CHAGANTI (2007), virtualização é a técnica de dividir recursos de um único servidor em múltiplos ambientes segregados. Desta forma, cada ambiente virtualizado pode ser executado independente dos outros ambientes. Assim é possível, por exemplo, que cada um desses ambientes execute um sistema operacional diferente.

* Conforme  WILLIANS(2007), virtualização é um *framework* ou metodologia para divisão de recursos do hardware do computador para múltiplos 
ambientes de execução. Isso é feito aplicando-se uma ou mais técnicas de particionamento de hardware e software, compartilhamento de tempo (*time-sharing*), simulação parcial ou completa da máquina, emulação, qualidade de serviço e muitas outras técnicas.

Então, resumidamente, a virtualização permite executar vários sistemas em um mesmo hardware, todavia cada um desses sistemas virtualizados terão a percepção que eles estão em um computador dedicado só para ele, só que isso não é necessariamente verdade.

## História

O conceito de virtualização não é novo, vem da década de 1960-70 e surgiu basicamente do conceito de compartilhamento de tempo (*time sharing*) e multiprogração. Sendo que o computador Atlas apresentou melhoras de desempenho devido a separação de algumas operações do Sistema Operacional em um componente chamado **supervisor**. Então, no Atlas, o *supervisor* gerenciava os recursos principais do computador para aprovisionar e gerenciar o ambiente computacional requeridos pelas chamadas de sistema dos programas de usuário. Desta forma, com o **supoervisor** do Atlas, surge o **_hypervisor_** ou **_Virtual Machine Monitor_ (VMM)**, que são utilizados na virtualização de hoje em dia. Já o projeto M44/44X da IBM, que utiliza arquitetura similar à do Atlas, foi o primeiro a utilizar o termo **_Virtual Machine_** **(VM)**, neste projeto foi utilizado o computador IBM 7044(M44) para executar VMs chamadas 44X, dai o nome M44/44X.

> Este texto irá constantemente utilizar a sigla **VM (Virtual Machine)** se referindo ao sistema que está sendo virtualizado.

## Tipos de virtualização:

Ainda conforme  CHAGANTI(2007), há basicamente três métodos principais para se fornecer virtualização: Emulação de sistema, Paravirtualização e Contêiner. Esses são explicados a seguir:

### 1. Emulação de Sistema 

Neste tipo de virtualização, o ambiente de execução é chamado de *Virtual Machime* (VM) e essa **emula todos os recursos de hardware**. Neste tipo de técnica o software que emula o hardware permite que o *guest*/hospede (nome dado ao sistema que está sendo virtualizado) seja executado sem nenhum tipo de alteração (sem que seja necessário alterar por exemplo, as chamadas de sistema, do Sistema Operacional do hospede). Tudo que o hospede precisa fazer, é repassado ao software que está emulando o hardware, que por sua vez repassa ao sistema operacional do computador físico, também chamado de *host*, anfitrião ou ainda hospedeiro. Essa é a técnica utilizada inicialmente no [VMWare Player](https://www.vmware.com/br/products/workstation-player.html) e [VirtualBox](https://www.virtualbox.org/).

<!-- | ![sem virtualização](img/semVirtualizacao.png) | -->

| <img src="img/semVirtualizacao.png" alt="image" width="40%" height="auto"> | 
|:--:|
| Figura 1 - Sistema sem virtualização |

| <img src="img/fullVirtualizacao.png" alt="image" width="40%" height="auto"> | 
|:--:|
| Figura 2 - Virtualização Completa/Full/Emulação |

### 2. Paravirtualização

Nesta técnica, em comparação à anterior, não há emulação de hardware, o que permite uma execução mais rápida, se comparada à técnica de emulação do hardware (já que é removido um intermediário de intercomunicação com o hardware - o software emulador). Todavia, nesta técnica, o sistema hospede precisa obrigatoriamente ser modificado para ser executado neste ambiente virtual, mas isso permite um aumento de desempenho para o hospede. Um exemplo de sistema que utiliza essa técnica é o [Xen](https://xenproject.org/); 

<!-- | ![Paravirtualização](img/paraVirtualizacao.png) | -->

| <img src="img/paraVirtualizacao.png" alt="image" width="40%" height="auto"> | 
|:--:|
| Figura 3 - Paravirtualização |

### 3. Contêiner 

ou Virtualização em Nível de Sistema Operacional**: Com a técnica de  **_container_**, cada hospede é executado em um ambiente isolado e seguro, todavia todos os hospedes devem ter o mesmo sistema operacional do hospedeiro - ou seja, não é possível executar um sistema operacional diferente do hospedeiro.
Por exemplo, se o hospedeiro utiliza o Sistema Operacional FreeBSD, todos os hospedes vão executar FreeBSD, não sendo possível neste caso, que o hospede execute um Linux, Windows, ou qualquer outro. Esta técnica é provavelmente a que tem menos *overhead* dentre as outras apresentadas.

<!-- | ![Contêiner](img/soVirtualizacao.png) | -->

| <img src="img/soVirtualizacao.png" alt="image" width="40%" height="auto"> | 
|:--:|
| Figura 4 - Contêiner |

Para muitas pessoas, há apenas dois métodos de virtualização: **VM** e **Container**. Sendo que VM se refere às técnicas de Emulação de Sistema e Paravirtualização. Já Container, seria a virtualização em Nível de Sistema Operacional, que está muito na moda quando o assunto é isolar microserviços. É claro que para leigos, tudo isso as vezes é chamado de VM ou simplesmente virtualização, mas agora sabemos que chamar de VM, pode estar errado, mas tudo isso com certeza é virtualização. 



# Referências

- HUMBLE DEVASSY CHIRAMMAL; PRASAD MUKHEDKAR; ANIL VETTATHU. Mastering KVM Virtualization. Birmingham: Packt Publishing, 2016. Disponível em: <https://research.ebsco.com/linkprocessor/plink?id=930abf25-3297-3717-805c-cc421b3b40db>. Acesso em: 29 dez. 2023.

- CHAGANTI, P. Xen Virtualization : A Fast and Practical Guide to Supporting Multiple Operating Systems with the Xen Hypervisor. Birmingham: Packt Publishing, 2007. Disponível em: <https://research.ebsco.com/linkprocessor/plink?id=7ededa0a-4250-3f01-b195-0945012c5333>. Acesso em: 29 dez. 2023.

- DAVID E. WILLIAMS. Virtualization with Xen(tm): Including XenEnterprise, XenServer, and XenExpress. Burlington, Mass: Syngress, 2007. Disponível em: <https://research.ebsco.com/linkprocessor/plink?id=9ad67e1a-3683-36ec-af22-648e304387a9>. Acesso em: 29 dez. 2023.
>> utilizar esse texto, tem a história

- CHAGANTI, P. Xen Virtualization : A Fast and Practical Guide to Supporting Multiple Operating Systems with the Xen Hypervisor. Birmingham: Packt Publishing, 2007. Disponível em: <https://research.ebsco.com/linkprocessor/plink?id=7ededa0a-4250-3f01-b195-0945012c5333>. Acesso em: 2 jan. 2024.

- <https://www.redhat.com/pt-br/topics/containers/containers-vs-vms>

- <https://www.pcmag.com/encyclopedia/term/paravirtualization>

- <https://blog.zwindler.fr/2016/08/25/when-should-we-have-containers/>
