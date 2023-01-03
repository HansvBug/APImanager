unit ApiRequest;

//https://wiki.freepascal.org/fcl-json

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, fphttpclient, ComCtrls, fpjson, StrUtils, StdCtrls,
  appdbFQ;

//ComCtrls, ExtCtrls,
//  StdCtrls

type

  { TApiRequest }

  TApiRequest = class(TObject)
    private
      function JsonSearchPath(aText : String) : String;
    public
      ApiRequestData : array of ApiObjectData;

      Trv: TTreeView;
      constructor Create; overload;
      destructor  Destroy; override;

      function ReadURLGet(Url, ApiToken, Auth_User, Auth_Pwd : string; Authentication : Boolean):string;
      procedure ShowJSONData(AParent : TTreeNode; Data : TJSONData);
      procedure ExpandTreeNodes(Nodes: TTreeNodes; Level: Integer);
      function FormatJsonData(json : TJSONData) : String;
      procedure GetJsonData(aTrv : TTreeView; StatusBar : TStatusBar; aMemo : TMemo);
      procedure GetJsonTExtFile(aTrv : TTreeView; StatusBar : TStatusBar; SourceMemo, DestMemo : TMemo);

  end;

Resourcestring

  SCaption = 'JSON Viewer';
  SEmpty   = 'Empty document';
  SArray   = 'Array (%d elements)';
  SObject  = 'Object (%d members)';
  SNull    = 'null';

implementation

uses Form_Main;

{ TApiRequest }

constructor TApiRequest.Create();
begin
  inherited;
  SetLength(ApiRequestData,1);
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

    // Search if the URL needs a Token => [Token]
    if pos('[Token]', Url) > 0 then begin
      Url := StringReplace(Url, '[Token]', ApiToken, [rfIgnoreCase]);
    end
    else if pos('[token]', Url) > 0 then begin
      Url := StringReplace(Url, '[token]', ApiToken, [rfIgnoreCase]);
    end;

    FrmMain.Logging.WriteToLogDebug(Url);

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
// source: ...:\lazarus\tools\jsonviewer\*.*
var
  Node_1 , Node_2 : TTreeNode;
  I : Integer;
  JsonData : TJSONData;
  aString : String;
  Strlist : TStringList;
begin
  if AParent <> Nil then
    Node_1 := AParent
  else
    Node_1 := Trv.Items.AddChild(AParent,'');

  Case Data.JSONType of
    jtArray, jtObject:
    begin
      If (Data.JSONType=jtArray) then
        aString := SArray
      else
        aString := SObject;

      aString := Format(aString,[Data.Count]); // format the string, add number of objects
      Strlist := TstringList.Create;

      try
    //          setLength(TestRecordArray, Data.Count);  // stel de array in

        For I := 0 to Data.Count - 1 do
          If Data.JSONtype = jtArray then
            Strlist.AddObject(IntToStr(I),Data.items[i])
          else
            Strlist.AddObject(TJSONObject(Data).Names[i],Data.items[i]);

        //S.Sort;
        For I := 0 to Strlist.Count - 1 do begin
          Node_2 := Trv.Items.AddChild(Node_1 , Strlist[i]);
          JsonData := TJSONData(Strlist.Objects[i]);

    //          new(TestRecord);
    //            TestRecord^.aObjDataId := i;
    //            TestRecord^.aObjDataString := 'test';
    //            TestRecordArray[i] := TestRecord; // Add the record to an arry of records.

    //            Node_2.Data := TestRecordArray[i].aObjDataId;  //is een pointer naar een object of iets dergelijks

          //Node_2.ImageIndex := ImageTypeMap[JsonData.JSONType];
          //Node_2.SelectedIndex := ImageTypeMap[JsonData.JSONType];
          ShowJSONData(Node_2 , JsonData);
        end
      finally
        Strlist.Free;
      end;
    end;

      jtNull:
      aString := SNull;
    else
      aString := Data.AsString;
    // if Options.FQuoteStrings and  (Data.JSONType=jtString) then
      aString := '"' + aString + '"';
    end;  // end case

  If Assigned(Node_1) then begin
    If Node_1.Text = '' then
      Node_1.Text := aString
    else
      Node_1.Text := Node_1.Text+': '+ aString;

    //Node_1.ImageIndex := ImageTypeMap[Data.JSONType];
    //Node_1.SelectedIndex := ImageTypeMap[Data.JSONType];
    Node_1.Data := Data;
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

function TApiRequest.JsonSearchPath(aText: String): String;
var
  A: TStringArray;
  i : Integer;
