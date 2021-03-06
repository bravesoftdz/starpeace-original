unit Explorer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ImgList, StdCtrls, Buttons, ExtCtrls, ComCtrls,   WinSockRDOConnection, //RDOServer,
  RDOInterfaces, RDOObjectProxy, ToolWin;



type
  TSQLExplorer = class(TForm)
    FiveListView: TListView;
    Panel1: TPanel;
    cbCurrKey: TComboBox;
    Label1: TLabel;
    ImageList1: TImageList;
    mmFiveDB: TMainMenu;
    spUpKey: TSpeedButton;
    File1: TMenuItem;
    Refresh1: TMenuItem;
    ExitMenu: TMenuItem;
    InitConnectionMenu: TMenuItem;
    EndConnectionMenu: TMenuItem;
    PopupMenu1: TPopupMenu;
    Edit1: TMenuItem;
    Delete1: TMenuItem;
    New1: TMenuItem;
    InsertValue1: TMenuItem;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Tools1: TMenuItem;
    FindUser: TMenuItem;
    FindSubscriptionID: TMenuItem;
    FindTransaction: TMenuItem;
    FindSerialNumber: TMenuItem;
    N1: TMenuItem;
    UnsubscribeUser1: TMenuItem;
    N2: TMenuItem;
    Stats: TMenuItem;
    FindUserWorlds1: TMenuItem;
    BlockUnblockUser: TMenuItem;
    FindSegaUser: TMenuItem;
    procedure FormDestroy(Sender: TObject);
    procedure FiveListViewDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FiveListViewKeyPress(Sender: TObject; var Key: Char);
    procedure cbCurrKeyKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure spUpKeyClick(Sender: TObject);
    procedure RefreshEntryClick(Sender: TObject);
    procedure ExitClick(Sender: TObject);
    procedure InitConnectionClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EndConnectionClick(Sender: TObject);
    procedure InsertKeyClick(Sender: TObject);
    procedure DeleteEntryClick(Sender: TObject);
    procedure FiveListViewEdited(Sender: TObject; Item: TListItem; var S: String);
    procedure ConfigurationClick(Sender: TObject);
    procedure EditValueClick(Sender: TObject);
    procedure InsertValueClick(Sender: TObject);
    procedure FindUserClick(Sender: TObject);
    procedure FindSubscriptionIDClick(Sender: TObject);
    procedure FindTransactionClick(Sender: TObject);
    procedure FindSerialNumberClick(Sender: TObject);
    procedure UnsubscribeUser1Click(Sender: TObject);
    procedure StatsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FindUserWorlds1Click(Sender: TObject);
    procedure BlockUnblockUserClick(Sender: TObject);
    procedure cbCurrKeyChange(Sender: TObject);
    procedure FindSegaUserClick(Sender: TObject);
  private
    function InitConnection : boolean;
    procedure LoadFirstKeys;
    function CanEdit : boolean;//root/users/b/boldbald/accountinfo
  public
    ISCnx    : IRDOConnectionInit;
    WSISCnx  : TWinSockRDOConnection;
    ISProxy  : OleVariant;
    Ending   : boolean ;
  private
    IsConfig : boolean;
  end;

var
  SQLExplorer: TSQLExplorer;

implementation

uses
  Configuration, NewKeyFrm, EditValueFrm, ComObj, FMsgBx, SubsExplorerFrm,
  StatsExplorerPlotter, BlockUnBlock;
  //StatsExplorerPlotter;

// RDOIsSecureValue

{$R *.DFM}

function TSQLExplorer.CanEdit : boolean;//root/users/b/boldbald/accountinfo
var
  saveKey : widestring;
begin
  //  root/users/b/boldbald/accountinfo
  Result := true;
  if not ConfigurationFrm.FullControl.Checked
    then
      begin
        saveKey := ISProxy.RDOGetCurrentKey;
        if (pos( 'root/users/', saveKey) = 1) and ( pos('/accountinfo', saveKey)<>0 )
          then
            Result := true
          else
            Result := false;
      end;
end;

function TSQLExplorer.InitConnection : boolean;
var
  session : integer;
begin
   try
     WSISCnx      := TWinSockRDOConnection.Create ('cnt1');
     ISCnx        := WSISCnx;
     ISCnx.Server := ConfigurationFrm.cboServers.Text ;//IpConfig.Text;
     ISCnx.Port   := StrToInt(ConfigurationFrm.cboPorts.Text);//Edit2.Text);
     ISProxy      := TRDOObjectProxy.Create as IDispatch;
     result       := false;
     if ISCnx.Connect( 20000 )
       then
         begin
           ISProxy.SetConnection( ISCnx );
           ISProxy.BindTo('DirectoryServer');
           ISProxy.TimeOut := 20000;
           try
             session := ISProxy.RDOOpenSession;
             ISProxy.BindTo( session );
             //Caption := IntToStr(session);
             ISProxy.WaitForAnswer := true;
             result := true ;
           except
             result := false;
           end;
         end
   except
     result := false;
   end;
