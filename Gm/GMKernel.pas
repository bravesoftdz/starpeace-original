unit GMKernel;

interface

  const
    INVALID_GAMEMASTER = 0;
    INVALID_INTSERVER  = 0;

  const
    GM_ERR_NOERROR       = 0;
    GM_ERR_UNEXPECTED    = 1000;
    GM_ERR_NOGMAVAILABLE = 1001;
    GM_ERR_UNKNOWGM      = 1002;
    GM_ERR_UNKNOWNIS     = 1003;
    GM_ERR_UNKNOWMCUST   = 1004;

  const
    GM_STATUS_ONLINE = 1;
    GM_STATUS_AWAY   = 2;

  const
    GM_NOTIFY_USERONLINE  = 1;
    GM_NOTIFY_USERWAITING = 2;

  const
    tidRDOHook_GMServer = 'GMServer';

  type
    TGameMasterId = integer;
    TCustomerId   = widestring;
    TErrorCode    = integer;
    TIServerId    = integer;

    IGMCustomer =
      interface['{B3B4FFC0-415B-11D4-8301-00A0CC2C3344}']
        procedure GameMasterMsg( Msg : WideString; Info : integer );
        procedure GMNotify( notID : integer; Info : WideString );
      end;

    IInterfaceServer =
      interface['{B3B4FFC1-415B-11D4-8301-00A0CC2C3344}']
        function  ConnectToGameMaster( ClientId : TCustomerId; ClientInfo : widestring; GameMasters : widestring ) : OleVariant;
        function  SendGMMessage( ClientId : TCustomerId; GMId : TGameMasterId; Msg : WideString ) : OleVariant;
        procedure DisconnectUser( ClientId : TCustomerId; GMId : TGameMasterId );
      end;

    IIServerConnection =
      interface['{B3B4FFC4-415B-11D4-8301-00A0CC2C3344}']
        function  GameMasterMsg( ClientId : TCustomerId; Msg : WideString; Info : integer ) : OleVariant;
        procedure GMNotify( ClientId : TCustomerId; notID : integer; Info : WideString );
      end;

    IGMServer =
      interface['{B3B4FFC2-415B-11D4-8301-00A0CC2C3344}']
        function  RegisterInterfaceServer( IsId : TIServerId; ClientId : integer; Info : WideString) : Olevariant;
        procedure UnRegisterCustomer( ISId : TIServerId; aCustomerId : TCustomerId );
        procedure DisconnectUser( ISId : TIServerId; ClientId : TCustomerId; GMId : TGameMasterId );
        function  ConnectToGameMaster( ISId : TIServerId; ClientId : TCustomerId; ClientInfo : widestring; GameMasters : widestring ) : OleVariant;
        function  SendGMMessage( ISId : TIServerId; ClientId : TCustomerId; GMId : TGameMasterId; Msg : WideString ) : OleVariant;
      end;

    IGMServerConnection =
      interface['{B3B4FFC5-415B-11D4-8301-00A0CC2C3344}']
        function  RegisterGameMaster( ClientId : integer; GMId : TGameMasterId; GMName : widestring; GMPassword : widestring ) : OleVariant;
        procedure NotifyGMStatus( GMId : TGameMasterId; Status : integer; Customers : integer; Pending : integer );
        procedure UserNotification( ISId : TIServerId; CustomerId : TCustomerId; notID : integer; Info : WideString );
        function  SendMessage( ISId : TIServerId; CustomerId : TCustomerId; Msg : WideString; Info : integer ) : OleVariant;
      end;

    IGameMaster =
      interface['{B3B4FFC3-415B-11D4-8301-00A0CC2C3344}']
        function  AddCustomer( ISId : TIServerId; CustomerId : TCustomerId; ClientInfo : widestring) : olevariant;
        procedure CustomerMsg( ISId : TIServerId; CustomerId : TCustomerId; Msg : WideString );
        procedure UnRegisterCustomer( ISId : TIServerId; aCustomerId : TCustomerId );
        procedure UnRegisterIServer( aIsId : TIServerId );
      end;

  function GMErrorToStr( error : TErrorCode ) : WideString;
  function GMStatusToStr( GMStatus : integer ) : WideString;

implementation

  function GMErrorToStr( error : TErrorCode ) : WideString;
    begin
      case error of
        GM_ERR_NOERROR       : result := 'No error!';
        GM_ERR_UNEXPECTED    : result := 'Unexpected error occurred';
        GM_ERR_NOGMAVAILABLE : result := 'Sorry, No Game Master available at this time, please try again later';
        GM_ERR_UNKNOWGM      : result := 'No such Game Master';
        GM_ERR_UNKNOWNIS     : result := 'No such interface server';
        GM_ERR_UNKNOWMCUST   : result := 'No such customer';
        else                   result := 'Unknown error';
      end;
    end;

  function GMStatusToStr( GMStatus : integer ) : WideString;
    begin
      case GMStatus of
        GM_STATUS_ONLINE : result := 'Game Master Ready';
        GM_STATUS_AWAY   : result := 'Game Master is Away';
        else               result := 'Unknown error';
      end;
    end;

end.


