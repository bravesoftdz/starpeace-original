unit Warehouses;

interface

  uses
    Collection, Kernel, Protocol, Surfaces, WorkCenterBlock, BackupInterfaces,
    CacheAgent, CacheCommon, Languages;

  const
    MinQualityIndex = 5;

  const
    WFEfficLimit = 0.80;
    MaxWares     = 16;

  type
    TMetaWarehouse = class;
    TMetaWare      = class;
    TWarehouse     = class;

    TMetaWarehouse =
      class(TMetaWorkCenter)
        public
          constructor Create(anId : string; aCapacities : array of TFluidValue; aBlockClass : CBlock);
          destructor  Destroy; override;
        protected
          procedure NewMetaInput (Gate, Fluid : string; MaxCap : TFluidValue; datasize, offset : integer);
          procedure NewMetaOutput(Gate, Fluid : string; MaxCap : TFluidValue; datasize, offset : integer);
        private
          fMetaWares : TCollection;
        public
          procedure RegisterWare(InputName : string; aWFPerc, DepFac, DefOverPrice : TPercent; MaxCapacity : TFluidValue);
        private
          function GetWareCount : integer;
          function GetWare(index : integer) : TMetaWare;
        public
          property WareCount : integer read GetWareCount;
          property Wares[index : integer] : TMetaWare read GetWare;
      end;

    TMetaWare =
      class
        public
          constructor Create(MetaInput  : TMetaInput; MetaOutput : TMetaOutput; DepFac, OverPrice : TPercent);
        private
          fMetaInput  : TMetaInput;
          fMetaOutput : TMetaOutput;
          fDepFac     : TPercent;
          fOverPrice  : TPercent;
      end;

    TWareInfo =
      record
        //FillPerc : TPercent;
        Stored   : TFluidValue;
        K        : single;
        Stock    : TFluidValue;
      end;

    PWareInfoArray = ^TWareInfoArray;
    TWareInfoArray = array[0..MaxWares - 1] of TWareInfo;

    TWarehouse =
      class(TFinanciatedWorkCenter)
        private
          fWares : PWareInfoArray;
          fRole  : TFacilityRole;
        private
          procedure FixPrices(count : integer);
          //function  GetPriceOf(Input : TInput; DefVal : TPercent) : single;
        protected
          function  GetStatusText( kind : TStatusKind; ToTycoon : TTycoon ) : string; override;
          function  Evaluate : TEvaluationResult; override;
        public
          procedure AutoConnect( loaded : boolean ); override;
        private
          function  GetWareCount : integer;
          function  GetWare(index : integer) : TMetaWare;
          function  GetFillPerc(index : integer) : TPercent;
        public
          property  WareCount : integer read GetWareCount;
          property  Wares[index : integer] : TMetaWare read GetWare;
          property  FillPerc[index : integer] : TPercent read GetFillPerc;
        private
          procedure CalculateWareQuality(index : integer);
        published
          procedure RDOSetRole( aRole : integer );
        protected
          function  GetRole : TFacilityRole; override;
          procedure LoadFromBackup( Reader : IBackupReader ); override;
          procedure StoreToBackup ( Writer : IBackupWriter ); override;
          function  GetVisualClassId : TVisualClassId;        override;
        private
          fWasInTrouble : boolean;
        protected
          procedure BlockLoaded; override;
      end;