end;{ TSQLExplorerFrm.InitConnection }

procedure TSQLExplorer.FormDestroy(Sender: TObject);
begin
  if EndConnectionMenu.Enabled = true
   then ISProxy.RDOEndSession;
end;

procedure TSQLExplorer.LoadFirstKeys;
var
  bool      : olevariant;
  i, sec    : integer;
  ListItem  : TListItem;
  EntryList : TStringList;
begin
  EntryList := TStringList.Create;
  try
    FiveListView.Items.BeginUpdate;
    try
      FiveListView.Items.Clear;
      cbCurrKey.Text := '';
      bool := ISProxy.RDOSetCurrentKey('');
      if not ConfigurationFrm.FullControl.Checked
        then
          cbCurrKeyChange( cbCurrKey );
      if bool
        then
          begin
            EntryList.Text := ISProxy.RDOGetKeyNames;
            for i := 0 to EntryList.Count - 1 do
              begin
                ListItem := FiveListView.Items.Add;
                ListItem.Caption := EntryList.Strings[i];
                ListItem.SubItems.Add('0');
                ListItem.SubItems.Add('');
                sec := ISProxy.RDOIsSecureKey(EntryList.Strings[i]);
                ListItem.SubItems.Add(IntToStr(sec));
              end;
          end;
      finally
        FiveListView.Items.EndUpdate;
      end;
  finally
    EntryList.Free;
  end;
end; {TALSPFrm.LoadDataBase}

procedure TSQLExplorer.FiveListViewDblClick(Sender: TObject);
var
  theItem   : TListItem;
  bool      : olevariant;
  i         : integer;
  kind, sec : integer;
  ListItem  : TListItem;
  EntryList : TStringList;
  NodeName  : string;
begin
    theItem   := FiveListView.ItemFocused;
    EntryList := TStringList.Create;
    if cbCurrKey.Text <> ''
      then
        begin
          if theItem <> nil
            then NodeName := cbCurrKey.Text + '/' + theItem.Caption
            else NodeName := cbCurrKey.Text;
        end
      else
        begin
          if theItem <> nil
            then NodeName := theItem.Caption
            else NodeName := ''
        end;
    Screen.Cursor := crHourGlass ;
    try
      bool := ISProxy.RDOSetCurrentKey(NodeName);
      if not bool
        then
          if FiveListView.Items.Count > 0
            then
              if FiveListView.Items.Item[0].ImageIndex > 0
                then
                  begin
                    i := LastDelimiter('/', NodeName );
                    if i > 0
                      then NodeName := Copy(NodeName, 0, i-1);
                    bool := ISProxy.RDOSetCurrentKey(NodeName);
                  end;
      if bool
        then
          begin
            if not ConfigurationFrm.FullControl.Checked
              then
                cbCurrKeyChange( cbCurrKey );
            FiveListView.Items.BeginUpdate;
            try
              FiveListView.Items.Clear;
              cbCurrKey.Text             := NodeName;
              FiveListView.Enabled       := false;
              FiveListView.HideSelection := true;
              EntryList.Text             := ISProxy.RDOGetKeyNames;
              if EntryList.Count > 0
                then
                  begin
                    for i := 0 to EntryList.Count - 1 do
                      begin
                        NodeName := cbCurrKey.Text + '/' + EntryList.Strings[i];
                        ListItem := FiveListView.Items.Add;
                        ListItem.Caption := EntryList.Strings[i];
                        ListItem.SubItems.Add('0');
                        ListItem.SubItems.Add('');
                        sec := ISProxy.RDOIsSecureKey(NodeName);
                        ListItem.SubItems.Add(IntToStr(sec));
                      end;
                  end;
              EntryList.Text := ISProxy.RDOGetValueNames;
              if EntryList.Count > 0
                then
                  begin
                    for i := 0 to EntryList.Count - 1 do
                      begin
                        NodeName         := cbCurrKey.Text + '/' + EntryList.Strings[i];
                        sec              := ISProxy.RDOIsSecureValue(NodeName);
                        kind             := ISProxy.RDOTypeOf(NodeName);
                        ListItem         := FiveListView.Items.Add;
                        ListItem.Caption := EntryList.Strings[i];
                        ListItem.ImageIndex := 1;
                        ListItem.SubItems.Add( IntToStr(kind) );
                        case Kind of
                          1 : ListItem.SubItems.Add( IntToStr  (ISProxy.RDOReadBoolean (EntryList.Strings[i]) ) );
                          2 : ListItem.SubItems.Add( IntToStr  (ISProxy.RDOReadInteger (EntryList.Strings[i]) ) );
                          3 : ListItem.SubItems.Add( FloatToStr(ISProxy.RDOReadFloat   (EntryList.Strings[i]) ) );
                          4 : ListItem.SubItems.Add(            ISProxy.RDOReadString  (EntryList.Strings[i]  ) );
                          5 : ListItem.SubItems.Add( DateToStr (ISProxy.RDOReadDate    (EntryList.Strings[i]) ) );
                          6 : ListItem.SubItems.Add( CurrToStr (ISProxy.RDOReadCurrency(EntryList.Strings[i]) ) );
                          7 : ListItem.SubItems.Add(            ISProxy.RDOReadString  (EntryList.Strings[i]  ) );
                        end;
                        ListItem.SubItems.Add( IntToStr( sec ) );
                      end;
                  end;
              FiveListView.Enabled := true;
              FiveListView.HideSelection := false;
            finally
              FiveListView.Items.EndUpdate;
            end
          end;
    finally
      Screen.Cursor := crDefault ;
      EntryList.Free;
    end;
