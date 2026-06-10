table 50114 Onboarding
{
    Caption = 'Onboarding';
    // HEADER TABLE for onboarding
    // Created when offer is accepted

    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Onboarding ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(2; "Application ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Application"."Application ID";
        }

        field(3; "Offer ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Offer Letter"."Offer ID";
        }

        field(4; "Applicant ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(5; "Applicant Name"; Text[200])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(6; "Applicant Email"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(7; "Job Title"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(8; "Department"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(9; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(10; "Onboarding Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Initiated","Documents Pending","Background Check In Progress","System Access Pending","Orientation Scheduled","First Day","In Progress","Completed";
            OptionCaptionML = ENU = 'Initiated,Documents Pending,Background Check In Progress,System Access Pending,Orientation Scheduled,First Day,In Progress,Completed';
            InitValue = "Initiated";
        }

        field(11; "Onboarding Manager"; Text[100])
        {
            DataClassification = ToBeClassified;
            // Person coordinating onboarding
        }

        field(12; "Onboarding Manager Email"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(13; "Assigned Equipment"; Text[500])
        {
            DataClassification = ToBeClassified;
            // Laptop, Phone, Keys, Badge, etc.
        }

        field(14; "IT Setup Completed"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(15; "IT Setup Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }

        field(16; "Training Assigned"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(17; "Training Completed"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(18; "Orientation Completed"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(19; "Documents Received"; Boolean)
        {
            DataClassification = ToBeClassified;
            // Tax forms, ID, emergency contact, etc.
        }

        field(20; "Background Check Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Required","Initiated","Pending","Passed","Failed","Pending Review";
        }

        field(21; "Background Check Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(22; "Onboarding Comments"; Text[1000])
        {
            DataClassification = ToBeClassified;
        }

        field(23; "Expected Completion Date"; Date)
        {
            DataClassification = ToBeClassified;
            // 30 days from start
            trigger OnValidate()
            begin
                "Expected Completion Date" := CalcDate('+30D', "Start Date");
            end;
        }

        field(24; "Actual Completion Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(25; "Is Completed"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(26; "Employee ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Generated employee ID once onboarded
        }

        field(27; "Created Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(28; "Checklist Items Completed"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(29; "Total Checklist Items"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(30; "Completion %"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            DecimalPlaces = 0;
        }
    }

    keys
    {
        key(PK; "Onboarding ID")
        {
            Clustered = true;
        }

        key(Status; "Onboarding Status", "Start Date")
        {
        }

        key(Applicant; "Applicant ID")
        {
        }
    }

    trigger OnInsert()
    begin
        "Onboarding ID" := GenerateOnboardingID();
        "Created Date" := CurrentDateTime;
    end;

    local procedure GenerateOnboardingID(): Code[20]
    var
        LastOnboarding: Record "Onboarding";
        NewID: Integer;
    begin
        LastOnboarding.SetCurrentKey("Onboarding ID");

        if LastOnboarding.FindLast() then begin
            Evaluate(
                NewID,
                CopyStr(LastOnboarding."Onboarding ID", 5)
            );
            NewID := NewID + 1;
        end else
            NewID := 1;

        exit('ONB-' + PadStr(Format(NewID), 6, '0'));
    end;

    procedure CompleteOnboarding()
    begin
        "Onboarding Status" := "Onboarding Status"::Completed;
        "Actual Completion Date" := Today;
        "Is Completed" := true;

        // TODO: Generate Employee ID
        // TODO: Create Employee record in BC Employees table

        Modify();
        Message('Onboarding completed. Employee ID: %1', "Employee ID");
    end;

    var
        Onboarding: Record "Onboarding";

    procedure CalcCompletionPercentage()
    begin
        if "Total Checklist Items" > 0 then
            "Completion %" :=
                ("Checklist Items Completed" / "Total Checklist Items") * 100
        else
            "Completion %" := 0;
    end;
}

