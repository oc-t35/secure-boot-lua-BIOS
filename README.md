# secure boot Lua BIOS
This is a BIOS for the OpenComputers mod that is compliant with secure boot ([OETF #20](https://oc.cil.li/topic/2646-oetf-20-secure-boot-for-lua-architectures/)).

First download all files into a directory.
To do this in OpenComputers you neet the wget program and an internet card.
Links:



It needs a T3 data card.
To generate a key pair, use secure-boot-genkey.lua.
To install, use secure-boot-genkey.lua, then secure-boot-install.lua.

To sign an init.lua, use secure-boot-sign.lua and give it the filename in which your private key is stored.
After signing, either encrypt the private key or delete it.
