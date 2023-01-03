unit Encryption;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs,
  DCPrc4, DCPsha512, Base64,
  AppDb;

Type

  { TEncryptDecrypt }

  TEncryptDecrypt = Class(TAppDatabase)
    private
      FEncryDecry, FSalt : String;
      function  Encode_String_Base64(Text : String) : String;
      function  Decode_String_Base64(Text : String) : String;

    public
      constructor Create(aText : String); overload;
      destructor Destroy; override;
      function GenerateSalt: String;

      function  Encrypt_String(Text, aSalt : String) : String;
      function  Decrypt_String(Text, aSalt : String) : String;

      function HashString(aString, aSalt : String) : String;
      function VerifyPassword(pwdPlain, pwdEncrypted, aSalt: String) : Boolean;

      Property Salt       : String read FSalt write FSalt;
  end;

const
  USER_NAMETXT = '-!Quercus7Salvia10_';

implementation

{ TEncryptDecrypt }

function TEncryptDecrypt.Encode_String_Base64(Text: String): String;
begin
  Result := EncodeStringBase64(Text);
end;

function TEncryptDecrypt.Decode_String_Base64(Text: String): String;
begin
  Result := DecodeStringBase64(Text);
end;

constructor TEncryptDecrypt.Create(aText : String);
const
  _ADD = 'API_manager';
begin
//  inherited;
  FEncryDecry := aText + USER_NAMETXT+ _ADD;
end;

destructor TEncryptDecrypt.Destroy;
begin
  inherited Destroy;
end;

function TEncryptDecrypt.GenerateSalt: String;
var
  aSalt : String;
begin
  aSalt := TGUID.NewGuid.ToString();
  aSalt := StringReplace(aSalt, '{', '', [rfReplaceAll]);
  aSalt := StringReplace(aSalt, '}', '', [rfReplaceAll]);
  aSalt := StringReplace(aSalt, '-', '', [rfReplaceAll]);
  Result := aSalt;
end;

function TEncryptDecrypt.Encrypt_String(Text, aSalt: String): String;
var
  Cipher : TDCP_rc4;
begin
  Result := '';
  Cipher:= TDCP_rc4.Create(nil);
  Cipher.InitStr(copy(aSalt, 0, 5)+ FEncryDecry, TDCP_sha512);
  Result := Cipher.EncryptString(Text);
  Result := Encode_String_Base64(Result);;
  Cipher.Burn;
  Cipher.Free;
end;

function TEncryptDecrypt.Decrypt_String(Text, aSalt: String): String;
var
  Cipher : TDCP_rc4;
begin
  Cipher:= TDCP_rc4.Create(nil);
  Cipher.InitStr(copy(aSalt, 0, 5)+ FEncryDecry, TDCP_sha512);

  if Text = '' then  // Empty value is not allowed
    Result := ''
  else begin
    Result := Decode_String_Base64(Text);
    Result := Cipher.DecryptString(Result);
  end;

  Cipher.Burn;
  Cipher.Free;
end;

function TEncryptDecrypt.HashString(aString, aSalt: String): String;
var
  Hash : TDCP_sha512;
  Digest: array[0..64] of byte;  // sha256 produces a 256bit digest (32bytes) 256/8=32
  i: integer;
  HashedString: string;
begin
  //Digest[0] := 0;
  if (aString <> '') and (salt <> '') then begin
    Hash:= TDCP_sha512.Create(nil);  // create the hash
    Hash.Init;                       // initialize it
    Hash.UpdateStr(salt+aString);
    Hash.Final(Digest);              // produce the digest
    Hash.Free;
    HashedString:= '';
      for i:= 0 to 50 do begin
        HashedString := HashedString + IntToHex(Digest[i],2);
      end;

    aString := HashedString;
    Result := aString;
  end
  else
    Result := '';
end;

function TEncryptDecrypt.VerifyPassword(pwdPlain, pwdEncrypted, aSalt: String): Boolean;
var
  computedPwdHash : String;
begin
  if (salt <> '') and
     (pwdEncrypted <> '') and
     (pwdPlain <> '') then
    begin
      computedPwdHash := HashString(pwdPlain, Salt);

      if (computedPwdHash = pwdEncrypted) then
        begin
          Result := True;
        end
      else
        begin
          Result := False;
        end;
    end
  else
  begin
    MessageDlg('Fout', 'Wachtwoord of Salt bevat geen waarde.', mtError, [mbOK],0);
    Result := False;
  end;
end;



end.

