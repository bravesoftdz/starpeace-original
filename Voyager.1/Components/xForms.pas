
{*******************************************************}
{                                                       }
{       Delphi Visual Component Library                 }
{                                                       }
{       Copyright (c) 1995,97 Borland International     }
{                                                       }
{*******************************************************}

unit Forms;

{$P+,S-,W-,R-}
{$C PRELOAD}

interface

uses Messages, Windows, SysUtils, Classes, Graphics, Menus, Controls, Imm;

type

{ Forward declarations }

  TScrollingWinControl = class;
  TCustomForm = class;
  TForm = class;

{ TControlScrollBar }

  TScrollBarKind = (sbHorizontal, sbVertical);
  TScrollBarInc = 1..32767;

  TControlScrollBar = class(TPersistent)
  private
    FControl: TScrollingWinControl;
    FIncrement: TScrollBarInc;
    FPosition: Integer;
    FRange: Integer;
    FCalcRange: Integer;
    FKind: TScrollBarKind;
    FMargin: Word;
    FVisible: Boolean;
    FTracking: Boolean;
    FScaled: Boolean;
    constructor Create(AControl: TScrollingWinControl; AKind: TScrollBarKind);
    procedure CalcAutoRange;
    function ControlSize(ControlSB, AssumeSB: Boolean): Integer;
    procedure DoSetRange(Value: Integer);
    function GetScrollPos: Integer;
    function NeedsScrollBarVisible: Boolean;
    procedure ScrollMessage(var Msg: TWMScroll);
    procedure SetPosition(Value: Integer);
    procedure SetRange(Value: Integer);
    procedure SetVisible(Value: Boolean);
    function IsRangeStored: Boolean;
    procedure Update(ControlSB, AssumeSB: Boolean);
  public
    procedure Assign(Source: TPersistent); override;
    property Kind: TScrollBarKind read FKind;
    property ScrollPos: Integer read GetScrollPos;
  published
    property Margin: Word read FMargin write FMargin default 0;
    property Increment: TScrollBarInc read FIncrement write FIncrement default 8;
    property Range: Integer read FRange write SetRange stored IsRangeStored default 0;
    property Position: Integer read FPosition write SetPosition default 0;
    property Tracking: Boolean read FTracking write FTracking default False;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

{ TScrollingWinControl }

  TScrollingWinControl = class(TWinControl)
  private
    FHorzScrollBar: TControlScrollBar;
    FVertScrollBar: TControlScrollBar;
    FAutoScroll: Boolean;
    FAutoRangeCount: Integer;
    FUpdatingScrollBars: Boolean;
    procedure CalcAutoRange;
    procedure ScaleScrollBars(M, D: Integer);
    procedure SetAutoScroll(Value: Boolean);
    procedure SetHorzScrollBar(Value: TControlScrollBar);
    procedure SetVertScrollBar(Value: TControlScrollBar);
    procedure UpdateScrollBars;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
  protected
    procedure AutoScrollInView(AControl: TControl);
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
    property AutoScroll: Boolean read FAutoScroll write SetAutoScroll default True;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DisableAutoRange;
    procedure EnableAutoRange;
    procedure ScrollInView(AControl: TControl);
  published
    property HorzScrollBar: TControlScrollBar read FHorzScrollBar write SetHorzScrollBar;
    property VertScrollBar: TControlScrollBar read FVertScrollBar write SetVertScrollBar;
  end;

{ TScrollBox }

  TFormBorderStyle = (bsNone, bsSingle, bsSizeable, bsDialog, bsToolWindow,
    bsSizeToolWin);
  TBorderStyle = bsNone..bsSingle;

  TScrollBox = class(TScrollingWinControl)
  private
    FBorderStyle: TBorderStyle;
    FOnResize: TNotifyEvent;
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMNCHitTest(var Message: TMessage); message WM_NCHITTEST;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Resize; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property AutoScroll;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Color nodefault;
    property Ctl3D;
    property Font;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
  end;

{ TDesigner }

  TDesigner = class(TObject)
  private
    FCustomForm: TCustomForm;
    function GetIsControl: Boolean;
    procedure SetIsControl(Value: Boolean);
  public
    function IsDesignMsg(Sender: TControl; var Message: TMessage): Boolean;
      virtual; abstract;
    procedure Modified; virtual; abstract;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); virtual; abstract;
    procedure PaintGrid; virtual; abstract;
    procedure ValidateRename(AComponent: TComponent;
      const CurName, NewName: string); virtual; abstract;
    property IsControl: Boolean read GetIsControl write SetIsControl;
    property Form: TCustomForm read FCustomForm write FCustomForm;
  end;

{ IOleForm }

  IOleForm = interface
    ['{CD02E1C1-52DA-11D0-9EA6-0020AF3D82DA}']
    procedure OnDestroy;
    procedure OnResize;
  end;

