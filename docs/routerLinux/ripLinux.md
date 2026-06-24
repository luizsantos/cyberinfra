'''console
RouterCISCO-2$enable
RouterCISCO-2#configure terminal
RouterCISCO-2(config)#interface f0/0
RouterCISCO-2(config-if)#ip address 10.0.0.20 255.255.255.0
RouterCISCO-2(config-if)#no shutdown
RouterCISCO-2(config-if)#interface f1/0
RouterCISCO-2(config-if)#ip address 192.168.121.20 255.255.255.0
RouterCISCO-2(config-if)#no shutdown
RouterCISCO-2(config-if)#exit
RouterCISCO-2(config)#router rip
RouterCISCO-2(config-router)#version 2
RouterCISCO-2(config-router)#network 10.0.0.0
RouterCISCO-2(config-router)#network 192.168.121.0
RouterCISCO-2(config-router)#end
'''
