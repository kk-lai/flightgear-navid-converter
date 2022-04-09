# flightgear-navid-converter
Convert earth_fix.dat and earth_nav.dat into Flightgear readable format

To convert nav data, type the following command in cmd prompt (assuming your x-plane installed in D:\X-Plane 11)

powershell -ExecutionPolicy Bypass -file .\xp2fg.ps1 nav "d:\X-Plane 11\Resources\default data\earth_nav.dat" nav.dat.gz

To convert fixes, type the following command in cmd prompt (assuming your x-plane installed in D:\X-Plane 11)

powershell -ExecutionPolicy Bypass -file .\xp2fg.ps1 fix "d:\X-Plane 11\Resources\default data\earth_fix.dat" fix.dat.gz

Override the nav.data.gz and fix.dat.gz in Navaids folder of flight gear default data folder.

