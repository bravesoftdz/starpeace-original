unit MagnaMarket;

interface

  uses
    Kernel, Surfaces, WorkCenterBlock, StdFluids, ServiceBlock, FoodStore,
    ClothesShop, HHAStore, ToyStore, DrugStore;

  type
    TMetaMagnaMarketBlock =
      class(TMetaServiceBlock)
        public
          constructor Create(anId          : string;
                             aCapacities   : array of TFluidValue;
                             aCompMax      : TFluidValue;
                             aLegalServMax : TFluidValue;
                             aFreshFoodMax : TFluidValue;
                             aElabFoodMax  : TFluidValue;
                             aClotheMax    : TFluidValue;
                             aToyMax       : TFluidValue;
                             aDrugMax      : TFluidValue;
                             aHHAMax       : TFluidValue;
                             aPricePerc    : TPercent;
                             EvlBuyProb    : array of TBuyProbability;
                             aMaxAd        : TFluidValue;
                             aBlockClass   : CBlock);
      end;

    TMagnaMarketBlock =
      class(TServiceBlock)
        private
          fElabFood  : TInputData;
          fFreshFood : TInputData;
          fClothes   : TInputData;
          fToy       : TInputData;
          fDrug      : TInputData;
          fHHA       : TInputData;
      end;

  procedure RegisterBackup;


