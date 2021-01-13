# secure boot Lua BIOS
This is a BIOS for the OpenComputers mod that is compliant with secure boot ([OETF #20](https://oc.cil.li/topic/2646-oetf-20-secure-boot-for-lua-architectures/)).

First download the secure-boot-* files and bios.lua.
To do this in OpenComputers you need the wget program and an internet card.
Links to the raw file data:
https://raw.githubusercontent.com/oc-t35/secure-boot-lua-BIOS/main/bios.lua
https://raw.githubusercontent.com/oc-t35/secure-boot-lua-BIOS/main/secure-boot-genkey.lua
https://raw.githubusercontent.com/oc-t35/secure-boot-lua-BIOS/main/secure-boot-install.lua
https://raw.githubusercontent.com/oc-t35/secure-boot-lua-BIOS/main/secure-boot-sign.lua

As these are files for secure boot, I would recommend just using edit in OpenComputers and copy&paste the file data, because OpenComputers wget doesn't support HTTPS.

It needs a T3 data card.
To generate a key pair, use secure-boot-genkey.lua.
To install, use secure-boot-install.lua.
secure-boot-install.lua needs the path to bios.lua and the path to the public key file.

To sign an init.lua, use secure-boot-sign.lua and give it the path to private key file, then the path to the file you want to sign.
After signing, either encrypt the private key or delete it.
