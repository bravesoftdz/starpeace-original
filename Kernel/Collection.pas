//****************************************************************************//
//                                                                            //
//       Merchise TCollection, the shortest implementation ever done.         //
//       All rights reserved, Merchise (c) 1997.                              //
//                                                                            //
//****************************************************************************//

unit Collection;

interface

  uses
    Windows, SysUtils, Classes, SyncObjs;

  const
    NoIndex = -1;

  type
    PItemArray = ^TItemArray;
    TItemArray = array[0..0] of TObject;

  type
    TCollection               = class;
    TNotifiedCollection       = class;
    TSortedCollection         = class;
    TNotifiedSortedCollection = class;

    CObject = class of TObject;

    TRelationshipKind         = (rkUse, rkBelonguer);
    TCollectionOperation      = (opInsertion, opDeletion, opExtraction);
    TOnModified               = procedure(Operation : TCollectionOperation;
                                          Index     : integer;
                                          Item      : TObject) of object;
    TCompareItemFuction       = function(Item1, Item2 : TObject) : integer of object;
    ECollectionError          = Exception;
    ECollectionOverflow       = Exception;

    CCollection = class of TCollection;
    PCollection = ^TCollection;
    TCollection =
      class
        public
          constructor Create(InitCapacity : integer; aRelKind : TRelationshipKind);
          destructor  Destroy; override;
        private
          fCapacity : integer;
          fCount    : integer;
          fItems    : PItemArray;
        protected
          class procedure Error(const msg : string; data : integer);
        public
          procedure Insert(Item : TObject);                     virtual;
          procedure Delete(Item : TObject);                     virtual;
          procedure Extract(Item : TObject);                    virtual;
          procedure AtInsert(Index : integer; Item : TObject);  virtual;
          procedure AtDelete(Index : integer);                  virtual;
          function  AtExtract(Index : integer) : TObject;       virtual;
          function  IndexOf(Item : TObject) : integer;          virtual;
          procedure InsertColl(Coll : TCollection);
          procedure DeleteColl(Coll : TCollection);
          procedure DeleteAll;                                  virtual;
          procedure ExtractAll;                                 virtual;
          procedure Sort(Compare : TCompareItemFuction);        virtual;
          procedure Move(CurPos, NewPos : integer);             virtual;
          procedure Exchange(index1, index2 : integer);         virtual;
          function  Matches( Coll : TCollection ) : integer;    virtual;
          procedure Pack;                                       virtual;
          function  CheckPolymorphism( ClassType : CObject ) : integer; virtual;
        protected
          function  GetDelta(aCapacity : integer) : integer;
          function  GetItem(index : integer) : TObject;         virtual;
          procedure SetItem(index : integer; Item : TObject);   virtual;
          function  GetCount : integer;                         virtual;
          procedure SetCount(aCount : integer);                 virtual;
          function  GetCapacity : integer;                      virtual;
          procedure SetCapacity(aCapacity : integer);           virtual;
          function  GetRelKind : TRelationshipKind;             virtual;
          procedure SetRelKind(aRelKind : TRelationshipKind);   virtual;
        public
          property  Items[index : integer] : TObject read GetItem write SetItem; default;
          property  Count    : integer read GetCount;
          property  Capacity : integer read GetCapacity write SetCapacity;
          property  RelKind  : TRelationshipKind read GetRelKind;
        public
          property friend_Capacity : integer           read GetCapacity write SetCapacity;
          property friend_Count    : integer           read fCount      write fCount;
          property friend_Items    : PItemArray        read fItems      write fItems;
          property friend_RelKind  : TRelationshipKind read GetRelKind  write SetRelKind;
        private
          procedure QuickSort(Compare : TCompareItemFuction;  L, R : integer);
      end;

    TNotifiedCollection =
      class(TCollection)
        public
          procedure AtInsert(Index : integer; Item : TObject); override;
          procedure AtDelete(Index : integer);                 override;
          function  AtExtract(Index : integer) : TObject;      override;
        public
          friend_OnModified : TOnModified;
        published
          property OnModified : TOnModified read friend_OnModified write friend_OnModified;
      end;

    TLockableCollection =
      class(TNotifiedCollection)
        public
          constructor Create(InitCapacity : integer; aRelKind : TRelationshipKind);
          destructor  Destroy; override;
        public
          fCriticalSec : TCriticalSection;
        public
          procedure InitLock;
          procedure DoneLock;
          procedure Lock;
          procedure Unlock;
        public
          procedure Insert(Item : TObject);                     override;
          procedure Delete(Item : TObject);                     override;
          procedure Extract(Item : TObject);                    override;
          procedure AtInsert(Index : integer; Item : TObject);  override;
          procedure AtDelete(Index : integer);                  override;
          function  AtExtract(Index : integer) : TObject;       override;
          function  IndexOf(Item : TObject) : integer;          override;
          procedure DeleteAll;                                  override;
          procedure ExtractAll;                                 override;
          procedure Sort(Compare : TCompareItemFuction);        override;
          procedure Move(CurPos, NewPos : integer);             override;
          procedure Exchange(index1, index2 : integer);         override;
          procedure Pack;                                       override;
          function  CheckPolymorphism( ClassType : CObject ) : integer; override;
        protected
          function  GetItem(index : integer) : TObject;         override;
          procedure SetItem(index : integer; Item : TObject);   override;
          function  GetCount : integer;                         override;
          procedure SetCount(aCount : integer);                 override;
          function  GetCapacity : integer;                      override;
          procedure SetCapacity(aCapacity : integer);           override;
          function  GetRelKind : TRelationshipKind;             override;
          procedure SetRelKind(aRelKind : TRelationshipKind);   override;
      end;

    TSortedCollection =
      class(TCollection)
        public
          constructor Create(InitCapacity : integer;
                             aRelKind     : TRelationshipKind;
                             aCompFunct   : TCompareItemFuction);
        public
          friend_CompFunct : TCompareItemFuction;
        public
          procedure AtInsert(Index : integer; Item : TObject); override;
          function  IndexOf(Item : TObject) : integer;         override;
          function  InsertPos(Item : TObject) : integer;
        private
          function  FindPos(Item : TObject) : integer;
      end;

    TNotifiedSortedCollection =
      class(TSortedCollection)
        public
          procedure AtInsert(Index : integer; Item : TObject); override;
          procedure AtDelete(Index : integer);                 override;
          function  AtExtract(Index : integer) : TObject;      override;
        public
          friend_OnModified : TOnModified;
        published
          property OnModified : TOnModified read friend_OnModified write friend_OnModified;
      end;