end;{ TSQLExplorer.FiveListViewDblClick }

procedure TSQLExplorer.FormResize(Sender: TObject);
begin
 cbCurrKey.Width := Width - 110;
 spUpKey.Left    := Width - 37;
end;{ TSQLExplorer.FormResize }

procedure TSQLExplorer.FiveListViewKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #13 : FiveListViewDblClick(Sender);
    #8  : spUpKeyClick(Sender);
  end;
end;{ TSQLExplorer.FiveListViewKeyPress }

procedure TSQLExplorer.cbCurrKeyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
 EntryList : TStringList;
 bool      : olevariant;
 i, sec    : integer;
 ListItem  : TListItem;
 NodeName  : string;
 kind : integer;
begin
  if char(Key) = #13
    then
      begin
        EntryList := TStringList.Create;
        FiveListView.Items.BeginUpdate;
        FiveListView.Items.Clear;
        try
          Screen.Cursor := crHourGlass ;
          bool := ISProxy.RDOSetCurrentKey(cbCurrKey.Text);
          if bool
            then
              begin
                if not ConfigurationFrm.FullControl.Checked
                  then
                    cbCurrKeyChange( cbCurrKey );
                if cbCurrKey.Items.IndexOf(cbCurrKey.Text) = -1
                  then cbCurrKey.Items.Add(cbCurrKey.Text);
                EntryList.Text := ISProxy.RDOGetKeyNames;
                if EntryList.Count > 0
                  then
                    begin
                      for i := 0 to EntryList.Count - 1 do
                        begin
                          NodeName := cbCurrKey.Text + '/' + EntryList.Strings[i];
                          ListItem := FiveListView.Items.Add;
                          ListItem.Caption := EntryList.Strings[i];
                          ListItem.SubItems.Add('0');
                          ListItem.SubItems.Add('');
                          sec := ISProxy.RDOIsSecureKey(NodeName);
                          ListItem.SubItems.Add(IntToStr(sec));
                        end;
                    end;
              EntryList.Text := ISProxy.RDOGetValueNames;
              if EntryList.Count > 0
                then
                  begin
                    for i := 0 to EntryList.Count - 1 do
                      begin
                        NodeName         := cbCurrKey.Text + '/' + EntryList.Strings[i];
                        sec              := ISProxy.RDOIsSecureValue(NodeName);
                        kind             := ISProxy.RDOTypeOf(NodeName);
                        ListItem         := FiveListView.Items.Add;
                        ListItem.Caption := EntryList.Strings[i];
                        ListItem.ImageIndex := 1;
                        ListItem.SubItems.Add( IntToStr(kind) );
                        case Kind of
                          1 : ListItem.SubItems.Add( IntToStr  (ISProxy.RDOReadBoolean (EntryList.Strings[i]) ) );
                          2 : ListItem.SubItems.Add( IntToStr  (ISProxy.RDOReadInteger (EntryList.Strings[i]) ) );
                          3 : ListItem.SubItems.Add( FloatToStr(ISProxy.RDOReadFloat   (EntryList.Strings[i]) ) );
                          4 : ListItem.SubItems.Add(            ISProxy.RDOReadString  (EntryList.Strings[i]  ) );
                          5 : ListItem.SubItems.Add( DateToStr (ISProxy.RDOReadDate    (EntryList.Strings[i]) ) );
                          6 : ListItem.SubItems.Add( CurrToStr (ISProxy.RDOReadCurrency(EntryList.Strings[i]) ) );
                          7 : ListItem.SubItems.Add(            ISProxy.RDOReadString  (EntryList.Strings[i]  ) );
                        end;
                        ListItem.SubItems.Add( IntToStr( sec ) );
                      end;
                  end;
            FiveListView.Enabled := true;
            FiveListView.HideSelection := false;


                {if EntryList.Count > 0
                  then
                    begin
                      FiveListView.Enabled := false;
                      FiveListView.HideSelection := true;
                      FiveListView.Items.BeginUpdate;
                      try
                        FiveListView.Items.Clear;
                        for i := 0 to EntryList.Count - 1 do
                          begin
                            ListItem := FiveListView.Items.Add;
                            ListItem.Caption := EntryList.Strings[i];
                            ListItem.SubItems.Add('0');
                            ListItem.SubItems.Add('');
                            sec := ISProxy.RDOIsSecureKey(cbCurrKey.Text + '/' + EntryList.Strings[i] );
                            ListItem.SubItems.Add(IntToStr(sec));
                          end;
                        FiveListView.Enabled := true;
                        FiveListView.HideSelection := false;
                      finally
                        FiveListView.Items.EndUpdate;
                      end
                    end;}
              end;
        finally
          Screen.Cursor := crDefault ;
          FiveListView.Items.EndUpdate;
          EntryList.free;
        end;
      end
