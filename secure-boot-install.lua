local io = require("io")
local component = require("component")
local eeprom = component.eeprom
if eeprom == nil then
	print("You need to have an EEPROM inserted")
	return
end
local args = table.pack(...)
if args.n ~= 2 then
	print("you need to specify the path to bios.lua, then to the public key file")
	return
end
local biosf, err = io.open(args[1],"rb")
if biosf == nil then
	print("could not open bios.lua: "..err)
	return
end
local bios = biosf:read("a")
biosf:close()
local pubf, err = io.open(args[2],"rb")
if pubf == nil then
	print("could not read public key: "..err)
	return
end
local pub = pubf:read("a")
pubf:close()
bios = "local keyformat=\"ec-public-256\"\n--[["..pub.."]]--\n"..bios
local ret, err = eeprom.set(bios)
if err then
	print("EEPROM is read-only")
	return
end
eeprom.setLabel("secure boot BIOS")
eeprom.makeReadonly(eeprom.getChecksum())
