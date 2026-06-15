table 50117 "Employee Loan Type"

{
    DataClassification = ToBeClassified;
    Caption = 'Employee Loan Type';

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Maximum Amount"; Decimal)
        {
            Caption = 'Maximum Amount';
            MinValue = 0;
        }
        field(4; "Interest Rate"; Decimal)
        {
            Caption = 'Interest Rate (%)';
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 2;
        }
        field(5; "Maximum Term Months"; Integer)
        {
            Caption = 'Maximum Term (Months)';
            MinValue = 1;
        }
        field(6; "Requires Approval"; Boolean)
        {
            Caption = 'Requires Approval';
            InitValue = true;
        }
        field(7; "Active"; Boolean)
        {
            Caption = 'Active';
            InitValue = true;
        }
        field(8; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            Editable = false;
        }
        field(9; "Modified Date"; DateTime)
        {
            Caption = 'Modified Date';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Created Date" := CurrentDateTime;
        "Modified Date" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Modified Date" := CurrentDateTime;
    end;

    trigger OnDelete()
    var
        EmployeeLoan: Record "Employee Loan Header";
    begin
        EmployeeLoan.SetRange("Loan Type", Code);
        if not EmployeeLoan.IsEmpty then
            Error('Cannot delete loan type. Loans exist with this type.');
    end;
}