{ TCustomForm }

  TWindowState = (wsNormal, wsMinimized, wsMaximized);
  TFormStyle = (fsNormal, fsMDIChild, fsMDIForm, fsStayOnTop);
  TBorderIcon = (biSystemMenu, biMinimize, biMaximize, biHelp);
  TBorderIcons = set of TBorderIcon;
  TPosition = (poDesigned, poDefault, poDefaultPosOnly, poDefaultSizeOnly,
    poScreenCenter);
  TPrintScale = (poNone, poProportional, poPrintToFit);
  TShowAction = (saIgnore, saRestore, saMinimize, saMaximize);
  TTileMode = (tbHorizontal, tbVertical);
  TModalResult = Low(Integer)..High(Integer);
  TCloseAction = (caNone, caHide, caFree, caMinimize);
  TCloseEvent = procedure(Sender: TObject; var Action: TCloseAction) of object;
  TCloseQueryEvent = procedure(Sender: TObject;
    var CanClose: Boolean) of object;
  TFormState = set of (fsCreating, fsVisible, fsShowing, fsModal,
    fsCreatedMDIChild);

  TCustomForm = class(TScrollingWinControl)
  private
    FActiveControl: TWinControl;
    FFocusedControl: TWinControl;
    FBorderIcons: TBorderIcons;
    FBorderStyle: TFormBorderStyle;
    FWindowState: TWindowState;
    FShowAction: TShowAction;
    FKeyPreview: Boolean;
    FActive: Boolean;
    FFormStyle: TFormStyle;
    FPosition: TPosition;
    FTileMode: TTileMode;
    FFormState: TFormState;
    FDropTarget: Boolean;
    FPrintScale: TPrintScale;
    FCanvas: TControlCanvas;
    FHelpFile: string;
    FIcon: TIcon;
    FMenu: TMainMenu;
    FModalResult: TModalResult;
    FDesigner: TDesigner;
    FClientHandle: HWND;
    FWindowMenu: TMenuItem;
    FPixelsPerInch: Integer;
    FObjectMenuItem: TMenuItem;
    FOleForm: IOleForm;
    FClientWidth: Integer;
    FClientHeight: Integer;
    FTextHeight: Integer;
    FDefClientProc: TFarProc;
    FClientInstance: TFarProc;
    FActiveOleControl: TWinControl;
    FOnActivate: TNotifyEvent;
    FOnClose: TCloseEvent;
    FOnCloseQuery: TCloseQueryEvent;
    FOnDeactivate: TNotifyEvent;
    FOnHelp: THelpEvent;
    FOnHide: TNotifyEvent;
    FOnPaint: TNotifyEvent;
    FOnResize: TNotifyEvent;
    FOnShow: TNotifyEvent;
    FOnCreate: TNotifyEvent;
    FOnDestroy: TNotifyEvent;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure RefreshMDIMenu;
    procedure ClientWndProc(var Message: TMessage);
    procedure CloseModal;
    function GetActiveMDIChild: TForm;
    function GetCanvas: TCanvas;
    function GetIconHandle: HICON;
    function GetMDIChildCount: Integer;
    function GetMDIChildren(I: Integer): TForm;
    function GetPixelsPerInch: Integer;
    function GetScaled: Boolean;
    function GetTextHeight: Integer;
    procedure IconChanged(Sender: TObject);
    function IsAutoScrollStored: Boolean;
    function IsClientSizeStored: Boolean;
    function IsColorStored: Boolean;
    function IsForm: Boolean;
    function IsFormSizeStored: Boolean;
    function IsIconStored: Boolean;
    procedure MergeMenu(MergeState: Boolean);
    procedure ReadTextHeight(Reader: TReader);
    procedure SetActive(Value: Boolean);
    procedure SetActiveControl(Control: TWinControl);
    procedure SetBorderIcons(Value: TBorderIcons);
    procedure SetBorderStyle(Value: TFormBorderStyle);
    procedure SetClientHeight(Value: Integer);
    procedure SetClientWidth(Value: Integer);
    procedure SetDesigner(ADesigner: TDesigner);
    procedure SetFormStyle(Value: TFormStyle);
    procedure SetIcon(Value: TIcon);
    procedure SetMenu(Value: TMainMenu);
    procedure SetPixelsPerInch(Value: Integer);
    procedure SetPosition(Value: TPosition);
    procedure SetScaled(Value: Boolean);
    procedure SetVisible(Value: Boolean);
    procedure SetWindowFocus;
    procedure SetWindowMenu(Value: TMenuItem);
    procedure SetObjectMenuItem(Value: TMenuItem);
    procedure SetWindowState(Value: TWindowState);
    procedure WritePixelsPerInch(Writer: TWriter);
    procedure WriteTextHeight(Writer: TWriter);
    function NormalColor: TColor;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMIconEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ICONERASEBKGND;
    procedure WMQueryDragIcon(var Message: TWMQueryDragIcon); message WM_QUERYDRAGICON;
    procedure WMNCCreate(var Message: TWMNCCreate); message WM_NCCREATE;
    procedure WMDestroy(var Message: TWMDestroy); message WM_DESTROY;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMInitMenuPopup(var Message: TWMInitMenuPopup); message WM_INITMENUPOPUP;
    procedure WMMenuSelect(var Message: TWMMenuSelect); message WM_MENUSELECT;
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMClose(var Message: TWMClose); message WM_CLOSE;
    procedure WMQueryEndSession(var Message: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMShowWindow(var Message: TWMShowWindow); message WM_SHOWWINDOW;
    procedure WMMDIActivate(var Message: TWMMDIActivate); message WM_MDIACTIVATE;
    procedure WMNextDlgCtl(var Message: TWMNextDlgCtl); message WM_NEXTDLGCTL;
    procedure WMEnterMenuLoop(var Message: TMessage); message WM_ENTERMENULOOP;
    procedure WMHelp(var Message: TWMHelp); message WM_HELP;
    procedure CMActivate(var Message: TCMActivate); message CM_ACTIVATE;
    procedure CMAppSysCommand(var Message: TMessage); message CM_APPSYSCOMMAND;
    procedure CMDeactivate(var Message: TCMDeactivate); message CM_DEACTIVATE;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMMenuChanged(var Message: TMessage); message CM_MENUCHANGED;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure CMIconChanged(var Message: TMessage); message CM_ICONCHANGED;
    procedure CMRelease(var Message: TMessage); message CM_RELEASE;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMUIActivate(var Message); message CM_UIACTIVATE;
    procedure CMParentFontChanged(var Message: TMessage); message CM_PARENTFONTCHANGED;
  protected
    procedure Activate; dynamic;
    procedure ActiveChanged; dynamic;
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Deactivate; dynamic;
    procedure DefaultHandler(var Message); override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DestroyWindowHandle; override;
    procedure DoHide; dynamic;
    procedure DoShow; dynamic;
    function GetClientRect: TRect; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Paint; dynamic;
    procedure PaintWindow(DC: HDC); override;
    function PaletteChanged(Foreground: Boolean): Boolean; override;
    procedure SetChildOrder(Child: TComponent; Order: Integer); override;
    procedure ReadState(Reader: TReader); override;
    procedure Resize; dynamic;
    procedure SetParent(AParent: TWinControl); override;
    procedure ValidateRename(AComponent: TComponent;
      const CurName, NewName: string); override;
    procedure VisibleChanging; override;
    procedure WndProc(var Message: TMessage); override;
    property ActiveMDIChild: TForm read GetActiveMDIChild;
    property BorderIcons: TBorderIcons read FBorderIcons write SetBorderIcons stored IsForm
      default [biSystemMenu, biMinimize, biMaximize];
    property BorderStyle: TFormBorderStyle read FBorderStyle write SetBorderStyle
      stored IsForm default bsSizeable;
    property AutoScroll stored IsAutoScrollStored;
    property ClientHandle: HWND read FClientHandle;
    property ClientHeight write SetClientHeight stored IsClientSizeStored;
    property ClientWidth write SetClientWidth stored IsClientSizeStored;
    property Ctl3D default True;
    property FormStyle: TFormStyle read FFormStyle write SetFormStyle
      stored IsForm default fsNormal;
    property Height stored IsFormSizeStored;
    property HorzScrollBar stored IsForm;
    property Icon: TIcon read FIcon write SetIcon stored IsIconStored;
    property MDIChildCount: Integer read GetMDIChildCount;
    property MDIChildren[I: Integer]: TForm read GetMDIChildren;
    property ObjectMenuItem: TMenuItem read FObjectMenuItem write SetObjectMenuItem
      stored IsForm;
    property PixelsPerInch: Integer read GetPixelsPerInch write SetPixelsPerInch
      stored False;
    property ParentFont default False;
    property PopupMenu stored IsForm;
    property Position: TPosition read FPosition write SetPosition stored IsForm
      default poDesigned;
    property PrintScale: TPrintScale read FPrintScale write FPrintScale stored IsForm
      default poProportional;
    property Scaled: Boolean read GetScaled write SetScaled stored IsForm default True;
    property TileMode: TTileMode read FTileMode write FTileMode default tbHorizontal;
    property VertScrollBar stored IsForm;
    property Visible write SetVisible default False;
    property Width stored IsFormSizeStored;
    property WindowMenu: TMenuItem read FWindowMenu write SetWindowMenu stored IsForm;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate stored IsForm;
    property OnClick stored IsForm;
    property OnClose: TCloseEvent read FOnClose write FOnClose stored IsForm;
    property OnCloseQuery: TCloseQueryEvent read FOnCloseQuery write FOnCloseQuery
      stored IsForm;
    property OnCreate: TNotifyEvent read FOnCreate write FOnCreate stored IsForm;
    property OnDblClick stored IsForm;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy stored IsForm;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate stored IsForm;
    property OnDragDrop stored IsForm;
    property OnDragOver stored IsForm;
    property OnHelp: THelpEvent read FOnHelp write FOnHelp;
    property OnHide: TNotifyEvent read FOnHide write FOnHide stored IsForm;
    property OnKeyDown stored IsForm;
    property OnKeyPress stored IsForm;
    property OnKeyUp stored IsForm;
    property OnMouseDown stored IsForm;
    property OnMouseMove stored IsForm;
    property OnMouseUp stored IsForm;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint stored IsForm;
    property OnResize: TNotifyEvent read FOnResize write FOnResize stored IsForm;
    property OnShow: TNotifyEvent read FOnShow write FOnShow stored IsForm;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateNew(AOwner: TComponent);
    destructor Destroy; override;
    procedure Close;
    function CloseQuery: Boolean;
    procedure DefocusControl(Control: TWinControl; Removing: Boolean);
    procedure FocusControl(Control: TWinControl);
    function GetFormImage: TBitmap;
    procedure Hide;
    procedure Print;
    procedure Release;
    procedure SendCancelMode(Sender: TControl);
    procedure SetFocus; override;
    function SetFocusedControl(Control: TWinControl): Boolean;
    procedure Show;
    function ShowModal: Integer;
    function WantChildKey(Child: TControl; var Message: TMessage): Boolean; virtual;
    property Active: Boolean read FActive;
    property ActiveControl: TWinControl read FActiveControl write SetActiveControl
      stored IsForm;
    property ActiveOleControl: TWinControl read FActiveOleControl write FActiveOleControl;
    property Canvas: TCanvas read GetCanvas;
    property Caption stored IsForm;
    property Color stored IsColorStored;
    property Designer: TDesigner read FDesigner write SetDesigner;
    property DropTarget: Boolean read FDropTarget write FDropTarget;
    property Font;
    property HelpFile: string read FHelpFile write FHelpFile;
    property KeyPreview: Boolean read FKeyPreview write FKeyPreview
      stored IsForm default False;
    property Menu: TMainMenu read FMenu write SetMenu stored IsForm;
    property ModalResult: TModalResult read FModalResult write FModalResult;
    property OleFormObject: IOleForm read FOleForm write FOleForm;
    property WindowState: TWindowState read FWindowState write SetWindowState
      stored IsForm default wsNormal;
  end;

{ TForm }

  TForm = class(TCustomForm)
  public
    procedure ArrangeIcons;
    procedure Cascade;
    procedure Next;
    procedure Previous;
    procedure Tile;
    property ActiveMDIChild;
    property ClientHandle;
    property MDIChildCount;
    property MDIChildren;
    property TileMode;
  published
    property ActiveControl;
    property BorderIcons;
    property BorderStyle;
    property AutoScroll;
    property Caption;
    property ClientHeight;
    property ClientWidth;
    property Ctl3D;
    property Color;
    property Enabled;
    property ParentFont default False;
    property Font;
    property FormStyle;
    property Height;
    property HelpFile;
    property HorzScrollBar;
    property Icon;
    property KeyPreview;
    property Menu;
    property ObjectMenuItem;
    property PixelsPerInch;
    property PopupMenu;
    property Position;
    property PrintScale;
    property Scaled;
    property ShowHint;
    property VertScrollBar;
    property Visible;
    property Width;
    property WindowState;
    property WindowMenu;
    property OnActivate;
    property OnClick;
    property OnClose;
    property OnCloseQuery;
    property OnCreate;
    property OnDblClick;
    property OnDestroy;
    property OnDeactivate;
    property OnDragDrop;
    property OnDragOver;
    property OnHide;
    property OnHelp;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnPaint;
    property OnResize;
    property OnShow;
  end;

  TFormClass = class of TForm;

{ TDataModule }

  TDataModule = class(TComponent)
  private
    FDesignSize: TPoint;
    FDesignOffset: TPoint;
    FOnCreate: TNotifyEvent;
    FOnDestroy: TNotifyEvent;
    procedure ReadHeight(Reader: TReader);
    procedure ReadHorizontalOffset(Reader: TReader);
    procedure ReadVerticalOffset(Reader: TReader);
    procedure ReadWidth(Reader: TReader);
    procedure WriteWidth(Writer: TWriter);
    procedure WriteHorizontalOffset(Writer: TWriter);
    procedure WriteVerticalOffset(Writer: TWriter);
    procedure WriteHeight(Writer: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function GetProviderNames: OleVariant; safecall;
    class procedure UpdateRegistry(Register: Boolean; const ClassID, ProgID: string); override;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateNew(AOwner: TComponent);
    destructor Destroy; override;
    property DesignOffset: TPoint read FDesignOffset write FDesignOffset;
    property DesignSize: TPoint read FDesignSize write FDesignSize;
  published
    property OnCreate: TNotifyEvent read FOnCreate write FOnCreate;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
  end;

{ TScreen }

  PCursorRec = ^TCursorRec;
  TCursorRec = record
    Next: PCursorRec;
    Index: Integer;
    Handle: HCURSOR;
  end;

  TScreen = class(TComponent)
  private
    FFonts: TStrings;
    FImes: TStrings;
    FDefaultIme: string;
    FDefaultKbLayout: HKL;
    FPixelsPerInch: Integer;
    FCursor: TCursor;
    FCursorCount: Integer;
    FForms: TList;
    FCustomForms: TList;
    FDataModules: TList;
    FCursorList: PCursorRec;
    FDefaultCursor: HCURSOR;
    FActiveControl: TWinControl;
    FActiveCustomForm: TCustomForm;
    FActiveForm: TForm;
    FLastActiveControl: TWinControl;
    FLastActiveCustomForm: TCustomForm;
    FFocusedForm: TCustomForm;
    FSaveFocusedList: TList;
    FIconFont: TFont;
    FOnActiveControlChange: TNotifyEvent;
    FOnActiveFormChange: TNotifyEvent;
    procedure AddDataModule(DataModule: TDataModule);
    procedure AddForm(AForm: TCustomForm);
    procedure CreateCursors;
    procedure DeleteCursor(Index: Integer);
    procedure DestroyCursors;
    procedure IconFontChanged(Sender: TObject);
    procedure InitImes;
    function GetCustomFormCount: Integer;
    function GetCustomForms(Index: Integer): TCustomForm;
    function GetCursors(Index: Integer): HCURSOR;
    function GetDataModule(Index: Integer): TDataModule;
    function GetDataModuleCount: Integer;
    function GetHeight: Integer;
    function GetWidth: Integer;
    function GetForm(Index: Integer): TForm;
    function GetFormCount: Integer;
    procedure GetMetricSettings;
    procedure InsertCursor(Index: Integer; Handle: HCURSOR);
    procedure RemoveDataModule(DataModule: TDataModule);
    procedure RemoveForm(AForm: TCustomForm);
    procedure SetCursors(Index: Integer; Handle: HCURSOR);
    procedure SetCursor(Value: TCursor);
    procedure UpdateLastActive;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ActiveControl: TWinControl read FActiveControl;
    property ActiveCustomForm: TCustomForm read FActiveCustomForm;
    property ActiveForm: TForm read FActiveForm;
    property CustomFormCount: Integer read GetCustomFormCount;
    property CustomForms[Index: Integer]: TCustomForm read GetCustomForms;
    property Cursor: TCursor read FCursor write SetCursor;
    property Cursors[Index: Integer]: HCURSOR read GetCursors write SetCursors;
    property DataModules[Index: Integer]: TDataModule read GetDataModule;
    property DataModuleCount: Integer read GetDataModuleCount;
    property IconFont: TFont read FIconFont write FIconFont;
    property Fonts: TStrings read FFonts;
    property FormCount: Integer read GetFormCount;
    property Forms[Index: Integer]: TForm read GetForm;
    property Imes: TStrings read FImes;
    property DefaultIme: string read FDefaultIme;
    property DefaultKbLayout: HKL read FDefaultKbLayout;
    property Height: Integer read GetHeight;
    property PixelsPerInch: Integer read FPixelsPerInch;
    property Width: Integer read GetWidth;
    property OnActiveControlChange: TNotifyEvent
      read FOnActiveControlChange write FOnActiveControlChange;
    property OnActiveFormChange: TNotifyEvent
      read FOnActiveFormChange write FOnActiveFormChange;
  end;

{ TApplication }

  TTimerMode = (tmShow, tmHide);

  PHintInfo = ^THintInfo;
  THintInfo = record
    HintControl: TControl;
    HintWindowClass: THintWindowClass;
    HintPos: TPoint;
    HintMaxWidth: Integer;
    HintColor: TColor;
    CursorRect: TRect;
    CursorPos: TPoint;
    ReshowTimeout: Integer;
    HideTimeout: Integer;
    HintStr: string;
    HintData: Pointer;
  end;

  TCMHintShow = record
    Msg: Cardinal;
    Reserved: Integer;
    HintInfo: PHintInfo;
    Result: Integer;
  end;

  TMessageEvent = procedure (var Msg: TMsg; var Handled: Boolean) of object;
  TExceptionEvent = procedure (Sender: TObject; E: Exception) of object;
  TIdleEvent = procedure (Sender: TObject; var Done: Boolean) of object;
  TShowHintEvent = procedure (var HintStr: string; var CanShow: Boolean;
    var HintInfo: THintInfo) of object;
  TWindowHook = function (var Message: TMessage): Boolean of object;

  TApplication = class(TComponent)
  private
    FHandle: HWnd;
    FObjectInstance: Pointer;
    FMainForm: TForm;
    FMouseControl: TControl;
    FHelpFile: string;
    FHint: string;
    FHintActive: Boolean;
    FUpdateFormatSettings: Boolean;
    FUpdateMetricSettings: Boolean;
    FShowMainForm: Boolean;
    FHintColor: TColor;
    FHintControl: TControl;
    FHintCursorRect: TRect;
    FHintPause: Integer;
    FHintShortPause: Integer;
    FHintHidePause: Integer;
    FHintWindow: THintWindow;
    FShowHint: Boolean;
    FTimerMode: TTimerMode;
    FTimerHandle: Word;
    FTitle: string;
    FTopMostList: TList;
    FTopMostLevel: Integer;
    FIcon: TIcon;
    FTerminate: Boolean;
    FActive: Boolean;
    FAllowTesting: Boolean;
    FTestLib: THandle;
    FHandleCreated: Boolean;
    FRunning: Boolean;
    FWindowHooks: TList;
    FWindowList: Pointer;
    FDialogHandle: HWnd;
    FOnException: TExceptionEvent;
    FOnMessage: TMessageEvent;
    FOnHelp: THelpEvent;
    FOnHint: TNotifyEvent;
    FOnIdle: TIdleEvent;
    FOnDeactivate: TNotifyEvent;
    FOnActivate: TNotifyEvent;
    FOnShowHint: TShowHintEvent;
    FOnMinimize: TNotifyEvent;
    FOnRestore: TNotifyEvent;
    procedure ActivateHint(CursorPos: TPoint);
    function CheckIniChange(var Message: TMessage): Boolean;
    function DoMouseIdle: TControl;
    procedure DoNormalizeTopMosts(IncludeMain: Boolean);
    function GetCurrentHelpFile: string;
    function GetDialogHandle: HWND;
    function GetExeName: string;
    function GetIconHandle: HICON;
    function GetTitle: string;
    procedure HintTimerExpired;
    procedure IconChanged(Sender: TObject);
    procedure Idle;
    function InvokeHelp(Command: Word; Data: Longint): Boolean;
    function IsDlgMsg(var Msg: TMsg): Boolean;
    function IsHintMsg(var Msg: TMsg): Boolean;
    function IsKeyMsg(var Msg: TMsg): Boolean;
    function IsMDIMsg(var Msg: TMsg): Boolean;
    procedure NotifyForms(Msg: Word);
    function ProcessMessage: Boolean;
    procedure SetDialogHandle(Value: HWnd);
    procedure SetHandle(Value: HWnd);
    procedure SetHint(const Value: string);
    procedure SetHintColor(Value: TColor);
    procedure SetIcon(Value: TIcon);
    procedure SetShowHint(Value: Boolean);
    procedure SetTitle(const Value: string);
    procedure StartHintTimer(Value: Integer; TimerMode: TTimerMode);
    procedure StopHintTimer;
    procedure WndProc(var Message: TMessage);
    procedure UpdateVisible;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BringToFront;
    procedure ControlDestroyed(Control: TControl);
    procedure CancelHint;
    procedure CreateForm(InstanceClass: TComponentClass; var Reference);
    procedure CreateHandle;
    procedure HandleException(Sender: TObject);
    procedure HandleMessage;
    function HelpCommand(Command: Integer; Data: Longint): Boolean;
    function HelpContext(Context: THelpContext): Boolean;
    function HelpJump(const JumpID: string): Boolean;
    procedure HideHint;
    procedure HintMouseMessage(Control: TControl; var Message: TMessage);
    procedure HookMainWindow(Hook: TWindowHook);
    procedure Initialize;
    function MessageBox(Text, Caption: PChar; Flags: Longint): Integer;
    procedure Minimize;
    procedure NormalizeAllTopMosts;
    procedure NormalizeTopMosts;
    procedure ProcessMessages;
    procedure Restore;
    procedure RestoreTopMosts;
    procedure Run;
    procedure ShowException(E: Exception);
    procedure Terminate;
    procedure UnhookMainWindow(Hook: TWindowHook);
    property Active: Boolean read FActive;
    property AllowTesting: Boolean read FAllowTesting write FAllowTesting;
    property CurrentHelpFile: string read GetCurrentHelpFile;
    property DialogHandle: HWnd read GetDialogHandle write SetDialogHandle;
    property ExeName: string read GetExeName;
    property Handle: HWnd read FHandle write SetHandle;
    property HelpFile: string read FHelpFile write FHelpFile;
    property Hint: string read FHint write SetHint;
    property HintColor: TColor read FHintColor write SetHintColor;
    property HintPause: Integer read FHintPause write FHintPause;
    property HintShortPause: Integer read FHintShortPause write FHintShortPause;
    property HintHidePause: Integer read FHintHidePause write FHintHidePause;
    property Icon: TIcon read FIcon write SetIcon;
    property MainForm: TForm read FMainForm;
    property ShowHint: Boolean read FShowHint write SetShowHint;
    property ShowMainForm: Boolean read FShowMainForm write FShowMainForm;
    property Terminated: Boolean read FTerminate;
    property Title: string read GetTitle write SetTitle;
    property UpdateFormatSettings: Boolean read FUpdateFormatSettings
      write FUpdateFormatSettings;
    property UpdateMetricSettings: Boolean read FUpdateMetricSettings
      write FUpdateMetricSettings;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
    property OnException: TExceptionEvent read FOnException write FOnException;
    property OnIdle: TIdleEvent read FOnIdle write FOnIdle;
    property OnHelp: THelpEvent read FOnHelp write FOnHelp;
    property OnHint: TNotifyEvent read FOnHint write FOnHint;
    property OnMessage: TMessageEvent read FOnMessage write FOnMessage;
    property OnMinimize: TNotifyEvent read FOnMinimize write FOnMinimize;
    property OnRestore: TNotifyEvent read FOnRestore write FOnRestore;
    property OnShowHint: TShowHintEvent read FOnShowHint write FOnShowHint;
  end;

{ Global objects }

var
  Application: TApplication;
  Screen: TScreen;
  Ctl3DBtnWndProc: Pointer = nil;
  Ctl3DDlgFramePaint: function(Window: HWnd; Msg, wParam, lParam: Longint): Longint stdcall = nil;
  Ctl3DCtlColorEx: function(Window: HWnd; Msg, wParam, lParam: Longint): Longint stdcall = nil;
  HintWindowClass: THintWindowClass = THintWindow;
  GetDataModuleProviderNames: function(Component: TComponent): Variant;
  UpdateDataModuleRegistry: procedure(Register: Boolean; const ClassID, ProgID: string);

function GetParentForm(Control: TControl): TCustomForm;
function ValidParentForm(Control: TControl): TCustomForm;

function DisableTaskWindows(ActiveWindow: HWnd): Pointer;
procedure EnableTaskWindows(WindowList: Pointer);

function MakeObjectInstance(Method: TWndMethod): Pointer;
procedure FreeObjectInstance(ObjectInstance: Pointer);

function IsAccel(VK: Word; const Str: string): Boolean;

function  Subclass3DWnd(Wnd: HWnd): Boolean;
procedure Subclass3DDlg(Wnd: HWnd; Flags: Word);
procedure SetAutoSubClass(Enable: Boolean);
function AllocateHWnd(Method: TWndMethod): HWND;
procedure DeallocateHWnd(Wnd: HWND);
procedure DoneCtl3D;
procedure InitCtl3D;

function KeysToShiftState(Keys: Word): TShiftState;
function KeyDataToShiftState(KeyData: Longint): TShiftState;

function ForegroundTask: Boolean;

implementation

uses Printers, Consts;//, LogFile;

var
  FocusMessages: Boolean = True;
  FocusCount: Integer = 0;

const
  DefHintColor = clInfoBk;  { default hint window color }
  DefHintPause = 500;      { default pause before hint window displays (ms)}
  DefHintShortPause = DefHintPause div 10;
  DefHintHidePause = DefHintPause * 5;

function Max(X, Y: Integer): Integer;
begin
  Result := X;
  if Y > X then Result := Y;
end;

{ Task window management }

type
  PTaskWindow = ^TTaskWindow;
  TTaskWindow = record
    Next: PTaskWindow;
    Window: HWnd;
  end;

var
  TaskActiveWindow: HWnd = 0;
  TaskFirstWindow: HWnd = 0;
  TaskFirstTopMost: HWnd = 0;
  TaskWindowList: PTaskWindow = nil;

procedure DoneApplication;
begin
  with Application do
  begin
    if Handle <> 0 then ShowOwnedPopups(Handle, False);
    ShowHint := False;
    Destroying;
    DestroyComponents;
  end;
end;

function DoDisableWindow(Window: HWnd; Data: Longint): WordBool; stdcall;
var
  P: PTaskWindow;
begin
  if (Window <> TaskActiveWindow) and IsWindowVisible(Window) and
    IsWindowEnabled(Window) then
  begin
    New(P);
    P^.Next := TaskWindowList;
    P^.Window := Window;
    TaskWindowList := P;
    EnableWindow(Window, False);
  end;
  Result := True;
end;

function DisableTaskWindows(ActiveWindow: HWnd): Pointer;
var
  SaveActiveWindow: HWND;
  SaveWindowList: Pointer;
begin
  Result := nil;
  SaveActiveWindow := TaskActiveWindow;
  SaveWindowList := TaskWindowList;
  TaskActiveWindow := ActiveWindow;
  TaskWindowList := nil;
  try
    try
      EnumThreadWindows(GetCurrentThreadID, @DoDisableWindow, 0);
      Result := TaskWindowList;
    except
      EnableTaskWindows(TaskWindowList);
      raise;
    end;
  finally
    TaskWindowList := SaveWindowList;
    TaskActiveWindow := SaveActiveWindow;
  end;
end;

procedure EnableTaskWindows(WindowList: Pointer);
var
  P: PTaskWindow;
begin
  while WindowList <> nil do
  begin
    P := WindowList;
    if IsWindow(P^.Window) then EnableWindow(P^.Window, True);
    WindowList := P^.Next;
    Dispose(P);
  end;
end;

function DoFindWindow(Window: HWnd; Param: Longint): WordBool; stdcall;
begin
  if (Window <> TaskActiveWindow) and (Window <> Application.FHandle) and
    IsWindowVisible(Window) and IsWindowEnabled(Window) then
    if GetWindowLong(Window, GWL_EXSTYLE) and WS_EX_TOPMOST = 0 then
    begin
      if TaskFirstWindow = 0 then TaskFirstWindow := Window;
    end else
    begin
      if TaskFirstTopMost = 0 then TaskFirstTopMost := Window;
    end;
  Result := True;
end;

function FindTopMostWindow(ActiveWindow: HWnd): HWnd;
begin
  TaskActiveWindow := ActiveWindow;
  TaskFirstWindow := 0;
  TaskFirstTopMost := 0;
  EnumThreadWindows(GetCurrentThreadID, @DoFindWindow, 0);
  if TaskFirstWindow <> 0 then
    Result := TaskFirstWindow else
    Result := TaskFirstTopMost;
end;

function SendFocusMessage(Window: HWnd; Msg: Word): Boolean;
var
  Count: Integer;
begin
  Count := FocusCount;
  SendMessage(Window, Msg, 0, 0);
  Result := FocusCount = Count;
end;

{ Check if this is the active Windows task }

type
  PCheckTaskInfo = ^TCheckTaskInfo;
  TCheckTaskInfo = record
    FocusWnd: HWnd;
    Found: Boolean;
  end;

function CheckTaskWindow(Window: HWnd; Data: Longint): WordBool; stdcall;
begin
  Result := True;
  if PCheckTaskInfo(Data)^.FocusWnd = Window then
  begin
    Result := False;
    PCheckTaskInfo(Data)^.Found := True;
  end;
end;

function ForegroundTask: Boolean;
var
  Info: TCheckTaskInfo;
begin
  Info.FocusWnd := GetActiveWindow;
  Info.Found := False;
  EnumThreadWindows(GetCurrentThreadID, @CheckTaskWindow, Longint(@Info));
  Result := Info.Found;
end;

function FindGlobalComponent(const Name: string): TComponent;
var
  I: Integer;
begin
  for I := 0 to Screen.FormCount - 1 do
  begin
    Result := Screen.Forms[I];
    if CompareText(Name, Result.Name) = 0 then Exit;
  end;
  for I := 0 to Screen.DataModuleCount - 1 do
  begin
    Result := Screen.DataModules[I];
    if CompareText(Name, Result.Name) = 0 then Exit;
  end;
  Result := nil;
end;

{ CTL3D32.DLL support }

var
  Ctl3DHandle: THandle = 0;

const
  Ctl3DLib = 'CTL3D32.DLL';
var
  Ctl3DRegister: function(Instance: THandle): Bool stdcall;
  Ctl3DUnregister: function(Instance: THandle): Bool stdcall;
  Ctl3DSubclassCtl: function(Wnd: HWnd): Bool stdcall;
  Ctl3DSubclassDlg: function(Wnd: HWnd; Flags: Word): Bool stdcall;
  Ctl3DAutoSubclass: function(Instance: THandle): Bool stdcall;
  Ctl3DUnAutoSubclass: function: Bool stdcall;
  Ctl3DColorChange: function: Bool stdcall;

procedure InitCtl3D;
var
  ErrMode: Word;
  Version: Longint;
begin
  if Ctl3DHandle = 0 then
  begin
    Version := GetVersion;
    if (LoByte(LoWord(Version)) < 4) and (HiByte(LoWord(Version)) < $59) then
    begin
      ErrMode := SetErrorMode(SEM_NOOPENFILEERRORBOX);
      Ctl3DHandle := LoadLibrary(Ctl3DLib);
      SetErrorMode(ErrMode);
    end;
    if (Ctl3DHandle >= 0) and (Ctl3DHandle < 32) then Ctl3DHandle := 1;
    if Ctl3DHandle >= 32 then
    begin
      @Ctl3DRegister := GetProcAddress(Ctl3DHandle, 'Ctl3dRegister');
      if Ctl3DRegister(HInstance) then
      begin
        @Ctl3DUnregister := GetProcAddress(Ctl3DHandle, 'Ctl3dUnregister');
        @Ctl3DSubclassCtl := GetProcAddress(Ctl3DHandle, 'Ctl3dSubclassCtl');
        @Ctl3DSubclassDlg := GetProcAddress(Ctl3DHandle, 'Ctl3dSubclassDlgEx');
        @Ctl3DDlgFramePaint := GetProcAddress(Ctl3DHandle, 'Ctl3dDlgFramePaint');
        @Ctl3DCtlColorEx := GetProcAddress(Ctl3DHandle, 'Ctl3dCtlColorEx');
        @Ctl3DAutoSubclass := GetProcAddress(Ctl3DHandle, 'Ctl3dAutoSubclass');
        @Ctl3DUnAutoSubclass := GetProcAddress(Ctl3DHandle, 'Ctl3dUnAutoSubclass');
        @Ctl3DColorChange := GetProcAddress(Ctl3DHandle, 'Ctl3DColorChange');
        Ctl3DBtnWndProc := GetProcAddress(Ctl3DHandle, 'BtnWndProc3d');
      end
      else
      begin
        FreeLibrary(Ctl3DHandle);
        Ctl3DHandle := 1;
      end;
    end;
  end;
end;

procedure DoneCtl3D;
begin
  if Ctl3DHandle >= 32 then
  begin
    Ctl3DUnregister(HInstance);
    FreeLibrary(Ctl3DHandle);
  end;
end;

function Subclass3DWnd(Wnd: HWnd): Boolean;
begin
  Result := False;
  if Ctl3DHandle = 0 then InitCtl3D;
  if Ctl3DHandle >= 32 then
    Result := Ctl3DSubclassCtl(Wnd);
end;

procedure Subclass3DDlg(Wnd: HWnd; Flags: Word);
begin
  if Ctl3DHandle = 0 then InitCtl3D;
  if Ctl3DHandle >= 32 then Ctl3DSubclassDlg(Wnd, Flags);
end;

procedure SetAutoSubClass(Enable: Boolean);
begin
  if Ctl3DHandle = 0 then InitCtl3D;
  if Ctl3DHandle >= 32 then
    if (@Ctl3DAutoSubclass = nil) or (@Ctl3DUnAutoSubclass = nil) then
      Exit
    else if Enable then
      Ctl3DAutoSubclass(HInstance)
    else Ctl3dUnAutoSubclass;
end;

const
  InstanceCount = 313;

{ Object instance management }

type
  PObjectInstance = ^TObjectInstance;
  TObjectInstance = packed record
    Code: Byte;
    Offset: Integer;
    case Integer of
      0: (Next: PObjectInstance);
      1: (Method: TWndMethod);
  end;

type
  PInstanceBlock = ^TInstanceBlock;
  TInstanceBlock = packed record
    Next: PInstanceBlock;
    Code: array[1..2] of Byte;
    WndProcPtr: Pointer;
    Instances: array[0..InstanceCount] of TObjectInstance;
  end;

var
  InstBlockList: PInstanceBlock;
  InstFreeList: PObjectInstance;

{ Standard window procedure }
{ In    ECX = Address of method pointer }
{ Out   EAX = Result }

function StdWndProc(Window: HWND; Message, WParam: Longint;
  LParam: Longint): Longint; stdcall; assembler;
asm
        XOR     EAX,EAX
        PUSH    EAX
        PUSH    LParam
        PUSH    WParam
        PUSH    Message
        MOV     EDX,ESP
        MOV     EAX,[ECX].Longint[4]
        CALL    [ECX].Pointer
        ADD     ESP,12
        POP     EAX
end;

{ Allocate an object instance }

function CalcJmpOffset(Src, Dest: Pointer): Longint;
begin
  Result := Longint(Dest) - (Longint(Src) + 5);
end;

function MakeObjectInstance(Method: TWndMethod): Pointer;
const
  BlockCode: array[1..2] of Byte = (
    $59,       { POP ECX }
    $E9);      { JMP StdWndProc }
  PageSize = 4096;
var
  Block: PInstanceBlock;
  Instance: PObjectInstance;
begin
  if InstFreeList = nil then
  begin
    Block := VirtualAlloc(nil, PageSize, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    Block^.Next := InstBlockList;
    Move(BlockCode, Block^.Code, SizeOf(BlockCode));
    Block^.WndProcPtr := Pointer(CalcJmpOffset(@Block^.Code[2], @StdWndProc));
    Instance := @Block^.Instances;
    repeat
      Instance^.Code := $E8;  { CALL NEAR PTR Offset }
      Instance^.Offset := CalcJmpOffset(Instance, @Block^.Code);
      Instance^.Next := InstFreeList;
      InstFreeList := Instance;
      Inc(Longint(Instance), SizeOf(TObjectInstance));
    until Longint(Instance) - Longint(Block) >= SizeOf(TInstanceBlock);
    InstBlockList := Block;
  end;
  Result := InstFreeList;
  Instance := InstFreeList;
  InstFreeList := Instance^.Next;
  Instance^.Method := Method;
end;

{ Free an object instance }

procedure FreeObjectInstance(ObjectInstance: Pointer);
begin
  if ObjectInstance <> nil then
  begin
    PObjectInstance(ObjectInstance)^.Next := InstFreeList;
    InstFreeList := ObjectInstance;
  end;
end;

var
  UtilWindowClass: TWndClass = (
    style: 0;
    lpfnWndProc: @DefWindowProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'TPUtilWindow');

function AllocateHWnd(Method: TWndMethod): HWND;
var
  TempClass: TWndClass;
  ClassRegistered: Boolean;
begin
  UtilWindowClass.hInstance := HInstance;
  ClassRegistered := GetClassInfo(HInstance, UtilWindowClass.lpszClassName,
    TempClass);
  if not ClassRegistered or (TempClass.lpfnWndProc <> @DefWindowProc) then
  begin
    if ClassRegistered then
      Windows.UnregisterClass(UtilWindowClass.lpszClassName, HInstance);
    Windows.RegisterClass(UtilWindowClass);
  end;
  Result := CreateWindowEx(WS_EX_TOOLWINDOW, UtilWindowClass.lpszClassName,
    '', WS_POPUP {!!!0}, 0, 0, 0, 0, 0, 0, HInstance, nil);
  if Assigned(Method) then
    SetWindowLong(Result, GWL_WNDPROC, Longint(MakeObjectInstance(Method)));
end;

procedure DeallocateHWnd(Wnd: HWND);
var
  Instance: Pointer;
begin
  Instance := Pointer(GetWindowLong(Wnd, GWL_WNDPROC));
  DestroyWindow(Wnd);
  if Instance <> @DefWindowProc then FreeObjectInstance(Instance);
end;

{ Utility mapping functions }

{ Convert mouse message to TMouseButton }

function KeysToShiftState(Keys: Word): TShiftState;
begin
  Result := [];
  if Keys and MK_SHIFT <> 0 then Include(Result, ssShift);
  if Keys and MK_CONTROL <> 0 then Include(Result, ssCtrl);
  if Keys and MK_LBUTTON <> 0 then Include(Result, ssLeft);
  if Keys and MK_RBUTTON <> 0 then Include(Result, ssRight);
  if Keys and MK_MBUTTON <> 0 then Include(Result, ssMiddle);
  if GetKeyState(VK_MENU) < 0 then Include(Result, ssAlt);
end;

{ Convert keyboard message data to TShiftState }

function KeyDataToShiftState(KeyData: Longint): TShiftState;
const
  AltMask = $20000000;
begin
  Result := [];
  if GetKeyState(VK_SHIFT) < 0 then Include(Result, ssShift);
  if GetKeyState(VK_CONTROL) < 0 then Include(Result, ssCtrl);
  if KeyData and AltMask <> 0 then Include(Result, ssAlt);
end;

function IsAccel(VK: Word; const Str: string): Boolean;
var
  P: Integer;
begin
  P := Pos('&', Str);
  Result := (P <> 0) and (P < Length(Str)) and
    (AnsiCompareText(Str[P + 1], Char(VK)) = 0);
end;

{ Form utility functions }

function GetParentForm(Control: TControl): TCustomForm;
begin
  while Control.Parent <> nil do Control := Control.Parent;
  Result := nil;
  if Control is TCustomForm then Result := TCustomForm(Control);
end;

function ValidParentForm(Control: TControl): TCustomForm;
begin
  Result := GetParentForm(Control);
  if Result = nil then
    raise EInvalidOperation.CreateFmt(SParentRequired, [Control.Name]);
end;

{ TDesigner }

function TDesigner.GetIsControl: Boolean;
begin
  Result := (FCustomForm <> nil) and FCustomForm.IsControl;
end;

procedure TDesigner.SetIsControl(Value: Boolean);
begin
  if (FCustomForm <> nil) then FCustomForm.IsControl := Value;
end;

{ TControlScrollBar }

constructor TControlScrollBar.Create(AControl: TScrollingWinControl;
  AKind: TScrollBarKind);
begin
  inherited Create;
  FControl := AControl;
  FKind := AKind;
  FIncrement := 8;
  FVisible := True;
end;

procedure TControlScrollBar.Assign(Source: TPersistent);
begin
  if Source is TControlScrollBar then
  begin
    Visible := TControlScrollBar(Source).Visible;
    Range := TControlScrollBar(Source).Range;
    Position := TControlScrollBar(Source).Position;
    Increment := TControlScrollBar(Source).Increment;
    Exit;
  end;
  inherited Assign(Source);
end;

procedure TControlScrollBar.CalcAutoRange;
var
  I: Integer;
  NewRange, AlignMargin: Integer;

  procedure ProcessHorz(Control: TControl);
  begin
    if Control.Visible then
      case TForm(Control).Align of
        alNone: NewRange := Max(NewRange, Position + Control.Left + Control.Width);
        alRight: Inc(AlignMargin, Control.Width);
      end;
  end;

  procedure ProcessVert(Control: TControl);
  begin
    if Control.Visible then
      case TForm(Control).Align of
        alNone: NewRange := Max(NewRange, Position + Control.Top + Control.Height);
        alBottom: Inc(AlignMargin, Control.Height);
      end;
  end;

begin
  if FControl.FAutoScroll then
  begin
    NewRange := 0;
    AlignMargin := 0;
    for I := 0 to FControl.ControlCount - 1 do
      if Kind = sbHorizontal then
        ProcessHorz(FControl.Controls[I]) else
        ProcessVert(FControl.Controls[I]);
    DoSetRange(NewRange + AlignMargin + Margin);
  end;
end;

function TControlScrollBar.ControlSize(ControlSB, AssumeSB: Boolean): Integer;
var
  BorderAdjust: Integer;

  function ScrollBarVisible(Code: Word): Boolean;
  var
    Style: Longint;
  begin
    Style := WS_HSCROLL;
    if Code = SB_VERT then Style := WS_VSCROLL;
    Result := GetWindowLong(FControl.Handle, GWL_STYLE) and Style <> 0;
  end;

  function Adjustment(Code, Metric: Word): Integer;
  begin
    Result := 0;
    if not ControlSB then
      if AssumeSB and not ScrollBarVisible(Code) then
        Result := -(GetSystemMetrics(Metric) - BorderAdjust)
      else if not AssumeSB and ScrollBarVisible(Code) then
        Result := GetSystemMetrics(Metric) - BorderAdjust;
  end;

begin
  BorderAdjust := Integer(GetWindowLong(FControl.Handle, GWL_STYLE) and
    (WS_BORDER or WS_THICKFRAME) <> 0);
  if Kind = sbVertical then
    Result := FControl.ClientHeight + Adjustment(SB_HORZ, SM_CXHSCROLL) else
    Result := FControl.ClientWidth + Adjustment(SB_VERT, SM_CYVSCROLL);
end;

function TControlScrollBar.GetScrollPos: Integer;
begin
  Result := 0;
  if Visible then Result := Position;
end;

function TControlScrollBar.NeedsScrollBarVisible: Boolean;
begin
  Result := FRange > ControlSize(False, False);
end;

procedure TControlScrollBar.ScrollMessage(var Msg: TWMScroll);
begin
  with Msg do
    case ScrollCode of
      SB_LINEUP: SetPosition(FPosition - FIncrement);
      SB_LINEDOWN: SetPosition(FPosition + FIncrement);
      SB_PAGEUP: SetPosition(FPosition - ControlSize(True, False));
      SB_PAGEDOWN: SetPosition(FPosition + ControlSize(True, False));
      SB_THUMBPOSITION: SetPosition(Pos);
      SB_THUMBTRACK: if Tracking then SetPosition(Pos);
      SB_TOP: SetPosition(0);
      SB_BOTTOM: SetPosition(FCalcRange);
      SB_ENDSCROLL: begin end;
    end;
end;

procedure TControlScrollBar.SetPosition(Value: Integer);
var
  Code: Word;
  Form: TCustomForm;
  OldPos: Integer;
begin
  if csReading in FControl.ComponentState then
    FPosition := Value
  else
  begin
    if Value > FCalcRange then Value := FCalcRange
    else if Value < 0 then Value := 0;
    if Kind = sbHorizontal then
      Code := SB_HORZ else
      Code := SB_VERT;
    if Value <> FPosition then
    begin
      OldPos := FPosition;
      FPosition := Value;
      if Kind = sbHorizontal then
        FControl.ScrollBy(OldPos - Value, 0) else
        FControl.ScrollBy(0, OldPos - Value);
      if csDesigning in FControl.ComponentState then
      begin
        Form := GetParentForm(FControl);
        if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
      end;
    end;
    if Windows.GetScrollPos(FControl.Handle, Code) <> FPosition then
      SetScrollPos(FControl.Handle, Code, FPosition, True);
  end;
end;

procedure TControlScrollBar.DoSetRange(Value: Integer);
begin
  FRange := Value;
  if FRange < 0 then FRange := 0;
  FControl.UpdateScrollBars;
end;

procedure TControlScrollBar.SetRange(Value: Integer);
begin
  FControl.FAutoScroll := False;
  FScaled := True;
  DoSetRange(Value);
end;

function TControlScrollBar.IsRangeStored: Boolean;
begin
  Result := not FControl.AutoScroll;
end;

procedure TControlScrollBar.SetVisible(Value: Boolean);
begin
  FVisible := Value;
  FControl.UpdateScrollBars;
end;

procedure TControlScrollBar.Update(ControlSB, AssumeSB: Boolean);
var
  Code: Word;
  ScrollInfo: TScrollInfo;
begin
  FCalcRange := 0;
  Code := SB_HORZ;
  if Kind = sbVertical then Code := SB_VERT;
  if Visible then
  begin
    FCalcRange := Range - ControlSize(ControlSB, AssumeSB);
    if FCalcRange < 0 then FCalcRange := 0;
  end;
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.fMask := SIF_ALL;
  ScrollInfo.nMin := 0;
  if FCalcRange > 0 then
    ScrollInfo.nMax := Range else
    ScrollInfo.nMax := 0;
  ScrollInfo.nPage := ControlSize(ControlSB, AssumeSB) + 1;
  ScrollInfo.nPos := FPosition;
  ScrollInfo.nTrackPos := FPosition;
  SetScrollInfo(FControl.Handle, Code, ScrollInfo, True);
  SetPosition(FPosition);
end;

{ TScrollingWinControl }

constructor TScrollingWinControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHorzScrollBar := TControlScrollBar.Create(Self, sbHorizontal);
  FVertScrollBar := TControlScrollBar.Create(Self, sbVertical);
  FAutoScroll := True;
end;

destructor TScrollingWinControl.Destroy;
begin
  FHorzScrollBar.Free;
  FVertScrollBar.Free;
  inherited Destroy;
end;

procedure TScrollingWinControl.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params.WindowClass do
    style := style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TScrollingWinControl.CreateWnd;
begin
  inherited CreateWnd;
  UpdateScrollBars;
end;

procedure TScrollingWinControl.AlignControls(AControl: TControl; var ARect: TRect);
begin
  CalcAutoRange;
  ARect := Bounds(-HorzScrollBar.Position, -VertScrollBar.Position,
    Max(HorzScrollBar.Range, ClientWidth), Max(ClientHeight, VertScrollBar.Range));
  inherited AlignControls(AControl, ARect);
end;

procedure TScrollingWinControl.CalcAutoRange;
begin
  if FAutoRangeCount <= 0 then
  begin
    HorzScrollBar.CalcAutoRange;
    VertScrollBar.CalcAutoRange;
  end;
end;

procedure TScrollingWinControl.SetAutoScroll(Value: Boolean);
begin
  if FAutoScroll <> Value then
  begin
    FAutoScroll := Value;
    if Value then CalcAutoRange else
    begin
      HorzScrollBar.Range := 0;
      VertScrollBar.Range := 0;
    end;
  end;
end;

procedure TScrollingWinControl.SetHorzScrollBar(Value: TControlScrollBar);
begin
  FHorzScrollBar.Assign(Value);
end;

procedure TScrollingWinControl.SetVertScrollBar(Value: TControlScrollBar);
begin
  FVertScrollBar.Assign(Value);
end;

procedure TScrollingWinControl.UpdateScrollBars;
begin
  if not FUpdatingScrollBars and HandleAllocated then
    try
      FUpdatingScrollBars := True;
      if FVertScrollBar.NeedsScrollBarVisible then
      begin
        FHorzScrollBar.Update(False, True);
        FVertScrollBar.Update(True, False);
      end
      else if FHorzScrollBar.NeedsScrollBarVisible then
      begin
        FVertScrollBar.Update(False, True);
        FHorzScrollBar.Update(True, False);
      end
      else
      begin
        FVertScrollBar.Update(False, False);
        FHorzScrollBar.Update(True, False);
      end;
    finally
      FUpdatingScrollBars := False;
    end;
end;

procedure TScrollingWinControl.AutoScrollInView(AControl: TControl);
begin
  if (AControl <> nil) and not (csLoading in AControl.ComponentState) and
    not (csLoading in ComponentState) then
    ScrollInView(AControl);
end;

procedure TScrollingWinControl.DisableAutoRange;
begin
  Inc(FAutoRangeCount);
end;

procedure TScrollingWinControl.EnableAutoRange;
begin
  if FAutoRangeCount > 0 then
  begin
    Dec(FAutoRangeCount);
    if (FAutoRangeCount = 0) and (FHorzScrollBar.Visible or
      FVertScrollBar.Visible) then CalcAutoRange;
  end;
end;

procedure TScrollingWinControl.ScrollInView(AControl: TControl);
var
  Rect: TRect;
begin
  if AControl = nil then Exit;
  Rect := AControl.ClientRect;
  Dec(Rect.Left, HorzScrollBar.Margin);
  Inc(Rect.Right, HorzScrollBar.Margin);
  Dec(Rect.Top, VertScrollBar.Margin);
  Inc(Rect.Bottom, VertScrollBar.Margin);
  Rect.TopLeft := ScreenToClient(AControl.ClientToScreen(Rect.TopLeft));
  Rect.BottomRight := ScreenToClient(AControl.ClientToScreen(Rect.BottomRight));
  if Rect.Left < 0 then
    with HorzScrollBar do Position := Position + Rect.Left
  else if Rect.Right > ClientWidth then
  begin
    if Rect.Right - Rect.Left > ClientWidth then
      Rect.Right := Rect.Left + ClientWidth;
    with HorzScrollBar do Position := Position + Rect.Right - ClientWidth;
  end;
  if Rect.Top < 0 then
    with VertScrollBar do Position := Position + Rect.Top
  else if Rect.Bottom > ClientHeight then
  begin
    if Rect.Bottom - Rect.Top > ClientHeight then
      Rect.Bottom := Rect.Top + ClientHeight;
    with VertScrollBar do Position := Position + Rect.Bottom - ClientHeight;
  end;
end;

procedure TScrollingWinControl.ScaleScrollBars(M, D: Integer);
begin
  if M <> D then
  begin
    if not (csLoading in ComponentState) then
    begin
      HorzScrollBar.FScaled := True;
      VertScrollBar.FScaled := True;
    end;
    HorzScrollBar.Position := 0;
    VertScrollBar.Position := 0;
    if not FAutoScroll then
    begin
      with HorzScrollBar do if FScaled then Range := MulDiv(Range, M, D);
      with VertScrollBar do if FScaled then Range := MulDiv(Range, M, D);
    end;
  end;
  HorzScrollBar.FScaled := False;
  VertScrollBar.FScaled := False;
end;

procedure TScrollingWinControl.ChangeScale(M, D: Integer);
begin
  ScaleScrollBars(M, D);
  inherited ChangeScale(M, D);
end;

procedure TScrollingWinControl.WMSize(var Message: TWMSize);
begin
  Inc(FAutoRangeCount);
  try
    inherited;
  finally
    Dec(FAutoRangeCount);
  end;
  if FHorzScrollBar.Visible or FVertScrollBar.Visible then
    UpdateScrollBars;
end;

procedure TScrollingWinControl.WMHScroll(var Message: TWMHScroll);
begin
  if (Message.ScrollBar = 0) and FHorzScrollBar.Visible then
    FHorzScrollBar.ScrollMessage(Message) else
    inherited;
end;

procedure TScrollingWinControl.WMVScroll(var Message: TWMVScroll);
begin
  if (Message.ScrollBar = 0) and FVertScrollBar.Visible then
    FVertScrollBar.ScrollMessage(Message) else
    inherited;
end;

{ TScrollBox }

constructor TScrollBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csDoubleClicks];
  Width := 185;
  Height := 41;
  FBorderStyle := bsSingle;
end;

procedure TScrollBox.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of Longint = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or BorderStyles[FBorderStyle];
    WindowClass.style := WindowClass.style or CS_HREDRAW or CS_VREDRAW;
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TScrollBox.Resize;
begin
  if Assigned(FOnResize) then FOnResize(Self);
end;

procedure TScrollBox.SetBorderStyle(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TScrollBox.WMSize(var Message: TWMSize);
begin
  inherited;
  if not (csLoading in ComponentState) then Resize;
  CalcAutoRange;
end;

procedure TScrollBox.WMNCHitTest(var Message: TMessage);
begin
  DefaultHandler(Message);
end;

procedure TScrollBox.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then RecreateWnd;
  inherited;
end;

{ TForm }

constructor TCustomForm.Create(AOwner: TComponent);
begin
  CreateNew(AOwner);
  if (ClassType <> TForm) and not (csDesigning in ComponentState) then
  begin
    Include(FFormState, fsCreating);
    try
      if not InitInheritedComponent(Self, TForm) then
        raise EResNotFound.CreateFmt(SResNotFound, [ClassName]);
    finally
      Exclude(FFormState, fsCreating);
    end;
    try
      if Assigned(FOnCreate) then FOnCreate(Self);
    except
      Application.HandleException(Self);
    end;
    if fsVisible in FFormState then Visible := True;
  end;
end;

constructor TCustomForm.CreateNew(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csDoubleClicks];
  Left := 0;
  Top := 0;
  Width := 320;
  Height := 240;
  Visible := False;
  ParentColor := False;
  ParentFont := False;
  Ctl3D := True;
  FBorderIcons := [biSystemMenu, biMinimize, biMaximize];
  FBorderStyle := bsSizeable;
  FWindowState := wsNormal;
  FIcon := TIcon.Create;
  FIcon.OnChange := IconChanged;
  FCanvas := TControlCanvas.Create;
  FCanvas.Control := Self;
  FPixelsPerInch := Screen.PixelsPerInch;
  FPrintScale := poProportional;
  Screen.AddForm(Self);
end;

destructor TCustomForm.Destroy;
begin
  try
    Destroying;
    Screen.FSaveFocusedList.Remove(Self);
    RemoveFixupReferences(Self, '');
    if FOleForm <> nil then FOleForm.OnDestroy;
    if FormStyle <> fsMDIChild then Hide;
    if Assigned(FOnDestroy) then
      try
        FOnDestroy(Self);
      except
        Application.HandleException(Self);
      end;
    MergeMenu(False);
    if HandleAllocated then DestroyWindowHandle;
    Screen.RemoveForm(Self);
    FCanvas.Free;
    FIcon.Free;
    FMenu.Free;
    inherited Destroy;
  except
  end;
end;

procedure TCustomForm.Loaded;
var
  Control: TWinControl;
begin
  inherited Loaded;
  if ActiveControl <> nil then
  begin
    Control := ActiveControl;
    FActiveControl := nil;
    if Control.CanFocus then SetActiveControl(Control);
  end;
end;

procedure TCustomForm.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  case Operation of
    opInsert:
      if not (csLoading in ComponentState) and (Menu = nil) and
        (AComponent.Owner = Self) and (AComponent is TMainMenu) then
        Menu := TMainMenu(AComponent);
    opRemove:
      begin
        if Menu = AComponent then Menu := nil;
        if WindowMenu = AComponent then WindowMenu := nil;
      end;
  end;
  if FDesigner <> nil then
    FDesigner.Notification(AComponent, Operation);
end;

procedure TCustomForm.ReadState(Reader: TReader);
var
  NewTextHeight: Integer;
  Scaled: Boolean;
begin
  DisableAlign;
  try
    FClientWidth := 0;
    FClientHeight := 0;
    FTextHeight := 0;
    Scaled := False;
    inherited ReadState(Reader);
    if (FPixelsPerInch <> 0) and (FTextHeight > 0) then
    begin
      if (sfFont in ScalingFlags) and (FPixelsPerInch <> Screen.PixelsPerInch) then
        Font.Height := MulDiv(Font.Height, Screen.PixelsPerInch,
          FPixelsPerInch);
      FPixelsPerInch := Screen.PixelsPerInch;
      NewTextHeight := GetTextHeight;
      if FTextHeight <> NewTextHeight then
      begin
        Scaled := True;
        ScaleScrollBars(NewTextHeight, FTextHeight);
        ScaleControls(NewTextHeight, FTextHeight);
        if sfWidth in ScalingFlags then
          FClientWidth := MulDiv(FClientWidth, NewTextHeight, FTextHeight);
        if sfHeight in ScalingFlags then
          FClientHeight := MulDiv(FClientHeight, NewTextHeight, FTextHeight);
      end;
    end;
    if FClientWidth > 0 then inherited ClientWidth := FClientWidth;
    if FClientHeight > 0 then inherited ClientHeight := FClientHeight;
    ScalingFlags := [];
    if not Scaled then
    begin
      { Forces all ScalingFlags to [] }
      ScaleScrollBars(1, 1);
      ScaleControls(1, 1);
    end;
  finally
    EnableAlign;
  end;
end;

procedure TCustomForm.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('PixelsPerInch', nil, WritePixelsPerInch, not IsControl);
  Filer.DefineProperty('TextHeight', ReadTextHeight, WriteTextHeight, not IsControl);
end;

procedure TCustomForm.ReadTextHeight(Reader: TReader);
begin
  FTextHeight := Reader.ReadInteger;
end;

procedure TCustomForm.WriteTextHeight(Writer: TWriter);
begin
  Writer.WriteInteger(GetTextHeight);
end;

procedure TCustomForm.WritePixelsPerInch(Writer: TWriter);
begin
  Writer.WriteInteger(GetPixelsPerInch);
end;

function TCustomForm.GetTextHeight: Integer;
begin
  Result := Canvas.TextHeight('0');
end;

procedure TCustomForm.ChangeScale(M, D: Integer);
var
  PriorHeight: Integer;
begin
  ScaleScrollBars(M, D);
  ScaleControls(M, D);
  if IsClientSizeStored then
  begin
    PriorHeight := ClientHeight;
    ClientWidth := MulDiv(ClientWidth, M, D);
    ClientHeight := MulDiv(PriorHeight, M, D);
  end;
  Font.Size := MulDiv(Font.Size, M, D);
end;

procedure TCustomForm.IconChanged(Sender: TObject);
begin
  if NewStyleControls then
  begin
    if HandleAllocated and (BorderStyle <> bsDialog) then
      SendMessage(Handle, WM_SETICON, 1, GetIconHandle);
  end else
    if IsIconic(Handle) then Invalidate;
end;

function TCustomForm.IsClientSizeStored: Boolean;
begin
  Result := not IsFormSizeStored;
end;

function TCustomForm.IsFormSizeStored: Boolean;
begin
  Result := AutoScroll or (HorzScrollBar.Range <> 0) or
    (VertScrollBar.Range <> 0);
end;

function TCustomForm.IsAutoScrollStored: Boolean;
begin
  Result := IsForm and
    (AutoScroll <> (BorderStyle in [bsSizeable, bsSizeToolWin]));
end;

procedure TCustomForm.DoHide;
begin
  if Assigned(FOnHide) then FOnHide(Self);
end;

procedure TCustomForm.DoShow;
begin
  if Assigned(FOnShow) then FOnShow(Self);
end;

function TCustomForm.GetClientRect: TRect;
begin
  if IsIconic(Handle) then
  begin
    SetRect(Result, 0, 0, 0, 0);
    AdjustWindowRectEx(Result, GetWindowLong(Handle, GWL_STYLE),
      Menu <> nil, GetWindowLong(Handle, GWL_EXSTYLE));
    SetRect(Result, 0, 0,
      Width - Result.Right + Result.Left,
      Height - Result.Bottom + Result.Top);
  end else
    Result := inherited GetClientRect;
end;

procedure TCustomForm.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
  OwnedComponent: TComponent;
begin
  inherited GetChildren(Proc, Root);
  if Root = Self then
    for I := 0 to ComponentCount - 1 do
    begin
      OwnedComponent := Components[I];
      if not OwnedComponent.HasParent then Proc(OwnedComponent);
    end;
end;

procedure TCustomForm.SetChildOrder(Child: TComponent; Order: Integer);
var
  I, J: Integer;
begin
  if Child is TControl then
    inherited SetChildOrder(Child, Order)
  else
  begin
    Dec(Order, ControlCount);
    J := -1;
    for I := 0 to ComponentCount - 1 do
      if not Components[I].HasParent then
      begin
        Inc(J);
        if J = Order then
        begin
          Child.ComponentIndex := I;
          Exit;
        end;
      end;
  end;
end;

procedure TCustomForm.SetClientWidth(Value: Integer);
begin
  if csReadingState in ControlState then
  begin
    FClientWidth := Value;
    ScalingFlags := ScalingFlags + [sfWidth];
  end else inherited ClientWidth := Value;
end;

procedure TCustomForm.SetClientHeight(Value: Integer);
begin
  if csReadingState in ControlState then
  begin
    FClientHeight := Value;
    ScalingFlags := ScalingFlags + [sfHeight];
  end else inherited ClientHeight := Value;
end;

procedure TCustomForm.SetVisible(Value: Boolean);
begin
  if fsCreating in FFormState then
    if Value then
      Include(FFormState, fsVisible) else
      Exclude(FFormState, fsVisible)
  else
    inherited Visible := Value;
end;

procedure TCustomForm.VisibleChanging;
begin
  if (FormStyle = fsMDIChild) and Visible then
    raise EInvalidOperation.Create(SMDIChildNotVisible);
end;

function TCustomForm.WantChildKey(Child: TControl; var Message: TMessage): Boolean;
begin
  Result := False;
end;

procedure TCustomForm.SetParent(AParent: TWinControl);
begin
  if (Parent <> AParent) and (AParent <> Self) then
  begin
    if Parent = nil then DestroyHandle;
    inherited SetParent(AParent);
    if Parent = nil then UpdateControlState;
  end;
end;

procedure TCustomForm.ValidateRename(AComponent: TComponent;
  const CurName, NewName: string);
begin
  inherited ValidateRename(AComponent, CurName, NewName);
  if FDesigner <> nil then
    FDesigner.ValidateRename(AComponent, CurName, NewName);
end;

procedure TCustomForm.WndProc(var Message: TMessage);
var
  FocusHandle: HWND;
  Rgn1, Rgn2: HRGN;
  BorderX, BorderY: Integer;
begin
  {$IFDEF Logs}
  if Message.Msg = WM_CHAR
    then
      LogThis( 'WM_CHAR message received within TCustomForm: ' + char( Message.wParam ) );
  {$ENDIF}
  with Message do
    case Msg of
      WM_SETTEXT, WM_NCPAINT, WM_NCACTIVATE:
        if HandleAllocated and (FBorderStyle = bsDialog) and Ctl3D and
          Assigned(Ctl3DDlgFramePaint) then
        begin
          if Msg = WM_SETTEXT then
           { Work around Ctl3D unicode bug (garbage caption) and redraw flicker.
             The string must be given to the default proc, but the defaultproc
             also redraws the old-style border, causing lots of flicker.
             Use SetWindowRgn to prevent that redraw, then simulate a
             WM_NCPAINT for Ctl3DDlgFramePaint to draw the new caption. }
          begin
            Rgn1 := CreateRectRgn(0, 0, Width, Height); // width & height required
            GetWindowRgn(Handle, Rgn1);
            SetWindowRgn(Handle, CreateRectRgn(0, 0, 0, 0), False);
            inherited WndProc(Message);
            SetWindowRgn(Handle, Rgn1, False);  // takes ownership of region
            BorderX := GetSystemMetrics(SM_CXDLGFRAME);
            BorderY := GetSystemMetrics(SM_CYDLGFRAME);
            Rgn2 := CreateRectRgn(Left + BorderX + 2, Top + BorderY + 1,
              Left + Width - 2*BorderX,
              Top + BorderY + GetSystemMetrics(SM_CYCAPTION) - 1);
            Ctl3DDlgFramePaint(Handle, WM_NCPAINT, Rgn2, 0);
            SetWindowRgn(Handle, 0, False);
            DeleteObject(Rgn2);
          end
          else
            Result := Ctl3DDlgFramePaint(Handle, Msg, wParam, lParam);
          Exit;
        end;
      WM_ACTIVATE, WM_SETFOCUS, WM_KILLFOCUS:
        begin
          if not FocusMessages then Exit;
          if (Msg = WM_SETFOCUS) and not (csDesigning in ComponentState) then
          begin
            FocusHandle := 0;
            if FormStyle = fsMDIForm then
            begin
              if ActiveMDIChild <> nil then FocusHandle := ActiveMDIChild.Handle;
            end
            else if (FActiveControl <> nil) and (FActiveControl <> Self) then
              FocusHandle := FActiveControl.Handle;
            if FocusHandle <> 0 then
            begin
              Windows.SetFocus(FocusHandle);
              Exit;
            end;
          end;
        end;
      WM_WINDOWPOSCHANGING:
        if ([csLoading, csDesigning] * ComponentState = [csLoading]) then
        begin
          if (Position in [poDefault, poDefaultPosOnly]) and
            (WindowState <> wsMaximized) then
            with PWindowPos(Message.lParam)^ do flags := flags or SWP_NOMOVE;
          if (Position in [poDefault, poDefaultSizeOnly]) and
            (BorderStyle in [bsSizeable, bsSizeToolWin]) then
            with PWindowPos(Message.lParam)^ do flags := flags or SWP_NOSIZE;
        end;
    end;
  inherited WndProc(Message);
end;

procedure TCustomForm.ClientWndProc(var Message: TMessage);

  procedure Default;
  begin
    with Message do
      Result := CallWindowProc(FDefClientProc, ClientHandle, Msg, wParam, lParam);
  end;

begin
  with Message do
    case Msg of
      WM_NCHITTEST:
        begin
          Default;
          if Result = HTCLIENT then Result := HTTRANSPARENT;
        end;
      WM_ERASEBKGND:
        begin
          FillRect(TWMEraseBkGnd(Message).DC, ClientRect, Brush.Handle);
          Result := 1;
        end;
    else
      Default;
    end;
end;

procedure TCustomForm.AlignControls(AControl: TControl; var Rect: TRect);
begin
  inherited AlignControls(AControl, Rect);
  if ClientHandle <> 0 then
    with Rect do
      { NOCOPYBITS flag prevents paint problems in mdi client for ole toolbar
        negotiations, especially word/excel toolbar docking }
      SetWindowPos(FClientHandle, HWND_BOTTOM, Left, Top, Right - Left,
        Bottom - Top, SWP_NOCOPYBITS);
end;

procedure TCustomForm.SetDesigner(ADesigner: TDesigner);
begin
  FDesigner := ADesigner;
end;

procedure TCustomForm.SetBorderIcons(Value: TBorderIcons);
begin
  if FBorderIcons <> Value then
  begin
    FBorderIcons := Value;
    if not (csDesigning in ComponentState) then RecreateWnd;
  end;
end;

procedure TCustomForm.SetBorderStyle(Value: TFormBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    AutoScroll := FBorderStyle in [bsSizeable, bsSizeToolWin];
    if not (csDesigning in ComponentState) then RecreateWnd;
  end;
end;

function TCustomForm.GetActiveMDIChild: TForm;
begin
  Result := nil;
  if (FormStyle = fsMDIForm) and (FClientHandle <> 0) then
    Result := TForm(FindControl(SendMessage(FClientHandle, WM_MDIGETACTIVE, 0,
      0)));
end;

function TCustomForm.GetMDIChildCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  if (FormStyle = fsMDIForm) and (FClientHandle <> 0) then
    for I := 0 to Screen.FormCount - 1 do
      if Screen.Forms[I].FormStyle = fsMDIChild then Inc(Result);
end;

function TCustomForm.GetMDIChildren(I: Integer): TForm;
var
  J: Integer;
begin
  if (FormStyle = fsMDIForm) and (FClientHandle <> 0) then
    for J := 0 to Screen.FormCount - 1 do
    begin
      Result := Screen.Forms[J];
      if Result.FormStyle = fsMDIChild then
      begin
        Dec(I);
        if I < 0 then Exit;
      end;
    end;
  Result := nil;
end;

function TCustomForm.GetCanvas: TCanvas;
begin
  Result := FCanvas;
end;

procedure TCustomForm.SetIcon(Value: TIcon);
begin
  FIcon.Assign(Value);
end;

function TCustomForm.IsColorStored: Boolean;
begin
  Result := (Ctl3D and (Color <> clBtnFace)) or (not Ctl3D and (Color <> clWindow));
end;

function TCustomForm.IsForm: Boolean;
begin
  Result := not IsControl;
end;

function TCustomForm.IsIconStored: Boolean;
begin
  Result := IsForm and (Icon.Handle <> 0);
end;

procedure TCustomForm.SetFormStyle(Value: TFormStyle);
var
  OldStyle: TFormStyle;
begin
  if FFormStyle <> Value then
  begin
    if (Value = fsMDIChild) and (Position = poDesigned) then
      Position := poDefault;
    if not (csDesigning in ComponentState) then DestroyHandle;
    OldStyle := FFormStyle;
    FFormStyle := Value;
    if ((Value = fsMDIForm) or (OldStyle = fsMDIForm)) and not Ctl3d then
      Color := NormalColor;
    if not (csDesigning in ComponentState) then UpdateControlState;
    if Value = fsMDIChild then Visible := True;
  end;
end;

procedure TCustomForm.RefreshMDIMenu;
var
  MenuHandle, WindowMenuHandle: HMenu;
  Redraw: Boolean;
begin
  if (FormStyle = fsMDIForm) and (ClientHandle <> 0) then
  begin
    MenuHandle := 0;
    if Menu <> nil then MenuHandle := Menu.Handle;
    WindowMenuHandle := 0;
    if WindowMenu <> nil then WindowMenuHandle := WindowMenu.Handle;
    Redraw := Windows.GetMenu(Handle) <> MenuHandle;
    SendMessage(ClientHandle, WM_MDISETMENU, MenuHandle, WindowMenuHandle);
    if Redraw then DrawMenuBar(Handle);
  end;
end;

procedure TCustomForm.SetObjectMenuItem(Value: TMenuItem);
begin
  FObjectMenuItem := Value;
  if Value <> nil then Value.Enabled := False;
end;

procedure TCustomForm.SetWindowMenu(Value: TMenuItem);
begin
  if FWindowMenu <> Value then
  begin
    FWindowMenu := Value;
    if Value <> nil then Value.FreeNotification(Self);
    RefreshMDIMenu;
  end;
end;

procedure TCustomForm.SetMenu(Value: TMainMenu);
var
  I: Integer;
begin
  if Value <> nil then
    for I := 0 to Screen.FormCount - 1 do
      if (Screen.Forms[I].Menu = Value) and (Screen.Forms[I] <> Self) then
        raise EInvalidOperation.CreateFmt(sDuplicateMenus, [Value.Name]);
  if FMenu <> nil then FMenu.WindowHandle := 0;
  FMenu := Value;
  if Value <> nil then Value.FreeNotification(Self);
  if (Value <> nil) and ((csDesigning in ComponentState) or
   (BorderStyle <> bsDialog)) then
  begin
    if not (Menu.AutoMerge or (FormStyle = fsMDIChild)) or
      (csDesigning in ComponentState) then
    begin
      if HandleAllocated then
      begin
        if Windows.GetMenu(Handle) <> Menu.Handle then
          Windows.SetMenu(Handle, Menu.Handle);
        Value.WindowHandle := Handle;
      end;
    end
    else if FormStyle <> fsMDIChild then
      if HandleAllocated then Windows.SetMenu(Handle, 0);
  end
  else if HandleAllocated then Windows.SetMenu(Handle, 0);
  if Active then MergeMenu(True);
  RefreshMDIMenu;
end;

function TCustomForm.GetPixelsPerInch: Integer;
begin
  Result := FPixelsPerInch;
  if Result = 0 then Result := Screen.PixelsPerInch;
end;

procedure TCustomForm.SetPixelsPerInch(Value: Integer);
begin
  if (Value <> GetPixelsPerInch) and ((Value = 0) or (Value >= 36))
    and (not (csLoading in ComponentState) or (FPixelsPerInch <> 0)) then
    FPixelsPerInch := Value;
end;

procedure TCustomForm.SetPosition(Value: TPosition);
begin
  if FPosition <> Value then
  begin
    FPosition := Value;
    if not (csDesigning in ComponentState) then RecreateWnd;
  end;
end;

function TCustomForm.GetScaled: Boolean;
begin
  Result := FPixelsPerInch <> 0;
end;

procedure TCustomForm.SetScaled(Value: Boolean);
begin
  if Value <> GetScaled then
  begin
    FPixelsPerInch := 0;
    if Value then FPixelsPerInch := Screen.PixelsPerInch;
  end;
end;

procedure TCustomForm.CMColorChanged(var Message: TMessage);
begin
  inherited;
  if FCanvas <> nil then FCanvas.Brush.Color := Color;
end;

function TCustomForm.NormalColor: TColor;
begin
  Result := clWindow;
  if FormStyle = fsMDIForm then Result := clAppWorkSpace;
end;

procedure TCustomForm.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
  if Ctl3D then
  begin
     if Color = NormalColor then Color := clBtnFace
  end
  else if Color = clBtnFace then Color := NormalColor;
end;

procedure TCustomForm.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FCanvas <> nil then FCanvas.Font := Font;
end;

procedure TCustomForm.CMMenuChanged(var Message: TMessage);
begin
  RefreshMDIMenu;
  SetMenu(FMenu);
end;

procedure TCustomForm.SetWindowState(Value: TWindowState);
const
  ShowCommands: array[TWindowState] of Integer =
    (SW_SHOWNORMAL, SW_MINIMIZE, SW_SHOWMAXIMIZED);
begin
  if FWindowState <> Value then
  begin
    FWindowState := Value;
    if not (csDesigning in ComponentState) and Showing then
      ShowWindow(Handle, ShowCommands[Value]);
  end;
end;

procedure TCustomForm.CreateParams(var Params: TCreateParams);
var
  Icons: TBorderIcons;
  CreateStyle: TFormBorderStyle;
begin
  inherited CreateParams(Params);
  with Params do
  begin
    if (Parent = nil) and (ParentWindow = 0) then
    begin
      WndParent := Application.Handle;
      Style := Style and not (WS_CHILD or WS_GROUP or WS_TABSTOP);
    end;
    WindowClass.style := CS_DBLCLKS;
    if csDesigning in ComponentState then
      Style := Style or (WS_CAPTION or WS_THICKFRAME or WS_MINIMIZEBOX or
        WS_MAXIMIZEBOX or WS_SYSMENU)
    else
    begin
      if FPosition in [poDefault, poDefaultPosOnly] then
      begin
        X := CW_USEDEFAULT;
        Y := CW_USEDEFAULT;
      end;
      Icons := FBorderIcons;
      CreateStyle := FBorderStyle;
      if (FormStyle = fsMDIChild) and (CreateStyle in [bsNone, bsDialog]) then
        CreateStyle := bsSizeable;
      case CreateStyle of
        bsNone:
          begin
            if (Parent = nil) and (ParentWindow = 0) then
              Style := Style or WS_POPUP;
            Icons := [];
          end;
        bsSingle, bsToolWindow:
          Style := Style or (WS_CAPTION or WS_BORDER);
        bsSizeable, bsSizeToolWin:
          begin
            Style := Style or (WS_CAPTION or WS_THICKFRAME);
            if FPosition in [poDefault, poDefaultSizeOnly] then
            begin
              Width := CW_USEDEFAULT;
              Height := CW_USEDEFAULT;
            end;
          end;
        bsDialog:
          begin
            Style := Style or WS_POPUP or WS_CAPTION;
            ExStyle := WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE;
            if not NewStyleControls then
              Style := Style or WS_DLGFRAME or DS_MODALFRAME;
            Icons := Icons * [biSystemMenu, biHelp];
            WindowClass.style := CS_DBLCLKS or CS_SAVEBITS or
              CS_BYTEALIGNWINDOW;
          end;
      end;
      if CreateStyle in [bsToolWindow, bsSizeToolWin] then
      begin
        ExStyle := WS_EX_TOOLWINDOW;
        Icons := Icons * [biSystemMenu];
      end;
      if CreateStyle in [bsSingle, bsSizeable, bsNone] then
      begin
        if (FormStyle <> fsMDIChild) or (biSystemMenu in Icons) then
        begin
          if biMinimize in Icons then Style := Style or WS_MINIMIZEBOX;
          if biMaximize in Icons then Style := Style or WS_MAXIMIZEBOX;
        end;
        if FWindowState = wsMinimized then Style := Style or WS_MINIMIZE else
          if FWindowState = wsMaximized then Style := Style or WS_MAXIMIZE;
      end else FWindowState := wsNormal;
      if biSystemMenu in Icons then Style := Style or WS_SYSMENU;
      if (biHelp in Icons) then ExStyle := ExStyle or WS_EX_CONTEXTHELP;
      if FormStyle = fsMDIChild then WindowClass.lpfnWndProc := @DefMDIChildProc;
    end;
  end;
end;

procedure TCustomForm.CreateWnd;
var
  ClientCreateStruct: TClientCreateStruct;
begin
  inherited CreateWnd;
  if NewStyleControls then
    if BorderStyle <> bsDialog then
      SendMessage(Handle, WM_SETICON, 1, GetIconHandle) else
      SendMessage(Handle, WM_SETICON, 1, 0);
  if not (csDesigning in ComponentState) then
    case FormStyle of
      fsMDIForm:
        begin
          with ClientCreateStruct do
          begin
            idFirstChild := $FF00;
            hWindowMenu := 0;
            if FWindowMenu <> nil then hWindowMenu := FWindowMenu.Handle;
          end;
          FClientHandle := Windows.CreateWindowEx(WS_EX_CLIENTEDGE, 'MDICLIENT', nil,
            WS_CHILD or WS_VISIBLE or WS_GROUP or WS_TABSTOP or
            WS_CLIPCHILDREN or WS_HSCROLL or WS_VSCROLL or
            WS_CLIPSIBLINGS or MDIS_ALLCHILDSTYLES,
            0, 0, ClientWidth, ClientHeight, Handle, 0, HInstance,
            @ClientCreateStruct);
          FClientInstance := MakeObjectInstance(ClientWndProc);
          FDefClientProc := Pointer(GetWindowLong(FClientHandle, GWL_WNDPROC));
          SetWindowLong(FClientHandle, GWL_WNDPROC, Longint(FClientInstance));
        end;
      fsStayOnTop:
        SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or
          SWP_NOSIZE or SWP_NOACTIVATE);
    end;
end;

procedure TCustomForm.CreateWindowHandle(const Params: TCreateParams);
var
  CreateStruct: TMDICreateStruct;
begin
  if (FormStyle = fsMDIChild) and not (csDesigning in ComponentState) then
  begin
    if (Application.MainForm = nil) or
      (Application.MainForm.ClientHandle = 0) then
      raise EInvalidOperation.Create(SNoMDIForm);
    with CreateStruct do
    begin
      szClass := Params.WinClassName;
      szTitle := Params.Caption;
      hOwner := HInstance;
      X := Params.X;
      Y := Params.Y;
      cX := Params.Width;
      cY := Params.Height;
      style := Params.Style;
      lParam := Longint(Params.Param);
    end;
    WindowHandle := SendMessage(Application.MainForm.ClientHandle,
      WM_MDICREATE, 0, Longint(@CreateStruct));
    Include(FFormState, fsCreatedMDIChild);
  end else
  begin
    inherited CreateWindowHandle(Params);
    Exclude(FFormState, fsCreatedMDIChild);
  end;
end;

procedure TCustomForm.DestroyWindowHandle;
begin
  if fsCreatedMDIChild in FFormState then
    SendMessage(Application.MainForm.ClientHandle, WM_MDIDESTROY, Handle, 0)
  else
    inherited DestroyWindowHandle;
  FClientHandle := 0;
end;

procedure TCustomForm.DefaultHandler(var Message);
begin
  if ClientHandle <> 0 then
    with TMessage(Message) do
      if Msg = WM_SIZE then
        Result := DefWindowProc(Handle, Msg, wParam, lParam) else
        Result := DefFrameProc(Handle, ClientHandle, Msg, wParam, lParam)
  else
    inherited DefaultHandler(Message)
end;

procedure TCustomForm.SetActiveControl(Control: TWinControl);
begin
  if FActiveControl <> Control then
  begin
    if not ((Control = nil) or (Control <> Self) and
      (GetParentForm(Control) = Self) and ((csLoading in ComponentState) or
        Control.CanFocus)) then
      raise EInvalidOperation.Create(SCannotFocus);
    FActiveControl := Control;
    if not (csLoading in ComponentState) then
    begin
      if FActive then SetWindowFocus;
      ActiveChanged;
    end;
  end;
end;

procedure TCustomForm.DefocusControl(Control: TWinControl; Removing: Boolean);
begin
  if Removing and Control.ContainsControl(FFocusedControl) then
    FFocusedControl := Control.Parent;
  if Control.ContainsControl(FActiveControl) then SetActiveControl(nil);
end;

procedure TCustomForm.FocusControl(Control: TWinControl);
var
  WasActive: Boolean;
begin
  WasActive := FActive;
  SetActiveControl(Control);
  if not WasActive then SetFocus;
end;

function TCustomForm.SetFocusedControl(Control: TWinControl): Boolean;
var
  FocusHandle: HWnd;
  TempControl: TWinControl;
begin
  Result := False;
  Inc(FocusCount);
  if FDesigner = nil then
    if Control <> Self then
      FActiveControl := Control else
      FActiveControl := nil;
  Screen.FActiveControl := Control;
  Screen.FActiveCustomForm := Self;
  Screen.FCustomForms.Remove(Self);
  Screen.FCustomForms.Insert(0, Self);
  if Self is TForm then
  begin
    Screen.FActiveForm := TForm(Self);
    Screen.FForms.Remove(Self);
    Screen.FForms.Insert(0, Self);
  end
  else Screen.FActiveForm := nil;
  if not (csFocusing in Control.ControlState) then
  begin
    Control.ControlState := Control.ControlState + [csFocusing];
    try
      if Screen.FFocusedForm <> Self then
      begin
        if Screen.FFocusedForm <> nil then
        begin
          FocusHandle := Screen.FFocusedForm.Handle;
          Screen.FFocusedForm := nil;
          if not SendFocusMessage(FocusHandle, CM_DEACTIVATE) then Exit;
        end;
        Screen.FFocusedForm := Self;
        if not SendFocusMessage(Handle, CM_ACTIVATE) then Exit;
      end;
      if FFocusedControl = nil then FFocusedControl := Self;
      if FFocusedControl <> Control then
      begin
        while not FFocusedControl.ContainsControl(Control) do
        begin
          FocusHandle := FFocusedControl.Handle;
          FFocusedControl := FFocusedControl.Parent;
          if not SendFocusMessage(FocusHandle, CM_EXIT) then Exit;
        end;
        while FFocusedControl <> Control do
        begin
          TempControl := Control;
          while TempControl.Parent <> FFocusedControl do
            TempControl := TempControl.Parent;
          FFocusedControl := TempControl;
          if not SendFocusMessage(TempControl.Handle, CM_ENTER) then Exit;
        end;
        TempControl := Control.Parent;
        while TempControl <> nil do
        begin
          if TempControl is TScrollingWinControl then
            TScrollingWinControl(TempControl).AutoScrollInView(Control);
          TempControl := TempControl.Parent;
        end;
        Perform(CM_FOCUSCHANGED, 0, Longint(Control));
        if (FActiveOleControl <> nil) and (FActiveOleControl <> Control) then
          FActiveOleControl.Perform(CM_UIDEACTIVATE, 0, 0);
      end;
    finally
      Control.ControlState := Control.ControlState - [csFocusing];
    end;
    Screen.UpdateLastActive;
    Result := True;
  end;
end;

procedure TCustomForm.ActiveChanged;
begin
end;

procedure TCustomForm.SetWindowFocus;
var
  FocusControl: TWinControl;
begin
  if (FActiveControl <> nil) and (FDesigner = nil)
    then FocusControl := FActiveControl
    else FocusControl := Self;
  Windows.SetFocus(FocusControl.Handle);
  //.rag ()
//  if GetFocus = FocusControl.Handle then   // Quite el If
  FocusControl.Perform(CM_UIACTIVATE, 0, 0);
end;

procedure TCustomForm.SetActive(Value: Boolean);
begin
  FActive := Value;
  if FActiveOleControl <> nil then
    FActiveOleControl.Perform(CM_DOCWINDOWACTIVATE, Ord(Value), 0);
  if Value then
  begin
    if (ActiveControl = nil) and not (csDesigning in ComponentState) then
      ActiveControl := FindNextControl(nil, True, True, False);
    MergeMenu(True);
    SetWindowFocus;
  end;
end;

procedure TCustomForm.SendCancelMode(Sender: TControl);
begin
  if Active and (ActiveControl <> nil) then
    ActiveControl.Perform(CM_CANCELMODE, 0, Longint(Sender));
  if (FormStyle = fsMDIForm) and (ActiveMDIChild <> nil) then
    ActiveMDIChild.SendCancelMode(Sender);
end;

procedure TCustomForm.MergeMenu(MergeState: Boolean);
var
  AMergeMenu: TMainMenu;
  Size: Longint;
begin
  if not (fsModal in FFormState) and
    (Application.MainForm <> nil) and
    (Application.MainForm.Menu <> nil) and
    (Application.MainForm <> Self) and
    ((FormStyle = fsMDIChild) or (Application.MainForm.FormStyle <> fsMDIForm)) then
  begin
    AMergeMenu := nil;
    if not (csDesigning in ComponentState) and (Menu <> nil) and
      (Menu.AutoMerge or (FormStyle = fsMDIChild)) then AMergeMenu := Menu;
    with Application.MainForm.Menu do
      if MergeState then Merge(AMergeMenu) else Unmerge(AMergeMenu);
    if MergeState and (FormStyle = fsMDIChild) and (WindowState = wsMaximized) then
    begin
      { Force MDI to put back the system menu of a maximized child }
      Size := ClientWidth + (Longint(ClientHeight) shl 16);
      SendMessage(Handle, WM_SIZE, SIZE_RESTORED, Size);
      SendMessage(Handle, WM_SIZE, SIZE_MAXIMIZED, Size);
    end;
  end;
end;

procedure TCustomForm.Activate;
begin
  if Assigned(FOnActivate) then FOnActivate(Self);
end;

procedure TCustomForm.Deactivate;
begin
  if Assigned(FOnDeactivate) then FOnDeactivate(Self);
end;

procedure TCustomForm.Paint;
begin
  if Assigned(FOnPaint) then FOnPaint(Self);
end;

procedure TCustomForm.Resize;
begin
  if Assigned(FOnResize) then FOnResize(Self);
end;

function TCustomForm.GetIconHandle: HICON;
begin
  Result := FIcon.Handle;
  if Result = 0 then Result := Application.GetIconHandle;
end;

procedure TCustomForm.PaintWindow(DC: HDC);
begin
  FCanvas.Lock;
  try
    FCanvas.Handle := DC;
    try
      if FDesigner <> nil then FDesigner.PaintGrid else Paint;
    finally
      FCanvas.Handle := 0;
    end;
  finally
    FCanvas.Unlock;
  end;
end;

function TCustomForm.PaletteChanged(Foreground: Boolean): Boolean;
var
  I: Integer;
  Active, Child: TForm;
begin
  Result := False;
  Active := ActiveMDIChild;
  if Assigned(Active) then
    Result := Active.PaletteChanged(Foreground);
  for I := 0 to MDIChildCount-1 do
  begin
    if Foreground and Result then Exit;
    Child := MDIChildren[I];
    if Active = Child then Continue;
    Result := Child.PaletteChanged(Foreground) or Result;
  end;
  if Foreground and Result then Exit;
  Result := inherited PaletteChanged(Foreground);
end;

procedure TCustomForm.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  PS: TPaintStruct;
begin
  if not IsIconic(Handle) then PaintHandler(Message) else
  begin
    DC := BeginPaint(Handle, PS);
    DrawIcon(DC, 0, 0, GetIconHandle);
    EndPaint(Handle, PS);
  end;
end;

procedure TCustomForm.WMIconEraseBkgnd(var Message: TWMIconEraseBkgnd);
begin
  if FormStyle = fsMDIChild then
  if (FormStyle = fsMDIChild) and not (csDesigning in ComponentState) then
    FillRect(Message.DC, ClientRect, Application.MainForm.Brush.Handle)
  else inherited;
end;

procedure TCustomForm.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  if not IsIconic(Handle) then inherited else
  begin
    Message.Msg := WM_ICONERASEBKGND;
    DefaultHandler(Message);
  end;
end;

procedure TCustomForm.WMQueryDragIcon(var Message: TWMQueryDragIcon);
begin
  Message.Result := GetIconHandle;
end;

procedure TCustomForm.WMNCCreate(var Message: TWMNCCreate);

  procedure ModifySystemMenu;
  var
    SysMenu: HMENU;
  begin
    if (FBorderStyle <> bsNone) and (biSystemMenu in FBorderIcons) and
      (FormStyle <> fsMDIChild) then
    begin
      { Modify the system menu to look more like it's s'pose to }
      SysMenu := GetSystemMenu(Handle, False);
      if FBorderStyle = bsDialog then
      begin
        { Make the system menu look like a dialog which has only
          Move and Close }
        DeleteMenu(SysMenu, SC_TASKLIST, MF_BYCOMMAND);
        DeleteMenu(SysMenu, 7, MF_BYPOSITION);
        DeleteMenu(SysMenu, 5, MF_BYPOSITION);
        DeleteMenu(SysMenu, SC_MAXIMIZE, MF_BYCOMMAND);
        DeleteMenu(SysMenu, SC_MINIMIZE, MF_BYCOMMAND);
        DeleteMenu(SysMenu, SC_SIZE, MF_BYCOMMAND);
        DeleteMenu(SysMenu, SC_RESTORE, MF_BYCOMMAND);
      end else
      begin
        { Else just disable the Minimize and Maximize items if the
          corresponding FBorderIcon is not present }
        if not (biMinimize in FBorderIcons) then
          EnableMenuItem(SysMenu, SC_MINIMIZE, MF_BYCOMMAND or MF_GRAYED);
        if not (biMaximize in FBorderIcons) then
          EnableMenuItem(SysMenu, SC_MAXIMIZE, MF_BYCOMMAND or MF_GRAYED);
      end;
    end;
  end;

begin
  inherited;
  SetMenu(FMenu);
  if not (csDesigning in ComponentState) then ModifySystemMenu;
end;

procedure TCustomForm.WMDestroy(var Message: TWMDestroy);
begin
  if NewStyleControls then SendMessage(Handle, WM_SETICON, 1, 0);
  if (FMenu <> nil) and (FormStyle <> fsMDIChild) then
  begin
    Windows.SetMenu(Handle, 0);
    FMenu.WindowHandle := 0;
  end;
  inherited;
end;

procedure TCustomForm.WMCommand(var Message: TWMCommand);
begin
  with Message do
    if (Ctl <> 0) or (Menu = nil) or not Menu.DispatchCommand(ItemID) then
      inherited;
end;

procedure TCustomForm.WMInitMenuPopup(var Message: TWMInitMenuPopup);
begin
  if FMenu <> nil then FMenu.DispatchPopup(Message.MenuPopup);
end;

procedure TCustomForm.WMMenuSelect(var Message: TWMMenuSelect);
var
  MenuItem: TMenuItem;
  ID: Integer;
  FindKind: TFindItemKind;
begin
  if FMenu <> nil then
    with Message do
    begin
      MenuItem := nil;
      if (MenuFlag <> $FFFF) or (IDItem <> 0) then
      begin
        FindKind := fkCommand;
        ID := IDItem;
        if MenuFlag and MF_POPUP <> 0 then
        begin
          FindKind := fkHandle;
          ID := GetSubMenu(Menu, ID);
        end;
        MenuItem := FMenu.FindItem(ID, FindKind);
      end;
      if MenuItem <> nil then
        Application.Hint := GetLongHint(MenuItem.Hint) else
        Application.Hint := '';
    end;
end;

procedure TCustomForm.WMActivate(var Message: TWMActivate);
begin
  if (FormStyle <> fsMDIForm) or (csDesigning in ComponentState) then
    SetActive(Message.Active <> WA_INACTIVE);
end;

procedure TCustomForm.WMSize(var Message: TWMSize);
begin
  inherited;
  if not (csDesigning in ComponentState) then
    case Message.SizeType of
      SIZENORMAL: FWindowState := wsNormal;
      SIZEICONIC: FWindowState := wsMinimized;
      SIZEFULLSCREEN: FWindowState := wsMaximized;
    end;
  if FOleForm <> nil then FOleForm.OnResize;
  if not (csLoading in ComponentState) then Resize;
  CalcAutoRange;
end;

procedure TCustomForm.WMClose(var Message: TWMClose);
begin
  Close;
end;

procedure TCustomForm.WMQueryEndSession(var Message: TWMQueryEndSession);
begin
  Message.Result := Integer(CloseQuery and CallTerminateProcs);
end;

procedure TCustomForm.CMAppSysCommand(var Message: TMessage);
type
  PWMSysCommand = ^TWMSysCommand;
begin
  Message.Result := 0;
  if (csDesigning in ComponentState) or (FormStyle = fsMDIChild) or
   (Menu = nil) or Menu.AutoMerge then
    with PWMSysCommand(Message.lParam)^ do
    begin
      SendCancelMode(nil);
      if SendAppMessage(CM_APPSYSCOMMAND, CmdType, Key) <> 0 then
        Message.Result := 1;;
    end;
end;

procedure TCustomForm.WMSysCommand(var Message: TWMSysCommand);
begin
  if (Message.CmdType and $FFF0 = SC_MINIMIZE) and
    (Application.MainForm = Self) then
    Application.Minimize
  else
    inherited;
end;

procedure TCustomForm.WMShowWindow(var Message: TWMShowWindow);
const
  ShowCommands: array[saRestore..saMaximize] of Integer =
    (SW_SHOWNOACTIVATE, SW_SHOWMINNOACTIVE, SW_SHOWMAXIMIZED);
begin
  with Message do
    case Status of
      SW_PARENTCLOSING:
        begin
          if IsIconic(Handle) then FShowAction := saMinimize else
            if IsZoomed(Handle) then FShowAction := saMaximize else
              FShowAction := saRestore;
          inherited;
        end;
      SW_PARENTOPENING:
        if FShowAction <> saIgnore then
        begin
          ShowWindow(Handle, ShowCommands[FShowAction]);
          FShowAction := saIgnore;
        end;
    else
      inherited;
    end;
end;

procedure TCustomForm.WMMDIActivate(var Message: TWMMDIActivate);
var
  IsActive: Boolean;
begin
  inherited;
  if FormStyle = fsMDIChild then
  begin
    IsActive := Message.ActiveWnd = Handle;
    SetActive(IsActive);
    if IsActive and (csPalette in Application.MainForm.ControlState) then
      Application.MainForm.PaletteChanged(True);
  end;
end;

procedure TCustomForm.WMNextDlgCtl(var Message: TWMNextDlgCtl);
begin
  with Message do
    if Handle then
      Windows.SetFocus(Message.CtlFocus) else
      SelectNext(FActiveControl, not BOOL(CtlFocus), True);
end;

procedure TCustomForm.WMEnterMenuLoop(var Message: TMessage);
begin
  SendCancelMode(nil);
  inherited;
end;

procedure TCustomForm.WMHelp(var Message: TWMHelp);

  function GetMenuHelpContext(Menu: TMenu): Integer;
  begin
    Result := 0;
    if Menu = nil then Exit;
    Result := Menu.GetHelpContext(Message.HelpInfo.iCtrlID, True);
    if Result = 0 then
      Result := Menu.GetHelpContext(Message.HelpInfo.hItemHandle, False);
  end;

var
  Control: TWinControl;
  ContextID: Integer;
  Pt: TSmallPoint;
begin
  with Message.HelpInfo^ do
  begin
    if iContextType = HELPINFO_WINDOW then
    begin
      Control := FindControl(hItemHandle);
      while (Control <> nil) and (Control.HelpContext = 0) do
        Control := Control.Parent;
      if Control = nil then Exit;
      ContextID := Control.HelpContext;
      Pt := PointToSmallPoint(Control.ClientToScreen(Point(0, 0)));
    end
    else  { Message.HelpInfo.iContextType = HELPINFO_MENUITEM }
    begin
      ContextID := GetMenuHelpContext(FMenu);
      if ContextID = 0 then
        ContextID := GetMenuHelpContext(PopupMenu);
      Pt := PointToSmallPoint(ClientToScreen(Point(0,0)));
    end;
  end;
  if (biHelp in BorderIcons) then
  begin
    Application.HelpCommand(HELP_SETPOPUP_POS, Longint(Pt));
    Application.HelpCommand(HELP_CONTEXTPOPUP, ContextID);
  end
  else
    Application.HelpContext(ContextID);
end;

procedure TCustomForm.CMActivate(var Message: TCMActivate);
begin
  Activate;
end;

procedure TCustomForm.CMDeactivate(var Message: TCMDeactivate);
begin
  Deactivate;
end;

procedure TCustomForm.CMDialogKey(var Message: TCMDialogKey);
begin
  if GetKeyState(VK_MENU) >= 0 then
    with Message do
      case CharCode of
        VK_TAB:
          if GetKeyState(VK_CONTROL) >= 0 then
          begin
            SelectNext(FActiveControl, GetKeyState(VK_SHIFT) >= 0, True);
            Result := 1;
            Exit;
          end;
        VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN:
          begin
            if FActiveControl <> nil then
            begin
              TForm(FActiveControl.Parent).SelectNext(FActiveControl,
                (CharCode = VK_RIGHT) or (CharCode = VK_DOWN), False);
              Result := 1;
            end;
            Exit;
          end;
      end;
  inherited;
end;

procedure TCustomForm.CMShowingChanged(var Message: TMessage);
const
  ShowCommands: array[TWindowState] of Integer =
    (SW_SHOWNORMAL, SW_SHOWMINNOACTIVE, SW_SHOWMAXIMIZED);
var
  X, Y: Integer;
  NewActiveWindow: HWnd;
begin
  if not (csDesigning in ComponentState) and (fsShowing in FFormState) then
    raise EInvalidOperation.Create(SVisibleChanged);
  Application.UpdateVisible;
  Include(FFormState, fsShowing);
  try
    if not (csDesigning in ComponentState) then
      if Showing then
      begin
        try
          DoShow;
        except
          Application.HandleException(Self);
        end;
        if FPosition = poScreenCenter then
        begin
          if FormStyle = fsMDIChild then
          begin
            X := (Application.MainForm.ClientWidth - Width) div 2;
            Y := (Application.MainForm.ClientHeight - Height) div 2;
          end else
          begin
            X := (Screen.Width - Width) div 2;
            Y := (Screen.Height - Height) div 2;
          end;
          if X < 0 then X := 0;
          if Y < 0 then Y := 0;
          SetBounds(X, Y, Width, Height);
        end;
        FPosition := poDesigned;
        if FormStyle = fsMDIChild then
        begin
          { Fake a size message to get MDI to behave }
          if FWindowState = wsMaximized then
          begin
            SendMessage(Application.MainForm.ClientHandle, WM_MDIRESTORE, Handle, 0);
            ShowWindow(Handle, SW_SHOWMAXIMIZED);
          end
          else
          begin
            ShowWindow(Handle, ShowCommands[FWindowState]);
            CallWindowProc(@DefMDIChildProc, Handle, WM_SIZE, SIZE_RESTORED,
              Width or (Height shl 16));
            BringToFront;
          end;
          SendMessage(Application.MainForm.ClientHandle,
            WM_MDIREFRESHMENU, 0, 0);
        end
        else
          ShowWindow(Handle, ShowCommands[FWindowState]);
      end else
      begin
        try
          DoHide;
        except
          Application.HandleException(Self);
        end;
        if Screen.ActiveForm = Self then
          MergeMenu(False);
        if FormStyle = fsMDIChild then
          DestroyHandle
        else if fsModal in FFormState then
          SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_HIDEWINDOW or
            SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE)
        else
        begin
          NewActiveWindow := 0;
          if (GetActiveWindow = Handle) and not IsIconic(Handle) then
            NewActiveWindow := FindTopMostWindow(Handle);
          if NewActiveWindow <> 0 then
          begin
            SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_HIDEWINDOW or
              SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE);
            SetActiveWindow(NewActiveWindow);
          end else
            ShowWindow(Handle, SW_HIDE);
        end;
      end;
  finally
    Exclude(FFormState, fsShowing);
  end;
end;

procedure TCustomForm.CMIconChanged(var Message: TMessage);
begin
  if FIcon.Handle = 0 then IconChanged(nil);
end;

procedure TCustomForm.CMRelease;
begin
  Free;
end;

procedure TCustomForm.CMTextChanged(var Message: TMessage);
begin
  inherited;
  if (FormStyle = fsMDIChild) and (Application.MainForm <> nil) and
    (Application.MainForm.ClientHandle <> 0) then
    SendMessage(Application.MainForm.ClientHandle, WM_MDIREFRESHMENU, 0, 0);
end;

procedure TCustomForm.CMUIActivate(var Message);
begin
  inherited;
end;

procedure TCustomForm.CMParentFontChanged(var Message: TMessage);
var
  F: TFont;
begin
  if ParentFont then
    if Message.wParam <> 0 then
      Font.Assign(TFont(Message.lParam))
    else
    begin
      F := TFont.Create;  // get locale defaults
      try
        Font.Assign(F);
      finally
        F.Free
      end;
    end;
end;

procedure TCustomForm.Close;
var
  CloseAction: TCloseAction;
begin
  if fsModal in FFormState then
    ModalResult := mrCancel
  else
    if CloseQuery then
    begin
      if FormStyle = fsMDIChild then
        if biMinimize in BorderIcons then
          CloseAction := caMinimize else
          CloseAction := caNone
      else
        CloseAction := caHide;
      if Assigned(FOnClose) then FOnClose(Self, CloseAction);
      if CloseAction <> caNone then
        if Application.MainForm = Self then Application.Terminate
        else if CloseAction = caHide then Hide
        else if CloseAction = caMinimize then WindowState := wsMinimized
        else Release;
    end;
end;

function TCustomForm.CloseQuery: Boolean;
var
  I: Integer;
begin
  if FormStyle = fsMDIForm then
  begin
    Result := False;
    for I := 0 to MDIChildCount - 1 do
      if not MDIChildren[I].CloseQuery then Exit;
  end;
  Result := True;
  if Assigned(FOnCloseQuery) then FOnCloseQuery(Self, Result);
end;

procedure TCustomForm.CloseModal;
var
  CloseAction: TCloseAction;
begin
  try
    CloseAction := caNone;
    if CloseQuery then
    begin
      CloseAction := caHide;
      if Assigned(FOnClose) then FOnClose(Self, CloseAction);
    end;
    case CloseAction of
      caNone: ModalResult := 0;
      caFree: Release;
    end;
  except
    ModalResult := 0;
    Application.HandleException(Self);
  end;
end;

function TCustomForm.GetFormImage: TBitmap;
begin
  Result := TBitmap.Create;
  try
    Result.Width := ClientWidth;
    Result.Height := ClientHeight;
    Result.Canvas.Brush := Brush;
    Result.Canvas.FillRect(ClientRect);
    Result.Canvas.Lock;
    try
      PaintTo(Result.Canvas.Handle, 0, 0);
    finally
      Result.Canvas.Unlock;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TCustomForm.Print;
var
  FormImage: TBitmap;
  Info: PBitmapInfo;
  InfoSize: Integer;
  Image: Pointer;
  ImageSize: DWORD;
  Bits: HBITMAP;
  DIBWidth, DIBHeight: Longint;
  PrintWidth, PrintHeight: Longint;
begin
  Printer.BeginDoc;
  try
    FormImage := GetFormImage;
    Canvas.Lock;
    try
      { Paint bitmap to the printer }
      with Printer, Canvas do
      begin
        Bits := FormImage.Handle;
        GetDIBSizes(Bits, InfoSize, ImageSize);
        Info := AllocMem(InfoSize);
        try
          Image := AllocMem(ImageSize);
          try
            GetDIB(Bits, 0, Info^, Image^);
            with Info^.bmiHeader do
            begin
              DIBWidth := biWidth;
              DIBHeight := biHeight;
            end;
            case PrintScale of
              poProportional:
                begin
                  PrintWidth := MulDiv(DIBWidth, GetDeviceCaps(Handle,
                    LOGPIXELSX), PixelsPerInch);
                  PrintHeight := MulDiv(DIBHeight, GetDeviceCaps(Handle,
                    LOGPIXELSY), PixelsPerInch);
                end;
              poPrintToFit:
                begin
                  PrintWidth := MulDiv(DIBWidth, PageHeight, DIBHeight);
                  if PrintWidth < PageWidth then
                    PrintHeight := PageHeight
                  else
                  begin
                    PrintWidth := PageWidth;
                    PrintHeight := MulDiv(DIBHeight, PageWidth, DIBWidth);
                  end;
                end;
            else
              PrintWidth := DIBWidth;
              PrintHeight := DIBHeight;
            end;
            StretchDIBits(Canvas.Handle, 0, 0, PrintWidth, PrintHeight, 0, 0,
              DIBWidth, DIBHeight, Image, Info^, DIB_RGB_COLORS, SRCCOPY);
          finally
            FreeMem(Image, ImageSize);
          end;
        finally
          FreeMem(Info, InfoSize);
        end;
      end;
    finally
      Canvas.Unlock;
      FormImage.Free;
    end;
  finally
    Printer.EndDoc;
  end;
end;

procedure TCustomForm.Hide;
begin
  Visible := False;
end;

procedure TCustomForm.Show;
begin
  Visible := True;
  BringToFront;
end;

procedure TCustomForm.SetFocus;
begin
  if not FActive then
  begin
    if not (Visible and Enabled) then
      raise EInvalidOperation.Create(SCannotFocus);
    SetWindowFocus;
  end;
end;

procedure TCustomForm.Release;
begin
  PostMessage(Handle, CM_RELEASE, 0, 0);
end;

function TCustomForm.ShowModal: Integer;
var
  WindowList: Pointer;
  SaveFocusCount: Integer;
  SaveCursor: TCursor;
  SaveCount: Integer;
  ActiveWindow: HWnd;
begin
  CancelDrag;
  if Visible or not Enabled or (fsModal in FFormState) or
    (FormStyle = fsMDIChild) then
    raise EInvalidOperation.Create(SCannotShowModal);
  if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
  ReleaseCapture;
  Include(FFormState, fsModal);
  ActiveWindow := GetActiveWindow;
  SaveFocusCount := FocusCount;
  Screen.FSaveFocusedList.Insert(0, Screen.FFocusedForm);
  Screen.FFocusedForm := Self;
  SaveCursor := Screen.Cursor;
  Screen.Cursor := crDefault;
  SaveCount := Screen.FCursorCount;
  WindowList := DisableTaskWindows(0);
  try
    Show;
    try
      SendMessage(Handle, CM_ACTIVATE, 0, 0);
      ModalResult := 0;
      repeat
        Application.HandleMessage;
        if Application.FTerminate then ModalResult := mrCancel else
          if ModalResult <> 0 then CloseModal;
      until ModalResult <> 0;
      Result := ModalResult;
      SendMessage(Handle, CM_DEACTIVATE, 0, 0);
      if GetActiveWindow <> Handle then ActiveWindow := 0;
    finally
      Hide;
    end;
  finally
    if Screen.FCursorCount = SaveCount then
      Screen.Cursor := SaveCursor
    else Screen.Cursor := crDefault;  
    EnableTaskWindows(WindowList);
    if Screen.FSaveFocusedList.Count > 0 then
    begin
      Screen.FFocusedForm := Screen.FSaveFocusedList.First;
      Screen.FSaveFocusedList.Remove(Screen.FFocusedForm);
    end else Screen.FFocusedForm := nil;
    if ActiveWindow <> 0 then SetActiveWindow(ActiveWindow);
    FocusCount := SaveFocusCount;
    Exclude(FFormState, fsModal);
  end;
end;

{ TForm }

procedure TForm.Tile;
const
  TileParams: array[TTileMode] of Word = (MDITILE_HORIZONTAL, MDITILE_VERTICAL);
begin
  if (FFormStyle = fsMDIForm) and (ClientHandle <> 0) then
    SendMessage(ClientHandle, WM_MDITILE, TileParams[FTileMode], 0);
end;

procedure TForm.Cascade;
begin
  if (FFormStyle = fsMDIForm) and (ClientHandle <> 0) then
    SendMessage(ClientHandle, WM_MDICASCADE, 0, 0);
end;

procedure TForm.ArrangeIcons;
begin
  if (FFormStyle = fsMDIForm) and (ClientHandle <> 0) then
    SendMessage(ClientHandle, WM_MDIICONARRANGE, 0, 0);
end;

procedure TForm.Next;
begin
  if (FFormStyle = fsMDIForm) and (ClientHandle <> 0) then
    SendMessage(ClientHandle, WM_MDINEXT, 0, 0);
end;

procedure TForm.Previous;
begin
  if (FormStyle = fsMDIForm) and (ClientHandle <> 0) then
    SendMessage(FClientHandle, WM_MDINEXT, 0, 1);
end;

{ TDataModule }

constructor TDataModule.Create(AOwner: TComponent);
begin
  CreateNew(AOwner);
  if (ClassType <> TDataModule) and not (csDesigning in ComponentState) then
  begin
    if not InitInheritedComponent(Self, TDataModule) then
      raise EResNotFound.CreateFmt(SResNotFound, [ClassName]);
    try
      if Assigned(FOnCreate) then FOnCreate(Self);
    except
      Application.HandleException(Self);
    end;
  end;
end;

constructor TDataModule.CreateNew(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Screen.AddDataModule(Self);
end;

destructor TDataModule.Destroy;
begin
  Destroying;
  RemoveFixupReferences(Self, '');
  if Assigned(FOnDestroy) then
    try
      FOnDestroy(Self);
    except
      Application.HandleException(Self);
    end;
  Screen.RemoveDataModule(Self);
  inherited Destroy;
end;

procedure TDataModule.DefineProperties(Filer: TFiler);
var
  Ancestor: TDataModule;

  function DoWriteWidth: Boolean;
  begin
    Result := True;
    if Ancestor <> nil then Result := FDesignSize.X <> Ancestor.FDesignSize.X;
  end;

  function DoWriteHorizontalOffset: Boolean;
  begin
    if Ancestor <> nil then
      Result := FDesignOffset.X <> Ancestor.FDesignOffset.X else
      Result := FDesignOffset.X <> 0;
  end;

  function DoWriteVerticalOffset: Boolean;
  begin
    if Ancestor <> nil then
      Result := FDesignOffset.Y <> Ancestor.FDesignOffset.Y else
      Result := FDesignOffset.Y <> 0;
  end;

  function DoWriteHeight: Boolean;
  begin
    Result := True;
    if Ancestor <> nil then Result := FDesignSize.Y <> Ancestor.FDesignSize.Y;
  end;

begin
  inherited DefineProperties(Filer);
  Ancestor := TDataModule(Filer.Ancestor);
  Filer.DefineProperty('Height', ReadHeight, WriteHeight, DoWriteHeight);
  Filer.DefineProperty('HorizontalOffset', ReadHorizontalOffset,
    WriteHorizontalOffset, DoWriteHorizontalOffset);
  Filer.DefineProperty('VerticalOffset', ReadVerticalOffset,
    WriteVerticalOffset, DoWriteVerticalOffset);
  Filer.DefineProperty('Width', ReadWidth, WriteWidth, DoWriteWidth);
end;

procedure TDataModule.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
  OwnedComponent: TComponent;
begin
  inherited GetChildren(Proc, Root);
  if Root = Self then
    for I := 0 to ComponentCount - 1 do
    begin
      OwnedComponent := Components[I];
      if not OwnedComponent.HasParent then Proc(OwnedComponent);
    end;
end;

function TDataModule.GetProviderNames: OleVariant;
begin
  if Assigned(GetDataModuleProviderNames) then
    Result := GetDataModuleProviderNames(Self) else
    Result := Null;
end;

class procedure TDataModule.UpdateRegistry(Register: Boolean; const ClassID, ProgID: string);
begin
  if Assigned(UpdateDataModuleRegistry) then
    UpdateDataModuleRegistry(Register, ClassID, ProgID);
end;

procedure TDataModule.ReadWidth(Reader: TReader);
begin
  FDesignSize.X := Reader.ReadInteger;
end;

procedure TDataModule.ReadHorizontalOffset(Reader: TReader);
begin
  FDesignOffset.X := Reader.ReadInteger;
end;

procedure TDataModule.ReadVerticalOffset(Reader: TReader);
begin
  FDesignOffset.Y := Reader.ReadInteger;
end;

procedure TDataModule.ReadHeight(Reader: TReader);
begin
  FDesignSize.Y := Reader.ReadInteger;
end;

procedure TDataModule.WriteWidth(Writer: TWriter);
begin
  Writer.WriteInteger(FDesignSize.X);
end;

procedure TDataModule.WriteHorizontalOffset(Writer: TWriter);
begin
  Writer.WriteInteger(FDesignOffset.X);
end;

procedure TDataModule.WriteVerticalOffset(Writer: TWriter);
begin
  Writer.WriteInteger(FDesignOffset.Y);
end;

procedure TDataModule.WriteHeight(Writer: TWriter);
begin
  Writer.WriteInteger(FDesignSize.Y);
end;

{ TScreen }

const
  IDC_NODROP =    PChar(32767);
  IDC_DRAG   =    PChar(32766);
  IDC_HSPLIT =    PChar(32765);
  IDC_VSPLIT =    PChar(32764);
  IDC_MULTIDRAG = PChar(32763);
  IDC_SQLWAIT =   PChar(32762);
  IDC_HANDPT =   PChar(32761);

function EnumFontsProc(var LogFont: TLogFont; var TextMetric: TTextMetric;
  FontType: Integer; Data: Pointer): Integer; stdcall;
var
  S: TStrings;
  Temp: string;
begin
  S := TStrings(Data);
  Temp := LogFont.lfFaceName;
  if (S.Count = 0) or (AnsiCompareText(S[S.Count-1], Temp) <> 0) then
    S.Add(Temp);
  Result := 1;
end;

constructor TScreen.Create(AOwner: TComponent);
var
  DC: HDC;
  LFont: TLogFont;
begin
  inherited Create(AOwner);
  CreateCursors;
  InitImes;
  FFonts := TStringList.Create;
  FForms := TList.Create;
  FCustomForms := TList.Create;
  FDataModules := TList.Create;
  FSaveFocusedList := TList.Create;
  DC := GetDC(0);
  try
    FFonts.Add('Default');
    if Lo(GetVersion) >= 4 then
    begin
      FillChar(LFont, sizeof(LFont), 0);
      LFont.lfCharset := DEFAULT_CHARSET;
      EnumFontFamiliesEx(DC, LFont, @EnumFontsProc, LongInt(FFonts), 0);
    end
    else
      EnumFonts(DC, nil, @EnumFontsProc, Pointer(FFonts));
    TStringList(FFonts).Sorted := TRUE;
    FPixelsPerInch := GetDeviceCaps(DC, LOGPIXELSY);
  finally
    ReleaseDC(0, DC);
  end;
  FIconFont := TFont.Create;
  GetMetricSettings;
  FIconFont.OnChange := IconFontChanged;
end;

destructor TScreen.Destroy;
begin
  FIconFont.Free;
  FDataModules.Free;
  FCustomForms.Free;
  FForms.Free;
  FFonts.Free;
  FImes.Free;
  FSaveFocusedList.Free;
  DestroyCursors;
  inherited Destroy;
end;

function TScreen.GetHeight: Integer;
begin
  Result := GetSystemMetrics(SM_CYSCREEN);
end;

function TScreen.GetWidth: Integer;
begin
  Result := GetSystemMetrics(SM_CXSCREEN);
end;

function TScreen.GetForm(Index: Integer): TForm;
begin
  Result := FForms[Index];
end;

function TScreen.GetFormCount: Integer;
begin
  Result := FForms.Count;
end;

function TScreen.GetCustomForms(Index: Integer): TCustomForm;
begin
  Result := FCustomForms[Index];
end;

function TScreen.GetCustomFormCount: Integer;
begin
  Result := FCustomForms.Count;
end;

procedure TScreen.UpdateLastActive;
begin
  if FLastActiveCustomForm <> FActiveCustomForm then
  begin
    FLastActiveCustomForm := FActiveCustomForm;
    if Assigned(FOnActiveFormChange) then FOnActiveFormChange(Self);
  end;
  if FLastActiveControl <> FActiveControl then
  begin
    FLastActiveControl := FActiveControl;
    if Assigned(FOnActiveControlChange) then FOnActiveControlChange(Self);
  end;
end;

procedure TScreen.AddForm(AForm: TCustomForm);
begin
  FCustomForms.Add(AForm);
  if AForm is TForm then
  begin
    FForms.Add(AForm);
    Application.UpdateVisible;
  end;
end;

procedure TScreen.RemoveForm(AForm: TCustomForm);
begin
  FCustomForms.Remove(AForm);
  FForms.Remove(AForm);
  Application.UpdateVisible;
  if (FCustomForms.Count = 0) and (Application.FHintWindow <> nil) then
    Application.FHintWindow.ReleaseHandle;
end;

procedure TScreen.AddDataModule(DataModule: TDataModule);
begin
  FDataModules.Add(DataModule);
end;

procedure TScreen.RemoveDataModule(DataModule: TDataModule);
begin
  FDataModules.Remove(DataModule);
end;

procedure TScreen.CreateCursors;
const
  CursorMap: array[crHandPoint..crArrow] of PChar = (
    IDC_HANDPT, IDC_HELP, IDC_APPSTARTING, IDC_NO, IDC_SQLWAIT, IDC_MULTIDRAG, IDC_VSPLIT,
    IDC_HSPLIT, IDC_NODROP, IDC_DRAG, IDC_WAIT, IDC_UPARROW, IDC_SIZEWE,
    IDC_SIZENWSE, IDC_SIZENS, IDC_SIZENESW, IDC_ARROW, IDC_IBEAM, IDC_CROSS,
    IDC_ARROW);
var
  I: Integer;
  Instance: THandle;
begin
  FDefaultCursor := LoadCursor(0, IDC_ARROW);
  for I := Low(CursorMap) to High(CursorMap) do
  begin
    if ((I >= crSqlWait) and (I <= crDrag)) or (I <= crHandPoint) then
      Instance := HInstance else
      Instance := 0;
    InsertCursor(I, LoadCursor(Instance, CursorMap[I]));
  end;
end;

procedure TScreen.DestroyCursors;
var
  P, Next: PCursorRec;
  Hdl: THandle;
begin
  P := FCursorList;
  while P <> nil do
  begin
    if (P^.Index <= crDrag) or (P^.Index > 0) then
      DestroyCursor(P^.Handle);
    Next := P^.Next;
    Dispose(P);
    P := Next;
  end;
  Hdl := LoadCursor(0, IDC_ARROW);
  if Hdl <> FDefaultCursor then
    DestroyCursor(FDefaultCursor);
end;

procedure TScreen.DeleteCursor(Index: Integer);
var
  P, Q: PCursorRec;
begin
  P := FCursorList;
  Q := nil;
  while (P <> nil) and (P^.Index <> Index) do
  begin
    Q := P;
    P := P^.Next;
  end;
  if P <> nil then
  begin
    DestroyCursor(P^.Handle);
    if Q = nil then FCursorList := P^.Next else Q^.Next := P^.Next;
    Dispose(P);
  end;
end;

procedure TScreen.InsertCursor(Index: Integer; Handle: HCURSOR);
var
  P: PCursorRec;
begin
  New(P);
  P^.Next := FCursorList;
  P^.Index := Index;
  P^.Handle := Handle;
  FCursorList := P;
end;

procedure TScreen.InitImes;
const
  KbLayoutRegkeyFmt = 'System\CurrentControlSet\Control\Keyboard Layouts\%.8x';  // do not localize
  KbLayoutRegSubkey = 'layout text'; // do not localize
var
  TotalKbLayout, I, Bufsize: Integer;
  KbList: array[0..63] of HKL;
  qKey: HKey;
  ImeFileName: array [Byte] of Char;
  RegKey: array [0..63] of Char;
begin
  FImes := TStringList.Create;

  FDefaultIme := '';
  FDefaultKbLayout := GetKeyboardLayout(0);
  TotalKbLayout := GetKeyboardLayoutList(64, KbList);

  for I := 0 to TotalKbLayout - 1 do
  begin
    if Imm32IsIME(KbList[I]) then
    begin
      if RegOpenKeyEx(HKEY_LOCAL_MACHINE,
        StrFmt(RegKey, KbLayoutRegKeyFmt, [KbList[I]]), 0, KEY_ALL_ACCESS,
        qKey) = ERROR_SUCCESS then
      try
        Bufsize := sizeof(ImeFileName);
        if RegQueryValueEx(qKey, KbLayoutRegSubKey, nil, nil,
             @ImeFileName, @Bufsize) = ERROR_SUCCESS then
        begin
          FImes.AddObject(ImeFileName, TObject(KbList[I]));
          if KbList[I] = FDefaultKbLayout then
            FDefaultIme := ImeFileName;
        end;
      finally
        RegCloseKey(qKey);
      end;
    end;
  end;
  TStringList(FImes).Duplicates := dupIgnore;
  TStringList(FImes).Sorted := TRUE;
end;

procedure TScreen.IconFontChanged(Sender: TObject);
begin
  Application.NotifyForms(CM_SYSFONTCHANGED);
end;

function TScreen.GetDataModule(Index: Integer): TDataModule;
begin
  Result := FDataModules[Index];
end;

function TScreen.GetDataModuleCount: Integer;
begin
  Result := FDataModules.Count;
end;

function TScreen.GetCursors(Index: Integer): HCURSOR;
var
  P: PCursorRec;
begin
  Result := 0;
  if Index <> crNone then
  begin
    P := FCursorList;
    while (P <> nil) and (P^.Index <> Index) do P := P^.Next;
    if P = nil then Result := FDefaultCursor else Result := P^.Handle;
  end;
end;

procedure TScreen.SetCursor(Value: TCursor);
var
  P: TPoint;
  Handle: HWND;
  Code: Longint;
begin
  if Value <> Cursor then
  begin
    FCursor := Value;
    if Value = crDefault then
    begin
      { Reset the cursor to the default by sending a WM_SETCURSOR to the
        window under the cursor }
      GetCursorPos(P);
      Handle := WindowFromPoint(P);
      if (Handle <> 0) and
        (GetWindowThreadProcessId(Handle, nil) = GetCurrentThreadId) then
      begin
        Code := SendMessage(Handle, WM_NCHITTEST, P.X, P.Y);
        SendMessage(Handle, WM_SETCURSOR, Handle, MakeLong(Code, WM_MOUSEMOVE));
        Exit;
      end;
    end;
    Windows.SetCursor(Cursors[Value]);
  end;
  Inc(FCursorCount);
end;

procedure TScreen.SetCursors(Index: Integer; Handle: HCURSOR);
begin
  if Index = crDefault then
    if Handle = 0 then
      FDefaultCursor := LoadCursor(0, IDC_ARROW)
    else
      FDefaultCursor := Handle
  else if Index <> crNone then
  begin
    DeleteCursor(Index);
    if Handle <> 0 then InsertCursor(Index, Handle);
  end;
end;

procedure TScreen.GetMetricSettings;
var
  LogFont: TLogFont;
begin
  if SystemParametersInfo(SPI_GETICONTITLELOGFONT, SizeOf(LogFont), @LogFont, 0) then
    FIconFont.Handle := CreateFontIndirect(LogFont)
  else
    FIconFont.Handle := GetStockObject(SYSTEM_FONT);
end;

{ Hint functions }

function GetHint(Control: TControl): string;
begin
  while Control <> nil do
    if Control.Hint = '' then
      Control := Control.Parent
    else
    begin
      Result := Control.Hint;
      Exit;
    end;
  Result := '';
end;

function GetHintControl(Control: TControl): TControl;
begin
  Result := Control;
  while (Result <> nil) and not Result.ShowHint do Result := Result.Parent;
  if (Result <> nil) and (csDesigning in Result.ComponentState) then Result := nil;
end;

procedure HintTimerProc(Wnd: HWnd; Msg, TimerID, SysTime: Longint); stdcall;
begin
  if Application <> nil then Application.HintTimerExpired;
end;

{ DLL specific hint routines - Only executed in the context of a DLL to
  simulate hooks the .EXE has in the message loop }
var
  HintThreadID: Integer;
  HintDoneEvent: THandle;

procedure HintMouseThread(Param: Integer); stdcall;
var
  P: TPoint;
begin
  HintThreadID := GetCurrentThreadID;
  while WaitForSingleObject(HintDoneEvent, 100) = WAIT_TIMEOUT do
  begin
    if (Application <> nil) and (Application.FHintControl <> nil) then
    begin
      GetCursorPos(P);
      if FindVCLWindow(P) = nil then
        Application.CancelHint;
    end;
  end;
end;

var
  HintHook: HHOOK;
  HintThread: THandle;

function HintGetMsgHook(nCode: Integer; wParam: Longint; var Msg: TMsg): Longint; stdcall;
begin
  Result := CallNextHookEx(HintHook, nCode, wParam, Longint(@Msg));
  if (nCode >= 0) and (Application <> nil) then Application.IsHintMsg(Msg);
end;

procedure HookHintHooks;
var
  ThreadID: Integer;
begin
  if not Application.FRunning then
  begin
    if HintHook = 0 then
      HintHook := SetWindowsHookEx(WH_GETMESSAGE, @HintGetMsgHook, 0, GetCurrentThreadID);
    if HintDoneEvent = 0 then
      HintDoneEvent := CreateEvent(nil, False, False, nil);
    if HintThread = 0 then
      HintThread := CreateThread(nil, 1000, @HintMouseThread, nil, 0, ThreadID);
  end;
end;

procedure UnhookHintHooks;
begin
  if HintHook <> 0 then UnhookWindowsHookEx(HintHook);
  HintHook := 0;
  if HintThread <> 0 then
  begin
    SetEvent(HintDoneEvent);
    if GetCurrentThreadId <> HintThreadID then
      WaitForSingleObject(HintThread, INFINITE);
    HintThread := 0;
  end;
end;

function GetAnimation: Boolean;
var
  Info: TAnimationInfo;
begin
  Info.cbSize := SizeOf(TAnimationInfo);
  if SystemParametersInfo(SPI_GETANIMATION, SizeOf(Info), @Info, 0) then
    Result := Info.iMinAnimate <> 0 else
    Result := False;
end;

procedure SetAnimation(Value: Boolean);
var
  Info: TAnimationInfo;
begin
  Info.cbSize := SizeOf(TAnimationInfo);
  BOOL(Info.iMinAnimate) := Value;
  SystemParametersInfo(SPI_SETANIMATION, SizeOf(Info), @Info, 0);
end;

procedure ShowWinNoAnimate(Handle: HWnd; CmdShow: Integer);
var
  Animation: Boolean;
begin
  Animation := GetAnimation;
  if Animation then SetAnimation(False);
  ShowWindow(Handle, CmdShow);
  if Animation then SetAnimation(True);
end;

{ TApplication }

var
  WindowClass: TWndClass = (
    style: 0;
    lpfnWndProc: @DefWindowProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'TApplication');

constructor TApplication.Create(AOwner: TComponent);
var
  P: PChar;
  ModuleName: array[0..255] of Char;
begin
  inherited Create(AOwner);
  FTopMostList := TList.Create;
  FWindowHooks := TList.Create;
  FHintControl := nil;
  FHintWindow := nil;
  FHintColor := DefHintColor;
  FHintPause := DefHintPause;
  FHintShortPause := DefHintShortPause;
  FHintHidePause := DefHintHidePause;
  FShowHint := False;
  FActive := True;
  FIcon := TIcon.Create;
  FIcon.Handle := LoadIcon(MainInstance, 'MAINICON');
  FIcon.OnChange := IconChanged;
  GetModuleFileName(MainInstance, ModuleName, SizeOf(ModuleName));
  OemToAnsi(ModuleName, ModuleName);
  P := AnsiStrRScan(ModuleName, '\');
  if P <> nil then StrCopy(ModuleName, P + 1);
  P := AnsiStrScan(ModuleName, '.');
  if P <> nil then P^ := #0;
  AnsiLower(ModuleName + 1);
  FTitle := ModuleName;
  if not IsLibrary then CreateHandle;
  UpdateFormatSettings := True;
  UpdateMetricSettings := True;
  FShowMainForm := True;
  FAllowTesting := True;
  FTestLib := 0;
end;

destructor TApplication.Destroy;
begin
  if FTestLib > 32 then
    FreeLibrary(FTestLib);
  if (FHandle <> 0) and FHandleCreated and (HelpFile <> '') then
    HelpCommand(HELP_QUIT, 0);
  FActive := False;
  CancelHint;
  ShowHint := False;
  inherited Destroy;
  UnhookMainWindow(CheckIniChange);
  if (FHandle <> 0) and FHandleCreated then
  begin
    if NewStyleControls then SendMessage(FHandle, WM_SETICON, 1, 0);
    DestroyWindow(FHandle);
  end;
  if FObjectInstance <> nil then FreeObjectInstance(FObjectInstance);
  DoneCtl3D;
  FWindowHooks.Free;
  FTopMostList.Free;
  FIcon.Free;
end;

procedure TApplication.CreateHandle;
var
  TempClass: TWndClass;
  SysMenu: HMenu;
begin
  if not FHandleCreated and not IsConsole then
  begin
    FObjectInstance := MakeObjectInstance(WndProc);
    if not GetClassInfo(HInstance, WindowClass.lpszClassName, TempClass) then
    begin
      WindowClass.hInstance := HInstance;
      if Windows.RegisterClass(WindowClass) = 0 then
        raise EOutOfResources.Create(SWindowClass);
    end;
    FHandle := CreateWindow(WindowClass.lpszClassName, PChar(FTitle),
      WS_POPUP or WS_CAPTION or WS_CLIPSIBLINGS or WS_SYSMENU
      or WS_MINIMIZEBOX,
      GetSystemMetrics(SM_CXSCREEN) div 2,
      GetSystemMetrics(SM_CYSCREEN) div 2,
      0, 0, 0, 0, HInstance, nil);
    FTitle := '';
    FHandleCreated := True;
//    ShowWinNoAnimate(FHandle, SW_RESTORE);
    SetWindowLong(FHandle, GWL_WNDPROC, Longint(FObjectInstance));
    if NewStyleControls then
      SendMessage(FHandle, WM_SETICON, 1, GetIconHandle);
    SysMenu := GetSystemMenu(FHandle, False);
    DeleteMenu(SysMenu, SC_MAXIMIZE, MF_BYCOMMAND);
    DeleteMenu(SysMenu, SC_SIZE, MF_BYCOMMAND);
    if NewStyleControls then DeleteMenu(SysMenu, SC_MOVE, MF_BYCOMMAND);
  end;
end;

procedure TApplication.ControlDestroyed(Control: TControl);
begin
  if FMainForm = Control then FMainForm := nil;
  if FMouseControl = Control then FMouseControl := nil;
  if Screen.FActiveControl = Control then Screen.FActiveControl := nil;
  if Screen.FActiveCustomForm = Control then
  begin
    Screen.FActiveCustomForm := nil;
    Screen.FActiveForm := nil;
  end;
  if Screen.FFocusedForm = Control then Screen.FFocusedForm := nil;
  if FHintControl = Control then FHintControl := nil;
  Screen.UpdateLastActive;
end;

type
  PTopMostEnumInfo = ^TTopMostEnumInfo;
  TTopMostEnumInfo = record
    TopWindow: HWND;
    IncludeMain: Boolean;
  end;

function GetTopMostWindows(Handle: HWND; Info: Pointer): BOOL; stdcall;
begin
  Result := True;
  if GetWindow(Handle, GW_OWNER) = Application.Handle then
    if (GetWindowLong(Handle, GWL_EXSTYLE) and WS_EX_TOPMOST <> 0) and
      ((Application.MainForm = nil) or PTopMostEnumInfo(Info)^.IncludeMain or
      (Handle <> Application.MainForm.Handle)) then
      Application.FTopMostList.Add(Pointer(Handle))
    else
    begin
      PTopMostEnumInfo(Info)^.TopWindow := Handle;
      Result := False;
    end;
end;

procedure TApplication.DoNormalizeTopMosts(IncludeMain: Boolean);
var
  I: Integer;
  Info: TTopMostEnumInfo;
begin
  if Application.Handle <> 0 then
  begin
    if FTopMostLevel = 0 then
    begin
      Info.TopWindow := Handle;
      Info.IncludeMain := IncludeMain;
      EnumWindows(@GetTopMostWindows, Longint(@Info));
      if FTopMostList.Count <> 0 then
      begin
        Info.TopWindow := GetWindow(Info.TopWindow, GW_HWNDPREV);
        if GetWindowLong(Info.TopWindow, GWL_EXSTYLE) and WS_EX_TOPMOST <> 0 then
          Info.TopWindow := HWND_NOTOPMOST;
        for I := FTopMostList.Count - 1 downto 0 do
          SetWindowPos(HWND(FTopMostList[I]), Info.TopWindow, 0, 0, 0, 0,
            SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
      end;
    end;
    Inc(FTopMostLevel);
  end;
end;

procedure TApplication.NormalizeTopMosts;
begin
  DoNormalizeTopMosts(False);
end;

procedure TApplication.NormalizeAllTopMosts;
begin
  DoNormalizeTopMosts(True);
end;

procedure TApplication.RestoreTopMosts;
var
  I: Integer;
begin
  if (Application.Handle <> 0) and (FTopMostLevel > 0) then
  begin
    Dec(FTopMostLevel);
    if FTopMostLevel = 0 then
    begin
      for I := FTopMostList.Count - 1 downto 0 do
        SetWindowPos(HWND(FTopMostList[I]), HWND_TOPMOST, 0, 0, 0, 0,
          SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
      FTopMostList.Clear;
    end;
  end;
end;

function TApplication.CheckIniChange(var Message: TMessage): Boolean;
begin
  Result := False;
  case Message.Msg of
    WM_WININICHANGE:
      begin
        if UpdateFormatSettings then
        begin
          SetThreadLocale(LOCALE_USER_DEFAULT);
          GetFormatSettings;
        end;
        if UpdateMetricSettings then
        begin
          Screen.GetMetricSettings;
          { Update the hint window font }
          if ShowHint then
          begin
            SetShowHint(False);
            SetShowHint(True);
          end;
        end;
      end;
  end;
end;

procedure TApplication.WndProc(var Message: TMessage);
type
  TInitTestLibrary = function(Size: DWord; PAutoClassInfo: Pointer): Boolean; stdcall;

var
  I: Integer;
  SaveFocus, TopWindow: HWnd;
  InitTestLibrary: TInitTestLibrary;

  procedure Default;
  begin
    with Message do
      Result := DefWindowProc(FHandle, Msg, WParam, LParam);
  end;

  procedure DrawAppIcon;
  var
    DC: HDC;
    PS: TPaintStruct;
  begin
    with Message do
    begin
      DC := BeginPaint(FHandle, PS);
      DrawIcon(DC, 0, 0, GetIconHandle);
      EndPaint(FHandle, PS);
    end;
  end;

begin
  {$IFDEF Logs}
  if Message.Msg = WM_CHAR
    then
      LogThis( 'WM_CHAR message received within TApplication: ' + char( Message.wParam ) );
  {$ENDIF}
  try
    Message.Result := 0;
    for I := 0 to FWindowHooks.Count - 1 do
      if TWindowHook(FWindowHooks[I]^)(Message) then Exit;
    CheckIniChange(Message);
    with Message do
      case Msg of
        WM_SYSCOMMAND:
          case WParam and $FFF0 of
            SC_MINIMIZE: Minimize;
            SC_RESTORE: Restore;
          else
            Default;
          end;
        WM_CLOSE:
          if MainForm <> nil then MainForm.Close;
        WM_SYSCOLORCHANGE:
          if (Ctl3DHandle >= 32) and (@Ctl3DColorChange <> nil) then
            Ctl3DColorChange;
        WM_PAINT:
          if IsIconic(FHandle) then DrawAppIcon else Default;
        WM_ERASEBKGND:
          begin
            Message.Msg := WM_ICONERASEBKGND;
            Default;
          end;
        WM_QUERYDRAGICON:
          Result := GetIconHandle;
        WM_SETFOCUS:
          begin
            PostMessage(FHandle, CM_ENTER, 0, 0);
            Default;
          end;
        WM_ACTIVATEAPP:
          begin
            Default;
            FActive := TWMActivateApp(Message).Active;
            if TWMActivateApp(Message).Active then
            begin
              RestoreTopMosts;
              PostMessage(FHandle, CM_ACTIVATE, 0, 0)
            end
            else
            begin
              NormalizeTopMosts;
              PostMessage(FHandle, CM_DEACTIVATE, 0, 0);
            end;
          end;
        WM_ENABLE:
          if TWMEnable(Message).Enabled then
          begin
            RestoreTopMosts;
            if FWindowList <> nil then
            begin
              EnableTaskWindows(FWindowList);
              FWindowList := nil;
            end;
            Default;
          end else
          begin
            Default;
            if FWindowList = nil then
              FWindowList := DisableTaskWindows(Handle);
            NormalizeAllTopMosts;
          end;
        WM_CTLCOLORMSGBOX..WM_CTLCOLORSTATIC:
          Result := SendMessage(LParam, CN_BASE + Msg, WParam, LParam);
        WM_ENDSESSION: if TWMEndSession(Message).EndSession then Halt;
        WM_COPYDATA:
          if (PCopyDataStruct(Message.lParam)^.dwData = $DE534454) and
            (FAllowTesting) then
            if FTestLib = 0 then
            begin
              FTestLib := LoadLibrary('vcltest3.dll');
              if (FTestLib < 0) or (FTestLib > 32) then
              begin
                Result := 0;
                @InitTestLibrary := GetProcAddress(FTestLib, 'RegisterAutomation');
                if @InitTestLibrary <> nil then
                  InitTestLibrary(PCopyDataStruct(Message.lParam)^.cbData,
                    PCopyDataStruct(Message.lParam)^.lpData);
              end
              else
              begin
                Result := GetLastError;
                FTestLib := 0;
              end;
            end
            else
              Result := 0;
        CM_APPKEYDOWN:
          if (MainForm <> nil) and (MainForm.Menu <> nil) and
            IsWindowEnabled(MainForm.Handle) and
            MainForm.Menu.IsShortCut(TWMKey(Message)) then Result := 1;
        CM_APPSYSCOMMAND:
          if MainForm <> nil then
            with MainForm do
              if (Handle <> 0) and IsWindowEnabled(Handle) and
                IsWindowVisible(Handle) then
              begin
                FocusMessages := False;
                SaveFocus := GetFocus;
                Windows.SetFocus(Handle);
                Perform(WM_SYSCOMMAND, WParam, LParam);
                Windows.SetFocus(SaveFocus);
                FocusMessages := True;
                Result := 1;
              end;
        CM_ACTIVATE:
          if Assigned(FOnActivate) then FOnActivate(Self);
        CM_DEACTIVATE:
          if Assigned(FOnDeactivate) then FOnDeactivate(Self);
        CM_ENTER:
          if not IsIconic(FHandle) and (GetFocus = FHandle) then
          begin
            TopWindow := FindTopMostWindow(0);
            if TopWindow <> 0 then Windows.SetFocus(TopWindow);
          end;
        CM_INVOKEHELP: InvokeHelp(WParam, LParam);
        CM_WINDOWHOOK:
          if wParam = 0 then
            HookMainWindow(TWindowHook(Pointer(LParam)^)) else
            UnhookMainWindow(TWindowHook(Pointer(LParam)^));
        CM_DIALOGHANDLE:
          if wParam = 1 then
            Result := FDialogHandle
          else
            FDialogHandle := lParam;
      else
        Default;
      end;
  except
    HandleException(Self);
  end;
end;

function TApplication.GetIconHandle: HICON;
begin
  Result := FIcon.Handle;
  if Result = 0 then Result := LoadIcon(0, IDI_APPLICATION);
end;

procedure TApplication.Minimize;
begin
  if not IsIconic(FHandle) then
  begin
    NormalizeTopMosts;
    SetActiveWindow(FHandle);
    ShowWinNoAnimate(FHandle, SW_MINIMIZE);
    if Assigned(FOnMinimize) then FOnMinimize(Self);
  end;
end;

procedure TApplication.Restore;
begin
  if IsIconic(FHandle) then
  begin
    SetActiveWindow(FHandle);
    ShowWinNoAnimate(FHandle, SW_RESTORE);
    if (FMainForm <> nil) and (FMainForm.FWindowState = wsMinimized) and
      not FMainForm.Visible then
    begin
      FMainForm.WindowState := wsNormal;
      FMainForm.Show;
    end;
    RestoreTopMosts;
    if Screen.ActiveControl <> nil then
      Windows.SetFocus(Screen.ActiveControl.Handle);
    if Assigned(FOnRestore) then FOnRestore(Self);
  end;
end;

procedure TApplication.BringToFront;
var
  TopWindow: HWnd;
begin
  if Handle <> 0 then
  begin
    TopWindow := GetLastActivePopup(Handle);
    if (TopWindow <> 0) and (TopWindow <> Handle) and
      IsWindowVisible(TopWindow) and IsWindowEnabled(TopWindow) then
      SetForegroundWindow(TopWindow);
  end;
end;

function TApplication.GetTitle: string;
var
  Buffer: array[0..255] of Char;
begin
  if FHandleCreated then
    SetString(Result, Buffer, GetWindowText(FHandle, Buffer,
      SizeOf(Buffer))) else
    Result := FTitle;
end;

procedure TApplication.SetIcon(Value: TIcon);
begin
  FIcon.Assign(Value);
end;

procedure TApplication.SetTitle(const Value: string);
begin
  if FHandleCreated then
    SetWindowText(FHandle, PChar(Value)) else
    FTitle := Value;
end;

procedure TApplication.SetHandle(Value: HWnd);
begin
  if not FHandleCreated and (Value <> FHandle) then
  begin
    if FHandle <> 0 then UnhookMainWindow(CheckIniChange);
    FHandle := Value;
    if FHandle <> 0 then HookMainWindow(CheckIniChange);
  end;
end;

function TApplication.IsDlgMsg(var Msg: TMsg): Boolean;
begin
  Result := False;
  if FDialogHandle <> 0 then
    Result := IsDialogMessage(FDialogHandle, Msg);
end;

function TApplication.IsMDIMsg(var Msg: TMsg): Boolean;
begin
  Result := False;
  if (MainForm <> nil) and (MainForm.FormStyle = fsMDIForm) and
    (Screen.ActiveForm <> nil) and
    (Screen.ActiveForm.FormStyle = fsMDIChild) then
    Result := TranslateMDISysAccel(MainForm.ClientHandle, Msg);
end;

function TApplication.IsKeyMsg(var Msg: TMsg): Boolean;
var
  WND: HWND;
begin
  Result := False;
  with Msg do
    if (Message >= WM_KEYFIRST) and (Message <= WM_KEYLAST) and
      (GetCapture = 0) then
    begin
      Wnd := HWnd;
      if (MainForm <> nil) and (Wnd = MainForm.ClientHandle) then
        Wnd := MainForm.Handle; // Wnd
     //().rag
      if (screen <> nil)
         and (screen.activeform <> nil)
         and (screen.activeform.FFocusedControl <> nil)
         and (screen.activeform.FFocusedControl.handle<>0)
        then Wnd := screen.activeform.FFocusedControl.handle;

      if SendMessage(Wnd, CN_BASE + Message, WParam, LParam) <> 0
        then Result := True;
    end;
end;

function TApplication.IsHintMsg(var Msg: TMsg): Boolean;
begin
  Result := False;
  if (FHintWindow <> nil) and FHintWindow.IsHintMsg(Msg) then
    CancelHint;
end;

function TApplication.ProcessMessage: Boolean;
var
  Handled: Boolean;
  Msg: TMsg;
begin
  Result := False;
  try
    if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then
    begin
      Result := True;
      if Msg.Message <> WM_QUIT then
      begin
        {$IFDEF Logs}
        if Msg.message = WM_KEYDOWN
          then LogThis( 'WM_CHAR peek : ' + char( Msg.wParam ) );
        {$ENDIF}
        Handled := False;
        if Assigned(FOnMessage) then FOnMessage(Msg, Handled);
        if not IsHintMsg(Msg) and not Handled and not IsMDIMsg(Msg) and
          not IsKeyMsg(Msg) and not IsDlgMsg(Msg) then
        begin
          TranslateMessage(Msg);
          DispatchMessage(Msg);
        end;
      end
      else
        FTerminate := True;
    end
  except
  end;
end;

procedure TApplication.ProcessMessages;
begin
  while ProcessMessage do {loop};
end;

procedure TApplication.HandleMessage;
begin
  if not ProcessMessage then Idle;
end;

procedure TApplication.HookMainWindow(Hook: TWindowHook);
var
  WindowHook: ^TWindowHook;
begin
  if not FHandleCreated then
  begin
    if FHandle <> 0 then
      SendMessage(FHandle, CM_WINDOWHOOK, 0, Longint(@@Hook));
  end else
  begin
    FWindowHooks.Expand;
    New(WindowHook);
    WindowHook^ := Hook;
    FWindowHooks.Add(WindowHook);
  end;
end;

procedure TApplication.UnhookMainWindow(Hook: TWindowHook);
var
  I: Integer;
  WindowHook: ^TWindowHook;
begin
  if not FHandleCreated then
  begin
    if FHandle <> 0 then
      SendMessage(FHandle, CM_WINDOWHOOK, 1, Longint(@@Hook));
  end else
    for I := 0 to FWindowHooks.Count - 1 do
    begin
      WindowHook := FWindowHooks[I];
      if (TMethod(WindowHook^).Code = TMethod(Hook).Code) and
        (TMethod(WindowHook^).Data = TMethod(Hook).Data) then
      begin
        Dispose(WindowHook);
        FWindowHooks.Delete(I);
        Break;
      end;
    end;
end;

procedure TApplication.Initialize;
begin
  if InitProc <> nil then TProcedure(InitProc);
end;

procedure TApplication.CreateForm(InstanceClass: TComponentClass; var Reference);
var
  Instance: TComponent;
begin
  Instance := TComponent(InstanceClass.NewInstance);
  TComponent(Reference) := Instance;
  try
    Instance.Create(Self);
  except
    TComponent(Reference) := nil;
    Instance.Free;
    raise;
  end;
  if (FMainForm = nil) and (Instance is TForm) then
  begin
    TForm(Instance).HandleNeeded;
    FMainForm := TForm(Instance);
  end;
end;

procedure TApplication.Run;
begin
  FRunning := True;
  try
    AddExitProc(DoneApplication);
    if FMainForm <> nil then
    begin
      case CmdShow of
        SW_SHOWMINNOACTIVE: FMainForm.FWindowState := wsMinimized;
        SW_SHOWMAXIMIZED: MainForm.WindowState := wsMaximized;
      end;
      if FShowMainForm then
        if FMainForm.FWindowState = wsMinimized then
          Minimize else
          FMainForm.Visible := True;
      repeat
        HandleMessage
      until Terminated;
    end;
  finally
    FRunning := False;
  end;
end;

procedure TApplication.Terminate;
begin
  if CallTerminateProcs then PostQuitMessage(0);
end;

procedure TApplication.HandleException(Sender: TObject);
begin
  {
  if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
  if ExceptObject is Exception then
  begin
    if not (ExceptObject is EAbort) then
      if Assigned(FOnException) then
        FOnException(Sender, Exception(ExceptObject))
      else
        ShowException(Exception(ExceptObject));
  end else
    SysUtils.ShowException(ExceptObject, ExceptAddr);
  }
end;

function TApplication.MessageBox(Text, Caption: PChar; Flags: Longint): Integer;
var
  ActiveWindow: HWnd;
  WindowList: Pointer;
begin
  ActiveWindow := GetActiveWindow;
  WindowList := DisableTaskWindows(0);
  try
    Result := Windows.MessageBox(Handle, Text, Caption, Flags);
  finally
    EnableTaskWindows(WindowList);
    SetActiveWindow(ActiveWindow);
  end;
end;

procedure TApplication.ShowException(E: Exception);
var
  Msg: string;
begin
  Msg := E.Message;
  if (Msg <> '') and (AnsiLastChar(Msg) > '.') then Msg := Msg + '.';
  MessageBox(PChar(Msg), PChar(GetTitle), MB_OK + MB_ICONSTOP);
end;

function TApplication.InvokeHelp(Command: Word; Data: Longint): Boolean;
var
  CallHelp: Boolean;
  HelpHandle: HWND;
  ActiveForm: TCustomForm;
begin
  Result := False;
  CallHelp := True;
  ActiveForm := Screen.ActiveCustomForm;
  if Assigned(ActiveForm) and Assigned(ActiveForm.FOnHelp) then
    Result := ActiveForm.FOnHelp(Command, Data, CallHelp)
  else if Assigned(FOnHelp) then
    Result := FOnHelp(Command, Data, CallHelp);
  if CallHelp then
    if Assigned(ActiveForm) and ActiveForm.HandleAllocated and (ActiveForm.FHelpFile <> '') then
    begin
      HelpHandle := ActiveForm.Handle;
      Result := WinHelp(HelpHandle, PChar(ActiveForm.FHelpFile), Command, Data);
    end
    else
    if FHelpFile <> '' then
    begin
      HelpHandle := Handle;
      if FMainForm <> nil then HelpHandle := FMainForm.Handle;
      Result := WinHelp(HelpHandle, PChar(FHelpFile), Command, Data);
    end else
      if not FHandleCreated then
        PostMessage(FHandle, CM_INVOKEHELP, Command, Data);
end;

function TApplication.HelpContext(Context: THelpContext): Boolean;
begin
  Result := InvokeHelp(HELP_CONTEXT, Context);
end;

function TApplication.HelpCommand(Command: Integer; Data: Longint): Boolean;
begin
  Result := InvokeHelp(Command, Data);
end;

function TApplication.HelpJump(const JumpID: string): Boolean;
var
  Command: array[0..255] of Char;
begin
  Result := True;
  if InvokeHelp(HELP_CONTENTS, 0) then
  begin
    StrLFmt(Command, SizeOf(Command) - 1, 'JumpID("","%s")', [JumpID]);
    Result := InvokeHelp(HELP_COMMAND, Longint(@Command));
  end;
end;

function TApplication.GetExeName: string;
begin
  Result := ParamStr(0);
end;

procedure TApplication.SetShowHint(Value: Boolean);
begin
  if FShowHint <> Value then
  begin
    FShowHint := Value;
    if FShowHint then
    begin
      FHintWindow := HintWindowClass.Create(Self);
      FHintWindow.Color := FHintColor;
    end else
    begin
      FHintWindow.Free;
      FHintWindow := nil;
    end;
  end;
end;

procedure TApplication.SetHintColor(Value: TColor);
begin
  if FHintColor <> Value then
  begin
    FHintColor := Value;
    if FHintWindow <> nil then
      FHintWindow.Color := FHintColor;
  end;
end;

function TApplication.DoMouseIdle: TControl;
var
  CaptureControl: TControl;
  P: TPoint;
begin
  GetCursorPos(P);
  Result := FindDragTarget(P, True);
  if (Result <> nil) and (csDesigning in Result.ComponentState) then
    Result := nil;
  CaptureControl := GetCaptureControl;
  if FMouseControl <> Result then
  begin
    if ((FMouseControl <> nil) and (CaptureControl = nil)) or
      ((CaptureControl <> nil) and (FMouseControl = CaptureControl)) then
      FMouseControl.Perform(CM_MOUSELEAVE, 0, 0);
    FMouseControl := Result;
    if ((FMouseControl <> nil) and (CaptureControl = nil)) or
      ((CaptureControl <> nil) and (FMouseControl = CaptureControl)) then
      FMouseControl.Perform(CM_MOUSEENTER, 0, 0);
  end;
end;

procedure TApplication.Idle;
var
  Control: TControl;
  Done: Boolean;
begin
  Control := DoMouseIdle;
  if FShowHint and (FMouseControl = nil) then
    CancelHint;
  Application.Hint := GetLongHint(GetHint(Control));
  Done := True;
  try
    if Assigned(FOnIdle) then FOnIdle(Self, Done);
  except
    on Exception do HandleException(Self);
  end;
  if Done then WaitMessage;
end;

procedure TApplication.NotifyForms(Msg: Word);
var
  I: Integer;
begin
  for I := 0 to Screen.FormCount - 1 do Screen.Forms[I].Perform(Msg, 0, 0);
end;

procedure TApplication.IconChanged(Sender: TObject);
begin
  if NewStyleControls then
    SendMessage(FHandle, WM_SETICON, 1, GetIconHandle)
  else
    if IsIconic(FHandle) then InvalidateRect(FHandle, nil, True);
  NotifyForms(CM_ICONCHANGED);
end;

procedure TApplication.SetHint(const Value: string);
begin
  if FHint <> Value then
  begin
    FHint := Value;
    if Assigned(FOnHint) then FOnHint(Self);
  end;
end;

procedure TApplication.UpdateVisible;

  procedure SetVisible(Value: Boolean);
  const
    ShowFlags: array[Boolean] of Word = (
      SWP_NOSIZE + SWP_NOMOVE + SWP_NOZORDER + SWP_NOACTIVATE + SWP_HIDEWINDOW,
      SWP_NOSIZE + SWP_NOMOVE + SWP_NOZORDER + SWP_NOACTIVATE + SWP_SHOWWINDOW);
  begin
    if IsWindowVisible(FHandle) <> Value then
      SetWindowPos(FHandle, 0, 0, 0, 0, 0, ShowFlags[Value]);
  end;

var
  I: Integer;
begin
  if FHandle <> 0 then
  begin
    for I := 0 to Screen.FormCount - 1 do
      if Screen.Forms[I].Visible then
      begin
        SetVisible(True);
        Exit;
      end;
    SetVisible(False);
  end;
end;

{ Hint window processing }

procedure TApplication.StartHintTimer(Value: Integer; TimerMode: TTimerMode);
begin
  StopHintTimer;
  FTimerHandle := SetTimer(0, 0, Value, @HintTimerProc);
  FTimerMode := TimerMode;
  if FTimerHandle = 0 then CancelHint;
end;

procedure TApplication.StopHintTimer;
begin
  if FTimerHandle <> 0 then
  begin
    KillTimer(0, FTimerHandle);
    FTimerHandle := 0;
  end;
end;

procedure TApplication.HintMouseMessage(Control: TControl; var Message: TMessage);
var
  NewHintControl: TControl;
  Pause: Integer;
  WasHintActive: Boolean;
begin
  NewHintControl := GetHintControl(FindDragTarget(Control.ClientToScreen(SmallPointToPoint(TWMMouse(Message).Pos)), True));
  if (NewHintControl = nil) or not NewHintControl.ShowHint then
    CancelHint
  else
  begin
    if (NewHintControl <> FHintControl) or
      (not PtInRect(FHintCursorRect, Control.ClientToScreen(SmallPointToPoint(TWMMouse(Message).Pos)))) then
    begin
      WasHintActive := FHintActive;
      if WasHintActive then
        Pause := FHintShortPause else
        Pause := FHintPause;
      CancelHint;
      FHintActive := WasHintActive;
      FHintControl := NewHintControl;
      StartHintTimer(Pause, tmShow);
    end;
  end;
end;

procedure TApplication.HintTimerExpired;
var
  P: TPoint;
begin
  StopHintTimer;
  case FTimerMode of
    tmHide:
      HideHint;
    tmShow:
      begin
        GetCursorPos(P);
        ActivateHint(P);
      end;
  end;
end;

procedure TApplication.HideHint;
begin
  if (FHintWindow <> nil) and FHintWindow.HandleAllocated and
    IsWindowVisible(FHintWindow.Handle) then
    ShowWindow(FHintWindow.Handle, SW_HIDE);
end;

procedure TApplication.CancelHint;
begin
  if FHintControl <> nil then
  begin
    HideHint;
    FHintControl := nil;
    FHintActive := False;
    UnhookHintHooks;
    StopHintTimer;
  end;
end;

procedure TApplication.ActivateHint(CursorPos: TPoint);
var
  ClientOrigin, ParentOrigin: TPoint;
  HintInfo: THintInfo;
  CanShow: Boolean;
  HintWinRect: TRect;

  { Return number of scanlines between the scanline containing cursor hotspot
    and the last scanline included in the cursor mask. }
  function GetCursorHeightMargin: Integer;
  var
    IconInfo: TIconInfo;
    BitmapInfoSize: Integer;
    BitmapBitsSize: Integer;
    Bitmap: PBitmapInfoHeader;
    Bits: Pointer;
    BytesPerScanline, ImageSize: Integer;

      function FindScanline(Source: Pointer; MaxLen: Cardinal;
        Value: Cardinal): Cardinal; assembler;
      asm
              PUSH    ECX
              MOV     ECX,EDX
              MOV     EDX,EDI
              MOV     EDI,EAX
              POP     EAX
              REPE    SCASB
              MOV     EAX,ECX
              MOV     EDI,EDX
      end;

  begin
    { Default value is entire icon height }
    Result := GetSystemMetrics(SM_CYCURSOR);
    if GetIconInfo(GetCursor, IconInfo) then
    try
      GetDIBSizes(IconInfo.hbmMask, BitmapInfoSize, BitmapBitsSize);
      Bitmap := AllocMem(BitmapInfoSize + BitmapBitsSize);
      try
        Bits := Pointer(Longint(Bitmap) + BitmapInfoSize);
        if GetDIB(IconInfo.hbmMask, 0, Bitmap^, Bits^) and
          (Bitmap^.biBitCount = 1) then
        begin
          { Point Bits to the end of this bottom-up bitmap }
          with Bitmap^ do
          begin
            BytesPerScanline := ((biWidth * biBitCount + 31) and not 31) div 8;
            ImageSize := biWidth * BytesPerScanline;
            Bits := Pointer(Integer(Bits) + BitmapBitsSize - ImageSize);
            { Use the width to determine the height since another mask bitmap
              may immediately follow }
            Result := FindScanline(Bits, ImageSize, $FF);
            { In case the and mask is blank, look for an empty scanline in the
              xor mask. }
            if (Result = 0) and (biHeight >= 2 * biWidth) then
              Result := FindScanline(Pointer(Integer(Bits) - ImageSize),
                ImageSize, $00);
            Result := Result div BytesPerScanline;
          end;
          Dec(Result, IconInfo.yHotSpot);
        end;
      finally
        FreeMem(Bitmap, BitmapInfoSize + BitmapBitsSize);
      end;
    finally
      if IconInfo.hbmColor <> 0 then DeleteObject(IconInfo.hbmColor);
      if IconInfo.hbmMask <> 0 then DeleteObject(IconInfo.hbmMask);
    end;
  end;

  procedure ValidateHintWindow(HintClass: THintWindowClass);
  begin
    if HintClass = nil then HintClass := HintWindowClass;
    if (FHintWindow = nil) or (FHintWindow.ClassType <> HintClass) then
    begin
      FHintWindow.Free;
      FHintWindow := HintClass.Create(Self);
    end;
  end;

begin
  FHintActive := False;
  if FShowHint and (FHintControl <> nil) and ForegroundTask and
    (FHintControl = GetHintControl(FindDragTarget(CursorPos, True))) then
  begin
    HintInfo.HintControl := FHintControl;
    HintInfo.HintPos := CursorPos;
    Inc(HintInfo.HintPos.Y, GetCursorHeightMargin);
    HintInfo.HintMaxWidth := Screen.Width;
    HintInfo.HintColor := FHintColor;
    HintInfo.CursorRect := FHintControl.BoundsRect;
    ClientOrigin := FHintControl.ClientOrigin;
    ParentOrigin.X := 0;
    ParentOrigin.Y := 0;
    if FHintControl.Parent <> nil then
      ParentOrigin := FHintControl.Parent.ClientOrigin
    else if (FHintControl is TWinControl) and
      (TWinControl(FHintControl).ParentWindow <> 0) then
      Windows.ClientToScreen(TWinControl(FHintControl).ParentWindow, ParentOrigin);
    OffsetRect(HintInfo.CursorRect, ParentOrigin.X - ClientOrigin.X,
      ParentOrigin.Y - ClientOrigin.Y);
    HintInfo.CursorPos := FHintControl.ScreenToClient(CursorPos);
    HintInfo.HintStr := GetShortHint(GetHint(FHintControl));
    HintInfo.ReshowTimeout := 0;
    HintInfo.HideTimeout := FHintHidePause;
    HintInfo.HintWindowClass := HintWindowClass;
    HintInfo.HintData := nil;
    CanShow := FHintControl.Perform(CM_HINTSHOW, 0, Longint(@HintInfo)) = 0;
    if CanShow and Assigned(FOnShowHint) then
      FOnShowHint(HintInfo.HintStr, CanShow, HintInfo);
    FHintActive := CanShow;
    if FHintActive and (HintInfo.HintStr <> '') then
    begin
      ValidateHintWindow(HintInfo.HintWindowClass);
      { calculate the width of the hint based on HintStr and MaxWidth }
      with HintInfo do
        HintWinRect := FHintWindow.CalcHintRect(HintMaxWidth, HintStr, HintData);
      OffsetRect(HintWinRect, HintInfo.HintPos.X, HintInfo.HintPos.Y);

      { Convert the client's rect to screen coordinates }
      with HintInfo do
      begin
        FHintCursorRect.TopLeft := FHintControl.ClientToScreen(CursorRect.TopLeft);
        FHintCursorRect.BottomRight := FHintControl.ClientToScreen(CursorRect.BottomRight);
      end;

      FHintWindow.Color := HintInfo.HintColor;
      FHintWindow.ActivateHintData(HintWinRect, HintInfo.HintStr, HintInfo.HintData);
      HookHintHooks;
      if HintInfo.ReshowTimeout > 0 then
        StartHintTimer(HintInfo.ReshowTimeout, tmShow)
      else StartHintTimer(HintInfo.HideTimeout, tmHide);
      Exit;
    end;
  end;
  if HintInfo.ReshowTimeout > 0 then
    StartHintTimer(HintInfo.ReshowTimeout, tmShow)
  else CancelHint;
end;

function TApplication.GetCurrentHelpFile: string;
var
  ActiveForm: TCustomForm;
begin
  ActiveForm := Screen.ActiveCustomForm;
  if Assigned(ActiveForm) and (ActiveForm.FHelpFile <> '') then
    Result := ActiveForm.HelpFile
  else
    Result := HelpFile;
end;

function TApplication.GetDialogHandle: HWND;
begin
  if not FHandleCreated then
    Result := SendMessage(Handle, CM_DIALOGHANDLE, 1, 0)
  else
    Result := FDialogHandle;
end;

procedure TApplication.SetDialogHandle(Value: HWND);
begin
  if not FHandleCreated then
    SendMessage(Handle, CM_DIALOGHANDLE, 0, Value);
  FDialogHandle := Value;
end;

initialization
  Classes.FindGlobalComponent := FindGlobalComponent;

finalization
  if Application <> nil then DoneApplication;
  if HintDoneEvent <> 0 then CloseHandle(HintDoneEvent);

end.
