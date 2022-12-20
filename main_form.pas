unit Main_Form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  fphttpclient, fpjson, jsonparser, ssockets, fpopenssl, sslsockets, opensslsockets,
  TypInfo;
{
  Download and extract the libeay32.dll and ssleay32.dll files from https://indy.fulgan.com/SSL/ into project folder.
  AMD add opensslsockets unit.
}

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    MemoFormatted: TMemo;
    TreeView1: TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TreeView1SelectionChanged(Sender: TObject);
  private
    function ReadURLGet(url:string):string;
    function FormatJsonData(json : TJSONData) : String;

//    function ShowNode(AParent: TTreeNode; AName : String; J: TJSONData) : TTreeNode;
    function NewElement(P : TJSONData;PT : TTreeNode) : TJSONData;
    procedure ShowJSONData(AParent : TTreeNode; Data : TJSONData);
    procedure ExpandTreeNodes(Nodes: TTreeNodes; Level: Integer);

  public

  end;

type
  JsonObjectDataPtr = ^ Objdata;
  TJsonObjectData = record
    aObjDataId : Integer;
    aObjDataString : String;

  end;

var
  Form1: TForm1;
  //TestRecord : TJsonObjectData;
  TestRecord :  JsonObjectDataPtr;
  TestRecordArray : array of TJsonObjectData;

Resourcestring

  SCaption = 'JSON Viewer';
  SEmpty   = 'Empty document';
  SArray   = 'Array (%d elements)';
  SObject  = 'Object (%d members)';
  SNull    = 'null';



implementation

{$R *.lfm}

{ TForm1 }

//https://wiki.freepascal.org/fcl-json


procedure TForm1.Button1Click(Sender: TObject);
var
  listitemsjson:string;
  jData : TJSONData;
   Node: TTreeNode;
begin
  listitemsjson := ReadURLGet(Edit1.Text);
  jData  := GetJSON(listitemsjson);

  TreeView1.Items.Clear;
  Treeview1.Items.Add (nil,'Root Node');

  Node := Treeview1.Items[0];
  ShowJSONData(Node,jData);

  ExpandTreeNodes(TreeView1.Items, 2);  // Expand the first level of the treeview
  memoFormatted.Text:=FormatJsonData(jData);

    jData.Free;
end;

function TForm1.ReadURLGet(url: string): string;
var
  respons : String;
  b64decoded, username , password : String;
begin

  with TFPHTTPClient.Create(nil) do
  try
    //UserName := 'bf17ad8d3ef89a0a5bad3c48133d464c';
    //Password := '790c1f926d356ba17b66c9f2c0dfea7a';
    respons:= Get(url);
  finally
    Free;

  end;
  result := respons;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.TreeView1SelectionChanged(Sender: TObject);
begin
     if (Sender is TTreeView) and assigned(TTreeView(Sender).Selected) then //<---- check that a node is selected
     begin
       Edit2.Text := (TTreeView(Sender).Selected.Text);

     end;
end;

procedure TForm1.ShowJSONData(AParent: TTreeNode; Data: TJSONData);
var
  N,N2 : TTreeNode;
  I : Integer;
  D : TJSONData;
  C : String;
  S : TStringList;
begin
  Case Data.JSONType of
    jtArray,
    jtObject:
      begin
        If (Data.JSONType=jtArray) then
          C:=SArray
        else
          C:=SObject;

        C:=Format(C,[Data.Count]); // format de string
        S:=TstringList.Create;

        try
          setLength(TestRecordArray, Data.Count);  // stel de array in



          For I:=0 to Data.Count-1 do
            If Data.JSONtype=jtArray then
              S.AddObject(IntToStr(I),Data.items[i])
            else
              S.AddObject(TJSONObject(Data).Names[i],Data.items[i]);

          //S.Sort;
          For I:=0 to S.Count-1 do
            begin
              N2:=Treeview1.Items.AddChild(N,S[i]);
              D:=TJSONData(S.Objects[i]);

              new(TestRecord);
              TestRecord^.aObjDataId:=i;
              TestRecord^.aObjDataString:='test';
              TestRecordArray[i] :=  TestRecord; // Add the record to an arry of records.

              N2.Data:=TestRecordArray[i].aObjDataId;  //is een pointer naar een object of iets dergelijks

              //N2.ImageIndex:=ImageTypeMap[D.JSONType];
              //N2.SelectedIndex:=ImageTypeMap[D.JSONType];
              ShowJSONData(N2,D);
            end
        finally
          S.Free;
        end;
      end;
      jtNull:
      C:=SNull;
    else
      C:=Data.AsString;
//    if Options.FQuoteStrings and  (Data.JSONType=jtString) then
      C:='"'+C+'"';
    end;
  If Assigned(N) then
    begin
      If N.Text='' then
        N.Text:=C
      else
        N.Text:=N.Text+': '+C;

      //N.ImageIndex:=ImageTypeMap[Data.JSONType];
      //N.SelectedIndex:=ImageTypeMap[Data.JSONType];
      N.Data:=Data;
    end;
end;

procedure TForm1.ExpandTreeNodes(Nodes: TTreeNodes; Level: Integer);
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

function TForm1.FormatJsonData(json: TJSONData) : String;
var
  s : String;
begin
  s :=   json.FormatJSON;
  result := s; //json.FormatJSON;  // "pretty print"
end;

{function TForm1.ShowNode(AParent: TTreeNode; AName: String; J: TJSONData
  ): TTreeNode;
Var
  O : TJSONObject;
  I : Integer;
begin
  if Not (J.JSONType in [jtArray,jtObject]) then
    AName:=AName + ' : ' +J.AsJSON;

  Result := TreeView1.Items.AddChild(AParent,AName);
  Result.Data:=J;
  If (J.Count<>0) then
    begin
      if (j is TJSONObject) then
        begin
          O:=J as TJSONObject;
          For I:=0 to O.Count-1 do
            ShowNode(Result,O.Names[i],O.Items[i]);
        end
      else if (j is TJSONArray) then
        begin
          For I:=0 to J.Count-1 do
            ShowNode(Result,IntToStr(I),J.Items[i]);
        end;
    end;
end;}

function TForm1.NewElement(P: TJSONData; PT: TTreeNode): TJSONData;
{Var
  NT : TJSonType;
  EN,EV : String;
  TN : TTreeNode;
  I : Integer;}
begin
{  Result:=Nil;
  With Form1.Create(Self) do
  try
    NeedName:=P is TJSONObject;
    If (ShowModal<>mrOK) then
      Exit;
    NT:=DataType;
    EN:=ElementName;
    EV:=ElementValue;
  finally
    Free;
  end;}

end;







end.

