table 50110 "Application Document"
{
    Caption = 'Application Document';
    DataClassification = ToBeClassified;

    // LINE TABLE for Job Application
    // Stores documents uploaded by applicant
    // CV, Cover Letter, Certificates, etc.



    fields
    {
        field(1; "Document ID"; Code[20])
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
                if "Application ID" = '' then
                    Error('Application ID is required');
            end;
        }

        field(3; "Document Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "CV","Cover Letter","Certificate","Transcript","Portfolio","Offer Letter","Other";
            OptionCaptionML = ENU = 'CV,Cover Letter,Certificate,Transcript,Portfolio,Offer Letter,Other';

            trigger OnValidate()
            begin
                if "Document Type" = "Document Type"::"Offer Letter" then
                    Error('Offer Letter cannot be uploaded by applicant');
            end;
        }

        field(4; "File Name"; Text[200])
        {
            DataClassification = ToBeClassified;
            // e.g., "John_Doe_CV.pdf"
        }

        field(5; "File Extension"; Text[10])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // e.g., "pdf", "docx", "jpg"
        }

        field(6; "File Size (KB)"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            DecimalPlaces = 2;
        }

        field(7; "Document Path"; Text[500])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Where file is stored in BC
            // Format: /Applications/JAPP-000001/CV_20240115.pdf
        }

        field(8; "Upload Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(9; "Uploaded By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // Applicant ID or User ID
        }

        field(10; "File Content"; Blob)
        {
            DataClassification = ToBeClassified;
        }

        field(11; "Description"; Text[300])
        {
            DataClassification = ToBeClassified;
            // Applicant can add notes about document
        }

        field(12; "Is Required"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(13; "Virus Scanned"; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
            Editable = false;
        }

        field(14; "Virus Scan Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(15; "Virus Scan Result"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Scanned","Clean","Suspicious","Infected","Error";
            OptionCaptionML = ENU = 'Not Scanned,Clean,Suspicious,Infected,Error';
            Editable = false;
        }

        field(16; "Access Count"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // How many times downloaded/viewed
        }

        field(17; "Last Accessed Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(18; "Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Active","Archived","Deleted";
            InitValue = "Active";
        }

        field(19; "Comments"; Text[500])
        {
            DataClassification = ToBeClassified;
            // HR comments on document
        }

        field(20; "Reviewed By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(21; "Review Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(22; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(23; "Mime Type"; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // e.g., "application/pdf", "image/jpeg"
        }

        field(24; "Hash Value"; Text[256])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // SHA256 hash for duplicate detection & integrity
        }

        field(25; "Document URL"; Text[500])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // URL to download from web portal
        }
    }

    keys
    {
        key(PK; "Document ID")
        {
            Clustered = true;
        }

        key(Application; "Application ID", "Document Type")
        {
        }

        key(Status; "Status", "Upload Date")
        {
        }

        key(Type; "Document Type", "Upload Date")
        {
        }
    }

    trigger OnInsert()
    begin
        "Document ID" := GenerateDocumentID();
        "Upload Date" := CurrentDateTime;
        "Uploaded By" := UserId;

        // Extract file extension
        ExtractFileExtension();

        // Generate SHA256 hash
        GenerateFileHash();

        // TODO: Virus scan file
    end;

    trigger OnDelete()
    begin
        Clear("Document Path");
    end;

    local procedure GenerateDocumentID(): Code[20]
    var
        LastDoc: Record "Application Document";
        NewID: Integer;
    begin
        LastDoc.SetCurrentKey("Document ID");

        if LastDoc.FindLast() then begin
            Evaluate(
                NewID,
                CopyStr(LastDoc."Document ID", 5)
            );
            NewID := NewID + 1;
        end else
            NewID := 1;

        exit('DOC-' + PadStr(Format(NewID), 6, '0'));
    end;

    local procedure ExtractFileExtension()
    var
        FileParts: List of [Text];
        NameLength: Integer;
    begin
        // Get extension from file name
        // e.g., "John_Doe_CV.pdf" → "pdf"

        FileParts := "File Name".Split('.');
        if FileParts.Count() > 1 then
            "File Extension" := FileParts.Get(FileParts.Count())
        else
            "File Extension" := '';
    end;

    local procedure GenerateFileHash()
    begin
        "Hash Value" := CalculateFileSHA256Hash();
    end;

    procedure MarkAsReviewed(ReviewComments: Text)
    begin
        "Reviewed By" := UserId;
        "Review Date" := CurrentDateTime;
        "Comments" := ReviewComments;
        Modify();
    end;

    procedure GetDownloadURL(): Text[500]
    begin
        // Generate secure URL for downloading
        // Format: https://portal.company.com/download/DOC-000001?token=xxxx

        "Document URL" := 'https://portal.company.com/download/' + "Document ID" + '?token=xxxxx';

        exit("Document URL");
    end;

    procedure LogAccess()
    begin
        "Access Count" += 1;
        "Last Accessed Date" := CurrentDateTime;
        Modify();
    end;

    procedure IsValidFile(): Boolean
    var
        AllowedExtensions: List of [Text];
    begin
        // Define allowed file types
        AllowedExtensions.Add('pdf');
        AllowedExtensions.Add('doc');
        AllowedExtensions.Add('docx');
        AllowedExtensions.Add('xls');
        AllowedExtensions.Add('xlsx');
        AllowedExtensions.Add('ppt');
        AllowedExtensions.Add('jpg');
        AllowedExtensions.Add('jpeg');
        AllowedExtensions.Add('png');
        AllowedExtensions.Add('txt');

        // Check extension
        if not AllowedExtensions.Contains("File Extension") then
            Error('File type not allowed. Only PDF, DOC, DOCX, XLS, XLSX, PPT, JPG, PNG, TXT allowed');

        // Check file size (max 10 MB)
        if "File Size (KB)" > 10240 then
            Error('File size exceeds 10 MB limit');

        exit(true);
    end;

    var
        StorageHelper: Codeunit "Storage Helper";

    local procedure CalculateFileSHA256Hash(): Text
    var
        CryptographyMgt: Codeunit "Cryptography Management";
        InStr: InStream;
    begin
        CalcFields("File Content");

        if not "File Content".HasValue() then
            exit('');

        "File Content".CreateInStream(InStr);

        exit(CryptographyMgt.GenerateHash(InStr, Enum::"Hash Algorithm"::SHA256));
    end;

    procedure UpdateHash()
    begin
        "Hash Value" := CalculateFileSHA256Hash();
        Modify();
    end;
}