end;{ TSQLExplorer.cbCurrKeyKeyDown }

procedure TSQLExplorer.spUpKeyClick(Sender: TObject);
var
  theItem   : TListItem;
  bool      : olevariant;
  i, lsPos  : integer;
  ListItem  : TListItem;
  EntryList : TStringList;
  NodeName  : string;
  sec, Kind : integer;
begin
  theItem := FiveListView.ItemFocused;
  if (theItem <> nil) or (cbCurrKey.Text <> '')
    then
      begin
        EntryList := TStringList.Create;
        Screen.Cursor := crHourGlass ;
        try
          lsPos := LastDelimiter('/', cbCurrKey.Text );
          if lsPos > 0
            then cbCurrKey.Text := copy(cbCurrKey.Text, 0, lsPos - 1)
            else cbCurrKey.Text := '';
          bool := ISProxy.RDOSetCurrentKey(cbCurrKey.Text);
          if bool
            then
              begin
                if not ConfigurationFrm.FullControl.Checked
                  then
                    cbCurrKeyChange( cbCurrKey );
                FiveListView.Items.BeginUpdate;
                try
                  FiveListView.Items.Clear;
                  EntryList.Text := ISProxy.RDOGetKeyNames;
                  if EntryList.Count > 0
                    then
                      begin
                        FiveListView.Enabled := false;
                        FiveListView.HideSelection := true;
                        for i := 0 to EntryList.Count - 1 do
                          begin
                            ListItem := FiveListView.Items.Add;
                            ListItem.Caption := EntryList.Strings[i];
                            ListItem.SubItems.Add('0');
                            ListItem.SubItems.Add('');
                            if cbCurrKey.Text <> ''
                              then sec := ISProxy.RDOIsSecureKey( cbCurrKey.Text + '/' + EntryList.Strings[i] )
                              else sec := ISProxy.RDOIsSecureKey( EntryList.Strings[i] ) ;
                            ListItem.SubItems.Add(IntToStr(sec));
                          end;
                      end;
                  EntryList.Text := ISProxy.RDOGetValueNames;
                  if EntryList.Count > 0
                    then
                      begin
                        for i := 0 to EntryList.Count - 1 do
                          begin
                            NodeName         := cbCurrKey.Text + '/' + EntryList.Strings[i];
                            sec              := ISProxy.RDOIsSecureValue(NodeName);
                            kind             := ISProxy.RDOTypeOf(NodeName);
                            ListItem         := FiveListView.Items.Add;
                            ListItem.Caption := EntryList.Strings[i];
                            ListItem.ImageIndex := 1;
                            ListItem.SubItems.Add( IntToStr(kind) );
                            case Kind of
                              1 : ListItem.SubItems.Add( IntToStr  (ISProxy.RDOReadBoolean (EntryList.Strings[i]) ) );
                              2 : ListItem.SubItems.Add( IntToStr  (ISProxy.RDOReadInteger (EntryList.Strings[i]) ) );
                              3 : ListItem.SubItems.Add( FloatToStr(ISProxy.RDOReadFloat   (EntryList.Strings[i]) ) );
                              4 : ListItem.SubItems.Add(            ISProxy.RDOReadString  (EntryList.Strings[i]  ) );
                              5 : ListItem.SubItems.Add( DateToStr (ISProxy.RDOReadDate    (EntryList.Strings[i]) ) );
                              6 : ListItem.SubItems.Add( CurrToStr (ISProxy.RDOReadCurrency(EntryList.Strings[i]) ) );
                              7 : ListItem.SubItems.Add(            ISProxy.RDOReadString  (EntryList.Strings[i]  ) );
                            end;
                            ListItem.SubItems.Add( IntToStr( sec ) );
                          end;
                      end;
                   FiveListView.Enabled := true;
                   FiveListView.HideSelection := false;
                 finally
                   FiveListView.Items.EndUpdate;
                 end
              end;
        finally
          Screen.Cursor := crDefault ;
          EntryList.Free;
        end;
      end
end;{ TSQLExplorer.spUpKeyClick }

procedure TSQLExplorer.RefreshEntryClick(Sender: TObject);
begin
  if FiveListView.ItemFocused <> nil
    then FiveListView.ItemFocused := nil;
  FiveListViewDblClick(Sender);
