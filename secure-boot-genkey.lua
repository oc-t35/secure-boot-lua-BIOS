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
print("generating keypair")
local pub, priv = data.generateKeyPair(256)
print("saving public key to /home/pubkey")
local f, err = io.open("/home/pubkey","wb")
if f ~= nil then
	f:write(pub.serialize())
	f:close()
else
	print("could not save the keys: "..err)
	return
end
print("saving private key to /home/privkey")
f, err = io.open("/home/privkey","wb")
if f ~= nil then
	f:write(priv.serialize())
	f:close()
else
	print("could not save the keys: "..err)
	return
end
