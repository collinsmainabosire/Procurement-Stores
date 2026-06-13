table 50118 "Employee Loan Header"
{
    DataClassification = ToBeClassified;
    Caption = 'Employee Loan';
  //  LookupPageID = "Employee Loan List";
   // DrillDownPageID = "Employee Loan List";

    fields
    {
        field(1; "Loan No."; Code[20])
        {
            Caption = 'Loan No.';
            NotBlank = true;
            Editable = false;
        }
        field(2; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = Employee;
            NotBlank = true;

            trigger OnValidate()
            var
                Employee: Record Employee;
            begin
                if Employee.Get("Employee No.") then
                    "Employee Name" := Employee."First Name" + ' ' + Employee."Last Name"
                else
                    Error('Employee %1 does not exist.', "Employee No.");
            end;
        }
        field(3; "Employee Name"; Text[100])
        {
            Caption = 'Employee Name';
            Editable = false;
        }
        field(4; "Loan Type"; Code[20])
        {
            Caption = 'Loan Type';
            TableRelation = "Employee Loan Type";
            NotBlank = true;

            trigger OnValidate()
            var
                LoanType: Record "Employee Loan Type";
            begin
                if LoanType.Get("Loan Type") then begin
                    if not LoanType.Active then
                        Error('Loan type %1 is inactive.', "Loan Type");
                    "Maximum Amount" := LoanType."Maximum Amount";
                    "Interest Rate" := LoanType."Interest Rate";
                    "Maximum Term Months" := LoanType."Maximum Term Months";
                end;
            end;
        }
        field(5; "Requested Amount"; Decimal)
        {
            Caption = 'Requested Amount';
            MinValue = 0;

            trigger OnValidate()
            begin
                ValidateLoanAmount();
            end;
        }
        field(6; "Approved Amount"; Decimal)
        {
            Caption = 'Approved Amount';
            Editable = false;
        }
        field(7; "Term Months"; Integer)
        {
            Caption = 'Term (Months)';
            MinValue = 1;

            trigger OnValidate()
            begin
                ValidateLoanTerm();
            end;
        }
        field(8; "Purpose"; Text[250])
        {
            Caption = 'Purpose';
        }
        field(9; "Application Date"; Date)
        {
            Caption = 'Application Date';
            Editable = false;
            InitValue = 0D;

            trigger OnValidate()
            begin
                if "Application Date" = 0D then
                    "Application Date" := Today;
            end;
        }
        field(10; "Status"; Enum "Loan Status")
        {
            Caption = 'Status';
            Editable = false;
            InitValue = Open;
        }
        field(11; "Approval Status"; Enum "Approval Status")
        {
            Caption = 'Approval Status';
            Editable = false;
        }
        field(12; "Disbursement Date"; Date)
        {
            Caption = 'Disbursement Date';
            Editable = false;
        }
        field(13; "Disbursed Amount"; Decimal)
        {
            Caption = 'Disbursed Amount';
            Editable = false;
        }
        field(14; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            Editable = false;
        }
        field(15; "Outstanding Balance"; Decimal)
        {
            Caption = 'Outstanding Balance';
            Editable = false;
        }
        field(16; "Total Paid"; Decimal)
        {
            Caption = 'Total Paid';
            Editable = false;
        }
        field(17; "Interest Rate"; Decimal)
        {
            Caption = 'Interest Rate (%)';
            Editable = false;
        }
        field(18; "Maximum Amount"; Decimal)
        {
            Caption = 'Maximum Amount';
            Editable = false;
        }
        field(19; "Maximum Term Months"; Integer)
        {
            Caption = 'Maximum Term (Months)';
            Editable = false;
        }
        field(20; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
        }
        field(21; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            Editable = false;
        }
        field(22; "Last Modified By"; Code[50])
        {
            Caption = 'Last Modified By';
            Editable = false;
        }
        field(23; "Last Modified Date"; DateTime)
        {
            Caption = 'Last Modified Date';
            Editable = false;
        }
        field(24; "Approved By"; Code[50])
        {
            Caption = 'Approved By';
            Editable = false;
        }
        field(25; "Approval Date"; Date)
        {
            Caption = 'Approval Date';
            Editable = false;
        }
        field(26; "Rejection Reason"; Text[500])
        {
            Caption = 'Rejection Reason';
            Editable = false;
        }
        field(27; "Closed Date"; Date)
        {
            Caption = 'Closed Date';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Loan No.")
        {
            Clustered = true;
        }
        key(SK1; "Employee No.")
        {
        }
        key(SK2; "Status")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Loan No." = '' then
            "Loan No." := GetNextLoanNumber();

        "Application Date" := Today;
        "Created By" := UserId;
        "Created Date" := CurrentDateTime;
        "Status" := "Status"::Open;
    end;

    trigger OnModify()
    begin
        "Last Modified By" := UserId;
        "Last Modified Date" := CurrentDateTime;
    end;

    trigger OnDelete()
    var
        LoanSchedule: Record "Employee Loan Schedule";
    begin
        if Status <> Status::Open then
            Error('Cannot delete loan that is not in Open status.');

        LoanSchedule.SetRange("Loan No.", "Loan No.");
        LoanSchedule.DeleteAll();
    end;

    local procedure ValidateLoanAmount()
    begin
        if "Requested Amount" > "Maximum Amount" then
            Error('Requested amount %1 exceeds maximum amount %2', "Requested Amount", "Maximum Amount");
    end;

    local procedure ValidateLoanTerm()
    begin
        if "Term Months" > "Maximum Term Months" then
            Error('Requested term %1 months exceeds maximum term %2 months', "Term Months", "Maximum Term Months");
    end;

    local procedure GetNextLoanNumber(): Code[20]
    var
        NoSeriesMgt: Codeunit "No. Series";
        LoanSetup: Record "Employee Loan Setup";
    begin
        LoanSetup.Get();
        exit(NoSeriesMgt.GetNextNo(LoanSetup."Loan Number Series", Today, true));
    end;
}