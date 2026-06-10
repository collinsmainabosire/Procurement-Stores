table 50105 "Qualification Master"
{
    Caption = 'Qualification Master';
    DataClassification = ToBeClassified;


    // This is a master table - stores ALL possible qualifications
    // Like a reference data table


    fields
    {
        field(1; "Qualification ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(2; "Qualification Name"; Text[100])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Qualification Name" = '' then
                    Error('Qualification Name is required');
            end;
        }

        field(3; "Description"; Text[500])
        {
            DataClassification = ToBeClassified;
        }

        field(4; "Category"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Academic","Professional","Certification","Other";
            OptionCaptionML = ENU = 'Academic,Professional,Certification,Other';
        }

        field(5; "Level"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Entry","Intermediate","Advanced","Expert";
            OptionCaptionML = ENU = 'Entry,Intermediate,Advanced,Expert';
        }

        field(6; "Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Active","Inactive";
            InitValue = "Active";
        }

        field(7; "Created Date"; DateTime)
        {
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Qualification ID")
        {
            Clustered = true;
        }

        key(Name; "Qualification Name")
        {
            Unique = true;
        }
    }

    trigger OnInsert()
    begin
        "Qualification ID" := GenerateQualificationID();
        "Created Date" := CurrentDateTime;
    end;

    local procedure GenerateQualificationID(): Code[20]
    var
        LastQual: Record "Qualification Master";
        NewID: Integer;
    begin
        LastQual.SetCurrentKey("Qualification ID");
        if LastQual.FindLast() then
            NewID := StrToInt(CopyStr(LastQual."Qualification ID", 5)) + 1
        else
            NewID := 1;

        exit('QUAL-' + PadStr(Format(NewID), 6, '0'));
    end;
}