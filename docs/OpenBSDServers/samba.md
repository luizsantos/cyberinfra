```console
# pkg_info -Q samba
```

```console
# pkg_add samba-4.17.7v0

quirks-6.121 signed on 2023-04-26T08:37:06Z
samba-4.17.7v0:tdb-1.4.7: ok
samba-4.17.7v0:libffi-3.4.4: ok
samba-4.17.7v0:sqlite3-3.41.0: ok
...
samba-4.17.7v0: ok
The following new rcscripts were installed: /etc/rc.d/messagebus /etc/rc.d/nmbd /etc/rc.d/samba /etc/rc.d/saslauthd /etc/rc.d/smbd /etc/rc.d/winbindd
See rcctl(8) for details.
New and changed readme(s):
	/usr/local/share/doc/pkg-readmes/dbus
	/usr/local/share/doc/pkg-readmes/libinotify
	/usr/local/share/doc/pkg-readmes/samba
```

```console
obsd2023# cp /etc/samba/smb.conf /etc/samba/smb.conf-def
obsd2023# vi /etc/samba/smb.conf
obsd2023# mkdir /mnt/empresa
obsd2023# touch /mnt/empresa/teste.txt
obsd2023# vi /etc/samba/smb.conf
obsd2023# rcctl start samba
smbd(ok)
nmbd(ok)


obsd2023# groupadd empresa
obsd2023# adduser
Use option ``-silent'' if you don't want to see all warnings and questions.

Reading /etc/shells
Check /etc/master.passwd
Check /etc/group

Ok, let's go.
Don't worry about mistakes. There will be a chance later to correct any input.
Enter username []: joao
Enter full name []:
Enter shell csh ksh nologin sh [ksh]:
Uid [1002]:
Login group joao [joao]: empresa
Login group is ``empresa''. Invite joao into other groups: guest no
[no]:
Login class authpf bgpd daemon default pbuild staff unbound vmd xenodm
[default]:
Enter password []:
Enter password again []:

Name:	     joao
Password:    ****
Fullname:    joao
Uid:	     1002
Gid:	     1002 (empresa)
Groups:	     empresa
Login Class: default
HOME:	     /home/joao
Shell:	     /bin/ksh
OK? (y/n) [y]:
Added user ``joao''
Copy files from /etc/skel to /home/joao
Add another user? (y/n) [y]: no
Goodbye!
obsd2023# smbpasswd -a joao
New SMB password:
Retype new SMB password:
Added user joao.

```

```console
obsd2023# netstat -a -p udp
Active Internet connections (including servers)
Proto   Recv-Q Send-Q  Local Address          Foreign Address
udp          0      0  obsd2023.6244          061239100196.cti.ntp
udp          0      0  obsd2023.5292          goamst.hojmark.n.ntp
udp          0      0  obsd2023.9555          ntp-b.0x5e.se.ntp
udp          0      0  obsd2023.19600         time.cloudflare..ntp
udp          0      0  obsd2023.32724         sth2.ntp.netnod..ntp
udp          0      0  *.*                    *.*
udp          0      0  192.168.122.255.netbio *.*
udp          0      0  obsd2023.netbios-      *.*
udp          0      0  obsd2023.netbios-      *.*
udp          0      0  192.168.122.255.netbio *.*
udp          0      0  *.netbios-             *.*
udp          0      0  *.netbios-             *.*
udp          0      0  obsd2023.bootpc        *.*
udp          0      0  *.*                    *.*
Active Internet connections (including servers)
Proto   Recv-Q Send-Q  Local Address          Foreign Address
udp6         0      0  *.*                    *.*
udp6         0      0  *.*                    *.*

obsd2023# netstat -a -p tcp
Active Internet connections (including servers)
Proto   Recv-Q Send-Q  Local Address          Foreign Address        TCP-State
tcp          0      0  obsd2023.ssh           192.168.122.1.42746    ESTABLISHED
tcp          0      0  obsd2023.netbios-      192.168.122.1.51188    ESTABLISHED
tcp          0      0  obsd2023.netbios-      192.168.122.1.54920    ESTABLISHED
tcp          0      0  obsd2023.microsof      192.168.122.1.33542    ESTABLISHED
tcp          0      0  *.https                *.*                    LISTEN
tcp          0      0  localhost.smtp         *.*                    LISTEN
tcp          0      0  *.ssh                  *.*                    LISTEN
tcp          0      0  *.www                  *.*                    LISTEN
tcp          0      0  *.microsof             *.*                    LISTEN
tcp          0      0  *.netbios-             *.*                    LISTEN
Active Internet connections (including servers)
Proto   Recv-Q Send-Q  Local Address          Foreign Address        TCP-State
tcp6         0      0  *.microsof             *.*                    LISTEN
tcp6         0      0  *.https                *.*                    LISTEN
tcp6         0      0  localhost.smtp         *.*                    LISTEN
tcp6         0      0  fe80::1%lo0.smtp       *.*                    LISTEN
tcp6         0      0  *.www                  *.*                    LISTEN
tcp6         0      0  *.netbios-             *.*                    LISTEN
tcp6         0      0  *.ssh                  *.*                    LISTEN

```

