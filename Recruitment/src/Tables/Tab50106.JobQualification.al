table 50106 "Job Qualification"
{
    Caption = 'Job Qualification';

    // This is a LINE table
    // Links jobs to their required qualifications
    // Think of it like Sales Line items

    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Vacancy ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Vacancy"."Vacancy ID";

            trigger OnValidate()
            begin
                if "Vacancy ID" = '' then
                    Error('Vacancy ID is required');
            end;
        }

        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Auto-incremented for each line
        }

        field(3; "Qualification ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Qualification Master"."Qualification ID";

            trigger OnValidate()
            begin
                if "Qualification ID" <> '' then begin
                    QualificationRec.Get("Qualification ID");
                    "Qualification Name" := QualificationRec."Qualification Name";
                end;
            end;
        }

        field(4; "Qualification Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(5; "Is Required"; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = true;
        }

        field(6; "Minimum Level"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Entry","Intermediate","Advanced","Expert";
        }

        field(7; "Preference Order"; Integer)
        {
            DataClassification = ToBeClassified;
            // Priority: 1 is most important
        }
    }

    keys
    {
        key(PK; "Vacancy ID", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Line No." = 0 then
            "Line No." := GetNextLineNo();
    end;

    local procedure GetNextLineNo(): Integer
    var
        JobQualification: Record "Job Qualification";
    begin
        JobQualification.SetRange("Vacancy ID", "Vacancy ID");
        if JobQualification.FindLast() then
            exit(JobQualification."Line No." + 10000)
        else
            exit(10000);
    end;

    var
        QualificationRec: Record "Qualification Master";
}