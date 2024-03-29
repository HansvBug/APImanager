unit Treeview_utils;

{$mode ObjFPC}{$H+}



interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls;

var
  FSearchCounter, FSearchNext : Integer;
  SearchResult : array of integer;

  function GetNodeByText(ATrv : TTreeView; AValue:String) : Integer;
  procedure SearchNextTrv(ATrv : TTreeView);

implementation

function GetNodeByText(ATrv: TTreeView; AValue: String) : Integer;
var
   i: Integer;
   iItem : String;
begin
  FSearchCounter := 0;
  ATrv.ClearSelection();

  if ATrv.Items.Count = 0 then Exit;

  for i := 0 to ATrv.Items.Count - 1 do begin
    iItem := ATrv.Items[i].Text;

    if pos(AValue, iItem)>=1 then begin  //x:=pos(substring,string);
      setlength(SearchResult, FSearchCounter+1);
      ATrv.Selected := ATrv.Items[i];
      ATrv.Items[i].Expanded := true; // expand the found node.

      SearchResult[FSearchCounter] := ATrv.Items[i].AbsoluteIndex;  // create a list with selected nodes indexes
      Inc(FSearchCounter);
    end;
  end;
  FSearchNext := 0;  // used for search next

  Result := FSearchCounter;
end;

procedure SearchNextTrv(ATrv: TTreeView);
var
  i : Integer;
  Node : TTreeNode;
begin
  if (length(SearchResult) >= 1) and (length(SearchResult) <> FSearchNext) then begin
    i := SearchResult[FSearchNext];
  end;

  for Node in ATrv.Items do begin
    if Node.AbsoluteIndex = i then begin
      ATrv.ClearSelection();
      Node.Selected := True;
      Inc(FSearchNext);

      if length(SearchResult) = FSearchNext then begin
        FSearchNext := 0;
      end;

      break;
    end;
  end;
end;



end.

