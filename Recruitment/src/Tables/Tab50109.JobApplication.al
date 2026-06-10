table 50109 "Job Application"
{
    Caption = 'Job Application';
    DataClassification = ToBeClassified;

    // HEADER TABLE
    // Every time applicant applies for job, new record here


    fields
    {
        field(1; "Application ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(2; "Applicant ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Applicant"."Applicant ID";

            trigger OnValidate()
            begin
                if "Applicant ID" <> '' then begin
                    JobApplicant.Get("Applicant ID");
                    "Applicant Name" := JobApplicant.GetFullName();
                    "Applicant Email" := JobApplicant."User Email";
                end;
            end;
        }

        field(3; "Vacancy ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Vacancy"."Vacancy ID";

            trigger OnValidate()
            begin
                if "Vacancy ID" <> '' then begin
                    JobVacancy.Get("Vacancy ID");
                    "Job Title" := JobVacancy."Job Title";
                    "Department" := JobVacancy."Department";

                    // Check if application already exists
                    JobApp.SetRange("Applicant ID", "Applicant ID");
                    JobApp.SetRange("Vacancy ID", "Vacancy ID");

                    if JobApp.FindFirst() then
                        if JobApp."Application ID" <> "Application ID" then
                            Error('Applicant has already applied for this vacancy');

                    // Check if vacancy is still open
                    if not JobVacancy.IsApplicationOpen() then
                        Error('This vacancy is no longer accepting applications');
                end;
            end;
        }

        field(4; "Applicant Name"; Text[200])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(5; "Applicant Email"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(6; "Job Title"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(7; "Department"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(8; "Application Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(9; "Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Submitted","Under Review","Shortlisted","Rejected","Interview Scheduled","Interview Completed","Offer Extended","Offer Accepted","Offer Rejected","Onboarded","Archived";
            OptionCaptionML = ENU = 'Submitted,Under Review,Shortlisted,Rejected,Interview Scheduled,Interview Completed,Offer Extended,Offer Accepted,Offer Rejected,Onboarded,Archived';
            InitValue = "Submitted";

            trigger OnValidate()
            var
                StatusChanged: Boolean;
            begin
                StatusChanged := "Status" <> xRec."Status";

                if StatusChanged then begin
                    "Last Status Change Date" := CurrentDateTime;
                    "Last Status Changed By" := UserId;

                    // Log status change
                    LogStatusChange(xRec."Status", "Status");
                end;
            end;
        }

        field(10; "Is Shortlisted"; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Is Shortlisted" then
                    "Status" := "Status"::Shortlisted
                else if "Status" = "Status"::Shortlisted then
                    "Status" := "Status"::"Under Review";
            end;
        }

        field(11; "Shortlist Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(12; "Shortlist Remarks"; Text[500])
        {
            DataClassification = ToBeClassified;
        }

        field(13; "Interview ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Interview"."Interview ID";
            Editable = false;
            // Populated when interview is scheduled
        }

        field(14; "Overall Score"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 100;
            // Calculated from interview scores
        }

        field(15; "Ranking Position"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // 1 = best, 2 = 2nd best, etc.
        }

        field(16; "Offer ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Offer Letter"."Offer ID";
            Editable = false;
        }

        field(17; "Offer Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Offered","Generated","Sent","Accepted","Rejected","Revoked";
            OptionCaptionML = ENU = 'Not Offered,Generated,Sent,Accepted,Rejected,Revoked';
            Editable = false;
        }

        field(18; "Rejection Reason"; Text[500])
        {
            DataClassification = ToBeClassified;
            // Why was applicant rejected?
        }

        field(19; "Rejection Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(20; "Last Status Change Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(21; "Last Status Changed By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(22; "Qualifications Match %"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            DecimalPlaces = 1;
            // Calculate % of job requirements applicant has
        }

        field(23; "Internal Notes"; Text[1000])
        {
            DataClassification = ToBeClassified;
            // HR/Hiring manager notes
        }

        field(24; "Created Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(25; "Modified Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(26; "Application Round"; Integer)
        {
            DataClassification = ToBeClassified;
            InitValue = 1;
            // For jobs with multiple rounds
        }

        field(27; "Days Since Application"; Integer)
        {
            Editable = false;
        }
        field(28; "Email Sent Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // When confirmation email was sent
        }

        field(29; "Resumé Reviewed"; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }

        field(30; "Resumé Review Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(31; "Resumé Review Comments"; Text[500])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Application ID")
        {
            Clustered = true;
        }

        key(Applicant; "Applicant ID", "Application Date")
        {
        }

        key(Vacancy; "Vacancy ID", "Status", "Application Date")
        {
        }

        key(Status; "Status", "Shortlist Date")
        {
            // For filtering by status
        }

        key(Ranking; "Overall Score", "Ranking Position")
        {
        }
    }

    trigger OnInsert()
    begin
        "Application ID" := GenerateApplicationID();
        "Application Date" := CurrentDateTime;
        "Created Date" := CurrentDateTime;

        // Send confirmation email
        SendApplicationConfirmationEmail();
    end;

    trigger OnModify()
    begin
        "Modified Date" := CurrentDateTime;
    end;

    trigger OnDelete()
    var
        ApplicationDoc: Record "Application Document";
        Interview: Record "Interview";
    begin
        // Delete related records
        ApplicationDoc.SetRange("Application ID", "Application ID");
        ApplicationDoc.DeleteAll();

        Interview.SetRange("Application ID", "Application ID");
        Interview.DeleteAll();
    end;

    local procedure GenerateApplicationID(): Code[20]
    var
        LastApp: Record "Job Application";
        NewID: Integer;
    begin
        LastApp.SetCurrentKey("Application ID");

        if LastApp.FindLast() then begin
            Evaluate(
                NewID,
                CopyStr(LastApp."Application ID", 6) // "JAPP-" = 5 chars, so start at 6
            );
            NewID := NewID + 1;
        end else
            NewID := 1;

        exit('JAPP-' + PadStr(Format(NewID), 6, '0'));
    end;

    local procedure LogStatusChange(OldStatus: Option; NewStatus: Option)
    var
        StatusLog: Record "Application Status Log";
    begin
        StatusLog.Init();
        StatusLog."Application ID" := "Application ID";
        StatusLog."Old Status" := OldStatus;
        StatusLog."New Status" := NewStatus;
        StatusLog."Change Date" := CurrentDateTime;
        StatusLog."Changed By" := UserId;
        StatusLog.Insert();
    end;

    local procedure SendApplicationConfirmationEmail()
    var
        EmailModule: Codeunit "Email";
        EmailContent: Text;
        EmailBody: Text;
    begin
        // TODO: Send email notification
        // We'll implement this when we create the email service

        EmailBody := 'Thank you for applying for ' + "Job Title" + '.' +
                     ' We have received your application and will review it shortly.';

        // Log that email should be sent (we'll implement actual sending later)
        Message('Confirmation email queued for: ' + "Applicant Email");
    end;

    procedure ShortlistApplicant(Remarks: Text)
    begin
        "Is Shortlisted" := true;
        "Shortlist Date" := CurrentDateTime;
        "Shortlist Remarks" := Remarks;
        "Status" := "Status"::Shortlisted;
        Modify();

        Message('Applicant shortlisted successfully');
    end;

    procedure RejectApplicant(RejectReason: Text)
    begin
        "Status" := "Status"::Rejected;
        "Rejection Reason" := RejectReason;
        "Rejection Date" := CurrentDateTime;
        Modify();

        Message('Applicant rejected');
    end;

    procedure CalculateQualificationsMatch(): Decimal
    var
        JobQualification: Record "Job Qualification";
        ApplicantQualification: Record "Applicant Qualification";
        TotalRequired: Integer;
        Matched: Integer;
        MatchPercentage: Decimal;
    begin
        // Get all qualifications required for this job
        JobQualification.SetRange("Vacancy ID", "Vacancy ID");
        TotalRequired := JobQualification.Count();

        if TotalRequired = 0 then
            exit(100); // No requirements = 100% match

        // Count how many applicant has
        Matched := 0;
        if JobQualification.FindSet() then
            repeat
                ApplicantQualification.SetRange("Applicant ID", "Applicant ID");
                ApplicantQualification.SetRange("Qualification ID", JobQualification."Qualification ID");

                if ApplicantQualification.FindFirst() then
                    Matched += 1;
            until JobQualification.Next() = 0;

        // Calculate percentage
        MatchPercentage := (Matched / TotalRequired) * 100;

        "Qualifications Match %" := MatchPercentage;

        exit(MatchPercentage);
    end;

    var
        JobApplicant: Record "Job Applicant";
        JobVacancy: Record "Job Vacancy";
        JobApp: Record "Job Application";

    procedure CalcDaysSinceApplication()
    begin
        "Days Since Application" :=
            Today() - DT2Date("Application Date");
    end;
}
