table 50111 Interview
{
    Caption = 'Interview';
    DataClassification = ToBeClassified;

    // HEADER TABLE for interviews
    // After shortlisting, applicant gets interview scheduled

    fields
    {
        field(1; "Interview ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(2; "Application ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Application"."Application ID";

            trigger OnValidate()
            begin
                if "Application ID" <> '' then begin
                    JobApplication.Get("Application ID");
                    "Applicant ID" := JobApplication."Applicant ID";
                    "Vacancy ID" := JobApplication."Vacancy ID";
                    "Job Title" := JobApplication."Job Title";
                end;
            end;
        }

        field(3; "Applicant ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(4; "Vacancy ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(5; "Job Title"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(6; "Interview Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Phone Screen","Technical Test","Technical Interview","HR Interview","Panel Interview","Final Round","Practical Test","Video Interview";
            OptionCaptionML = ENU = 'Phone Screen,Technical Test,Technical Interview,HR Interview,Panel Interview,Final Round,Practical Test,Video Interview';
            InitValue = "Phone Screen";
        }

        field(7; "Scheduled Date"; DateTime)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                // Can't schedule in the past
                if "Scheduled Date" < CurrentDateTime() then
                    Error('Interview cannot be scheduled in the past');
            end;
        }

        field(8; "Scheduled Duration (Minutes)"; Integer)
        {
            DataClassification = ToBeClassified;
            MinValue = 15;
            MaxValue = 480;
            InitValue = 60;
        }

        field(9; "Interviewer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            // Name of person conducting interview
        }

        field(10; "Interviewer Email"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(11; "Interview Location"; Text[200])
        {
            DataClassification = ToBeClassified;
            // Office address or Zoom link, etc.
        }

        field(12; "Interview Link"; Text[500])
        {
            DataClassification = ToBeClassified;
            // Zoom/Teams link if video interview
        }

        field(13; "Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Scheduled","Reminder Sent","Candidate Confirmed","In Progress","Completed","No Show","Rescheduled","Cancelled";
            OptionCaptionML = ENU = 'Scheduled,Reminder Sent,Candidate Confirmed,In Progress,Completed,No Show,Rescheduled,Cancelled';
            InitValue = "Scheduled";
        }

        field(14; "Feedback"; Text[1000])
        {
            DataClassification = ToBeClassified;
            // Interviewer's feedback
        }

        field(15; "Recommendation"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Pending","Proceed to Next Round","Shortlist for Offer","Reject","On Hold";
            OptionCaptionML = ENU = 'Pending,Proceed to Next Round,Shortlist for Offer,Reject,On Hold';
            InitValue = "Pending";
        }

        field(16; "Recommendation Remarks"; Text[500])
        {
            DataClassification = ToBeClassified;
        }

        field(17; "Technical Score"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 100;
        }

        field(18; "Soft Skills Score"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 100;
        }

        field(19; "Communication Score"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 100;
        }

        field(20; "Overall Interview Score"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            DecimalPlaces = 2;
        }

        field(21; "Actual Interview Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(22; "Interview End Time"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(23; "Rating"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Poor","Below Average","Average","Good","Excellent";
            OptionCaptionML = ENU = 'Poor,Below Average,Average,Good,Excellent';
        }

        field(24; "Created Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(25; "Next Round Scheduled"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(26; "Interview Round Number"; Integer)
        {
            DataClassification = ToBeClassified;
            InitValue = 1;
        }

        field(27; "Strength Areas"; Text[500])
        {
            DataClassification = ToBeClassified;
            // What candidate did well
        }

        field(28; "Improvement Areas"; Text[500])
        {
            DataClassification = ToBeClassified;
            // What candidate needs to improve
        }

        field(29; "Candidate Confirmation Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Sent","Email Sent","Confirmed","Declined","No Response";
            OptionCaptionML = ENU = 'Not Sent,Email Sent,Confirmed,Declined,No Response';
            InitValue = "Not Sent";
        }

        field(30; "Candidate Confirmation Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Interview ID")
        {
            Clustered = true;
        }

        key(Application; "Application ID", "Interview Round Number")
        {
        }

        key(Status; "Status", "Scheduled Date")
        {
        }

        key(Scheduled; "Scheduled Date", "Status")
        {
            // For interview calendar
        }
    }

    trigger OnInsert()
    begin
        "Interview ID" := GenerateInterviewID();
        "Created Date" := CurrentDateTime;

        // Send interview invitation email
        SendInterviewInvitationEmail();
    end;

    trigger OnModify()
    begin
        // If status changed to Completed, calculate overall score
        if ("Status" = "Status"::Completed) and
           (xRec."Status" <> "Status"::Completed) then begin
            "Actual Interview Date" := CurrentDateTime;
            CalculateOverallScore();
        end;
    end;

    local procedure GenerateInterviewID(): Code[20]
    var
        LastInterview: Record "Interview";
        NewID: Integer;
    begin
        LastInterview.SetCurrentKey("Interview ID");

        if LastInterview.FindLast() then begin
            Evaluate(
                NewID,
                CopyStr(LastInterview."Interview ID", 5)
            );
            NewID := NewID + 1;
        end else
            NewID := 1;

        exit('INT-' + PadStr(Format(NewID), 6, '0'));
    end;

    local procedure SendInterviewInvitationEmail()
    begin
        // TODO: Send email with interview details
        Message('Interview invitation queued to send');
    end;

    procedure MarkAsCompleted()
    begin
        "Status" := "Status"::Completed;
        "Actual Interview Date" := CurrentDateTime;
        CalculateOverallScore();
        Modify();
    end;

    procedure CalculateOverallScore()
    begin
        if ("Technical Score" > 0) and ("Soft Skills Score" > 0) and ("Communication Score" > 0) then begin
            "Overall Interview Score" :=
                ("Technical Score" + "Soft Skills Score" + "Communication Score") / 3;
            Modify();
        end;
    end;

    procedure GetInterviewDuration(): Duration
    begin
        // Calculate actual interview duration
        if "Interview End Time" <> 0DT then
            exit("Interview End Time" - "Actual Interview Date")
        else
            exit(0);
    end;

    var
        JobApplication: Record "Job Application";
}