begin
  if aText <> '' then begin
    A := aText.Split('[,]');
    for i:=0 to Length(A)-1 do begin
      if A[i] <> '' then begin
        if JsonSearchpath = '' then
          JsonSearchpath := A[i]
        else
        JsonSearchpath += '.' + A[i]
      end;
    end;
  end;
  result :=  JsonSearchpath;
end;

procedure TApiRequest.GetJsonData(aTrv: TTreeView;  StatusBar : TStatusBar; aMemo : TMemo);
var
  JsonText, PagingSearchText, RequestUrlExecute : string;
  jData : TJSONData;
  Node: TTreeNode;
  i : Integer;
  PagesTotal : Integer;
  _StatusBar : TStatusBar;
begin
  if StatusBar is TStatusBar then begin
    _StatusBar := TStatusBar(StatusBar);
  end;

  PagesTotal := 0;
  if ( ApiRequestData[0].ObjectType = appdbFQ.Query) and (ApiRequestData[0].Url <> '')  then begin
    _StatusBar.Panels.Items[0].Text := ' Testen API request "' + ApiRequestData[0].Url + '"...';
    Application.ProcessMessages;
    aMemo.Clear;
    aTrv.BeginUpdate;

    try
      JsonText := ReadURLGet(ApiRequestData[0].Url, ApiRequestData[0].Token, ApiRequestData[0].AuthenticationUserName, ApiRequestData[0].AuthenticationPassword, ApiRequestData[0].Authentication);
      jData  := GetJSON(JsonText);

      PagingSearchText := JsonSearchPath(ApiRequestData[0].Paging_searchtext);  // Create search path

      if PagingSearchText <> '' then begin
        if jData.FindPath(PagingSearchText) <> nil then begin
          PagesTotal := JData.GetPath(PagingSearchText).AsInteger;
        end
        else begin
          PagesTotal := jData.GetPath(PagingSearchText).AsInteger;
        end;
      end;

      aTrv.Items.Clear;
      aTrv.Items.Add (nil,'Root Node');
      Node := aTrv.Items[0];
      Trv :=  aTrv;

      // go through all the pages
      if PagesTotal > 1 then begin
        jData.Free;
        ApiRequestData[0].Url += '?page=';          // =======>>>>>>> Let op!, dit is misschien anders bij andere API's. In de gaten houden.
        for i := 1 to PagesTotal do begin
          RequestUrlExecute :=  ApiRequestData[0].Url + IntToStr(i);
          _StatusBar.Panels.Items[0].Text := 'Testen API request "' + RequestUrlExecute + '"...';
          Application.ProcessMessages;

          JsonText := ReadURLGet(RequestUrlExecute, ApiRequestData[0].Token, ApiRequestData[0].AuthenticationUserName, ApiRequestData[0].AuthenticationPassword, ApiRequestData[0].Authentication);
          jData  := GetJSON(JsonText);
          ShowJSONData(Node,jData);
          aMemo.Lines.Add(FormatJsonData(jData));
          jData.Free;
        end;
      end
      else begin
        ShowJSONData(Node,jData);

        aMemo.Lines.Add(FormatJsonData(jData));
        jData.Free;
      end;
    finally
      ExpandTreeNodes(aTrv.Items, 2);  // Expand the first level of the treeview
      aTrv.EndUpdate;
      _StatusBar.Panels.Items[0].Text := '';
      Application.ProcessMessages;
    end;
  end;
end;

procedure TApiRequest.GetJsonTExtFile(aTrv: TTreeView; StatusBar: TStatusBar; SourceMemo, DestMemo: TMemo);
var
  JsonText : string;
  jData : TJSONData;
  Node: TTreeNode;
  _StatusBar : TStatusBar;
begin
  if StatusBar is TStatusBar then begin
    _StatusBar := TStatusBar(StatusBar);
  end;

  _StatusBar.Panels.Items[0].Text := 'Bezig met het openen en formateren van de Jsonfile...';
  Application.ProcessMessages;
  DestMemo.Clear;
  aTrv.BeginUpdate;

  try
    JsonText := SourceMemo.Text;
    jData  := GetJSON(JsonText);

    aTrv.Items.Clear;
    aTrv.Items.Add (nil,'Root Node');
    Node := aTrv.Items[0];
    Trv :=  aTrv;

    ShowJSONData(Node,jData);

    DestMemo.Lines.Add(FormatJsonData(jData));
    jData.Free;
  finally
    ExpandTreeNodes(aTrv.Items, 2);  // Expand the first level of the treeview
    aTrv.EndUpdate;
    _StatusBar.Panels.Items[0].Text := '';
    Application.ProcessMessages;
  end;
end;

end.














