table 50115 "Online User"
{
    Caption = 'Online Users';
    // This tracks logged-in users on the web portal
    // Used for security and activity monitoring

    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Session ID"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(2; "Applicant ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Applicant"."Applicant ID";
        }

        field(3; "Email"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(4; "Full Name"; Text[200])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(5; "Login Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(6; "Last Activity Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(7; "Logout Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(8; "IP Address"; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(9; "Browser"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Chrome, Firefox, Safari, Edge, etc.
        }

        field(10; "Device Type"; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Desktop, Tablet, Mobile
        }

        field(11; "Operating System"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(12; "Is Active"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            InitValue = true;
        }

        field(13; "Session Duration (Minutes)"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(14; "Pages Visited"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(15; "Last Page Visited"; Text[200])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(16; "Logout Reason"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "User Initiated","Session Timeout","Account Locked","Manual Logout","Admin Logout";
            OptionCaptionML = ENU = 'User Initiated,Session Timeout,Account Locked,Manual Logout,Admin Logout';
        }

        field(17; "Timezone"; Text[50])
        {
            DataClassification = ToBeClassified;
        }

        field(18; "Location"; Text[200])
        {
            DataClassification = ToBeClassified;
            // City, Country (from IP geolocation)
        }
    }

    keys
    {
        key(PK; "Session ID")
        {
            Clustered = true;
        }

        key(Applicant; "Applicant ID", "Login Date")
        {
        }

        key(Active; "Is Active", "Last Activity Date")
        {
            // Find active sessions
        }
    }

    trigger OnInsert()
    begin
        "Session ID" := GenerateSessionID();
    end;

    local procedure GenerateSessionID(): Code[50]
    var
        RandomGuid: Guid;
    begin
        RandomGuid := CreateGuid();
        exit(Format(RandomGuid).Replace('-', ''));
    end;

    procedure UpdateLastActivity()
    begin
        "Last Activity Date" := CurrentDateTime;
        "Pages Visited" += 1;
        Modify();
    end;

    procedure EndSession(LogoutReason: Option)
    begin
        "Is Active" := false;
        "Logout Date" := CurrentDateTime;
        "Logout Reason" := LogoutReason;
        "Session Duration (Minutes)" :=
            ((("Logout Date" - "Login Date") / 60000)); // Convert to minutes
        Modify();
    end;
}