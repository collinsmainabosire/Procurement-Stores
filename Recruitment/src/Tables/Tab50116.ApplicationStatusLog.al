table 50116 "Application Status Log"
{
    Caption = 'Application Status Log';
    // AUDIT TABLE
    // Tracks every time an application's status changes
    // Used for compliance, audit trail, and reporting

    // Example:
    // Application JAPP-000001:
    // - 2024-01-15 10:00 → Created (Status: Submitted)
    // - 2024-01-18 14:30 → Status changed to Under Review (by HR Manager)
    // - 2024-01-22 09:15 → Status changed to Shortlisted (Remarks: Good fit)
    // - 2024-02-05 16:45 → Status changed to Interview Scheduled
    // - 2024-02-10 11:00 → Status changed to Interview Completed
    // - 2024-02-15 13:20 → Status changed to Offer Extended

    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Log ID"; BigInteger)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
            Editable = false;
            // Auto-incrementing unique ID
        }

        field(2; "Application ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Application"."Application ID";

            trigger OnValidate()
            begin
                if "Application ID" = '' then
                    Error('Application ID is required');
            end;
        }

        field(3; "Old Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Submitted","Under Review","Shortlisted","Rejected","Interview Scheduled","Interview Completed","Offer Extended","Offer Accepted","Offer Rejected","Onboarded","Archived","";
            OptionCaptionML = ENU = 'Submitted,Under Review,Shortlisted,Rejected,Interview Scheduled,Interview Completed,Offer Extended,Offer Accepted,Offer Rejected,Onboarded,Archived, ';
            Editable = false;
            // What was the status BEFORE this change
        }

        field(4; "New Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Submitted","Under Review","Shortlisted","Rejected","Interview Scheduled","Interview Completed","Offer Extended","Offer Accepted","Offer Rejected","Onboarded","Archived";
            OptionCaptionML = ENU = 'Submitted,Under Review,Shortlisted,Rejected,Interview Scheduled,Interview Completed,Offer Extended,Offer Accepted,Offer Rejected,Onboarded,Archived';
            Editable = false;
            // What is the new status AFTER this change
        }

        field(5; "Change Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // When was the change made
        }

        field(6; "Changed By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Who made the change (User ID)
        }

        field(7; "Changed By Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Full name of person who made change
        }

        field(8; "Reason for Change"; Text[500])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // WHY was status changed?
            // e.g., "Candidate doesn't meet requirements"
            // e.g., "Interview scheduled for 2024-02-10"
            // e.g., "Offer accepted by candidate"
        }

        field(9; "Additional Comments"; Text[1000])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Extra notes about the change
        }

        field(10; "Changed From IP"; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // IP address of person making change (for security)
        }

        field(11; "Applicant Email"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Snapshot of applicant email at time of change
        }

        field(12; "Applicant Name"; Text[200])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Snapshot of applicant name at time of change
        }

        field(13; "Job Title"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Which job was this for
        }

        field(14; "Department"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Which department
        }

        field(15; "Email Sent"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Was notification email sent?
        }

        field(16; "Email Sent Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // When was email sent
        }

        field(17; "Email Delivery Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Sent","Pending","Sent","Delivered","Bounced","Failed";
            OptionCaptionML = ENU = 'Not Sent,Pending,Sent,Delivered,Bounced,Failed';
            Editable = false;
        }

        field(18; "Document Attached"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Was a document attached (e.g., offer letter)
        }

        field(19; "Document ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Application Document"."Document ID";
            // Link to attachment if any
        }

        field(20; "Time to Previous Status (Hours)"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            DecimalPlaces = 2;
            // How long were they in previous status?
        }

        field(21; "Days in Status"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Easier to read format
        }

        field(22; "System Generated"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            InitValue = false;
            // TRUE = automated change (e.g., interview scheduled)
            // FALSE = manual change by user
        }

        field(23; "Notification Required"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Should applicant be notified?
        }

        field(24; "Notification Sent To Applicant"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(25; "Log Entry Number"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Sequential number for this application
            // 1st change, 2nd change, etc.
        }

        field(26; "Related Interview ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Interview"."Interview ID";
            // If status change is related to interview
        }

        field(27; "Related Offer ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Offer Letter"."Offer ID";
            // If status change is related to offer
        }
    }

    keys
    {
        key(PK; "Log ID")
        {
            Clustered = true;
        }

        key(Application; "Application ID", "Change Date")
        {
            // Most important - find all changes for an application
            // Sorted by newest first
        }

        key(Status; "Old Status", "New Status", "Change Date")
        {
            // For analytics - track status change patterns
        }

        key(User; "Changed By", "Change Date")
        {
            // Find all changes made by a specific user
        }

        key(Date; "Change Date")
        {
            // For recent activity dashboard
        }

        key(Type; "New Status", "Application ID")
        {
            // Find all applications in specific status
        }
    }

    trigger OnInsert()
    begin
        // Get sequential log entry number
        GetLogEntryNumber();

        // Store snapshots of important data
        StoreDataSnapshots();
    end;

    local procedure GetLogEntryNumber()
    var
        PreviousLog: Record "Application Status Log";
    begin
        PreviousLog.SetRange("Application ID", "Application ID");
        PreviousLog.SetCurrentKey("Log Entry Number");
        if PreviousLog.FindLast() then
            "Log Entry Number" := PreviousLog."Log Entry Number" + 1
        else
            "Log Entry Number" := 1;
    end;

    local procedure StoreDataSnapshots()
    var
        JobApplication: Record "Job Application";
        JobApplicant: Record "Job Applicant";
    begin
        // Get application details
        if JobApplication.Get("Application ID") then begin
            "Applicant Email" := JobApplication."Applicant Email";
            "Applicant Name" := JobApplication."Applicant Name";
            "Job Title" := JobApplication."Job Title";
            "Department" := JobApplication."Department";

            // Get applicant details
            if JobApplicant.Get(JobApplication."Applicant ID") then begin
                // Already have email and name from application
            end;
        end;
    end;

    procedure CalculateDaysInStatus(PreviousChangeDate: DateTime)
    begin
        if PreviousChangeDate <> 0DT then begin
            "Time to Previous Status (Hours)" :=
                (("Change Date" - PreviousChangeDate) / 3600000); // Convert milliseconds to hours
            "Days in Status" := Round(("Time to Previous Status (Hours)" / 24), 1);
        end;
    end;

    procedure GetStatusChangeDescription(): Text
    var
        Description: Text;
    begin
        Description := 'Status changed from ';

        case "Old Status" of
            "Old Status"::Submitted:
                Description += 'Submitted';
            "Old Status"::"Under Review":
                Description += 'Under Review';
            "Old Status"::Shortlisted:
                Description += 'Shortlisted';
            "Old Status"::Rejected:
                Description += 'Rejected';
            "Old Status"::"Interview Scheduled":
                Description += 'Interview Scheduled';
            "Old Status"::"Interview Completed":
                Description += 'Interview Completed';
            "Old Status"::"Offer Extended":
                Description += 'Offer Extended';
            "Old Status"::"Offer Accepted":
                Description += 'Offer Accepted';
            "Old Status"::"Offer Rejected":
                Description += 'Offer Rejected';
            "Old Status"::Onboarded:
                Description += 'Onboarded';
            "Old Status"::Archived:
                Description += 'Archived';
        end;

        Description += ' to ';

        case "New Status" of
            "New Status"::Submitted:
                Description += 'Submitted';
            "New Status"::"Under Review":
                Description += 'Under Review';
            "New Status"::Shortlisted:
                Description += 'Shortlisted';
            "New Status"::Rejected:
                Description += 'Rejected';
            "New Status"::"Interview Scheduled":
                Description += 'Interview Scheduled';
            "New Status"::"Interview Completed":
                Description += 'Interview Completed';
            "New Status"::"Offer Extended":
                Description += 'Offer Extended';
            "New Status"::"Offer Accepted":
                Description += 'Offer Accepted';
            "New Status"::"Offer Rejected":
                Description += 'Offer Rejected';
            "New Status"::Onboarded:
                Description += 'Onboarded';
            "New Status"::Archived:
                Description += 'Archived';
        end;

        exit(Description);
    end;

    var
        JobApplication: Record "Job Application";
        JobApplicant: Record "Job Applicant";
}