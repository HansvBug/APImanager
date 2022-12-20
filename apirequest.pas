unit ApiRequest;

//https://wiki.freepascal.org/fcl-json

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, ComCtrls, fpjson, StrUtils;

type

  { TApiRequest }

  TApiRequest = class(TObject)
    private
    public
      Trv: TTreeView;
     constructor Create; overload;
      destructor  Destroy; override;

      function ReadURLGet(Url, ApiToken, Auth_User, Auth_Pwd : string; Authentication : Boolean):string;
      procedure ShowJSONData(AParent : TTreeNode; Data : TJSONData);
      procedure ExpandTreeNodes(Nodes: TTreeNodes; Level: Integer);
      function FormatJsonData(json : TJSONData) : String;
  end;


Resourcestring

  SCaption = 'JSON Viewer';
  SEmpty   = 'Empty document';
  SArray   = 'Array (%d elements)';
  SObject  = 'Object (%d members)';
  SNull    = 'null';

implementation

{ TApiRequest }

constructor TApiRequest.Create();
begin
  inherited;
  //..
end;

destructor TApiRequest.Destroy;
begin
  //..
  inherited Destroy;
end;

function TApiRequest.ReadURLGet(Url, ApiToken, Auth_User, Auth_Pwd : string; Authentication : Boolean): string;
var
  respons : String;
begin
  with TFPHTTPClient.Create(nil) do
  try
    if Authentication then begin
      UserName := Auth_User;
      Password := Auth_Pwd;
    end;

    // Search if the URL needs a Token => $(Token)
    if pos('$(Token)', Url) > 0 then begin
      Url := StringReplace(Url, '$(Token)', ApiToken, [rfIgnoreCase]);
    end;

    if Authentication then begin
      UserName := Auth_User;
      Password :=  Auth_Pwd;
      respons:= Get(url);
    end
    else begin
      respons:= Get(url);
    end;
  finally
    Free;
  end;
  result := respons;
end;

procedure TApiRequest.ShowJSONData(AParent: TTreeNode; Data: TJSONData);
// source: C:\lazarus\tools\jsonviewer\*.*
var
  N,N2 : TTreeNode;
  I : Integer;
  D : TJSONData;
  C : String;
  S : TStringList;
begin
  if AParent <> Nil then
    N := AParent
  else
    N:=Trv.Items.AddChild(AParent,'');

  Case Data.JSONType of
    jtArray,
    jtObject:
      begin
        If (Data.JSONType=jtArray) then
          C := SArray
        else
          C:=SObject;

        C := Format(C,[Data.Count]); // format de string
        S := TstringList.Create;

        try
//          setLength(TestRecordArray, Data.Count);  // stel de array in

          For I := 0 to Data.Count - 1 do
            If Data.JSONtype = jtArray then
              S.AddObject(IntToStr(I),Data.items[i])
            else
              S.AddObject(TJSONObject(Data).Names[i],Data.items[i]);

          //S.Sort;
          For I := 0 to S.Count - 1 do begin
            N2 := Trv.Items.AddChild(N,S[i]);
            D := TJSONData(S.Objects[i]);

  //          new(TestRecord);
//            TestRecord^.aObjDataId:=i;
//            TestRecord^.aObjDataString:='test';
//            TestRecordArray[i] :=  TestRecord; // Add the record to an arry of records.

//            N2.Data:=TestRecordArray[i].aObjDataId;  //is een pointer naar een object of iets dergelijks

            //N2.ImageIndex:=ImageTypeMap[D.JSONType];
            //N2.SelectedIndex:=ImageTypeMap[D.JSONType];
            ShowJSONData(N2,D);
          end
        finally
          S.Free;
        end;
      end;
      jtNull:
      C := SNull;
    else
      C := Data.AsString;
//    if Options.FQuoteStrings and  (Data.JSONType=jtString) then
      C := '"' + C + '"';
    end;
  If Assigned(N) then begin
    If N.Text = '' then
      N.Text := C
    else
      N.Text:=N.Text+': '+C;

    //N.ImageIndex:=ImageTypeMap[Data.JSONType];
    //N.SelectedIndex:=ImageTypeMap[Data.JSONType];
    N.Data := Data;
  end;
end;

procedure TApiRequest.ExpandTreeNodes(Nodes: TTreeNodes; Level: Integer);
var
  I: Integer;
begin
  Nodes.BeginUpdate;
    try
      for I := 0 to Nodes.Count - 1 do
        if Nodes[I].Level < Level then
          Nodes[I].Expand(False);
    finally
      Nodes.EndUpdate;
    end;
end;




function TApiRequest.FormatJsonData(json: TJSONData): String;
var
  s : String;
begin
  s :=   json.FormatJSON;
  result := s; //json.FormatJSON;  // "pretty print"
end;

end.