implementation

  uses
    SysUtils, ClassStorage, MathUtils, Population, SimHints, StdAccounts, Math;

  // TMetaWarehouse

  constructor TMetaWarehouse.Create(anId : string; aCapacities : array of TFluidValue; aBlockClass : CBlock);
    begin
      inherited Create(anId,
        aCapacities,
        accIdx_Warehouses_Supplies,
        accIdx_Warehouses_Products,
        accIdx_Warehouses_Salaries,
        aBlockClass);
      fMetaWares    := TCollection.Create(0, rkBelonguer);
      MinWFRequired := 0.5;
    end;

  destructor TMetaWarehouse.Destroy;
    begin
      fMetaWares.Free;
      inherited;
    end;
                      
  procedure TMetaWarehouse.NewMetaInput(Gate, Fluid : string; MaxCap : TFluidValue; datasize, offset : integer);
    begin
      MetaInputs.Insert(
        TMetaInput.Create(
          Gate,
          inputZero,
          InputData(MaxCap, 100),
          inputZero,
          qIlimited,
          TPullInput,
          TMetaFluid(TheClassStorage.ClassById[tidClassFamily_Fluids, Fluid]),
          5,
          mglAditional,
          [mgoptCacheable, mgoptEditable],
          datasize,
          offset));
    end;

  procedure TMetaWarehouse.NewMetaOutput(Gate, Fluid : string; MaxCap : TFluidValue; datasize, offset : integer);
    begin
      MetaOutputs.Insert(
        TMetaOutput.Create(
          Gate,
          FluidData(MaxCap, 100),
          TPullOutput,
          TMetaFluid(TheClassStorage.ClassById[tidClassFamily_Fluids, Fluid]),
          5,
          [mgoptCacheable, mgoptEditable],
          datasize,
          offset));
    end;

  procedure TMetaWarehouse.RegisterWare(InputName : string; aWFPerc, DepFac, DefOverPrice : TPercent; MaxCapacity : TFluidValue);
    var
      Input  : TMetaInput;
      Output : TMetaOutput;
    begin
      Input  := InputByName[InputName];
      Output := OutputByName[InputName];
      if (Input <> nil) and (Output <> nil)
        then
          begin
            fMetaWares.Insert(
              TMetaWare.Create(
                Input,
                Output,
                DepFac,
                DefOverPrice));
          end;
    end;

  function TMetaWarehouse.GetWareCount : integer;
    begin
      result := fMetaWares.Count;
    end;

  function TMetaWarehouse.GetWare(index : integer) : TMetaWare;
    begin
      result := TMetaWare(fMetaWares[index]);
    end;

  // TMetaWare

  constructor TMetaWare.Create(MetaInput : TMetaInput; MetaOutput : TMetaOutput; DepFac, OverPrice : TPercent);
    begin
      fMetaInput  := MetaInput;
      fMetaOutput := MetaOutput;
      fDepFac     := DepFac;
      fOverPrice  := OverPrice;
    end;

  // TWarehouse

  procedure TWarehouse.FixPrices(count : integer);
    var
      i : integer;
    begin
      if count > 0
        then
          begin
            with TMetaWarehouse(MetaBlock) do
              for i := 0 to pred(WareCount) do
                Outputs[Wares[i].fMetaOutput.Index].PricePerc := Wares[i].fOverPrice;
          end;
    end;

  function TWarehouse.GetStatusText( kind : TStatusKind; ToTycoon : TTycoon ) : string;
    var
      OutputAbstract : string;
      i              : integer;
      k              : TPeopleKind;
    begin
      result := inherited GetStatusText(kind, ToTyCoon);
      case kind of
        sttMain :
          begin
            if not Facility.CriticalTrouble
              then
                if Facility.Trouble and facNeedsWorkForce <> 0
                  then
                    result := result + SimHints.GetHintText( mtidHiringWorkForce.Values[ToTycoon.Language], [round(100*WorkForceEfficiency)] )
                  else
                    begin
                      for i := 0 to pred(WareCount) do
                        begin
                          OutputAbstract := OutputAbstract + ' ' + Wares[i].fMetaInput.MetaFluid.Name_MLS.Values[ToTycoon.Language] + ': ' + IntToStr(FillPerc[i]) + '%';
                          if i <> pred(WareCount)
                            then OutputAbstract := OutputAbstract + LineBreak
                            else OutputAbstract := OutputAbstract + '.'
                        end;
                      result := result + OutputAbstract;
                    end;
          end;
        sttSecondary :
          begin
            if not Facility.CriticalTrouble
              then
                if Facility.Trouble and facNeedsWorkForce = 0
                  then
                    begin
                      result := SimHints.GetHintText( mtidWarehouseRepHead.Values[ToTycoon.Language], [0] ) + ' ';
                      for i := 0 to pred(WareCount) do
                        begin
                          result :=
                            result +
                            SimHints.GetHintText(
                              mtidWarehouseRepN.Values[ToTycoon.Language],
                              [
                              //Wares[i].fMetaInput.MetaFluid.FormatSingleValue((fWares[i].FillPerc/100)*Wares[i].fMetaInput.MaxFluid.Q, ToTycoon.Language),
                              Wares[i].fMetaInput.MetaFluid.FormatSingleValue(realmin(Wares[i].fMetaOutput.MaxFluid.Q, fWares[i].Stock), ToTycoon.Language),
                              Wares[i].fMetaInput.MetaFluid.Name_MLS.Values[ToTycoon.Language],
                              SmartRound(fWares[i].K)
                              ] );
                          if i <> pred(WareCount)
                            then result := result + '  '
                            else result := result + '.';
                        end;
                    end
                  else
                    with TMetaWorkCenter(MetaBlock) do
                      for k := low(k) to high(k) do
                        if Capacity[k] > 0
                          then
                            begin
                              if WorkersMax[k].Q > 0
                                then
                                  begin
                                    result := result +
                                      SimHints.GetHintText(
                                        mtidHiringWorkForceSec.Values[ToTycoon.Language],
                                        [
                                        mtidWorkforceKindName[k].Values[ToTycoon.Language],
                                        round(Workers[k].Q),
                                        round(WorkersMax[k].Q)
                                        ] );
                                  end;
                            end;
          end;
        sttHint :
          case Facility.AccessLevelOf( ToTycoon ) of
            acsFull, acsModerate :
              begin
                if Facility.Trouble and facNeedCompSupport <> 0
                  then result := GetHintText(mtidNeedsCompSupport.Values[ToTycoon.Language], [0])
              end;
          end;
      end;
    end;

  {
  function TWarehouse.GetPriceOf(Input : TInput; DefVal : TPercent) : single;
    begin
      if Input.FluidData.Q > 0
        then result := Input.LastCost/(Input.FluidData.Q*Input.MetaInput.MetaFluid.MarketPrice)
        else result := DefVal;
    end;
  }

  function TWarehouse.Evaluate : TEvaluationResult;
    var
      i       : integer;
      Output  : TOutput;
      Input   : TInput;
      Total   : TFluidValue;
      WEffic  : single;
      OpRatio : integer;
      Extra   : TFluidValue;
      Delta   : TFluidValue;
    begin
      result := inherited Evaluate;
      if not Facility.CriticalTrouble
        then
          begin
            OpRatio := 0;
            WEffic  := WorkForceEfficiency;
            for i := 0 to pred(WareCount) do
              with TMetaWarehouse(MetaBlock).Wares[i] do
                begin
                  Input  := Inputs[fMetaInput.Index];
                  Output := Outputs[fMetaOutput.Index];
                  Extra  := POutputData(Output.FluidData).Extra.Q;
                  Delta  := realmax(0, fWares[i].Stored - Extra);
                  // Extra to stored
                  if not fWasInTrouble
                    then
                      begin
                        // Reincorporate the extra to the temp stock
                        fWares[i].Stored := realmax(0, Extra); // realmin(Output.MetaOutput.MaxFluid.Q, Extra));
                        fWares[i].K := realmax(fWares[i].K, POutputData(Output.FluidData).Extra.K);
                        // Quality(stored value, input value)
                        CalculateWareQuality(i);
                      end
                    else Extra := fWares[i].Stored;

                  // Output Quality
                  Output.FluidData.K := SmartRound(fWares[i].K);

                  // Total Fluid
                  Total := fWares[i].Stored + Input.FluidData.Q; //realmin(Output.MetaOutput.MaxFluid.Q, fWares[i].Stored + Input.FluidData.Q);
                  fWares[i].Stored   := Total;
                  Output.FluidData.Q := Total;

                  // Stock to show
                  fWares[i].Stock := Extra;

                  // Clear extra
                  POutputData(Output.FluidData).Extra.Q := 0;
                  Input.ActualMaxFluid.Q := realmax(0, WEffic*(Output.MetaOutput.MaxFluid.Q - Extra + Delta));
                  Input.MaxCapacity      := Input.ActualMaxFluid.Q;

                  // Operation ratio
                  OpRatio := OpRatio + 1;
                end;
            OpRatio := round(OpRatio/WareCount);
            HireWorkForce(1);
            SetCargoValue( carLight, OpRatio/10 );
            fWasInTrouble := false;
          end
        else
          begin
            for i := 0 to pred(WareCount) do
              with TMetaWarehouse(MetaBlock).Wares[i] do
                begin
                  Output := Outputs[fMetaOutput.Index];
                  if not fWasInTrouble
                    then
                      begin
                        Input := Inputs[fMetaInput.Index];
                        CalculateWareQuality(i);
                        fWares[i].Stored := fWares[i].Stored + Input.FluidData.Q;
                        fWares[i].Stock  := fWares[i].Stored;
                      end;
                  Output.FluidData.Q := 0;
                  Output.FluidData.K := 0;
                  POutputData(Output.FluidData).Extra.Q := 0;
                  POutputData(Output.FluidData).Extra.K := 0;
                end;
            fWasInTrouble := true;
          end;
    end;

  procedure TWarehouse.AutoConnect( loaded : boolean );
    var
      i : integer;
    begin
      if not loaded
        then fRole := rolDistributer;
      inherited;
      ReallocMem(fWares, WareCount*sizeof(fWares[0]));
      FillChar(fWares^, WareCount*sizeof(fWares[0]), 0);
      if not loaded
        then
          begin
            FixPrices(WareCount);
            Facility.Stopped := true;
          end
        else
          for i := 0 to pred(WareCount) do
            fWares[i].K := POutputData(Outputs[TMetaWarehouse(MetaBlock).Wares[i].fMetaOutput.Index].FluidData).Extra.K;
    end;

  function TWarehouse.GetWareCount : integer;
    begin
      result := TMetaWarehouse(MetaBlock).WareCount;
    end;

  function TWarehouse.GetWare(index : integer) : TMetaWare;
    begin
      result := TMetaWarehouse(MetaBlock).Wares[index];
    end;

  function TWarehouse.GetFillPerc(index : integer) : TPercent;
    var
      Output : TOutput;
    begin
      with TMetaWarehouse(MetaBlock).Wares[index] do
        begin
          Output := Outputs[fMetaOutput.Index];
          result := min(100, SmartRound(100*fWares[index].Stock/(Output.MetaOutput.MaxFluid.Q))); // dt
        end;
    end;

  procedure TWarehouse.CalculateWareQuality(index : integer);
    var
      Input  : TInput;
      WQ     : TFluidValue;
      WK     : single;
      IQ     : TFluidValue;
      IK     : TPercent;
    begin
      with TMetaWarehouse(MetaBlock).Wares[index] do
        begin
          Input  := Inputs[fMetaInput.Index];

          // Avoid the case of zero quality.
          WK := fWares[index].K;
          if WK > 0
            then WQ := fWares[index].Stored
            else WQ := 0;

          // Avoid the case of zero quality.
          IK := Input.FluidData.K;
          if IK > 0
            then IQ := Input.FluidData.Q
            else IQ := 0;

          // Average the Qualities
          if IQ + WQ > 0
            then fWares[index].K := (IQ*IK + WQ*WK)/(IQ + WQ)
            else fWares[index].K := 0;
        end;
    end;

  procedure TWarehouse.RDOSetRole( aRole : integer );
    var
      i : integer;
    begin
      try
        fRole := TFacilityRole(aRole);
        for i := 0 to pred(InputCount) do  
          Inputs[i].SortConnections;
        for i := 0 to pred(OutputCount) do
          Outputs[i].SortConnections;
        Facility.UpdateCache;
      except
      end;
    end;

  function TWarehouse.GetRole : TFacilityRole;  
    begin
      result := fRole;
    end;

  procedure TWarehouse.LoadFromBackup( Reader : IBackupReader );
    begin
      inherited;
      fRole := TFacilityRole(Reader.ReadInteger( 'Role', integer(rolDistributer) ));
    end;

  procedure TWarehouse.StoreToBackup( Writer : IBackupWriter );

    const
      acClear = 0;
      acSave  = 1;

    procedure SaveToExtra(action : integer);
      var
        i      : integer;
        Output : TOutput;
      begin
        for i := 0 to pred(WareCount) do
          with TMetaWarehouse(MetaBlock).Wares[i] do
            begin
              Output := Outputs[fMetaOutput.Index];
              case action of
                acClear :
                  begin
                    POutputData(Output.FluidData).Extra.Q := 0;
                    POutputData(Output.FluidData).Extra.K := 0;
                  end;
                acSave :
                  begin
                    POutputData(Output.FluidData).Extra.Q := fWares[i].Stored;
                    POutputData(Output.FluidData).Extra.K := ceil(fWares[i].K);
                  end;
            end;
          end;
      end;

    begin
      if Facility.CriticalTrouble
        then SaveToExtra(acSave);

      inherited;
      Writer.WriteInteger( 'Role', integer(fRole) );

      if Facility.CriticalTrouble and fWasInTrouble
        then SaveToExtra(acClear);
    end;

  function TWarehouse.GetVisualClassId : TVisualClassId;
    var
      MPB : TMetaBlock;
    begin
      MPB := TMetaBlock(MetaBlock);
      case MPB.VisualStages of
        3 :
          case Role of
            rolCompExport :
              result := 1;
            rolCompInport :
              result := 2;
            else
              result := 0;
          end;
        else result := 0;
      end;
    end;

  procedure TWarehouse.BlockLoaded;

    procedure GetStoredFromExtra;
      var
        i      : integer;
        Output : TOutput;
      begin
        for i := 0 to pred(WareCount) do
          with TMetaWarehouse(MetaBlock).Wares[i] do
            begin
              Output := Outputs[fMetaOutput.Index];
              fWares[i].Stored := POutputData(Output.FluidData).Extra.Q;
              fWares[i].K      := POutputData(Output.FluidData).Extra.K;
            end;
      end;

    begin
      inherited;
      if Facility.CriticalTrouble
        then GetStoredFromExtra;
    end;

end.



