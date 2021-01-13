local data
for d in component.list("data") do
	d = component.proxy(d)
	if d.generateKeyPair ~= nil then
		data = d
	end
end
if data == nil then
	error("The secure boot BIOS needs a T3 data card to verify signatures!")
end
local eeprom = component.proxy(component.list("eeprom")())
if table.pack(eeprom.set(eeprom.get())).n == 0 then
	error("eeprom isn't read-only, public key could have been changed!")
end
-- get the boot device and the public key
-- the public key is prepended as a multiline comment by the installer
local pubkey = string.match(eeprom.get(),"%-%-%[(.*)%]%-%-")
if pubkey == nil or pubkey == "" then
	error("public key not found")
end
pubkey = string.sub(pubkey,2,#pubkey-1) -- for some reason that pattern matches one [ at the start and one ] at the end
pubkey, err = data.deserializeKey(pubkey,"ec-public")
if pubkey == nil or not pubkey.isPublic() then
	error("public key invalid!")
end
secure_boot = {}
secure_boot.pubkey = pubkey
secure_boot.keyformat = keyformat -- keyformat is prepended by the installer
local readfile = function(fs,path)
	local f = fs.open(path,"rb")
	if f == nil then
		return nil
	end
	local dat = ""
	local add = ""
	repeat
		add = fs.read(f,math.huge)
		dat = dat .. (add or "")
	until not add
	fs.close(f)
	return dat
end
local bootdev = component.proxy(eeprom.getData())
local err = nil
local kernel = nil
local bootaddr = nil
if bootdev ~= nil and bootdev.type == "filesystem" then
	if bootdev.exists("/init.lua") and bootdev.exists("/init.lua.sig") then
		local sig = readfile(bootdev,"/init.lua.sig")
		local init = readfile(bootdev,"/init.lua")
		if sig ~= nil and init ~= nil and data.ecdsa(init,pubkey,sig) then
			kernel,err = load(init)
			bootaddr = bootdev.address
		end
	end
end
if kernel == nil then
	for fs in component.list("filesystem") do
		fs = component.proxy(fs)
		if fs.exists("/init.lua") and fs.exists("/init.lua.sig") then
			local sig = readfile(fs,"/init.lua.sig")
			local init = readfile(fs,"/init.lua")
			if sig ~= nil and init ~= nil and data.ecdsa(init,pubkey,sig) then
				kernel,err = load(init)
				bootaddr = fs.address
				if kernel ~= nil then
					break
				end
			end
		end
	end
end
if kernel == nil then
	if err ~= nil then
		error("error loading last signed /init.lua: "..err)
	end
	error("no signed loadable /init.lua found in any connected filesystem!")
end
eeprom.setData(bootaddr)
computer.getBootAddress = function()
	return eeprom.getData()
end
computer.setBootAddress = function(addr)
	return eeprom.setData(addr)
end
local success, err = pcall(kernel)
if success then
	error("/init.lua returned!")
else
	error("/init crashed with error: "..err)
end
