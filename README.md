# wiroVehicleSave

## Features And Infos
This script is make esx servers doesn't need a garage script no longer because this script's feature is saving players vehicles data's. Yes but what kind of datas ? its basiclly saving almost every properties in the vehicle included glass, tier, car damages and all vehicle coordinates ofcourse. Every time server started script reloads that datas and create every vehicles from scratch. You all free to use this script and improve it and use in marketplace just don't forget to point me for reference :)

## Setup

run the sql file in your database. <br/>
if you are using es_extended 1.1V goto config.lua and find `Config.esExtended1_1` variable and make it equel true. <br/>
(hardest part)goto your vehicleshop script and you must find the where player is purching the vehicle and paste this code in here `TriggerEvent('wiroVehicleSave:addVehicleClient', vehicle)`(vehicle variable is must be hash of the created vehicle).

## Last Words
Don't forget to share issues that you find in the script so I can fix and make it better. <br/>
If you have any issue or question you can make contact with me in github or discord. <br/>
[My Discord Server](https://discord.gg/s5fWTrW)
