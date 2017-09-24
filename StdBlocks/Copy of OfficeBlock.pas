unit OfficeBlock;

interface

  uses
    ClassStorageInt, Kernel, Population, Surfaces, BackupInterfaces, Protocol, CacheAgent,
    WorkCenterBlock, Accounts;

  const
    modBeautyRatio    = 10;
    modBAPRatio       = 7;
    modCrimeRatio     = 1;
    modPollutionRatio = 1;
    modStrengthOfBAP  = 10;
                                         
  const
    MaxBAP       = 10; //1000;
    MaxBeauty    = 10; //2000;
    MaxCrime     = 10; //50;                  
    MaxPollution = 10; //10;                 

  const
    BAPWeight         = 200;
    BeautyWeight      =  30;
    CrimeWeight       = 100;
    PollWeight        = 100;               
    MaintenanceWeight = 150;
    PriceWeight       =  10;
    EfficiencyWeight  =  90;

  const
    OfficesPrice = 10;

  const
    TotalWeight =
      BAPWeight +
      BeautyWeight +
      CrimeWeight +
      PollWeight +
      MaintenanceWeight +
      PriceWeight +
      EfficiencyWeight;

  const
    ProfitLimit      = 60;     // Minimal occupancy of positive-profit office building
    MinOccupancy     = 35;     // Minimal occupancy of old-looking office building
    BrandNewEffect   = 365*24; // Minimal age of old-looking residential
    BuildingUglyness = -70;    // For the beauty modifier if in ugly state
    LowBAP           = -70;    // For the BAP modifier if in ugly state
    RepairPriceShare = 1/4;
    OfsRecovTime     = 2*356*24;

  type
    TOfficeVisualState  = (ofstNormal, ofstReparing, ofstHalfEmpty);
    TOfficeVisualStates = set of TOfficeVisualState;

  type
    TMetaOfficeBlock =
      class( TMetaWorkCenter )
        public
          constructor Create( anId        : string;
                              aCapacity   : TFluidValue;
                              aBlockClass : CBlock );
        private
          fCapacity        : TFluidValue;
          fEfficiency      : single;
          fCrimeResist     : single;
          fPollResist      : single;
          fBAP             : single;
          fAvailableStates : TOfficeVisualStates;
        public
          property Capacity        : TFluidValue         read fCapacity;
          property Efficiency      : single              read fEfficiency      write fEfficiency;
          property CrimeResist     : single              read fCrimeResist     write fCrimeResist;
          property PollResist      : single              read fPollResist      write fPollResist;
          property BAP             : single              read fBAP             write fBAP;
          property AvailableStates : TOfficeVisualStates read fAvailableStates write fAvailableStates;
        protected
          function ModifyStageStack( Stage : TMetaBlock ) : boolean; override;
        public
          procedure Register( ClassFamily : TClassFamilyId );
      end;

    TOfficeBlock =
      class( TWorkCenter )
        protected
          constructor Create( aMetaBlock : TMetaBlock; aFacility : TFacility ); override;
        public
          destructor  Destroy; override;
        private
          fEmigration  : TPushInputData;
          fInmigration : TPushInputData;
          fRecycleIn   : TPushInputData;
          fDemand      : TOutputData;
          fOfficesRep  : TOutputData;
          fRecycleOut  : TOutputData;
        protected
          function GetSurfaceValue( SurfaceId : TSurfaceId ) : TSurfaceValue; override;
        protected
          function Evaluate : TEvaluationResult; override;
        public
          procedure AutoConnect( loaded : boolean ); override;
        public
          procedure Stop; override;
        protected
          function GetVisualClassId  : TVisualClassId; override;
        protected
          fOffices     : TFluidData;
          fRent        : TPercent;
          fMaintenance : TPercent;
          fRepair      : TPercent;
          fRepairDate  : TVirtDateAbs;
        private
          function  GetRent : TPercent;
          procedure SetRent( aRent : TPercent );
          function  GetMaintenance : TPercent;
          procedure SetMaintenance( aMaintenance : TPercent );
          function  GetOccupancy : TPercent;
        published
          property Rent        : TPercent read GetRent        write SetRent;
          property Maintenance : TPercent read GetMaintenance write SetMaintenance;
          property Occupancy   : TPercent read GetOccupancy;
        published                                 
          procedure RdoRepair(useless : integer);
          procedure RdoStopRepair(useless : integer);
        public
          property Offices : TFluidData read fOffices;
        private
          function GetMarketPrice : TMoney;
        published
          function GetStatusText( kind : TStatusKind; ToTycoon : TTycoon ) : string; override;
        private
          fBeautyModifier      : TSurfaceModifier;
          fBAPModifier         : TSurfaceModifier;
          fBeautyIntegrator    : TSurfaceIntegrator;
          fPollutionIntegrator : TSurfaceIntegrator;
          fCrimeIntegrator     : TSurfaceIntegrator;
          fBAPIntegrator       : TSurfaceIntegrator;
          fPrivateWorkers      : array[TPeopleKind] of TTownParameter;
          fAdm                 : TAdmitance;
      private
          invCrimeRes : single;
          invPollRes  : single;
          invBeauty   : single;
          invPrivacy  : single;
          invMaint    : single;
        private
          function GetBAPPercent   ( value : TSurfaceValue ) : TPercent;
          function GetBeautyPercent( value : TSurfaceValue ) : TPercent;
          function GetCrimePercent ( value : TSurfaceValue ) : TPercent;
          function GetPollPercent  ( value : TSurfaceValue ) : TPercent;
        public
          procedure StoreToCache  ( Cache  : TObjectCache  ); override;
          procedure LoadFromBackup( Reader : IBackupReader ); override;
          procedure StoreToBackup ( Writer : IBackupWriter ); override;
        private
          function LooksUgly : boolean;     
      end;

  const
    OfsEmigrationProb = 30;

  procedure RegisterBackup;

