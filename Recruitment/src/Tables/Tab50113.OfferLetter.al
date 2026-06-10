table 50113 "Offer Letter"
{
    Caption = 'Offer Letter';
    DataClassification = ToBeClassified;
    // HEADER TABLE for job offers
    // Generated after candidate passes all interviews


    fields
    {
        field(1; "Offer ID"; Code[20])
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

        field(5; "Offer Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(6; "Offer Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Draft","Generated","Sent","Viewed","Accepted","Rejected","Revoked","Expired";
            OptionCaptionML = ENU = 'Draft,Generated,Sent,Viewed,Accepted,Rejected,Revoked,Expired';
            InitValue = "Draft";

            trigger OnValidate()
            var
                OfferStatusChanged: Boolean;
            begin
                OfferStatusChanged := "Offer Status" <> xRec."Offer Status";

                if OfferStatusChanged then begin
                    "Last Status Change" := CurrentDateTime;
                    "Last Status Changed By" := UserId;
                end;
            end;
        }

        field(7; "Job Title"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(8; "Department"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(9; "Position Title"; Text[100])
        {
            DataClassification = ToBeClassified;
            // Exact position title in org chart
        }

        field(10; "Reporting Manager"; Text[100])
        {
            DataClassification = ToBeClassified;
            // Who will they report to
        }

        field(11; "Salary"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 2;
        }

        field(12; "Currency Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Currency.Code;
            InitValue = 'USD';
        }

        field(13; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Start Date" < Today then
                    Error('Start date cannot be in the past');
            end;
        }

        field(14; "Contract Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Full-Time","Part-Time","Contract","Temporary","Internship";
        }

        field(15; "Contract Duration (Months)"; Integer)
        {
            DataClassification = ToBeClassified;
            // If contract/temporary
        }

        field(16; "Benefits Summary"; Text[1000])
        {
            DataClassification = ToBeClassified;
            // Health insurance, 401k, PTO, etc.
        }

        field(17; "Offer Letter Content"; Blob)
        {
            DataClassification = ToBeClassified;
            // Actual PDF/document content
        }

        field(18; "Offer Letter URL"; Text[500])
        {
            DataClassification = ToBeClassified;
            // Link to download offer letter
        }

        field(19; "Sent Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(20; "Viewed Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // When candidate opened the offer
        }

        field(21; "Acceptance Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(22; "Acceptance IP Address"; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(23; "Rejection Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(24; "Rejection Reason"; Text[500])
        {
            DataClassification = ToBeClassified;
            // Why did candidate reject?
        }

        field(25; "Validity Days"; Integer)
        {
            DataClassification = ToBeClassified;
            InitValue = 7;
            // How long candidate has to accept/reject
        }

        field(26; "Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(27; "Is Revoked"; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }

        field(28; "Revocation Reason"; Text[500])
        {
            DataClassification = ToBeClassified;
        }

        field(29; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(30; "Last Status Change"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(31; "Last Status Changed By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(32; "Additional Terms"; Text[2000])
        {
            DataClassification = ToBeClassified;
            // Any special terms/conditions
        }

        field(33; "Offer Template ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            // Which template was used to generate
        }
    }

    keys
    {
        key(PK; "Offer ID")
        {
            Clustered = true;
        }

        key(Application; "Application ID")
        {
        }

        key(Status; "Offer Status", "Expiry Date")
        {
        }
    }

    trigger OnInsert()
    begin
        "Offer ID" := GenerateOfferID();
        "Offer Date" := Today;
        "Created By" := UserId;
        "Expiry Date" := Today + "Validity Days";
    end;

    local procedure GenerateOfferID(): Code[20]
    var
        LastOffer: Record "Offer Letter";
        NewID: Integer;
    begin
        LastOffer.SetCurrentKey("Offer ID");

        if LastOffer.FindLast() then begin
            Evaluate(
                NewID,
                CopyStr(LastOffer."Offer ID", 5)
            );
            NewID := NewID + 1;
        end else
            NewID := 1;

        exit('OFR-' + PadStr(Format(NewID), 6, '0'));
    end;

    procedure MarkAsAccepted()
    begin
        "Offer Status" := "Offer Status"::Accepted;
        "Acceptance Date" := CurrentDateTime;
        // TODO: Update Job Application status
        Modify();
    end;

    procedure MarkAsRejected(RejectionReason: Text)
    begin
        "Offer Status" := "Offer Status"::Rejected;
        "Rejection Date" := CurrentDateTime;
        "Rejection Reason" := RejectionReason;
        Modify();
    end;

    procedure RevokeOffer(RevocationReason: Text)
    begin
        if "Offer Status" = "Offer Status"::Accepted then
            Error('Cannot revoke accepted offers');

        "Is Revoked" := true;
        "Revocation Reason" := RevocationReason;
        "Offer Status" := "Offer Status"::Revoked;
        Modify();
    end;

    procedure IsExpired(): Boolean
    begin
        exit(("Expiry Date" < Today) and ("Offer Status" <> "Offer Status"::Accepted));
    end;

    var
        JobApplication: Record "Job Application";
}