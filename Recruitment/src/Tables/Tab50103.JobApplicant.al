table 50103 "Job Applicant"
{
    Caption = 'Job Applicant';
    DataClassification = ToBeClassified;

    // This is the header table for job applicants
    // Think of it like a master record in BC
    
    // FIELDS SECTION - Define all columns
    fields
    {
        field(1; "Applicant ID"; Code[20])
        {
            // Primary Key - Unique identifier
            // Code[20] = Text with max 20 characters
            // Like an Employee ID
            DataClassification = ToBeClassified;
            Editable = false; // System generates this
            
            trigger OnValidate()
            begin
                // No validation needed for ID
            end;
        }

        field(2; "First Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            
            trigger OnValidate()
            begin
                // Ensure not empty
                if "First Name" = '' then
                    Error('First Name cannot be empty');
            end;
        }

        field(3; "Last Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            
            trigger OnValidate()
            begin
                if "Last Name" = '' then
                    Error('Last Name cannot be empty');
            end;
        }

        field(4; "Email"; Text[100])
        {
            DataClassification = ToBeClassified;
            
            trigger OnValidate()
            var
                EmailRegex: Codeunit Regex;
            begin
                // Basic email validation
                if "Email" <> '' then
                    if not ("Email" like '*@*.%') then
                        Error('Please enter a valid email address');
                
                // Check for duplicates
                if "Email" <> xRec."Email" then begin
                    if JobApplicant.FindSet() then
                        repeat
                            if JobApplicant."Email" = "Email" then
                                Error('This email is already registered');
                        until JobApplicant.Next() = 0;
                end;
            end;
        }

        field(5; "Phone Number"; Text[20])
        {
            DataClassification = ToBeClassified;
            
            trigger OnValidate()
            begin
                if "Phone Number" <> '' then
                    if not ("Phone Number" like '+[0-9]@' or "Phone Number" like '[0-9]@') then
                        Error('Please enter a valid phone number');
            end;
        }

        field(6; "Date of Birth"; Date)
        {
            DataClassification = ToBeClassified;
            
            trigger OnValidate()
            begin
                // Ensure applicant is at least 18 years old
                if "Date of Birth" <> 0D then begin
                    if (Today - "Date of Birth") < 365 * 18 then
                        Error('Applicant must be at least 18 years old');
                end;
            end;
        }

        field(7; "Current Position"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(8; "Current Company"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(9; "Years of Experience"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 1;
            MinValue = 0;
        }

        field(10; "Summary"; Text[500])
        {
            DataClassification = ToBeClassified;
            // Professional summary/about me
        }

        field(11; "Created Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(12; "Modified Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(13; "Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Active","Inactive","Archived","Blocked";
            OptionCaptionML = ENU = 'Active,Inactive,Archived,Blocked';
            InitValue = "Active";
        }

        field(14; "User Email"; Text[100])
        {
            // Email they use to login (might be different from field 4)
            DataClassification = ToBeClassified;
        }

        field(15; "Password Hash"; Text[255])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(16; "Address"; Text[200])
        {
            DataClassification = ToBeClassified;
        }

        field(17; "City"; Text[50])
        {
            DataClassification = ToBeClassified;
        }

        field(18; "Country"; Text[50])
        {
            DataClassification = ToBeClassified;
        }

        field(19; "LinkedIn URL"; Text[200])
        {
            DataClassification = ToBeClassified;
        }

        field(20; "Portfolio URL"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
    }

    // KEYS SECTION - Define indexes (for performance)
    keys
    {
        key(PK; "Applicant ID")
        {
            // Primary key - must be unique
            Clustered = true; // Most important lookup
        }
        
        key(Email; "Email")
        {
            // Secondary index for email lookups
            Unique = true; // Email must be unique
        }

        key(Status; "Status", "Created Date")
        {
            // For filtering active applicants by date
        }
    }

    // TRIGGERS - Automatic actions when data changes
    trigger OnInsert()
    begin
        // When new applicant is created
        "Applicant ID" := GenerateApplicantID();
        "Created Date" := CurrentDateTime;
        "Modified Date" := CurrentDateTime;
        
        Message('Applicant %1 created successfully', "Applicant ID");
    end;

    trigger OnModify()
    begin
        // When applicant record is updated
        "Modified Date" := CurrentDateTime;
    end;

    trigger OnDelete()
    begin
        // When applicant is deleted
        // Delete all related records first
        DeleteRelatedRecords();
    end;

    // PROCEDURES (Functions/Methods)
    local procedure GenerateApplicantID(): Code[20]
    var
        LastApplicant: Record "Job Applicant";
        NewID: Integer;
    begin
        // Generate ID like APP-001, APP-002, etc.
        LastApplicant.SetCurrentKey("Applicant ID");
        if LastApplicant.FindLast() then begin
            NewID := StrToInt(CopyStr(LastApplicant."Applicant ID", 5)) + 1;
        end else begin
            NewID := 1;
        end;
        
        exit('APP-' + PadStr(Format(NewID), 6, '0'));
    end;

    local procedure DeleteRelatedRecords()
    var
        ApplicantQualification: Record "Applicant Qualification";
        JobApplication: Record "Job Application";
    begin
        // Delete qualifications
        ApplicantQualification.SetRange("Applicant ID", "Applicant ID");
        ApplicantQualification.DeleteAll();
        
        // Delete applications (will cascade delete documents, interviews, etc.)
        JobApplication.SetRange("Applicant ID", "Applicant ID");
        JobApplication.DeleteAll();
    end;

    procedure GetFullName(): Text[200]
    begin
        // Helper method to get full name
        exit("First Name" + ' ' + "Last Name");
    end;
}
