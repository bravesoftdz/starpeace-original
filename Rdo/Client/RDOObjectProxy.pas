unit RDOObjectProxy;

interface

  uses
    Windows,
    Classes,
    SyncObjs,
    ComObj,
    ActiveX,
    {$IFDEF AutoServer}
    RDOClient_TLB,
    {$ENDIF}
    RDOInterfaces;

  type
    TRDOObjectProxy =
      {$IFDEF AutoServer}
      class( TAutoObject, IRDOObjectProxy )
      {$ELSE}
      class( TInterfacedObject, IDispatch )
      {$ENDIF}
          {$IFDEF AutoServer}
        public
          procedure Initialize; override;
          {$ELSE}
        public
          constructor Create;
          {$ENDIF}
          destructor Destroy; override;
        protected // IDispatch
          function GetIDsOfNames( const IID : TGUID; Names : Pointer; NameCount, LocaleID : Integer; DispIDs : Pointer) : HResult; {$IFDEF AutoServer } override; {$ENDIF} stdcall;
          {$IFNDEF AutoServer}
          function GetTypeInfo( Index, LocaleID : Integer; out TypeInfo ) : HResult; stdcall;
          function GetTypeInfoCount( out Count : Integer ) : HResult; stdcall;
          {$ENDIF}
          function Invoke( DispID : Integer; const IID : TGUID; LocaleID : Integer; Flags : Word; var Params; VarResult, ExcepInfo, ArgErr : Pointer ) : HResult; {$IFDEF AutoServer } override; {$ENDIF} stdcall;
        private
          fObjectId      : integer;
          fRDOConnection : IRDOConnection;
          fTimeOut       : integer;
          fWaitForAnswer : boolean;
          fPriority      : integer;
          fErrorCode     : integer;
          fDispIds       : TStringList;
          fDispLock      : TCriticalSection;
        private
          procedure Lock;
          procedure Unlock;
          function  GetSingleThreaded : boolean;
          procedure SetSingleThreaded(value : boolean);
          function  GetDispIndexOf(const name : string) : integer;
          function  AddName(const name : string) : integer;
          function  GetNameAt(index : integer) : string;
        private
          property SingleThreaded : boolean read GetSingleThreaded write SetSingleThreaded;
      end;