end;{ TSQLExplorer.Refresh1Click }

procedure TSQLExplorer.ExitClick(Sender: TObject);
begin
  Ending := true ;
  Close;
end;{ TSQLExplorer.Exit1Click }

procedure TSQLExplorer.InitConnectionClick(Sender: TObject);
begin
  //  then
  //    begin
  if ConfigurationFrm.ShowModal <> mrOK
    then
      exit ;
  //    end;
  if ConfigurationFrm.cboServers.Text{IpConfig.Text} <> ''
    then
      begin
        if InitConnection
          then
            begin
              LoadFirstKeys;
              InitConnectionMenu.Enabled := false;
              EndConnectionMenu.Enabled  := true;
              Refresh1.Enabled := true;
              spUpKey.Enabled := true ;
              FindUser.Enabled := true ;
              FindSegaUser.Enabled := true;
              FindSubscriptionID.Enabled := true ;
              FindTransaction.Enabled := true ;
              FindSerialNumber.Enabled := true ;
              UnsubscribeUser1.Enabled := true ;
              BlockUnBlockUser.Enabled := true;
              Stats.Enabled := true ;
              FindUserWorlds1.Enabled := true ;
              //FiveListViewDblClick(Refresh1);
              cbCurrKeyChange(cbCurrKey);              
            end
          else
            begin
              Application.MessageBox('Can not get Connected to Directory Server', 'ERROR', IDOK );
            end;
      end;
end;{ TSQLExplorer.InitConnection1Click }

procedure TSQLExplorer.EndConnectionClick(Sender: TObject);
begin
  InitConnectionMenu.Enabled := true;
  EndConnectionMenu.Enabled  := false;
  Refresh1.Enabled := false;
  spUpKey.Enabled := false ;
  FindUser.Enabled := false ;
  FindSegaUser.Enabled := false;
  FindSubscriptionID.Enabled := false ;
  FindTransaction.Enabled := false ;
  FindSerialNumber.Enabled := false ;
  UnsubscribeUser1.Enabled := false ;
  BlockUnBlockUser.Enabled := false;
  FiveListView.Items.Clear ;
  Stats.Enabled := false ;
  FindUserWorlds1.Enabled := false ;
end;{ TSQLExplorer.EndConnection1Click }

procedure TSQLExplorer.FormShow(Sender: TObject);
begin
  IsConfig := false;
  InitConnectionMenu.Enabled := true;
  EndConnectionMenu.Enabled  := false;
end;{ TSQLExplorer.FormShow }

procedure TSQLExplorer.InsertKeyClick(Sender: TObject);
var
  ListItem    : TListItem;
  bool        : olevariant;
  NameNode    : string;
begin
  NewKeyForm.edNewKey.Text   := '';
  NewKeyForm.edCurrKey.Text  := cbCurrKey.Text;
  NewKeyForm.cbSecurity.Text := NewKeyForm.cbSecurity.Items[0];
  if NewKeyForm.ShowModal = mrOk
    then
      begin
        if NewKeyForm.edCurrKey.Text = ''
          then NameNode := NewKeyForm.edNewKey.Text
          else NameNode := NewKeyForm.edCurrKey.Text + '/' + NewKeyForm.edNewKey.Text;
        bool := ISProxy.RDOSetCurrentKey(cbCurrKey.Text);
        if bool
          then
            bool := ISProxy.RDOCreateFullPathKey( NameNode, true );
            if bool
              then
                begin
                  FiveListView.Enabled := false;
                  if NewKeyForm.edCurrKey.Text <> cbCurrKey.Text
                    then
                      begin
                        FiveListView.Items.BeginUpdate;
                        try
                          FiveListView.Items.Clear;
                          cbCurrKey.Text := NewKeyForm.edCurrKey.Text;
                        finally
                          FiveListView.Items.EndUpdate;
                        end
                      end;
                  ListItem := FiveListView.Items.Add;
                  ListItem.ImageIndex := 0;
                  ListItem.Caption := NewKeyForm.edNewKey.Text;
                  ListItem.SubItems.Add('0');
                  ListItem.SubItems.Add('');
                  if NewKeyForm.cbSecurity.Text = 'True'
                    then ListItem.SubItems.Add('-1')
                    else ListItem.SubItems.Add('0');
                  FiveListView.Enabled := true;
                  if not ConfigurationFrm.FullControl.Checked
                    then
                      cbCurrKeyChange( cbCurrKey );
                end
              else MessageDlg('Can not create two keys with equal names!', mtWarning, [mbYes], 0);
      end;
end;{ TSQLExplorer.New1Click }

procedure TSQLExplorer.DeleteEntryClick(Sender: TObject);
var
  theItem : TListItem;
  index   : integer;
  bool    : olevariant;
  KeyName : string;
