program DDrawIsoViewerTest;

uses
  Forms,
  SoundTypes in '..\..\Voyager\Components\MapIsoview\SoundTypes.pas',
  Aircraft in '..\..\Voyager\Components\MapIsoview\Aircraft.pas',
  BuildClasses in '..\..\Voyager\Components\MapIsoview\BuildClasses.pas',
  CacheBackup in '..\..\Voyager\Components\MapIsoview\CacheBackup.pas',
  Car in '..\..\Voyager\Components\MapIsoview\Car.pas',
  Circuits in '..\..\Voyager\Components\MapIsoview\Circuits.pas',
  CircuitsHandler in '..\..\Voyager\Components\MapIsoview\CircuitsHandler.pas',
  Concrete in '..\..\Voyager\Components\MapIsoview\Concrete.pas',
  FiveControl in '..\..\Voyager\Components\MapIsoview\FiveControl.pas',
  FiveTypes in '..\..\Voyager\Components\MapIsoview\FiveTypes.pas',
  GameControl in '..\..\Voyager\Components\MapIsoview\GameControl.pas',
  GameTypes in '..\..\Voyager\Components\MapIsoview\GameTypes.pas',
  GlassedBuffers in '..\..\Voyager\Components\MapIsoview\GlassedBuffers.pas',
  GroundObject in '..\..\Voyager\Components\MapIsoview\GroundObject.pas',
  ImageCache in '..\..\Voyager\Components\MapIsoview\ImageCache.pas',
  ImageLoader in '..\..\Voyager\Components\MapIsoview\ImageLoader.pas',
  Lander in '..\..\Voyager\Components\MapIsoview\Lander.pas',
  LanderTypes in '..\..\Voyager\Components\MapIsoview\LanderTypes.pas',
  LocalCacheManager in '..\..\Voyager\Components\MapIsoview\LocalCacheManager.pas',
  LocalCacheTypes in '..\..\Voyager\Components\MapIsoview\LocalCacheTypes.pas',
  Map in '..\..\Voyager\Components\MapIsoview\Map.pas',
  MapSprites in '..\..\Voyager\Components\MapIsoview\MapSprites.pas',
  MapTypes in '..\..\Voyager\Components\MapIsoview\MapTypes.pas',
  Ship in '..\..\Voyager\Components\MapIsoview\Ship.pas',
  SoundCache in '..\..\Voyager\Components\MapIsoview\SoundCache.pas',
  SoundMixer in '..\..\Voyager\Components\MapIsoview\SoundMixer.pas',
  Sounds in '..\..\Voyager\Components\MapIsoview\Sounds.pas',
  Animations in '..\..\Utils\CodeLib\Animations.pas',
  AxlDebug in '..\..\Utils\CodeLib\AxlDebug.pas',
  CoreTypes in '..\..\Utils\CodeLib\CoreTypes.pas',
  ScrollRegions in '..\..\Utils\CodeLib\ScrollRegions.pas',
  ShutDown in '..\..\Utils\CodeLib\ShutDown.pas',
  Threads in '..\..\Utils\CodeLib\Threads.pas',
  ThreadTimer in '..\..\Utils\CodeLib\ThreadTimer.pas',
  Warnings in '..\..\Utils\CodeLib\Warnings.pas',
  ServerCnxEvents in 'ServerCnxEvents.pas',
  ClientView in 'ClientView.pas',
  FiveMain in 'FiveMain.pas' {FiveMainForm},
  CaptureCoords in 'CaptureCoords.pas' {CaptureCoordinates},
  VisualClassManager in '..\..\Class Packer\VisualClassManager.pas',
  Roads in '..\..\Voyager\Components\MapIsoview\Roads.pas',
  Railroads in '..\..\Voyager\Components\MapIsoview\Railroads.pas',
  TraincarSprite in '..\..\Voyager\Components\MapIsoview\TraincarSprite.pas',
  ActorPool in '..\..\Actors\ActorPool.pas',
  DistributedStates in '..\..\Actors\DistributedStates.pas',
  StateEngine in '..\..\Actors\StateEngine.pas',
  ActorTypes in '..\..\Actors\ActorTypes.pas',
  LogFile in '..\..\Rdo\Common\LogFile.pas',
  DDraw in '..\..\Utils\DirectX\DDraw.pas',
  DXTools in '..\..\Utils\DirectX\DXTools.pas',
  D3D in '..\..\Utils\DirectX\D3d.pas',
  D3DTypes in '..\..\Utils\DirectX\D3DTypes.pas',
  D3DCaps in '..\..\Utils\DirectX\D3DCaps.pas',
  BufferManager in '..\..\Voyager\Components\MapIsoView\BufferManager.pas',
  FiveIsometricMap in '..\..\Voyager\Components\IsometricMap\FiveIsometricMap.pas',
  IsometricMap in '..\..\Voyager\Components\IsometricMap\IsometricMap.pas',
  IsometricMapTypes in '..\..\Voyager\Components\IsometricMap\IsometricMapTypes.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFiveMainForm, FiveMainForm);
  Application.CreateForm(TCaptureCoordinates, CaptureCoordinates);
  Application.Run;
end.

