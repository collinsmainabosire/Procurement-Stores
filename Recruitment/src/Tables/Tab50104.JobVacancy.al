table 50104 "Job Vacancy"
{
    Caption = 'Job Vacancy';
    DataClassification = ToBeClassified;


    fields
    {
        field(1; "Vacancy ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(2; "Job Title"; Text[100])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Job Title" = '' then
                    Error('Job Title is required');
            end;
        }

        field(3; "Department"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('DEPARTMENT'));
            // This links to BC's built-in dimension table
            // Real-world: HR, IT, Finance, etc.
        }

        field(4; "Description"; Text[2000])
        {
            DataClassification = ToBeClassified;
            // Long text for job description
        }

        field(5; "Number of Positions"; Integer)
        {
            DataClassification = ToBeClassified;
            MinValue = 1;
        }

        field(6; "Salary From"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0;
            MinValue = 0;
        }

        field(7; "Salary To"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0;
            MinValue = 0;

            trigger OnValidate()
            begin
                // Ensure "Salary To" >= "Salary From"
                if ("Salary To" > 0) and ("Salary From" > 0) then
                    if "Salary To" < "Salary From" then
                        Error('Salary To must be greater than or equal to Salary From');
            end;
        }

        field(8; "Currency Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Currency.Code;
            InitValue = 'USD';
        }

        field(9; "Posted Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(10; "Closing Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                // Ensure closing date is in future
                if "Closing Date" < Today then
                    Error('Closing date must be in the future');
            end;
        }

        field(11; "Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Draft","Published","Closed","On Hold","Archived";
            OptionCaptionML = ENU = 'Draft,Published,Closed,On Hold,Archived';
            InitValue = "Draft";
        }

        field(12; "Experience Required"; Text[100])
        {
            DataClassification = ToBeClassified;
            // e.g., "3-5 years"
        }

        field(13; "Employment Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Full-Time","Part-Time","Contract","Temporary","Internship";
            OptionCaptionML = ENU = 'Full-Time,Part-Time,Contract,Temporary,Internship';
        }

        field(14; "Location"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(15; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(16; "Created Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(17; "Modified By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(18; "Modified Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(19; "Active Applicants Count"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Calculated field - count of applications
        }

        field(20; "Is Open"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;


        }
    }

    keys
    {
        key(PK; "Vacancy ID")
        {
            Clustered = true;
        }

        key(Status; "Status", "Posted Date")
        {
        }

        key(Closing; "Closing Date", "Is Open")
        {
        }
    }

    trigger OnInsert()
    begin
        "Vacancy ID" := GenerateVacancyID();
        "Posted Date" := CurrentDateTime;
        "Created By" := UserId;
        "Created Date" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Modified By" := UserId;
        "Modified Date" := CurrentDateTime;
    end;

    local procedure GenerateVacancyID(): Code[20]
    var
        LastVacancy: Record "Job Vacancy";
        NewID: Integer;
    begin
        LastVacancy.SetCurrentKey("Vacancy ID");

        if LastVacancy.FindLast() then begin
            Evaluate(NewID, CopyStr(LastVacancy."Vacancy ID", 5));
            NewID := NewID + 1;
        end else
            NewID := 1;

        exit('VAC-' + PadStr(Format(NewID), 6, '0'));
    end;

    procedure GetDaysUntilClosing(): Integer
    begin
        if "Closing Date" >= Today then
            exit("Closing Date" - Today)
        else
            exit(-1); // Already closed
    end;

    procedure IsApplicationOpen(): Boolean
    begin
        exit(("Status" = "Status"::Published) and ("Closing Date" >= Today));
    end;
}