implementation

  uses
    SysUtils, ClassStorage, MathUtils, PyramidalModifier, Classes, SimHints, Languages,
    BasicAccounts, StdFluids, MetaInstances, Construction, PopulatedBlock;

  const
    MoveInDays = 10*TimeUnits;


  // TMetaOfficeBlock

  constructor TMetaOfficeBlock.Create( anId        : string;
                                       aCapacity   : TFluidValue;
                                       aBlockClass : CBlock );
    var
      Sample  : TOfficeBlock;
      Offices : TMetaFluid;
      Total   : single;
    begin
      Total := WorkersPerOffice*aCapacity;
      inherited Create( anId, [0.2*Total, 0.3*Total, 0.5*Total], accIdx_None, accIdx_Offices, accIdx_None, aBlockClass );
      fCapacity   := aCapacity;
      fEfficiency := 1;
      Offices     := TMetaFluid(TheClassStorage.ClassById['Fluids', tidFluid_Offices]);
      Sample      := nil;
      fBAP        := 10*aCapacity;
      MetaInputs.Insert(
        TMetaInput.Create(
          tidGate_OfsInmigration,
          inputZero,
          InputData( aCapacity/MoveInDays, kIlimited ),
          inputZero,
          fCapacity,
          TPushInput,
          Offices,
          1,
          mglBasic,
          [],
          sizeof(Sample.fInmigration),
          Sample.Offset( Sample.fInmigration )));
      MetaInputs.Insert(
        TMetaInput.Create(
          tidGate_OfsEmigration,
          inputZero,
          InputData( aCapacity, kIlimited ),
          inputZero,
          fCapacity,
          TPushInput,
          Offices,
          1,
          mglBasic,
          [],
          sizeof(Sample.fEmigration),
          Sample.Offset( Sample.fEmigration )));
      MetaInputs.Insert(
        TMetaInput.Create(
          tidGate_OfsRecycleIn,
          inputZero,
          InputData( aCapacity, kIlimited ),
          inputZero,
          fCapacity,
          TPushInput,
          Offices,
          1,
          mglBasic,
          [],
          sizeof(Sample.fRecycleIn),
          Sample.Offset( Sample.fRecycleIn )));
      MetaOutputs.Insert(
        TMetaOutput.Create(
          tidGate_OfsDemand,
          FluidData( aCapacity, kIlimited ),
          TPushOutput,
          Offices,
          1,
          [],
          sizeof(Sample.fDemand),
          Sample.Offset( Sample.fDemand )));
      MetaOutputs.Insert(
        TMetaOutput.Create(
          tidGate_Offices,
          FluidData( aCapacity, kIlimited ),
          TPushOutput,
          Offices,
          1,
          [],
          sizeof(Sample.fOfficesRep),
          Sample.Offset( Sample.fOfficesRep )));
      MetaOutputs.Insert(
        TMetaOutput.Create(
          tidGate_OfsRecycleOut,
          FluidData( aCapacity, kIlimited ),
          TPushOutput,
          Offices,
          1,
          [],
          sizeof(Sample.fRecycleOut),
          Sample.Offset( Sample.fRecycleOut )));
      fAvailableStates := [ofstNormal];
    end;

  function TMetaOfficeBlock.ModifyStageStack( Stage : TMetaBlock ) : boolean;
    var
      OptRent    : single;
      Profit     : TMoney;
      ConstPrice : TMoney;
      Cost       : TMoney;
    begin
      if ObjectIs( TMetaBlockUnderConstruction.ClassName, Stage )
        then
          begin
            OptRent    := realmax(0, 1 + Efficiency/3);
            Profit     := (100 - ProfitLimit)*OptRent*Capacity*OfficesPrice/100;
            Cost       := realmax(0, OfsRecovTime*Profit);
            ConstPrice := TMetaFluid(TheClassStorage.ClassById[tidClassFamily_Fluids, tidFluid_ConstructionForce]).MarketPrice;
            TMetaBlockUnderConstruction(Stage).ConstVolumeRequired := Cost/ConstPrice;
            result := true;
          end
        else result := false;
    end;

  procedure TMetaOfficeBlock.Register( ClassFamily : TClassFamilyId );
    var
      i    : integer;
      lang : TLanguageId;
    begin
      for i := 0 to pred(LangList.Count) do
        begin
          lang := LangList[i];
          if Desc_MLS.Values[lang] <> ''
            then Desc_MLS.Values[lang] := Desc_MLS.Values[lang] + ' ';
          Desc_MLS.Values[lang] := Desc + SimHints.GetHintText( mtidDescOffice.Values[lang], [round(Capacity), round(100*Efficiency)] );
        end;
      inherited Register( ClassFamily );
    end;



  // TOfficeBlock

  constructor TOfficeBlock.Create( aMetaBlock : TMetaBlock; aFacility : TFacility );
    begin
      inherited;
      fRent        := 100;
      fMaintenance := 100;
    end;

  destructor TOfficeBlock.Destroy;
    begin
      fBeautyModifier.Delete;
      fBAPModifier.Delete;
      fBeautyIntegrator.Delete;
      fPollutionIntegrator.Delete;
      fCrimeIntegrator.Delete;
      fBAPIntegrator.Delete;
      inherited;
    end;

  function TOfficeBlock.GetSurfaceValue( SurfaceId : TSurfaceId ) : TSurfaceValue;
    begin
      if SurfaceId = tidEnvironment_Beauty
        then result := fBeautyIntegrator.Media
        else
          if SurfaceId = tidEnvironment_Pollution
            then result := fPollutionIntegrator.Media
            else
              if SurfaceId = tidEnvironment_Crime
                then result := fCrimeIntegrator.Media
                else
                  if SurfaceId = tidEnvironment_BAP
                    then result := fBAPIntegrator.Media
                    else result := inherited GetSurfaceValue( SurfaceId );
    end;

  function TOfficeBlock.Evaluate : TEvaluationResult;

    procedure IntegrateInventions( out invCrimeRes, invPollRes, invBeauty, invPrivacy, invMaint : single );
      var
        Invention : TResidentialInvention;
        i         : integer;
      begin
        invCrimeRes := 0;
        invPollRes  := 0;
        invBeauty   := 0;
        invPrivacy  := 0;
        invMaint    := 0;
        for i := 0 to pred(MetaBlock.Inventions.Count) do
          begin
            Invention := TResidentialInvention(MetaBlock.Inventions[i]);
            if Facility.Company.HasInvention[Invention.NumId]
              then
                begin
                  invCrimeRes := invCrimeRes + Invention.CrimeRes;           
                  invPollRes  := invPollRes  + Invention.PollRes;
                  invBeauty   := invBeauty   + Invention.Beauty;
                  invPrivacy  := invPrivacy  + Invention.Privacy;
                  invMaint    := invMaint    + Invention.Maintenance;
                end;
          end;
        invCrimeRes := invCrimeRes/100;
        invPollRes  := invPollRes/100;
        invBeauty   := invBeauty/100;
        invPrivacy  := invPrivacy/100;
        invMaint    := invMaint/100;
      end;

    var
      OfficesIn   : TFluidData;
      OfficesOut  : TFluidData;
      realAdmit   : single;
      Admitance   : TAdmitance;
      Price       : TMoney;
      MarketPrice : TMoney;
      dRepair     : integer;
      MaxCap      : TFluidValue;
      i           : TPeopleKind;
    begin
      result := inherited Evaluate;
      if Facility.Trouble and facStoppedByTycoon = 0
        then
          with TMetaOfficeBlock(MetaBlock) do
            begin
              IntegrateInventions( invCrimeRes, invPollRes, invBeauty, invPrivacy, invMaint );
              // Computing office building quality
              realAdmit :=
                EfficiencyWeight*Efficiency/TotalWeight +
                BeautyWeight*fBeautyIntegrator.Media/(TotalWeight*MaxBeauty) + invBeauty +
                BAPWeight*fBAPIntegrator.Media/(TotalWeight*MaxBAP) -
                CrimeWeight*(1 - CrimeResist - invCrimeRes)*realmax(0, fCrimeIntegrator.Media)/(TotalWeight*MaxCrime) -
                PollWeight*(1 - PollResist - invPollRes)*realmax(0, fPollutionIntegrator.Media)/(TotalWeight*MaxPollution) +
                MaintenanceWeight*fMaintenance/(100*TotalWeight) +
                PriceWeight*(1 - Rent)/(100*TotalWeight);
              Admitance := round(realmax( 0, 10 + 50*realAdmit ));
              fAdm := Admitance;

              // Acepting inmigration
              OfficesIn.Q := fInmigration.Q + fRecycleIn.Q;
              OfficesIn.K := AverageK( @fInmigration, @fRecycleIn );

              // Population Recycle
              fRecycleOut.Q := realmin( fOffices.Q, sqr(100.0 - fDemand.K)*OfsEmigrationProb*fOffices.Q*dt/(2*100*OfsEmigrationTimeSlope*10000));
              fRecycleOut.K := fOffices.K;
              fRecycleIn.S  := sqr(Admitance) + 1;

              // Emigration
              OfficesOut.Q := fEmigration.Q + fRecycleOut.Q;
              OfficesOut.K := AverageK( @fEmigration, @fRecycleOut );

              // Generate office signals
              if OfficesOut.Q > OfficesIn.Q
                then
                  begin
                    OfficesOut.Q   := OfficesOut.Q - OfficesIn.Q;
                    fOffices.Q     := fOffices.Q - OfficesOut.Q;
                    fRecycleOut.Q  := OfficesOut.Q - fEmigration.Q;
                    fOffices.K     := AverageK( @fOffices, @OfficesOut );
                  end
                else
                  begin
                    OfficesIn.Q := OfficesIn.Q - OfficesOut.Q;
                    fOffices.K := AverageK( @fOffices, @OfficesIn );
                    fRecycleOut.Q := 0;
                    fOffices.Q := fOffices.Q + OfficesIn.Q;
                  end;

              // Sending demand
              fDemand.Q := Outputs[0].MetaOutput.MaxFluid.Q - fOffices.Q;
              fDemand.K := min( 100, Admitance );

              // Feeding back population
              fOfficesRep.Q := fOffices.Q;
              fOfficesRep.K := fOffices.K;

              // Adjusting Emigration and Inmigration
              fInmigration.S := sqr(Admitance) + 1;
              if Admitance > 0
                then fEmigration.S := 10000 div Admitance
                else fEmigration.S := 0;

              MaxCap := TMetaOfficeBlock(MetaBlock).Capacity - fOffices.Q;
              with InputsByName[tidGate_OfsInmigration] do
                begin
                  ActualMaxFluid.Q := MaxCap;
                  MaxCapacity      := MaxCap;
                end;
              with InputsByName[tidGate_OfsEmigration] do
                begin
                  ActualMaxFluid.Q := fOffices.Q;
                  MaxCapacity      := fOffices.Q;
                end;
              with InputsByName[tidGate_OfsRecycleIn] do
                begin
                  ActualMaxFluid.Q := MaxCap;                
                  MaxCapacity      := MaxCap;                          
                end;

              // Generating money
              MarketPrice := GetMarketPrice;       
              Price := fRent*MarketPrice/100;
              BlockGenMoney( fOffices.Q*Price*dt, accIdx_Offices_Rents );
              BlockGenMoney( -ProfitLimit*realmax(0, fMaintenance/100 - invMaint)*TMetaOfficeBlock(MetaBlock).Capacity*MarketPrice*dt/100, accIdx_Offices_Maintenance );

              // Modifying environment
              if not LooksUgly
                then
                  begin
                    fBeautyModifier.Value := MetaBlock.Beauty;
                    fBAPModifier.Value    := (fOffices.Q/TMetaOfficeBlock(MetaBlock).Capacity)*7*TMetaOfficeBlock(MetaBlock).BAP;
                  end
                else                 
                  begin
                    fBeautyModifier.Value := BuildingUglyness;   
                    fBAPModifier.Value    := LowBAP;     
                  end;
            end;
      // Repairing-wearing
      if fRepair > 0
        then
          if fRepair < 100
            then
              begin
                dRepair := fRepair;
                if fRepair + dt < 100
                  then inc( fRepair, round(dt) )
                  else fRepair := 100;
                dRepair := fRepair - dRepair;
                BlockGenMoney( -dRepair/100*RepairPriceShare*Facility.MetaFacility.Price, accIdx_Offices_Repairs );
              end
            else
              begin
                fRepairDate := Facility.Town.Timer.GetVirtualTimeAbs;
                fRepair     := 0;
              end;
      if not Facility.CriticalTrouble
        then HireWorkForce( fOffices.Q/TMetaOfficeBlock(MetaBlock).Capacity )
        else HireWorkForce( 0 );
      // Setting private workers
      for i := low(i) to high(i) do
        fPrivateWorkers[i].CurrValue := fPrivateWorkers[i].CurrValue + fWorkDemand[i].Q;
    end;

  procedure TOfficeBlock.AutoConnect( loaded : boolean );
    var
      TownHall : TBlock;
      i        : TPeopleKind;
    begin
      inherited;      

      // TownHall connections
      TownHall := TInhabitedTown(Facility.Town).TownHall.CurrBlock;
      InputsByName[tidGate_OfsInmigration].ConnectTo( TownHall.OutputsByName[tidGate_OfsInmigration] );
      InputsByName[tidGate_OfsEmigration].ConnectTo( TownHall.OutputsByName[tidGate_OfsEmigration] );
      InputsByName[tidGate_OfsRecycleIn].ConnectTo( TownHall.OutputsByName[tidGate_OfsRecycleIn] );
      OutputsByName[tidGate_Offices].ConnectTo( TownHall.InputsByName[tidGate_Offices] );
      OutputsByName[tidGate_OfsDemand].ConnectTo( TownHall.InputsByName[tidGate_OfsDemand] );
      OutputsByName[tidGate_OfsRecycleOut].ConnectTo( TownHall.InputsByName[tidGate_OfsRecycleOut] );
      fRepairDate := Facility.Town.Timer.GetVirtualTimeAbs;

      // Environmental stuff
      fBeautyModifier :=
        TPyramidalModifier.Create(
          tidEnvironment_Beauty,
          Point(xOrigin, yOrigin),
          MetaBlock.Beauty,
          MetaBlock.BeautyStrength );
      fBAPModifier :=
        TPyramidalModifier.Create(
          tidEnvironment_BAP,
          Point(xOrigin, yOrigin),
          TMetaOfficeBlock(MetaBlock).BAP,
          modStrengthOfBAP );

      fBeautyIntegrator    := TSurfaceIntegrator.Create( tidEnvironment_Beauty, GetArea( modBeautyRatio, amdIncludeBlock ));
      fPollutionIntegrator := TSurfaceIntegrator.Create( tidEnvironment_Pollution, GetArea( modPollutionRatio, amdIncludeBlock ));
      fCrimeIntegrator     := TSurfaceIntegrator.Create( tidEnvironment_Crime, GetArea( modCrimeRatio, amdExcludeBlock ));
      fBAPIntegrator       := TSurfaceIntegrator.Create( tidEnvironment_BAP, GetArea( modBAPRatio, amdExcludeBlock ));

      // Set town parameters
      for i := low(i) to high(i) do
        fPrivateWorkers[i] := Facility.Town.Parameters[tidTownParameter_PrivateWorkers + PeopleKindPrefix[i]];
    end;

  procedure TOfficeBlock.Stop;
    begin
      inherited;
      fOffices.Q    := 0;
      fOfficesRep.Q := 0;
      fDemand.Q     := 0;
      fRecycleOut.Q := 0;
      fBAPModifier.Value := 0;
    end;

  function TOfficeBlock.GetVisualClassId : TVisualClassId;
    var
      MPB : TMetaOfficeBlock;
    begin
      MPB := TMetaOfficeBlock(MetaBlock);
      case MPB.VisualStages of
        2 :
          if LooksUgly
            then result := 1
            else result := 0;
        else result := 0;
      end;
    end;

  function TOfficeBlock.GetRent : TPercent;
    begin
      Facility.Lock;
      try
        result := fRent;
      finally
        Facility.Unlock;
      end;
    end;

  procedure TOfficeBlock.SetRent( aRent : TPercent );
    begin
      Facility.Lock;
      try
        fRent := aRent;
        Facility.UpdateCache;
      finally
        Facility.Unlock;
      end;
    end;

  function TOfficeBlock.GetMaintenance : TPercent;
    begin
      Facility.Lock;
      try
        result := fMaintenance
      finally
        Facility.Unlock;
      end;
    end;

  procedure TOfficeBlock.SetMaintenance( aMaintenance : TPercent );
    begin
      Facility.Lock;
      try
        fMaintenance := aMaintenance;
        Facility.UpdateCache;
      finally
        Facility.Unlock;
      end;
    end;

  function TOfficeBlock.GetOccupancy : TPercent;
    begin
      with TMetaOfficeBlock(MetaBlock) do
        result := round(100*fOffices.Q/Capacity);
    end;

  procedure TOfficeBlock.RdoRepair(useless : integer);
    begin
      fRepair := 1;
    end;

  procedure TOfficeBlock.RdoStopRepair(useless : integer);
    begin
      fRepair := 0;
    end;

  function TOfficeBlock.GetMarketPrice : TMoney;
    begin
      result := OfficesPrice;
    end;

  function TOfficeBlock.GetStatusText( kind : TStatusKind; ToTycoon : TTycoon ) : string;
    begin
      result := inherited GetStatusText( kind, ToTycoon );
      case kind of
        sttMain :
          begin
            if Facility.Trouble and facStoppedByTycoon = 0
              then
                result :=
                  result +
                  SimHints.GetHintText( mtidOfficeTitle.Values[ToTycoon.Language], [0] ) + LineBreak +
                  SimHints.GetHintText( mtidOfficeOccup.Values[ToTycoon.Language], [Occupancy] )
                  {
                     result +
                     'Office Building' + LineBreak +
                     IntToStr(Occupancy) +
                     '% occupancy'
                  }
              else result := SimHints.GetHintText( mtidResClosedByLine.Values[ToTycoon.Language], [0] );
            if fRepair > 0
              then
                result :=
                  result + LineBreak +
                  SimHints.GetHintText( mtidResRepaired.Values[ToTycoon.Language], [fRepair] );
                  //IntToStr(fRepair) + '% repaired';
          end;
        sttSecondary :
          begin
            result :=
              SimHints.GetHintText(
                mtidOfficeReport.Values[ToTycoon.Language],
                [
                round(fOffices.Q),
                fAdm,
                max(0, round(realmin(100, 100*fBAPIntegrator.Media/MaxBAP))),
                max(0, round(realmin(100, 100*fBeautyIntegrator.Media/MaxBeauty))),
                max(0, round(realmin(100, 100*fCrimeIntegrator.Media/MaxCrime))),
                max(0, round(realmin(100, 100*fPollutionIntegrator.Media/MaxPollution)))
                ] );
              {
              IntToStr(round(fOffices.Q)) + ' offices.  ' +
              IntToStr(fAdm) + ' quality index. ' +
              'BAP: ' + IntToStr(max(0, round(realmin(100, 100*fBAPIntegrator.Media/MaxBAP)))) + '% ' +
              'Beauty: ' + IntToStr(max(0, round(realmin(100, 100*fBeautyIntegrator.Media/MaxBeauty)))) + '% ' +
              'Crime: ' + IntToStr(max(0, round(realmin(100, 100*fCrimeIntegrator.Media/MaxCrime)))) + '% ' +
              'Pollution: ' + IntToStr(max(0, round(realmin(100, 100*fPollutionIntegrator.Media/MaxPollution)))) + '%. ';
              }
          end;
        sttHint :
          case Facility.AccessLevelOf( ToTycoon ) of
            acsFull, acsModerate :
              {
              if Facility.Trouble = facNoTrouble
                then
                  begin
                    FillRatio := 100*People.Q/TMetaOfficeBlock(MetaBlock).Capacity;
                    if FillRatio >= (100 + ProfitLimit) div 2
                      then
                        if FillRatio >= 93
                          then result := GetHintText( hidResWorkingFine, [0] )
                          else result := GetHintText( hidResMildUnderPopulated, [0] )
                      else
                        if FillRatio >= ProfitLimit
                          then result := GetHintText( hidResUnderPopulated, [0] )
                          else result := GetHintText( hidResVeryUnderPopulated, [0] )
                  end
                else result := GetHintText( hidVisitWebSite, [0] );
            }
          end;
      end;
    end;

  function TOfficeBlock.GetBAPPercent( value : TSurfaceValue ) : TPercent;
    begin
      result := max(0, round(realmin(100, 100*fBAPIntegrator.Media/MaxBAP)));
    end;

  function TOfficeBlock.GetBeautyPercent( value : TSurfaceValue ) : TPercent;
    begin
      result := max(0, round(realmin(100, 100*value/MaxBeauty)));
    end;

  function TOfficeBlock.GetCrimePercent( value : TSurfaceValue ) : TPercent;
    begin
      result := max(0, round(realmin(100, 100*value/MaxCrime)));
    end;

  function TOfficeBlock.GetPollPercent( value : TSurfaceValue ) : TPercent;
    begin
      result := max(0, round(realmin(100, 100*value/MaxPollution)));
    end;

  procedure TOfficeBlock.StoreToCache( Cache : TObjectCache );
    begin
      inherited;
      Cache.WriteInteger( 'Offices', round(fOffices.Q) );
      Cache.WriteInteger( 'Rent', fRent );
      Cache.WriteInteger( 'Maintenance', fMaintenance );
      Cache.WriteInteger( 'Repair', fRepair );
      Cache.WriteInteger( 'BAP', GetBAPPercent( fBAPIntegrator.Media ));
      Cache.WriteInteger( 'Beauty', GetBeautyPercent( fBeautyIntegrator.Media ));
      Cache.WriteInteger( 'Crime', GetCrimePercent( fCrimeIntegrator.Media ));
      Cache.WriteInteger( 'Pollution', GetPollPercent( fPollutionIntegrator.Media ));
      Cache.WriteString( 'RepairPrice', FormatMoney( RepairPriceShare*Facility.MetaFacility.Price ));
      with TMetaOfficeBlock(MetaBlock) do
        begin
          Cache.WriteInteger( 'ActualCrime', GetCrimePercent( CrimeResist*fCrimeIntegrator.Media ));
          Cache.WriteInteger( 'ActualPollution', GetPollPercent( PollResist*fPollutionIntegrator.Media ));
          Cache.WriteInteger( 'Efficiency', round( 100*Efficiency ));
        end;
      Cache.WriteInteger( 'InvBeauty', round(100*invBeauty) );
      Cache.WriteInteger( 'invCrimeRes', round(100*invCrimeRes) );
      Cache.WriteInteger( 'invPollutionRes', round(100*invPollRes) );
      Cache.WriteInteger( 'invPrivacy', round(100*invPrivacy) );
    end;

  procedure TOfficeBlock.LoadFromBackup( Reader : IBackupReader );
    begin
      inherited;
      LoadFluidData( 'Offices', fOffices, Reader );
      fRent := Reader.ReadByte( 'Rent', 100 );
      fMaintenance := Reader.ReadByte( 'Maintenance', 100 );
      fRepair := Reader.ReadByte( 'Repair', 100 );
      fRepairDate := Reader.ReadInteger( 'RepairDate', 0 ); // >>
      vVisualClassId := GetVisualClassId;
    end;

  procedure TOfficeBlock.StoreToBackup( Writer : IBackupWriter );
    begin
      inherited;
      StoreFluidData( 'Offices', fOffices, Writer );
      Writer.WriteByte( 'Rent', fRent );
      Writer.WriteByte( 'Maintenance', fMaintenance );
      Writer.WriteByte( 'Repair', fRepair );
      Writer.WriteInteger( 'RepairDate', fRepairDate );
    end;

  function TOfficeBlock.LooksUgly : boolean;
    begin
      result := (Occupancy < MinOccupancy) and (Facility.Town.Timer.GetVirtualTimeAbs - fRepairDate > BrandNewEffect);
    end;


  // RegisterBackup

  procedure RegisterBackup;
    begin
      BackupInterfaces.RegisterClass( TOfficeBlock );
    end;



end.