implementation

{$IFDEF USELogs}
  uses
    Logs;
{$ENDIF}

  const
    erIndexOutOfRange  = 'Collection index out of range';
    erCapacityOverflow = 'Collection out of capacity';
    HugeMask           = $7FFFFFFF;

  const
    tidLog_Survival = 'Survival';

  // ObjectIs

  function ObjectIs( ClassName : string; O : TObject ) : boolean;
    var
      SuperClass : TClass;
    begin
      try
        SuperClass := O.ClassType;
        while (SuperClass <> nil) and (SuperClass.ClassName <> ClassName) do
          SuperClass := SuperClass.ClassParent;
        result := (SuperClass <> nil);
      except
        result := false;                               
      end;
    end;

  // TCollection

  constructor TCollection.Create(InitCapacity : integer; aRelKind : TRelationshipKind);
    begin
      inherited Create;
      if InitCapacity <> 0
        then Capacity := InitCapacity;
      SetRelKind(aRelKind);
    end;

  destructor TCollection.Destroy;
    begin
      DeleteAll;
      inherited Destroy;
    end;

  class procedure TCollection.Error(const msg : string; data : integer);

    function ReturnAddr : pointer;
      asm
         MOV EAX,[EBP+4]
      end;

    begin
      raise EListError.CreateFmt(Msg, [Data]) at ReturnAddr;
    end;

  procedure TCollection.Insert(Item : TObject);
    begin
      AtInsert(Count, Item);
    end;

  procedure TCollection.Delete(Item : TObject);
    var
      idx : integer;
    begin
      idx := IndexOf(Item);
      if idx <> NoIndex
        then AtDelete(idx);
    end;

  procedure TCollection.Extract(Item : TObject);
    var
      idx : integer;
    begin
      idx := IndexOf(Item);
      if idx <> NoIndex
        then AtExtract(idx);
    end;

  procedure TCollection.AtInsert(Index : integer; Item : TObject);
    var
      cap : integer;
      cnt : integer;
    begin
      // Lets save time, Count invokes a function.
      cnt := Count;
      {#IFNDEF RELEASE}
      if (index < 0) or (index > cnt)
        then Error(erIndexOutOfRange, index);
      {#ENDIF}
      // Check the array dimension
      cap := Capacity;
      if (cap = 0) or (cnt = cap)
        then Capacity := cap + GetDelta(cap);
      // Shift right the array if necesary
      if Index < cnt
        then System.move(fItems[Index], fItems[Index+1], (cnt - Index)*sizeof(fItems[0]));
      // Insert the Item
      fItems[Index] := Item;
      SetCount(cnt + 1);
    end;

  procedure TCollection.AtDelete(Index : integer);
    var
      cnt  : integer;
      Item : TObject;
      cap  : integer;
      dlt  : integer;
    begin
      cnt := Count;
      {#IFNDEF RELEASE}
      if (index < 0) or (index >= cnt)
        then Error(erIndexOutOfRange, index);
      {#ENDIF}
      if RelKind = rkBelonguer
        then Item := Items[Index]
        else Item := nil;
      dec(cnt);
      if Index < cnt
        then System.move(fItems[Index+1], fItems[Index], (cnt - Index)*sizeof(fItems[0]));
      SetCount(cnt);
      if cnt > 0
        then
          begin
            cap := Capacity;
            dlt := GetDelta(cap);
            if cnt + dlt < cap
              then SetCapacity(cnt + dlt div 2);
          end
        else SetCapacity(0);
      if Item <> nil
        then Item.Free;
    end;

  function TCollection.AtExtract(Index : integer) : TObject;
    var
      cnt : integer;
    begin
      cnt := Count;
      {#IFNDEF RELEASE}
      if (index < 0) or (index >= cnt)
        then Error(erIndexOutOfRange, index);
      {#ENDIF}
      result := fItems[Index];
      dec(cnt);
      if Index < cnt
        then System.move(fItems[Index+1], fItems[Index], (cnt - Index)*sizeof(fItems[0]));
      SetCount(cnt);
      if cnt = 0
        then Capacity := 0;
    end;

  function TCollection.IndexOf(Item : TObject) : integer;
    var
      idx : integer;
      cnt : integer;
    begin
      cnt := Count;
      idx := 0;
      while (idx < cnt) and (fItems[idx] <> Item) do
        inc(idx);
      if idx < cnt
        then result := idx
        else result := NoIndex;
    end;

  procedure TCollection.InsertColl(Coll : TCollection);
    var
      idx : integer;
      aux : PItemArray;
    begin
      aux := Coll.fItems;
      for idx := 0 to pred(Coll.Count) do
        Insert(aux[idx]);
    end;

  procedure TCollection.DeleteColl(Coll : TCollection);
    var
      idx : integer;
      aux : PItemArray;
    begin
      aux := Coll.fItems;
      for idx := 0 to pred(Coll.Count) do
        Delete(aux[idx]);
    end;

  procedure TCollection.DeleteAll;
    begin
      Capacity := 0;
    end;

  procedure TCollection.ExtractAll;
    begin
      ReallocMem(fItems, 0);
      SetCount(0);
    end;

  procedure TCollection.Sort(Compare : TCompareItemFuction);
    var
      cnt : integer;
    begin
      cnt := Count;
      if cnt > 0
        then QuickSort(Compare, 0, cnt - 1);
    end;

  procedure TCollection.Move(CurPos, NewPos : integer);
    var
      Item : TObject;
      cnt  : integer;
    begin
      {#IFNDEF RELEASE}
      cnt := Count;
      if (CurPos < cnt) and (NewPos < cnt)
        then
          begin
      {#ENDIF}
            Item := AtExtract(CurPos);
            AtInsert(NewPos, Item);
      {#IFNDEF RELEASE}
          end
        else Error(erIndexOutOfRange, CurPos);
      {#ENDIF}
    end;

  procedure TCollection.Exchange(index1, index2 : integer);
    var
      Item : TObject;
      cnt  : integer;
    begin
      {#IFNDEF RELEASE}
      cnt := Count;
      if (index1 < cnt) and (index2 < cnt)
        then
          begin
      {#ENDIF}
            Item := fItems[index1];
            fItems[index1] := fItems[index2];
            fItems[index2] := Item;
      {#IFNDEF RELEASE}
          end
        else Error(erIndexOutOfRange, index1);
      {#ENDIF}
    end;

  function TCollection.Matches( Coll : TCollection ) : integer;
    var
      i : integer;
    begin
      result := 0;
      for i := 0 to pred(Coll.Count) do
        if IndexOf( Coll[i] ) <> NoIndex
          then inc( result );
    end;

  procedure TCollection.Pack;
    var
      i : integer;
    begin                                                     
      for i := pred(Count) downto 0 do
        if fItems[i] = nil
          then AtDelete(i);
    end;

  function TCollection.CheckPolymorphism( ClassType : CObject ) : integer;
    var
      i : integer;
    begin
      result := 0;
      try
        for i := pred(Count) downto 0 do
          if not ObjectIs( ClassType.ClassName, fItems[i] )
            then
              begin
                try
                {$IFDEF USELogs}
                  Logs.Log( tidLog_Survival, DateTimeToStr(Now) + ' Polymorphism ERROR: ' + fItems[i].ClassName + ' instead of ' + ClassType.ClassName );
                {$ENDIF}
                except
                end;
                inc(result);
                AtExtract(i);
              end;
      except
        {$IFDEF USELogs}
        Logs.Log( tidLog_Survival, DateTimeToStr(Now) + ' Catastrophic error checking Polymorphism.' );
        {$ENDIF}
      end;
    end;

  function TCollection.GetDelta(aCapacity : integer) : integer;
    begin
      if aCapacity > 64
        then result := aCapacity div 8
        else
          if aCapacity > 8
            then result := 8
            else result := 4;
    end;
{
  function TCollection.GetDelta(aCapacity : integer) : integer;
    begin
      if aCapacity > 64
        then
          result := aCapacity div 4
        else
          if aCapacity > 8
            then result := 16
            else result := 4;
    end;

}
  function TCollection.GetItem(index : integer) : TObject;
    begin
      {#IFNDEF RELEASE}
      if (index < 0) or (index >= Count)
        then Error(erIndexOutOfRange, index);
      {#ENDIF}
      result := fItems[index];
    end;

  procedure TCollection.SetItem(index : integer; Item : TObject);
    begin
      {#IFNDEF RELEASE}
      if (index < 0) or (index >= Count)
        then Error(erIndexOutOfRange, index);
      {#ENDIF}
      fItems[index] := Item;
    end;

  function TCollection.GetCount : integer;
    begin
      result := fCount and HugeMask;
    end;

  procedure TCollection.SetCount(aCount : integer);
    begin
      fCount := (fCount and not HugeMask) or aCount;
    end;

  function TCollection.GetCapacity : integer;
    begin
      result := fCapacity;
    end;

  procedure TCollection.SetCapacity(aCapacity : integer);
    var
      idx  : integer;
      cnt  : integer;
      aux  : PItemArray;
    begin
      if aCapacity >= fCapacity
        then
          begin
            ReallocMem(fItems, aCapacity*sizeof(fItems[0]));
            fCapacity := aCapacity;
          end
        else
          begin
            cnt := Count;
            if (cnt > 0) and (RelKind = rkBelonguer)
              then
                for idx := aCapacity to pred(cnt) do
                  try
                    fItems[idx].Free;
                  except
                  end;
            if cnt > aCapacity
              then
                begin
                  cnt := aCapacity;
                  SetCount(aCapacity);
                end;
            if aCapacity > 0
              then
                begin
                  GetMem(aux, aCapacity*sizeof(aux[0]));
                  System.move(fItems[0], aux[0], cnt*sizeof(aux[0]));
                  ReallocMem(fItems, 0);
                  fItems := aux;
                  fCapacity := aCapacity;
                end
              else
                begin
                  ReallocMem(fItems, 0);
                  fCapacity := 0;
                end;
          end;
    end;

  function TCollection.GetRelKind : TRelationshipKind;
    begin
      if (fCount and not HugeMask) = 0
        then result := rkUse
        else result := rkBelonguer;
    end;

  procedure TCollection.SetRelKind(aRelKind : TRelationshipKind);
    begin
      if aRelKind = rkUse
        then fCount := fCount and HugeMask
        else fCount := fCount or not HugeMask;
    end;

  procedure TCollection.QuickSort(Compare : TCompareItemFuction;  L, R : integer);
    var
      i, j : integer;
      P, T : TObject;
    begin
      repeat
        i := L;
        j := R;
        P := fItems[(L + R) shr 1];
        repeat
          while Compare(fItems[i], P) < 0 do
            inc(i);
          while Compare(fItems[j], P) > 0 do
            dec(j);
          if i <= j
            then
              begin
                T := fItems[i];
                fItems[i] := fItems[j];
                fItems[j] := T;
                inc(i);
                dec(j);
              end;
        until i > j;
        if L < j
          then QuickSort(Compare, L, j);
        L := i;
      until i >= R;
    end;


  // TNotifiedCollection

  procedure TNotifiedCollection.AtInsert(Index : integer; Item : TObject);
    begin
      inherited;
      if assigned(friend_OnModified)
        then friend_OnModified(opInsertion, Index, Item);
    end;

  procedure TNotifiedCollection.AtDelete(Index : integer);
    var
      cnt : integer;
    begin
      cnt := Count;
      {#IFNDEF RELEASE}
      if (index < 0) or (index >= cnt)
        then Error(erIndexOutOfRange, index);
      {#ENDIF}
      if assigned(friend_OnModified)
        then friend_OnModified(opDeletion, Index, fItems[Index]);
      inherited;
    end;

  function TNotifiedCollection.AtExtract(Index : integer) : TObject;
    var
      cnt : integer;
    begin
      cnt := Count;
      {#IFNDEF RELEASE}
      if (index < 0) or (index >= cnt)
        then Error(erIndexOutOfRange, index);
      {#ENDIF}
      if assigned(friend_OnModified)
        then friend_OnModified(opExtraction, Index, fItems[Index]);
      result := inherited AtExtract(Index);
    end;

  // TLockableCollection

  constructor TLockableCollection.Create(InitCapacity : integer; aRelKind : TRelationshipKind);
    begin
      inherited Create(InitCapacity, aRelKind);
      InitLock;
    end;

  destructor TLockableCollection.Destroy;
    begin
      DoneLock;
      inherited Destroy;
    end;

  procedure TLockableCollection.InitLock;
    begin
      fCriticalSec := TCriticalSection.Create;
    end;

  procedure TLockableCollection.DoneLock;
    begin
      fCriticalSec.Free;
      fCriticalSec := nil;
    end;

  procedure TLockableCollection.Lock;
    begin
      if fCriticalSec <> nil
        then fCriticalSec.Enter;
    end;

  procedure TLockableCollection.Unlock;
    begin
      if fCriticalSec <> nil
        then fCriticalSec.Leave;
    end;

  procedure TLockableCollection.Insert(Item : TObject);
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.Delete(Item : TObject);
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.Extract(Item : TObject);
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.AtInsert(Index : integer; Item : TObject);
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.AtDelete(Index : integer);
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  function TLockableCollection.AtExtract(Index : integer) : TObject;
    begin
      Lock;
      try
        result := inherited AtExtract(Index);
      finally
        Unlock;
      end;
    end;

  function TLockableCollection.IndexOf(Item : TObject) : integer;
    begin
      Lock;
      try
        result := inherited IndexOf(Item);
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.DeleteAll;
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.ExtractAll;
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.Sort(Compare : TCompareItemFuction);
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.Move(CurPos, NewPos : integer);
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.Exchange(Index1, Index2 : integer);
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.Pack;
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  function TLockableCollection.CheckPolymorphism( ClassType : CObject ) : integer;
    begin
      Lock;
      try
        result := inherited CheckPolymorphism(ClassType);
      finally
        Unlock;
      end;
    end;

  function TLockableCollection.GetItem(Index : integer) : TObject;
    begin
      Lock;
      try
        result := inherited GetItem(Index);
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.SetItem(index : integer; Item : TObject);
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  function TLockableCollection.GetCount : integer;
    begin
      Lock;
      try
        result := inherited GetCount;
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.SetCount(aCount : integer);
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  function TLockableCollection.GetCapacity : integer;
    begin
      Lock;
      try
        result := inherited GetCapacity;
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.SetCapacity(aCapacity : integer);
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  function TLockableCollection.GetRelKind : TRelationshipKind;
    begin
      Lock;
      try
        result := inherited GetRelKind;
      finally
        Unlock;
      end;
    end;

  procedure TLockableCollection.SetRelKind(aRelKind : TRelationshipKind);
    begin
      Lock;
      try
        inherited;
      finally
        Unlock;
      end;
    end;

  // TSortedCollection

  constructor TSortedCollection.Create(InitCapacity : integer;
                                       aRelKind : TRelationshipKind;
                                     aCompFunct : TCompareItemFuction);
    begin
      inherited Create(InitCapacity, aRelKind);
      friend_CompFunct := aCompFunct;
    end;

  procedure TSortedCollection.AtInsert(Index : integer; Item : TObject);
    begin
      inherited AtInsert(InsertPos(Item), Item);
    end;

  function TSortedCollection.IndexOf(Item : TObject) : integer;
    {
    var
      Idx  : integer;
      flag : boolean;
    }
    begin
      result := inherited IndexOf( Item );
      { >> comments by Cepero
      Idx  := InsertPos(Item);
      flag := false;
      while (Idx > 0) and not flag and (friend_CompFunct(Item, fItems[Idx-1]) = 0) do
        begin
          flag := fItems[Idx-1] = Item;
          dec(Idx);
        end;
      if flag
        then result := Idx
        else result := NoIndex;
      }
    end;

  function TSortedCollection.InsertPos(Item : TObject) : integer;
    var
      cnt : integer;
    begin
      cnt := Count;
      if Assigned(friend_CompFunct)
        then
          if (cnt = 0) or (friend_CompFunct(fItems[0], Item) > 0)
            then result := 0
            else
              if friend_CompFunct(fItems[pred(cnt)], Item) <= 0
                then result := cnt
                else result := FindPos(Item)
        else result := Count;
    end;

  function TSortedCollection.FindPos(Item : TObject) : integer;
    var
      l : integer;
      m : integer;
      h : integer;
      c : integer;
    begin
      l := 0;
      h := pred(Count);
      repeat
        m := (l + h) div 2;
        c := friend_CompFunct(fItems[m], Item);
        if c <= 0
          then l := m
          else h := m
      until (h - l <= 1);
      result := h;
    end;

  // TNotifiedSortedCollection

  procedure TNotifiedSortedCollection.AtInsert(Index : integer; Item : TObject);
    begin
      inherited;
      if assigned(friend_OnModified)
        then friend_OnModified(opInsertion, Index, Item);
    end;

  procedure TNotifiedSortedCollection.AtDelete(Index : integer);
    begin
      if (fItems <> nil) and assigned(friend_OnModified)
        then friend_OnModified(opDeletion, Index, fItems[Index]);
      inherited;
    end;

  function TNotifiedSortedCollection.AtExtract(Index : integer) : TObject;
    var
      cnt : integer;
    begin
      cnt := Count;
      {#IFNDEF RELEASE}
      if (index < 0) or (index >= cnt)
        then Error(erIndexOutOfRange, index);
      {#ENDIF}
      if assigned(friend_OnModified)
        then friend_OnModified(opExtraction, Index, fItems[Index]);
      result := inherited AtExtract(Index);
    end;

end.