begin
  theItem := FiveListView.ItemFocused;
  if theItem <> nil
   then
     if MessageDlg('Are you sure ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes
       then
         begin
           if cbCurrKey.Text <> ''
             then KeyName := cbCurrKey.Text + '/' + theItem.Caption
             else KeyName := theItem.Caption;
           bool := ISProxy.RDODeleteFullPathNode( KeyName );
           if bool
             then
               begin
                 FiveListView.Enabled := false;
                 Index := FiveListView.Items.IndexOf(theItem);
                 FiveListView.Items.Delete(Index);
                 FiveListView.Enabled := true;
               end;
         end;
end; { TSQLExplorer.Delete1Click }

procedure TSQLExplorer.FiveListViewEdited(Sender: TObject; Item: TListItem; var S: String);
var
  bool        : olevariant;
  FullKeyName : string;
begin
  if (FiveListView.ItemFocused <> nil) and (S <> Item.Caption)
    then
      begin
        FullKeyName := cbCurrKey.Text + '/' + Item.Caption;
        if FiveListView.ItemFocused.SubItems.Strings[0] = '0'
          then bool := ISProxy.RDOEditKey( FullKeyName, S, 0)
          else bool := ISProxy.RDOEditKey( FullKeyName, S, 1);
     end;
end;{ TSQLExplorerFrm.TreeFiveKeyEdited }

procedure TSQLExplorer.ConfigurationClick(Sender: TObject);
begin
  IsConfig := true;
  ConfigurationFrm.ShowModal;
//  ConfigurationFrm.Text
end;{ TSQLExplorer.Configurations1Click }

procedure TSQLExplorer.EditValueClick(Sender: TObject);
var
  bool        : olevariant;
  FullKeyName : string;
  oldkeyName  : string;
  Kind, lsPos : integer;
begin
  if (FiveListView.ItemFocused <> nil)
    then
      begin
        FullKeyName := cbCurrKey.Text + '/' + FiveListView.ItemFocused.Caption;

        if FiveListView.ItemFocused.SubItems.Strings[0] = '0'
          then
            with NewKeyForm do
              begin
                edCurrKey.Text    := cbCurrKey.Text;
                edCurrKey.Enabled := false;
                edNewKey.Text     := FiveListView.ItemFocused.Caption;

                if FiveListView.ItemFocused.SubItems.Strings[2] <> '0'
                  then cbSecurity.ItemIndex := 1
                  else cbSecurity.ItemIndex := 0;

                if ShowModal = mrOK
                  then
                    if (FullKeyName <> '') and (edNewKey.Text <> '')
                      then
                        begin
                          lsPos := LastDelimiter('/', FullKeyName);
                          if lsPos > 0
                            then oldKeyName := copy(FullKeyName, lsPos+1, length(FullKeyName))
                            else oldKeyName := FullKeyName;
                          bool := ISProxy.RDOEditKey( FullKeyName, edNewKey.Text, oldKeyName, cbSecurity.ItemIndex );
                        end;
                FiveListView.ItemFocused.Caption := edNewKey.Text;
                if cbSecurity.ItemIndex = 1
                  then FiveListView.ItemFocused.SubItems.Strings[2] := '-1'
                  else FiveListView.ItemFocused.SubItems.Strings[2] := '0';
                edCurrKey.Enabled := true;
              end
          else
            with editValueForm do
              begin
                edCurrKey.Text       := cbCurrKey.Text;
                edCurrKey.Enabled    := false;
                edEntryName.Enabled  := false;
                edEntryName.Text     := FiveListView.ItemFocused.Caption;
                cbKind.Text          := cbKind.Items[ StrToInt(FiveListView.ItemFocused.SubItems.Strings[0]) - 1 ];
                edValue.Text         := FiveListView.ItemFocused.SubItems.Strings[1];

                if ISProxy.RDOIsSecureValue(edCurrKey.Text + '/' + edEntryName.Text )
                  then cbSecurity.ItemIndex := 1
                  else cbSecurity.ItemIndex := 0;

                if ShowModal = mrOK
                  then
                    begin
                      Kind := StrToInt(FiveListView.ItemFocused.SubItems.Strings[0]);
                      bool := ISProxy.RDOSetCurrentKey(edCurrKey.Text);
                      if bool
                        then
                          begin
                            case Kind of
                              1 : ISProxy.RDOWriteBoolean (edEntryName.Text, wordbool(StrToInt  (edValue.Text) ) );
                              2 : ISProxy.RDOWriteInteger (edEntryName.Text,          StrToInt  (edValue.Text)   );
                              3 : ISProxy.RDOWriteFloat   (edEntryName.Text,          StrToFloat(edValue.Text)   );
                              4 : ISProxy.RDOWriteString  (edEntryName.Text,                     edValue.Text    );
                              5 : ISProxy.RDOWriteDate    (edEntryName.Text,  double( StrToDate (edValue.Text) ) );
                              6 : ISProxy.RDOWriteCurrency(edEntryName.Text,          StrToCurr (edValue.Text)   );
                            end;
                          end;

                      bool := ISProxy.RDOSetSecurityOfValue(edCurrKey.Text + '/' + edEntryName.Text, cbSecurity.ItemIndex );

                      FiveListView.ItemFocused.SubItems.Strings[0] := IntToStr(Kind);
                      FiveListView.ItemFocused.SubItems.Strings[1] := edValue.Text;
                      if cbSecurity.ItemIndex = 1
                        then FiveListView.ItemFocused.SubItems.Strings[2] := '-1'
                        else FiveListView.ItemFocused.SubItems.Strings[2] := '0';
                      edCurrKey.Enabled := true;
                      edEntryName.Enabled := true;
                    end;
              end;
      end;
end;{ TSQLExplorer.Configurations1Click }

procedure TSQLExplorer.InsertValueClick(Sender: TObject);
var
  ListItem    : TListItem;
  Kind        : integer;
  bool        : boolean;
begin
  with editValueForm do
    begin
      edCurrKey.Text    := cbCurrKey.Text;
      edEntryName.Text  := '';
      cbKind.Text       := '';
      edValue.Text      := '';
      cbSecurity.Text   := 'False';
      edCurrKey.Enabled   := false;
      edEntryName.Enabled := true;

      if (ShowModal = mrOK) and (edEntryName.Text <> '')
        then
          begin
            if FiveListView.ItemFocused <> nil
              then Kind := StrToInt(FiveListView.ItemFocused.SubItems.Strings[0])
              else Kind := cbKind.ItemIndex + 1;
            bool := ISProxy.RDOSetCurrentKey(edCurrKey.Text);
            if bool
              then
                begin
                  case Kind of
                    1 : ISProxy.RDOWriteBoolean (edEntryName.Text, wordbool(StrToInt  (edValue.Text) ) );
                    2 : ISProxy.RDOWriteInteger (edEntryName.Text,          StrToInt  (edValue.Text)   );
                    3 : ISProxy.RDOWriteFloat   (edEntryName.Text,          StrToFloat(edValue.Text)   );
                    4 : ISProxy.RDOWriteString  (edEntryName.Text,                     edValue.Text    );
                    5 : ISProxy.RDOWriteDate    (edEntryName.Text, double ( StrToDate (edValue.Text) ) );
                    6 : ISProxy.RDOWriteCurrency(edEntryName.Text,          StrToCurr (edValue.Text)   );
                  end;

                  bool := ISProxy.RDOSetSecurityOfValue(edCurrKey.Text + '/' + edEntryName.Text, cbSecurity.ItemIndex );

                  ListItem := FiveListView.Items.Add;
                  ListItem.ImageIndex := 1;
                  ListItem.Caption := edEntryName.Text;
                  ListItem.SubItems.Add(IntToStr(Kind));
                  ListItem.SubItems.Add(edValue.Text);
                  ListItem.SubItems.Add(IntToStr(cbSecurity.ItemIndex));
                  FiveListView.Enabled := true;
                end;
            edCurrKey.Enabled := true;
          end;
    end;
end;{ TSQLExplorer.InsertValue1Click }


(*
procedure TSQLExplorer.Button1Click(Sender: TObject);
var
  i   : integer;
  r,w : string;
  b   : boolean;
  d   : double;
  T,S : TStringList;
begin
  T := TStringList.Create;
  S := TStringList.Create;

  S.Add('desc');
  S.Add('url');

//  T.Text := ISProxy.RDOQueryKey('root/sites', S.Text );

//  r := ISProxy.RDOGetValueNames;
//  i := ISProxy.RDOKeysCount;

//  b := ISProxy.RDOIsSecureKey('root/zorro');

    b := ISProxy.RDOSetCurrentKey('Root/Areas/America/Worlds/Trinity/Interface');
    i := ISProxy.RDOTypeOf('Root/Areas/America/Worlds/Trinity/Interface/ProxyIP');
    i := ISProxy.RDOReadInteger('ProxyIP');
  if i > 0
    then b := false;

  S.Free;
  T.Free;
end;
*)

procedure TSQLExplorer.FindUserClick(Sender: TObject);
var
  w : word ;
  username : string;
begin
 MsgBx.Edit1.Text := '' ;
 MsgBx.Caption := 'Find User' ;
 MsgBx.Label1.Caption := 'User Name:';
 if MsgBx.ShowModal = mrOk
   then
     begin
       username := MsgBx.Edit1.Text;
       username := StringReplace( username, ' ', '.', [rfReplaceAll] );
       cbCurrKey.Text := 'root/users/'+copy(MsgBx.Edit1.Text,1,1)+'/'+
                         username ;
       w := 13 ;
       cbCurrKeyKeyDown(cbCurrKey, w, []);
     end ;
end;

procedure TSQLExplorer.FindSubscriptionIDClick(Sender: TObject);
var
  w : word ;
begin
 MsgBx.Edit1.Text := '' ;
 MsgBx.Caption := 'Find Subscription ID' ;
 MsgBx.Label1.Caption := 'Subscription ID:';
 if MsgBx.ShowModal = mrOk
   then
     begin
       cbCurrKey.Text := 'root/subcriptions/'+MsgBx.Edit1.Text ;
       w := 13 ;
       cbCurrKeyKeyDown(cbCurrKey, w, []);
     end ;
end;

procedure TSQLExplorer.FindTransactionClick(Sender: TObject);
var
  w : word ;
begin
 MsgBx.Edit1.Text := '' ;
 MsgBx.Caption := 'Find Transaction' ;
 MsgBx.Label1.Caption := 'Transaction:';
 if MsgBx.ShowModal = mrOk
   then
     begin
       cbCurrKey.Text := 'root/transactions/'+MsgBx.Edit1.Text ;
       w := 13 ;
       cbCurrKeyKeyDown(cbCurrKey, w, []);
     end ;

end;

procedure TSQLExplorer.FindSerialNumberClick(Sender: TObject);
var
  w : word ;
begin
 MsgBx.Edit1.Text := '' ;
 MsgBx.Caption := 'Find Serial Number' ;
 MsgBx.Label1.Caption := 'Serial Number:';
 if MsgBx.ShowModal = mrOk
   then
     begin
       cbCurrKey.Text := 'root/serials/_'+MsgBx.Edit1.Text ;
       w := 13 ;
       cbCurrKeyKeyDown(cbCurrKey, w, []);
     end ;
end;

procedure TSQLExplorer.UnsubscribeUser1Click(Sender: TObject);
begin
 SubsForm.ShowModal ;
end;

procedure TSQLExplorer.StatsClick(Sender: TObject);
begin
  StatsForm.Show ;
end;

procedure TSQLExplorer.FormCreate(Sender: TObject);
begin
  Ending := false ;
end;

procedure TSQLExplorer.FindUserWorlds1Click(Sender: TObject);
var
  w : word ;
begin
//root/users/i/iroel/accountinfo/worlds
 MsgBx.Edit1.Text := '' ;
 MsgBx.Caption := 'Find User Worlds' ;
 MsgBx.Label1.Caption := 'User Name:';
 if MsgBx.ShowModal = mrOk
   then
     begin
       cbCurrKey.Text := 'root/users/'+copy(MsgBx.Edit1.Text,1,1)+'/'+
                         MsgBx.Edit1.Text+'/accountinfo/worlds' ;
       w := 13 ;
       cbCurrKeyKeyDown(cbCurrKey, w, []);
     end ;
end;

procedure TSQLExplorer.BlockUnblockUserClick(Sender: TObject);
var
  w : word;
  savekey : string;
  bool : OleVariant;
  accountid : string;
begin
 if FBlockUnblock.ShowModal = mrOk
   then
     begin
       saveKey := cbCurrKey.Text;
       bool := ISProxy.RDOSetCurrentKey('root/users/'+copy(FBlockUnblock.Edit1.Text,1,1)+'/'+FBlockUnblock.Edit1.Text);
       if bool
         then
           begin
             accountid := ISProxy.RDOReadString( 'accountid' );
             bool := ISProxy.RDOSetCurrentKey('root/serials/_'+accountid);
             if bool
               then
                 begin
                   ISProxy.RDOWriteBoolean ('blocked', FBlockUnblock.block.Checked );
                 end;
           end;
       bool := ISProxy.RDOSetCurrentKey(saveKey);
     end ;
end;

procedure TSQLExplorer.cbCurrKeyChange(Sender: TObject);
begin
  if CanEdit
    then
      begin
        SpeedButton1.Enabled := true;
        SpeedButton2.Enabled := true;
        SpeedButton3.Enabled := true;
        SpeedButton4.Enabled := true;
        FiveListView.PopupMenu := PopupMenu1;
      end
    else
      begin
        SpeedButton1.Enabled := false;
        SpeedButton2.Enabled := false;
        SpeedButton3.Enabled := false;
        SpeedButton4.Enabled := false;
        FiveListView.PopupMenu := nil;
      end;
end;

procedure TSQLExplorer.FindSegaUserClick(Sender: TObject);
var
  w : word ;
  username : string;
  SegaUserName : string;
begin
 MsgBx.Edit1.Text := '' ;
 MsgBx.Caption := 'Find Sega User' ;
 MsgBx.Label1.Caption := 'User Name:';
 if MsgBx.ShowModal = mrOk
   then
     begin
       SegaUserName := MsgBx.Edit1.Text;
       SegaUserName := StringReplace( SegaUserName, ' ', '.', [rfReplaceAll] );
       username := ISProxy.RDOMapSegaUser(SegaUserName);
       username := StringReplace( username, ' ', '.', [rfReplaceAll] );
       cbCurrKey.Text := 'root/users/'+copy(username,1,1)+'/'+
                         username ;
       w := 13 ;
       cbCurrKeyKeyDown(cbCurrKey, w, []);
     end ;
end;

end.
