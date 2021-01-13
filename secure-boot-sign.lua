local io = require("io")
local component = require("component")
local data
for d in component.list("data") do
	d = component.proxy(d)
	if d.generateKeyPair ~= nil then
		data = d
	end
end
if data == nil then
	print("You need a T3 data card for secure boot!")
	return
end
local args = table.pack(...)
if args.n ~= 2 then
	print("You need to specify the file path of the private key, then the path to the file to sign")
	return
end
local privf, err = io.open(args[1],"rb")
if privf == nil then
	print("could not read private key: "..err)
	return
end
local priv = data.deserializeKey(privf:read("a"),"ec-private")
privf:close()
if priv == nil then
	print("invalid private key")
	return
end
local sigf, err = io.open(args[2],"rb")
if sigf == nil then
	print("could not open file to sign: "..err)
	return
end
local sig = sigf:read("a")
sigf:close()
local signature = data.ecdsa(sig,priv)
sigf, err = io.open(args[2]..".sig","wb")
if sigf == nil then
	print("could not write signature: "..err)
	return
end
sigf:write(signature)
sigf:close()