implementation

  uses
    ClassStorage, PyramidalModifier, Classes, BackupInterfaces,
    Population, MathUtils, StdAccounts;

  // TMetaMagnaMarketBlock

  constructor TMetaMagnaMarketBlock.Create(anId          : string;
                                         aCapacities   : array of TFluidValue;
                                         aCompMax      : TFluidValue;
                                         aLegalServMax : TFluidValue;
                                         aFreshFoodMax : TFluidValue;
                                         aElabFoodMax  : TFluidValue;
                                         aClotheMax    : TFluidValue;
                                         aToyMax       : TFluidValue;
                                         aDrugMax      : TFluidValue;
                                         aHHAMax       : TFluidValue;
                                         aPricePerc    : TPercent;
                                         EvlBuyProb    : array of TBuyProbability;
                                         aMaxAd        : TFluidValue;
                                         aBlockClass   : CBlock);
    var
      Sample           : TMagnaMarketBlock;
      FreshFoodService : TMetaService;
      ElabFoodService  : TMetaService;
      ClothesService   : TMetaService;
      ToyService       : TMetaService;
      DrugService      : TMetaService;
      HHAService       : TMetaService;
    begin
      inherited Create(anId,
        aCapacities,
        accIdx_SuperMarket_Supplies,
        accIdx_SuperMarket_Salaries,
        accIdx_SuperMarket_Sales,
        aMaxAd,
        aBlockClass);
      Sample := nil;

      PresenceFac := 1.25;

      // Services
      FreshFoodService := TMetaService(TheClassStorage.ClassById[tidClassFamily_Services, tidService_FreshFood]);
      ElabFoodService  := TMetaService(TheClassStorage.ClassById[tidClassFamily_Services, tidService_ElabFood]);
      ClothesService   := TMetaService(TheClassStorage.ClassById[tidClassFamily_Services, tidService_Clothes]);
      ToyService       := TMetaService(TheClassStorage.ClassById[tidClassFamily_Services, tidService_Toys]);
      DrugService      := TMetaService(TheClassStorage.ClassById[tidClassFamily_Services, tidService_DrugStore]);
      HHAService       := TMetaService(TheClassStorage.ClassById[tidClassFamily_Services, tidService_HouseHoldingAppliances]);

      // Inputs
      if aFreshFoodMax > 0
        then
          MetaInputs.Insert(
            TMetaInput.Create(
              tidGate_FreshFood,
              inputZero,
              InputData(aFreshFoodMax, 100),
              inputZero,
              qIlimited,
              TPullInput,
              TMetaFluid(TheClassStorage.ClassById[tidClassFamily_Fluids, tidFluid_FreshFood]),
              5,
              mglBasic,
              [mgoptCacheable, mgoptEditable],
              sizeof(Sample.fFreshFood),
              Sample.Offset(Sample.fFreshFood)));

      if aElabFoodMax > 0
        then
          MetaInputs.Insert(
            TMetaInput.Create(
              tidGate_ElabFood,
              inputZero,
              InputData(aElabFoodMax, 100),
              inputZero,
              qIlimited,
              TPullInput,
              TMetaFluid(TheClassStorage.ClassById[tidClassFamily_Fluids, tidFluid_ElabFood]),
              5,
              mglBasic,
              [mgoptCacheable, mgoptEditable],
              sizeof(Sample.fElabFood),
              Sample.Offset(Sample.fElabFood)));

      if aClotheMax > 0
        then
          MetaInputs.Insert(
            TMetaInput.Create(
              tidGate_Clothes,
              inputZero,
              InputData(aClotheMax, 100),
              inputZero,
              qIlimited,
              TPullInput,
              TMetaFluid(TheClassStorage.ClassById[tidClassFamily_Fluids, tidFluid_Clothes]),
              5,
              mglBasic,
              [mgoptCacheable, mgoptEditable],
              sizeof(Sample.fClothes),
              Sample.Offset(Sample.fClothes)));

      if aToyMax > 0
        then
          MetaInputs.Insert(
            TMetaInput.Create(
              tidGate_Toys,
              inputZero,
              InputData(aToyMax, 100),
              inputZero,
              qIlimited,
              TPullInput,
              TMetaFluid(TheClassStorage.ClassById[tidClassFamily_Fluids, tidFluid_Toys]),
              5,
              mglBasic,
              [mgoptCacheable, mgoptEditable],
              sizeof(Sample.fToy),
              Sample.Offset(Sample.fToy)));

      if aDrugMax > 0
        then
          MetaInputs.Insert(
            TMetaInput.Create(
              tidGate_Drugs,
              inputZero,
              InputData(aDrugMax, 100),
              inputZero,
              qIlimited,
              TPullInput,
              TMetaFluid(TheClassStorage.ClassById[tidClassFamily_Fluids, tidFluid_Drugs]),
              5,
              mglBasic,
              [mgoptCacheable, mgoptEditable],
              sizeof(Sample.fDrug),
              Sample.Offset(Sample.fDrug)));

      if aHHAMax > 0
        then
          MetaInputs.Insert(
            TMetaInput.Create(
              tidGate_HouseHoldingAppliances,
              inputZero,
              InputData(aHHAMax, 100),
              inputZero,
              qIlimited,
              TPullInput,
              TMetaFluid(TheClassStorage.ClassById[tidClassFamily_Fluids, tidFluid_HouseHoldingAppliances]),
              5,
              mglBasic,
              [mgoptCacheable, mgoptEditable],
              sizeof(Sample.fHHA),
              Sample.Offset(Sample.fHHA)));


      // Company Inputs
      if aCompMax > 0
        then RegisterCompanyInput(tidFluid_CompServ, aCompMax, false);
      if aLegalServMax > 0
        then RegisterCompanyInput(tidFluid_LegalServ, aLegalServMax, false);

      // Service: Fresh Food
      if aFreshFoodMax > 0
        then
          with TMetaServiceEvaluator.Create(
            FreshFoodService,
            'Fresh Food',
            aPricePerc,
            aFreshFoodMax,
            16,
            EvlBuyProb) do
            begin
              RegisterInput(
                TMetaServiceEvaluatorInput.Create(
                  InputByName[tidGate_FreshFood],
                  1,
                  100));
              Register(self);
            end;

      // Service: Processed Food
      if aElabFoodMax > 0
        then
          with TMetaServiceEvaluator.Create(
            ElabFoodService,
            'Processed Food',
            aPricePerc,
            aElabFoodMax,
            16,
            EvlBuyProb) do
            begin
              RegisterInput(
                TMetaServiceEvaluatorInput.Create(
                  InputByName[tidGate_ElabFood],
                  1,
                  100));
              Register(self);
            end;

      // Service: Clothes
      if aClotheMax > 0
        then
          with TMetaServiceEvaluator.Create(
            ClothesService,
            'Clothes',
            aPricePerc,
            aClotheMax,
            16,
            EvlBuyProb) do
            begin
              RegisterInput(
                TMetaServiceEvaluatorInput.Create(
                  InputByName[tidGate_Clothes],
                  1,
                  100));
              Register(self);
            end;

      // Service: Toys
      if aToyMax > 0
        then
          with TMetaServiceEvaluator.Create(
            ToyService,
            'Toys',
            aPricePerc,
            aToyMax,
            16,
            EvlBuyProb) do
            begin
              RegisterInput(
                TMetaServiceEvaluatorInput.Create(
                  InputByName[tidGate_Toys],
                  1,
                  100));
              Register(self);
            end;

      // Service: Drugs
      if aDrugMax > 0
        then
          with TMetaServiceEvaluator.Create(
            DrugService,
            'Drugs',
            aPricePerc,
            aDrugMax,
            16,
            EvlBuyProb) do
            begin
              RegisterInput(
                TMetaServiceEvaluatorInput.Create(
                  InputByName[tidGate_Drugs],
                  1,
                  100));
              Register(self);
            end;

      // Service: House Holding Appliances
      if aHHAMax > 0
        then
          with TMetaServiceEvaluator.Create(
            HHAService,
            'Household Appliances',
            aPricePerc,
            aHHAMax,
            16,
            EvlBuyProb) do
            begin
              RegisterInput(
                TMetaServiceEvaluatorInput.Create(
                  InputByName[tidGate_HouseHoldingAppliances],
                  1,
                  100));
              Register(self);
            end;
    end;


  // Register backup

  procedure RegisterBackup;
    begin
      BackupInterfaces.RegisterClass(TMagnaMarketBlock);
    end;

end.

