unit ApiRequest;

//https://wiki.freepascal.org/fcl-json

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, fphttpclient, ComCtrls, fpjson, StrUtils, StdCtrls,
  appdbFQ;


type

  { TApiRequest }

  TApiRequest = class(TObject)
    private
      function JsonSearchPath(aText : String) : String;

    public
      ApiRequestData : array of ApiObjectData;
      FieldNames : array of String;

      Trv: TTreeView;
      constructor Create; overload;
      destructor  Destroy; override;

      function ReadURLGet : string;  // Get request
      function ReadURLPost : string; // Post request

      procedure ShowJSONData(AParent : TTreeNode; Data : TJSONData);
      procedure ExpandTreeNodes(Nodes: TTreeNodes; Level: Integer);
      function FormatJsonData(json : TJSONData) : String;
      procedure GetJsonData(aTrv : TTreeView; StatusBar : TStatusBar; aMemo : TMemo);
      procedure GetJsonTextFile(aTrv : TTreeView; StatusBar : TStatusBar; SourceMemo, DestMemo : TMemo);
      function GetExternalIPAddress: string;


  end;


Resourcestring

  SCaption = 'JSON Viewer';
  SEmpty   = 'Empty document';
  SArray   = 'Array (%d elements)';
  SObject  = 'Object (%d members)';
  SNull    = 'null';

implementation

uses Form_Main, RegExpr {extrernalIPadress};

{ TApiRequest }

constructor TApiRequest.Create();
begin
  inherited;
  SetLength(ApiRequestData, 1);
  SetLength(FieldNames, 0);
  //...
end;

destructor TApiRequest.Destroy;
begin
  //...
  inherited Destroy;
end;

function TApiRequest.ReadURLGet: string;
var
  Client: TFPHttpClient;
  respons : String;
  Params : string;
begin
  Client := TFPHttpClient.Create(nil);

  with Client do
  try
    if ApiRequestData[0].Authentication then begin
      UserName := ApiRequestData[0].AuthenticationUserName;
      Password := ApiRequestData[0].AuthenticationPassword;
    end;

    // Search if the URL needs a Token => [Token]
    if pos('[Token]', ApiRequestData[0].Url) > 0 then begin
      ApiRequestData[0].Url := StringReplace(ApiRequestData[0].Url, '[Token]', ApiRequestData[0].Token, [rfIgnoreCase]);
    end
    else if pos('[token]', ApiRequestData[0].Url {Url}) > 0 then begin
      ApiRequestData[0].Url := StringReplace(ApiRequestData[0].Url, '[token]', ApiRequestData[0].Token, [rfIgnoreCase]);
    end;

    if ApiRequestData[0].Authentication then begin
      UserName := ApiRequestData[0].AuthenticationUserName;
      Password := ApiRequestData[0].AuthenticationPassword;

      respons:= Get(ApiRequestData[0].Url);
    end
    else begin
      respons:= Get(ApiRequestData[0].Url);
    end;
  finally
    RequestBody.Free;
    Client.Free;
  end;
  result := respons;
end;

function TApiRequest.ReadURLPost: string;
var
  Client: TFPHttpClient;
  respons : String;
  Params : string;
begin
  Client := TFPHttpClient.Create(nil);

  with Client do
  try
    if ApiRequestData[0].Authentication then begin
      UserName := ApiRequestData[0].AuthenticationUserName;
      Password := ApiRequestData[0].AuthenticationPassword;
    end;

    // Search if the URL needs a Token => [Token]
    if pos('[Token]', ApiRequestData[0].Url) > 0 then begin
      ApiRequestData[0].Url := StringReplace(ApiRequestData[0].Url, '[Token]', ApiRequestData[0].Token, [rfIgnoreCase]);
    end
    else if pos('[token]', ApiRequestData[0].Url {Url}) > 0 then begin
      ApiRequestData[0].Url := StringReplace(ApiRequestData[0].Url, '[token]', ApiRequestData[0].Token, [rfIgnoreCase]);
    end;

    AddHeader('Content-Type','application/json; charset=UTF-8');
    AddHeader('Accept', 'application/json');
    AllowRedirect := true;
    Params := ApiRequestData[0].Request_body;
    RequestBody := TRawByteStringStream.Create(Params);

    respons := Post(ApiRequestData[0].Url);

  finally
    RequestBody.Free;
    Client.Free;
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
//  Counter := 1;


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
        For I := 0 to Data.Count - 1 do
          If Data.JSONtype = jtArray then begin
            Strlist.AddObject(IntToStr(I),Data.items[i]);
          end
          else begin
            Strlist.AddObject(TJSONObject(Data).Names[i],Data.items[i]);
            FrmMain.Logging.WriteToLogAndFlushDebug(Strlist[i] + ': ');  // Write field names  mowet naar een tstringlist

            SetLength(FieldNames, Length(FieldNames)+1);
            FieldNames[Length(FieldNames)-1] := Strlist[i];
          end;
        //S.Sort;


        For I := 0 to Strlist.Count - 1 do begin
          Node_2 := Trv.Items.AddChild(Node_1 , Strlist[i]);
          JsonData := TJSONData(Strlist.Objects[i]);

          //Node_2.ImageIndex := ImageTypeMap[JsonData.JSONType];
          //Node_2.SelectedIndex := ImageTypeMap[JsonData.JSONType];
          ShowJSONData(Node_2 , JsonData);

          if Strlist.Objects[i].ToString = 'TJSONString' then begin
            FrmMain.Logging.WriteToLogAndFlushDebug(Strlist[i]);

            SetLength(FieldNames, Length(FieldNames)+1);
            FieldNames[Length(FieldNames)-1] := Strlist[i];
          end;
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
  x : Integer;
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
      if ApiRequestData[0].HTTP_Methode = 'Get' then
        JsonText := ReadURLGet
      else
        JsonText := ReadURLPost;

      jData  := GetJSON(JsonText);

      PagingSearchText := JsonSearchPath(ApiRequestData[0].Paging_searchtext);  // Create search path. Search for a specific text in the json which gives the amount of pages.

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

          if ApiRequestData[0].HTTP_Methode = 'Get' then
            JsonText := ReadURLGet
          else
            JsonText := ReadURLPost;

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
  end
  else begin
    FrmMain.Logging.WriteToLogInfo('Betreft géén query maar een folder. Kan geen https request uitvoeren vanuit een folder.');
  end;
end;

procedure TApiRequest.GetJsonTextFile(aTrv: TTreeView; StatusBar: TStatusBar; SourceMemo, DestMemo: TMemo);
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

function TApiRequest.GetExternalIPAddress: string;
var
  HTTPClient: TFPHTTPClient;
  IPRegex: TRegExpr;
  RawData: string;
begin
  try
    HTTPClient := TFPHTTPClient.Create(nil);
    IPRegex := TRegExpr.Create;
    try
      //returns something like:
      {
                <html><head><title>Current IP Check</title></head><body>Current IP Address: 44.151.191.44</body></html>
      }
      RawData := HTTPClient.Get('http://checkip.dyndns.org');
      // adjust for expected output; we just capture the first IP address now:
      IPRegex.Expression := '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b';
                       //or '\b(?:\d{1,3}\.){3}\d{1,3}\b'
      if IPRegex.Exec(RawData) then
        Result := IPRegex.Match[0]
      else
        Result := 'Got invalid results getting external IP address. Details:'
          + LineEnding + RawData;
    except
      on E: Exception do
      begin
        Result := 'Error retrieving external IP address: ' + E.Message;
      end;
    end;
  finally
    HTTPClient.Free;
    IPRegex.Free;
  end;
end;

end.

