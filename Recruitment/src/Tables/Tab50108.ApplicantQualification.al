table 50108 "Applicant Qualification"
{
    Caption = 'Applicant Qualification';
    DataClassification = ToBeClassified;
    // LINE TABLE
    // One applicant can have multiple qualifications
    // Example: John has BSc, MSc, CCNA, PMP, etc.


    fields
    {
        field(1; "Applicant ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Applicant"."Applicant ID";

            trigger OnValidate()
            begin
                if "Applicant ID" = '' then
                    Error('Applicant ID is required');

                // Validate applicant exists
                JobApplicant.Get("Applicant ID");
            end;
        }

        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Auto-incremented
        }

        field(3; "Qualification ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Qualification Master"."Qualification ID";

            trigger OnValidate()
            begin
                if "Qualification ID" <> '' then begin
                    // Get qualification details
                    QualificationRec.Get("Qualification ID");
                    "Qualification Name" := QualificationRec."Qualification Name";
                    "Qualification Level" := QualificationRec."Level";

                    // Check for duplicates
                    ApplicantQual.SetRange("Applicant ID", "Applicant ID");
                    ApplicantQual.SetRange("Qualification ID", "Qualification ID");

                    if ApplicantQual.FindFirst() then
                        if ApplicantQual."Line No." <> "Line No." then
                            Error('This qualification is already added');
                end;
            end;
        }

        field(4; "Qualification Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Populated from Qualification Master
        }

        field(5; "Qualification Level"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Entry","Intermediate","Advanced","Expert";
            Editable = false;
            // Set from Qualification Master
        }

        field(6; "Year Obtained"; Integer)
        {
            DataClassification = ToBeClassified;
            MinValue = 1900;
            MaxValue = 2100;

            trigger OnValidate()
            begin
                if "Year Obtained" <> 0 then begin

                    // Can't be in future
                    if "Year Obtained" > Date2DMY(Today(), 3) then
                        Error('Year obtained cannot be in the future');

                    // Can't be before 1900
                    if "Year Obtained" < 1900 then
                        Error('Please enter a valid year');
                end;
            end;
        }

        field(7; "Institution"; Text[150])
        {
            DataClassification = ToBeClassified;
            // Where they got the qualification
            // e.g., "University of Technology", "Microsoft", etc.
        }

        field(8; "Grade/Score"; Text[50])
        {
            DataClassification = ToBeClassified;
            // e.g., "A+", "85%", "Distinction", etc.
        }

        field(9; "Certificate Number"; Text[100])
        {
            DataClassification = ToBeClassified;
            // For verification purposes
        }

        field(10; "Valid Until"; Date)
        {
            DataClassification = ToBeClassified;
            // Some certifications expire (e.g., PMP, CCNA)

            trigger OnValidate()
            begin
                if "Valid Until" <> 0D then begin
                    if "Valid Until" < Today then
                        Message('Note: This certification has expired');
                end;
            end;
        }

        field(11; "Is Verified"; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
            Editable = false;
            // Set by HR when they verify the document
        }

        field(12; "Verified Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(13; "Verified By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // User ID of person who verified
        }

        field(14; "Document ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Application Document"."Document ID";
            // Link to uploaded certificate
        }

        field(15; "Is Primary"; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
            // Is this the main/most important qualification?
        }

        field(16; "Notes"; Text[300])
        {
            DataClassification = ToBeClassified;
        }

        field(17; "Created Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Applicant ID", "Line No.")
        {
            Clustered = true;
        }

        key(QualID; "Qualification ID")
        {
            // For looking up all applicants with specific qualification
        }

        key(Verified; "Is Verified", "Verified Date")
        {
            // For HR to find unverified qualifications
        }
    }

    trigger OnInsert()
    begin
        if "Line No." = 0 then
            "Line No." := GetNextLineNo();

        "Created Date" := CurrentDateTime;
    end;

    trigger OnDelete()
    var
        ApplicationDoc: Record "Application Document";
    begin
        // Don't delete document when removing qualification
        // Document might be needed for other qualifications
        Message('Qualification removed from applicant record');
    end;

    local procedure GetNextLineNo(): Integer
    var
        ApplicantQual: Record "Applicant Qualification";
    begin
        ApplicantQual.SetRange("Applicant ID", "Applicant ID");
        if ApplicantQual.FindLast() then
            exit(ApplicantQual."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure MarkAsVerified(VerifiedBy: Code[50])
    begin
        "Is Verified" := true;
        "Verified Date" := Today;
        "Verified By" := VerifiedBy;
        Modify();
    end;

    procedure IsCurrentlyValid(): Boolean
    begin
        // Check if qualification is still valid
        if "Valid Until" = 0D then
            exit(true); // No expiry date

        exit("Valid Until" >= Today);
    end;

    var
        JobApplicant: Record "Job Applicant";
        QualificationRec: Record "Qualification Master";
        ApplicantQual: Record "Applicant Qualification";
}