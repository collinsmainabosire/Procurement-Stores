table 50121 "Employee Loan Ledger Entry"
{
    DataClassification = ToBeClassified;
    Caption = 'Employee Loan Ledger Entry';

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Loan No."; Code[20])
        {
            Caption = 'Loan No.';
            TableRelation = "Employee Loan Header";
        }
        field(3; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = Employee;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(5; "Document Type"; Enum "Loan Ledger Document Type")
        {
            Caption = 'Document Type';
        }
        field(6; "Description"; Text[250])
        {
            Caption = 'Description';
        }
        field(7; "Amount"; Decimal)
        {
            Caption = 'Amount';
        }
        field(8; "Balance"; Decimal)
        {
            Caption = 'Balance';
        }
        field(9; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            Editable = false;
        }
        field(10; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK1; "Loan No.")
        {
        }
        key(SK2; "Employee No.")
        {
        }
        key(SK3; "Posting Date")
        {
        }
    }

    trigger OnInsert()
    begin
        "Created Date" := CurrentDateTime;
        "Created By" := UserId;
    end;
}