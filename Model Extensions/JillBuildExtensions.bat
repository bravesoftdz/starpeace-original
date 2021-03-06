@echo off

e:

echo "GENERAL"

cd "\Work\Five\Source\Model Extensions\General\"

"f:\Program Files\Borland\Delphi 3\Bin\dcc32.exe" -b -n"..\..\..\dcu" -e"..\..\..\release\Servers" -u"..\..\Tasks;..\..\Actors;..\..\Kernel;..\..\StdBlocks;..\..\Class Storage;..\..\Cache;..\..\RDO\Common;..\..\RDO\Server;..\..\Utils\Network;..\..\RDO\Client\;..\..\Persistence;..\..\Utils\Misc;..\..\Utils\Vcl;..\..\Surfaces;..\..\Mail;..\..\Protocol;..\..\Circuits;f:\Program Files\Borland\Delphi 3\Lib" "GeneralPack1.dpr"

echo "MOAB"

cd "\Work\Five\Source\Model Extensions\Moab\"

"f:\Program Files\Borland\Delphi 3\Bin\dcc32.exe" -b -n"..\..\..\dcu" -e"..\..\..\release\Servers" -u"..\..\Tasks;..\..\Actors;..\..\Kernel;..\..\StdBlocks;..\..\Class Storage;..\..\Cache;..\..\RDO\Common;..\..\RDO\Server;..\..\Utils\Network;..\..\RDO\Client\;..\..\Persistence;..\..\Utils\Misc;..\..\Utils\Vcl;..\..\Surfaces;..\..\Mail;..\..\Protocol;..\..\Circuits;f:\Program Files\Borland\Delphi 3\Lib" "MoabPack1.dpr"

echo "DISSIDENTS"

cd "\Work\Five\Source\Model Extensions\Dissidents\"

"f:\Program Files\Borland\Delphi 3\Bin\dcc32.exe" -b -n"..\..\..\dcu" -e"..\..\..\release\Servers" -u"..\..\Tasks;..\..\Actors;..\..\Kernel;..\..\StdBlocks;..\..\Class Storage;..\..\Cache;..\..\RDO\Common;..\..\RDO\Server;..\..\Utils\Network;..\..\RDO\Client\;..\..\Persistence;..\..\Utils\Misc;..\..\Utils\Vcl;..\..\Surfaces;..\..\Mail;..\..\Protocol;..\..\Circuits;f:\Program Files\Borland\Delphi 3\Lib" "DissidentPack1.dpr"

echo "UNIVERSAL WAREHOUSES"

cd "\Work\Five\Source\Model Extensions\UW\"

"f:\Program Files\Borland\Delphi 3\Bin\dcc32.exe" -b -n"..\..\..\dcu" -e"..\..\..\release\Servers" -u"..\..\Tasks;..\..\Actors;..\..\Kernel;..\..\StdBlocks;..\..\Class Storage;..\..\Cache;..\..\RDO\Common;..\..\RDO\Server;..\..\Utils\Network;..\..\RDO\Client\;..\..\Persistence;..\..\Utils\Misc;..\..\Utils\Vcl;..\..\Surfaces;..\..\Mail;..\..\Protocol;..\..\Circuits;f:\Program Files\Borland\Delphi 3\Lib" "UWPack1.dpr"

echo "PGI"

cd "\Work\Five\Source\Model Extensions\PGI\"

"f:\Program Files\Borland\Delphi 3\Bin\dcc32.exe" -b -n"..\..\..\dcu" -e"..\..\..\release\Servers" -u"..\..\Tasks;..\..\Actors;..\..\Kernel;..\..\StdBlocks;..\..\Class Storage;..\..\Cache;..\..\RDO\Common;..\..\RDO\Server;..\..\Utils\Network;..\..\RDO\Client\;..\..\Persistence;..\..\Utils\Misc;..\..\Utils\Vcl;..\..\Surfaces;..\..\Mail;..\..\Protocol;..\..\Circuits;f:\Program Files\Borland\Delphi 3\Lib" "PGIPack1.dpr"

echo "MARIKO"

cd "\Work\Five\Source\Model Extensions\Mariko\"

"f:\Program Files\Borland\Delphi 3\Bin\dcc32.exe" -b -n"..\..\..\dcu" -e"..\..\..\release\Servers" -u"..\..\Tasks;..\..\Actors;..\..\Kernel;..\..\StdBlocks;..\..\Class Storage;..\..\Cache;..\..\RDO\Common;..\..\RDO\Server;..\..\Utils\Network;..\..\RDO\Client\;..\..\Persistence;..\..\Utils\Misc;..\..\Utils\Vcl;..\..\Surfaces;..\..\Mail;..\..\Protocol;..\..\Circuits;f:\Program Files\Borland\Delphi 3\Lib" "MarikoPack1.dpr"

echo "MAGNA"

cd "\Work\Five\Source\Model Extensions\Magna\"

"f:\Program Files\Borland\Delphi 3\Bin\dcc32.exe" -b -n"..\..\..\dcu" -e"..\..\..\release\Servers" -u"..\..\Tasks;..\..\Actors;..\..\Kernel;..\..\StdBlocks;..\..\Class Storage;..\..\Cache;..\..\RDO\Common;..\..\RDO\Server;..\..\Utils\Network;..\..\RDO\Client\;..\..\Persistence;..\..\Utils\Misc;..\..\Utils\Vcl;..\..\Surfaces;..\..\Mail;..\..\Protocol;..\..\Circuits;f:\Program Files\Borland\Delphi 3\Lib" "MagnaPack1.dpr"

echo "TRAINS"

cd "\Work\Five\Source\Model Extensions\Trains\"

"f:\Program Files\Borland\Delphi 3\Bin\dcc32.exe" -b -n"..\..\..\dcu" -e"..\..\..\release\Servers" -u"..\..\Land\;..\..\Tasks;..\..\Actors;..\..\Kernel;..\..\StdBlocks;..\..\Class Storage;..\..\Cache;..\..\RDO\Common;..\..\RDO\Server;..\..\Utils\Network;..\..\RDO\Client\;..\..\Persistence;..\..\Utils\Misc;..\..\Utils\Vcl;..\..\Surfaces;..\..\Mail;..\..\Protocol;..\..\Circuits;f:\Program Files\Borland\Delphi 3\Lib" "Trains.dpr"

echo "MODEL SERVER"

cd "\Work\Five\Source\Model Server\"

"f:\Program Files\Borland\Delphi 3\Bin\dcc32.exe" -b -n"..\..\dcu" -e"..\..\release\Servers" -u"..\Tasks;..\Actors;..\Model extensions;..\Kernel;..\StdBlocks;..\Class Storage;..\Cache;..\RDO\Common;..\RDO\Server;..\Utils\Network;..\RDO\Client\;..\Persistence;..\Utils\Misc;..\Utils\Vcl;..\Surfaces;..\Mail;f:\Program Files\Borland\Delphi 3\Lib" "FIVEModelServer.dpr"