implementation

  uses
    {$IFDEF AutoServer}
    ComServ,
    {$ENDIF}
    SysUtils,
    {$IFDEF VER140}
      Variants,
    {$ENDIF}
    ErrorCodes,
    RDOMarshalers;

  const
    BindToName        = 'bindto';
    SetConnectionName = 'setconnection';
    WaitForAnswerName = 'waitforanswer';
    TimeOutName       = 'timeout';
    PriorityName      = 'priority';
    ErrorCodeName     = 'errorcode';
    OnStartPageName   = 'onstartpage';   // Needed for ASP components only
    OnEndPageName     = 'onendpage';     // Needed for ASP components only
    RemoteObjectName  = 'remoteobjectid';

  const
    BaseDispId          = 1000;
    BindToDispId        = BaseDispId + 1;
    SetConnectionDispId = BaseDispId + 2;
    WaitForAnswerDispId = BaseDispId + 3;
    TimeOutDispId       = BaseDispId + 4;
    PriorityDispId      = BaseDispId + 5;
    ErrorCodeDispId     = BaseDispId + 6;
    OnStartPageDispId   = BaseDispId + 7;
    OnEndPageDispId     = BaseDispId + 8;
    RemoteObjectId      = BaseDispId + 9;
    RemoteDispId        = BaseDispId + 10;

  const
    noDispId = -1;

  const
    DefTimeOut = 60000;

  const
    DefPriority = THREAD_PRIORITY_NORMAL;

  type
    PInteger = ^integer;

  function MapQueryErrorToHResult( ErrorCode : integer ) : HResult;
    begin
      case ErrorCode of
        errNoError, errNoResult:
          Result := S_OK;
        errMalformedQuery:
          Result := E_UNEXPECTED;
        errIllegalObject:
          Result := DISP_E_BADCALLEE;
        errUnexistentProperty:
          Result := DISP_E_MEMBERNOTFOUND;
        errIllegalPropValue:
          Result := DISP_E_TYPEMISMATCH;
        errUnexistentMethod:
          Result := DISP_E_MEMBERNOTFOUND;
        errIllegalParamList:
          Result := DISP_E_BADVARTYPE;
        errIllegalPropType:
          Result := DISP_E_BADVARTYPE;
        else
          Result := E_FAIL
      end
    end;

  // TObjectProxy

  {$IFDEF AutoServer}
  procedure TRDOObjectProxy.Initialize;
  {$ELSE}
  constructor TRDOObjectProxy.Create;
  {$ENDIF}
    begin
      inherited;
      fDispLock := TCriticalSection.Create;
      fDispIds  := TStringList.Create;
      fTimeOut  := DefTimeOut;
      fPriority := DefPriority
    end;

  destructor TRDOObjectProxy.Destroy;
    begin
      fDispLock.Free;
      fDispIds.Free;
      inherited;
    end;

  function TRDOObjectProxy.GetIDsOfNames( const IID : TGUID; Names : Pointer; NameCount, LocaleID : Integer; DispIDs : Pointer ) : HResult;

    function MemberNameToDispId( MemberName : string ) : integer;
      const
        LocalMembers : array [ BindToDispId .. RemoteObjectId ] of string =
          (
            BindToName,
            SetConnectionName,
            WaitForAnswerName,
            TimeOutName,
            PriorityName,
            ErrorCodeName,
            OnStartPageName,
            OnEndPageName,
            RemoteObjectName
          );

      var
        MembNamLowerCase : string;

      begin
        result := BindToDispId;
        MembNamLowerCase := LowerCase(MemberName);
        while (result < RemoteDispId) and (LocalMembers[result] <> MembNamLowerCase) do
          inc(result);
      end;

    var
      MemberName : string;
      dspId      : integer;
    begin
      {$IFDEF AutoServer}
      if not Succeeded( inherited GetIDsOfNames( IID, Names, NameCount, LocaleID, DispIDs ) )
        then
          begin
      {$ENDIF}
            // Get prop/meth name
            MemberName := POLEStrList( Names )^[0];
            {$ifopt d+}
              if MainThreadID=GetCurrentThreadID
                then OutputDebugString(pchar(format('Proxy MainThreadID<>GetCurrentThreadID Metodo = %s',[MemberName])));
            // assert(MainThreadID=GetCurrentThreadID, 'Call Server on VCL Thread');
            {$endif}
            // Get id of list
            dspId := GetDispIndexOf(MemberName);
            if dspId = noDispId
              then
                begin
                  dspId := MemberNameToDispId(MemberName);
                  if dspId >= RemoteDispId
                    then dspId := AddName(MemberName);
                end;
            PInteger(DispIDs)^ := dspId;
            Result := NOERROR;
      {$IFDEF AutoServer}
          end
        else result := S_OK;
      {$ENDIF}
    end;

  {$IFNDEF AutoServer}
  function TRDOObjectProxy.GetTypeInfo( Index, LocaleID : Integer; out TypeInfo ) : HResult;
    begin
      pointer( TypeInfo ) := nil;
      Result := E_NOTIMPL
    end;

  function TRDOObjectProxy.GetTypeInfoCount( out Count : Integer ) : HResult;
    begin
      Count := 0;
      Result := NOERROR
    end;
  {$ENDIF}

  function TRDOObjectProxy.Invoke( DispID : Integer; const IID : TGUID; LocaleID : Integer; Flags : Word; var Params; VarResult, ExcepInfo, ArgErr : Pointer ) : HResult;
    var
      Parameters  : TDispParams;
      ParamIdx    : integer;
      RetValue    : variant;
      VarParams   : variant;
      Handled     : boolean;
      ByRefParams : integer;
      MemberName  : string;
    begin
      try
        {$IFDEF AutoServer}
        Result := inherited Invoke( DispId, IID, LocaleID, Flags, Params, VarResult, ExcepInfo, ArgErr );
        if not Succeeded( Result ) and (DispId >= BaseDispId)
          then
            begin
        {$ENDIF}
              Parameters := TDispParams( Params );
              Result := S_OK;
              // Adjust DispId
              if DispId >= RemoteDispId
                then
                  begin
                    MemberName := GetNameAt(DispId);
                    DispId     := RemoteDispId;
                  end
                else MemberName := '';
              case DispId of
                BindToDispId:
                  if fRDOConnection <> nil
                    then
                      if Flags and DISPATCH_METHOD <> 0
                        then
                          if Parameters.cArgs = 1
                            then
                              begin
                                if VarResult <> nil
                                  then PVariant( VarResult )^ := true;
                                case Parameters.rgvarg[ 0 ].vt and VT_TYPEMASK of
                                  VT_INT:
                                    if Parameters.rgvarg[ 0 ].vt and VT_BYREF <> 0
                                      then fObjectId := Parameters.rgvarg[ 0 ].pintVal^
                                      else fObjectId := Parameters.rgvarg[ 0 ].intVal;
                                  VT_I4:
                                    if Parameters.rgvarg[ 0 ].vt and VT_BYREF <> 0
                                      then fObjectId := Parameters.rgvarg[ 0 ].plVal^
                                      else fObjectId := Parameters.rgvarg[ 0 ].lVal;
                                  VT_BSTR:
                                    begin
                                      if Parameters.rgvarg[ 0 ].vt and VT_BYREF <> 0
                                        then fObjectId := MarshalObjIdGet( Parameters.rgvarg[ 0 ].pbstrVal^, fRDOConnection, fTimeOut, fPriority, fErrorCode )
                                        else fObjectId := MarshalObjIdGet( Parameters.rgvarg[ 0 ].bstrVal, fRDOConnection, fTimeOut, fPriority, fErrorCode );
                                      if VarResult <> nil
                                        then
                                          if fErrorCode <> errNoError
                                            then PVariant( VarResult )^ := false
                                    end
                                  else Result := DISP_E_TYPEMISMATCH
                                end
                              end
                            else Result := DISP_E_BADPARAMCOUNT
                        else Result := DISP_E_MEMBERNOTFOUND
                    else
                      if VarResult <> nil
                        then PVariant( VarResult )^ := false;
                SetConnectionDispId:
                  if Flags and DISPATCH_METHOD <> 0
                    then
                      if Parameters.cArgs = 1
                        then
                          begin
                            if Parameters.rgvarg[ 0 ].vt and VT_TYPEMASK = VT_DISPATCH
                              then
                                if Parameters.rgvarg[ 0 ].vt and VT_BYREF <> 0
                                  then
                                    try
                                      fRDOConnection := Parameters.rgvarg[ 0 ].pdispVal^ as IRDOConnection
                                    except
                                      Result := DISP_E_TYPEMISMATCH
                                    end
                                  else
                                    try
                                      fRDOConnection := IDispatch( Parameters.rgvarg[ 0 ].dispVal ) as IRDOConnection
                                    except
                                      Result := DISP_E_TYPEMISMATCH
                                    end
                              else
                                if Parameters.rgvarg[ 0 ].vt and VT_TYPEMASK = VT_UNKNOWN
                                  then
                                    if Parameters.rgvarg[ 0 ].vt and VT_BYREF <> 0
                                      then
                                        try
                                          fRDOConnection := Parameters.rgvarg[ 0 ].punkVal^ as IRDOConnection
                                        except
                                          Result := DISP_E_TYPEMISMATCH
                                        end
                                      else
                                        try
                                          fRDOConnection := IUnknown( Parameters.rgvarg[ 0 ].unkVal ) as IRDOConnection
                                        except
                                          Result := DISP_E_TYPEMISMATCH
                                        end
                                  else
                                    if Parameters.rgvarg[ 0 ].vt and VT_TYPEMASK = VT_VARIANT
                                      then
                                        try
                                          fRDOConnection := IDispatch( Parameters.rgvarg[ 0 ].pvarVal^ ) as IRDOConnection
                                        except
                                          Result := DISP_E_TYPEMISMATCH
                                        end
                                      else
                                        Result := DISP_E_TYPEMISMATCH;
                            if fRDOConnection <> nil
                              then fTimeOut := fRDOConnection.TimeOut;
                          end
                        else
                          Result := DISP_E_BADPARAMCOUNT
                    else
                      Result := DISP_E_MEMBERNOTFOUND;
                WaitForAnswerDispId .. ErrorCodeDispId, RemoteObjectId:
                  if Flags and DISPATCH_PROPERTYGET <> 0 // reading the property
                    then
                      begin
                        if Parameters.cArgs = 0
                          then
                            if VarResult <> nil
                              then
                                case DispId of
                                  WaitForAnswerDispId:
                                    PVariant( VarResult )^ := fWaitForAnswer;
                                  TimeOutDispId:
                                    PVariant( VarResult )^ := fTimeOut;
                                  PriorityDispId:
                                    PVariant( VarResult )^ := fPriority;
                                  ErrorCodeDispId:
                                    PVariant( VarResult )^ := fErrorCode;
                                  RemoteObjectId:
                                    PVariant( VarResult )^ := fObjectId;
                                end
                              else Result := E_INVALIDARG
                          else Result := DISP_E_BADPARAMCOUNT;
                      end
                    else
                      if Flags and DISPATCH_METHOD <> 0 // method call
                        then Result := DISP_E_MEMBERNOTFOUND
                        else // setting the property, must make certain by checking a few other things
                          if Parameters.cArgs = 1
                            then
                              if ( Parameters.cNamedArgs = 1 ) and ( Parameters.rgdispidNamedArgs[ 0 ] = DISPID_PROPERTYPUT )
                                then
                                  case DispId of
                                    WaitForAnswerDispId:
                                      fWaitForAnswer := OleVariant( Parameters.rgvarg[ 0 ] );
                                    TimeOutDispId:
                                      fTimeOut := OleVariant( Parameters.rgvarg[ 0 ] );
                                    PriorityDispId:
                                      fPriority := OleVariant( Parameters.rgvarg[ 0 ] );
                                    ErrorCodeDispId:
                                      fErrorCode := OleVariant( Parameters.rgvarg[ 0 ] )
                                  end
                                else Result := DISP_E_PARAMNOTOPTIONAL
                            else Result := DISP_E_BADPARAMCOUNT;
                OnStartPageDispId, OnEndPageDispId: ;
                RemoteDispId:
                  if fRDOConnection <> nil
                    then
                      begin
                        Handled    := false;
                        if ( Flags and DISPATCH_PROPERTYGET <> 0 ) and ( Parameters.cArgs = 0 ) // property get or call to a method with no args
                          then
                            begin
                              if VarResult <> nil
                                then
                                  begin
                                    Handled := true;
                                    RetValue := MarshalPropertyGet( fObjectId, MemberName, fRDOConnection, fTimeOut, fPriority, fErrorCode );
                                    Result := MapQueryErrorToHResult( fErrorCode );
                                    if Result = S_OK
                                      then PVariant( VarResult )^ := RetValue;
                                  end
                                else
                                  if Flags and DISPATCH_METHOD = 0
                                    then
                                      begin
                                        Handled := true;
                                        Result := E_INVALIDARG
                                      end
                            end;
                        if not Handled
                          then
                            if Flags and DISPATCH_METHOD <> 0 // method call
                              then
                                if Parameters.cNamedArgs =  0
                                  then
                                    begin
                                      ByRefParams := 0;
                                      if Parameters.cArgs <> 0
                                        then
                                          begin
                                            VarParams := VarArrayCreate( [ 1, Parameters.cArgs ], varVariant );
                                            for ParamIdx := 1 to Parameters.cArgs do
                                              begin
                                                VarParams[ ParamIdx ] := OleVariant( Parameters.rgvarg[ Parameters.cArgs - ParamIdx ] );
                                                if TVarData( VarParams[ ParamIdx ] ).VType and varTypeMask = varVariant
                                                  then
                                                    inc( ByRefParams )
                                              end
                                          end
                                        else
                                          VarParams := UnAssigned;
                                      if VarResult <> nil
                                        then TVarData( RetValue ).VType := varVariant
                                        else RetValue := UnAssigned;
                                      if fWaitForAnswer or ( VarResult <> nil ) or ( ByRefParams <> 0 )
                                        then MarshalMethodCall( fObjectId, MemberName, VarParams, RetValue, fRDOConnection, fTimeOut, fPriority, fErrorCode )
                                        else MarshalMethodCall( fObjectId, MemberName, VarParams, RetValue, fRDOConnection, 0, fPriority, fErrorCode );
                                      for ParamIdx := 1 to Parameters.cArgs do
                                        if Parameters.rgvarg[ Parameters.cArgs - ParamIdx ].vt and varTypeMask = VT_VARIANT
                                          then Parameters.rgvarg[ Parameters.cArgs - ParamIdx ].pvarVal^ := VarParams[ ParamIdx ];
                                      VarParams := NULL;
                                      Result := MapQueryErrorToHResult( fErrorCode );
                                      if ( Result = S_OK ) and ( VarResult <> nil )
                                        then PVariant( VarResult )^ := RetValue;
                                    end
                                  else Result := DISP_E_NONAMEDARGS
                              else // property put but, must make certain by checking a few other things
                                if Parameters.cArgs = 1
                                  then
                                    if ( Parameters.cNamedArgs = 1 ) and ( Parameters.rgdispidNamedArgs[ 0 ] = DISPID_PROPERTYPUT )
                                      then
                                        begin
                                          if fWaitForAnswer
                                            then MarshalPropertySet( fObjectId, MemberName, OleVariant( Parameters.rgvarg[ 0 ] ), fRDOConnection, fTimeOut, fPriority, fErrorCode )
                                            else MarshalPropertySet( fObjectId, MemberName, OleVariant( Parameters.rgvarg[ 0 ] ), fRDOConnection, 0, fPriority, fErrorCode );
                                          Result := MapQueryErrorToHResult( fErrorCode )
                                        end
                                      else Result := DISP_E_PARAMNOTOPTIONAL
                                  else Result := DISP_E_BADPARAMCOUNT;
                      end
                    else Result := E_FAIL;
              end;
        {$IFDEF AutoServer}
            end;
        {$ENDIF}
      finally
      end;
    end;

  procedure TRDOObjectProxy.Lock;
    begin
      if fDispLock <> nil
        then fDispLock.Enter;
    end;

  procedure TRDOObjectProxy.Unlock;
    begin
      if fDispLock <> nil
        then fDispLock.Leave;
    end;

  function TRDOObjectProxy.GetSingleThreaded : boolean;
    begin
      result := fDispLock = nil;
    end;

  procedure TRDOObjectProxy.SetSingleThreaded(value : boolean);
    begin
      if value <> SingleThreaded
        then
          if not value
            then fDispLock := TCriticalSection.Create
            else
              begin
                fDispLock.Free;
                fDispLock := nil;
              end;
    end;

  function TRDOObjectProxy.GetDispIndexOf(const name : string) : integer;
    begin
      Lock;
      try
        result := fDispIds.IndexOf(name);
        if result <> -1
          then result := result + RemoteDispId
          else result := noDispId;
      finally
        Unlock;
      end;
    end;

  function TRDOObjectProxy.AddName(const name : string) : integer;
    begin
      Lock;
      try
        result := fDispIds.Add(name) + RemoteDispId;
      finally
        Unlock;
      end;
    end;

  function TRDOObjectProxy.GetNameAt(index : integer) : string;
    begin
      Lock;
      try
        dec(index, RemoteDispId);
        if index < fDispIds.Count
          then result := fDispIds[index]
          else result := '';
      finally
        Unlock;
      end;
    end;


initialization
  {
  MembNameTLSIdx := TLSAlloc;
  if MembNameTLSIdx = $FFFFFFFF
    then
      raise Exception.Create( 'Unable to use thread local storage' );
  }
  {$IFDEF AutoServer}
  TAutoObjectFactory.Create(ComServer, TRDOObjectProxy, Class_RDOObjectProxy, ciMultiInstance, tmApartment);
  {$ENDIF}
finalization
  {
  if MembNameTLSIdx <> $FFFFFFFF
    then
      TLSFree( MembNameTLSIdx )
  }
end.
