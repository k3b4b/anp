--Адрес роутера
local router = ""
local filesystem = require("filesystem")
local dbr = io.open("router", "r")
if not filesystem.exists("/home/router") then
  print("test")
else
  local dbr = io.open("router", "r")
  router = dbr:read "*a"
dbr:close()
end

local component = require("component")
local event = require("event")
local terminal = require("term")
local os = require("os")
local modem = component.modem
local serial = require("serialization")
--Порт
port = 20
modem.open(port)
--Функции

--Помощь
function printHelp()
  print("Alias Network Protocol client - made by k3b4b. 2021.")
  print("Список доступных команд: ")
  print("1. help - помощь.")
  print("2. register - регистрация устройства в сети.")
  print("3. list - список устройств в сети.")
  print("4. send <алиас> <сообщение> - отправить сообщение устройству.") 
  print("5. get - получить сообщение.")
  print("6. settings - настройки. TODO")
end

--Отправка пакета


--Список хостов
function printHosts(message)
  local serial = require("serialization")
  local tableOfHosts = serial.unserialize(message)
  print("Список устройств в сети: ")
  for key, value in pairs(tableOfHosts) do
    print("\t" .. key .. "\t" .. value)
  end
end

--Вывод помощи
function firstStart(arguments)
  if(arguments[1] == nil) or (string.lower(arguments[1]) == "help") or arguments[1] == "?" then
    printHelp()
    os.exit()
  end
  return fExit
end


--Настройки
function printSettings()
  print("Alias Network Protocol client - made by k3b4b. 2021.")
  print("НЕ ТРОГАЙТЕ ТЕ НАСТРОЙКИ, НАЗНАЧЕНИЕ КОТОРЫХ ВАМ НЕВЕДОМО!!!")
  print("Список доступных настроек: ")
  print("1. alias - изменить свой алиас в сети.")
  print("**2. port - изменить свой порт.**")
end

--Основной блок
arguments = { ... }
local tablePackage = {}
local serialRouterResponsePackage = ""
local packageFrom = ""
local packageMessage = ""

--Вывод помощи "для новичка"
firstStart(arguments)

--Регистрация в сети
if string.lower(arguments[1]) == "register" then
  print("Устанавливаем связь с роутером...\n")
  tablePackage["destination"] = "router"
  tablePackage["command"] = "register"
  serialPackage = serial.serialize(tablePackage)
  modem.broadcast(20, serialPackage)
  _, _, router, _, _ = event.pull("modem_message")
  dbw = io.open("router", "w")
  dbw:write(router)
  dbw:close()
  print("Ответ получен. Адрес роутера: " ..router.. "\n")
  print("Введите ваш алиас(алиас - ваше имя в сети): ")
  tablePackage["command"] = "host"
  tablePackage["message"] = io.read("*l")
  serialPackage = serial.serialize(tablePackage)
  modem.send(router, port, serialPackage)
  _, _, _, _, _, feedback = event.pull("modem_message")
  print(feedback)
end

--Запрос списка хостов
if string.lower(arguments[1]) == "list" then
  tablePackage["destination"] = "router"
  tablePackage["command"] = "list"
else
  tablePackage["destination"] = string.lower(tostring(arguments[1]))
  tablePackage["command"] = string.lower(tostring(arguments[2]))
end

--Отправка сообщения
if string.lower(arguments[1]) == "send" then
  tablePackage["destination"] = string.lower(tostring(arguments[2]))
  tablePackage["command"] = string.lower(tostring(arguments[1]))
  tablePackage["message"] = string.lower(tostring(arguments[3]))
end

--Получение сообщения
--if string.lower(arguments[1]) == "get" then
--  _, _, packageFrom, _, _, packageMessage = event.pull("modem_message")
--  print(packageMessage)
--end
local thread = require("thread")
event.listen("modem_message", function()
    thread.create(function()
    while true do
      _, _, _, _, _, packageMessage = event.pull("modem_message")
      print(packageMessage)
      os.sleep(1)
    end
  end):detach()
end)
      
  
--Настройки
if string.lower(arguments[1]) == "settings" then
  printSettings()
end

if string.lower(arguments[1]) == "setting" then
  if string.lower(arguments[2]) == "alias" then
    --сделаю смену алиаса
  else if string.lower(arguments[2]) == "port" then
    --а тут смену порта
  end
  end
end


--Отправка пакета
  serialPackage = serial.serialize(tablePackage)
  modem.send(router, port, serialPackage)

--Ожидание списка хостов от сервера
if tablePackage.command == "list" then
  _, _, _, _, _, serialRouterResponsePackage = event.pull("modem_message")
  printHosts(serialRouterResponsePackage)
end

