unit appdbFQ;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  PtrApiObject = ^ApiObjectData;
  ApiObjectData = record
    Id                      : Integer;
    Guid                    : String;
    ParentFolder            : String;
    Name                    : String;
    ObjectType              : String;  // Folder, Query
    Url                     : String;
    Description_short       : String;
    Description_long        : String;
    Authentication          : Boolean;
    AuthenticationUserName  : String;
    AuthenticationPassword  : String;
    Salt                    : String;
    Paging_searchtext       : String;
    Paging_number           : Integer;
    Token                   : String;
    Action                  : String; { #todo : Dit moet een enumeratie worden. Insert, delete, update}
    Date_Created            : TDateTime;
    Date_Modified           : TDateTime;
    CreatedBy               : String;
    ModifiedBy              : String;
  end;
  AllApiObjectData = array of  ApiObjectData;

const
 Folder = 'Folder';
 Query = 'Query';
 USER_NAMETXT = '$ThisIsJustAsmallPiece#69';
implementation

end.

