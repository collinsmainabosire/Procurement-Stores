table 50120 "Employee Loan Setup"
{
    DataClassification = ToBeClassified;
    Caption = 'Employee Loan Setup';
   // SingleInstance = true;
    
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Loan Number Series"; Code[20])
        {
            Caption = 'Loan Number Series';
            TableRelation = "No. Series";
            NotBlank = true;
        }
        field(3; "Enable Approval Workflow"; Boolean)
        {
            Caption = 'Enable Approval Workflow';
            InitValue = true;
        }
        field(4; "Send Notifications"; Boolean)
        {
            Caption = 'Send Notifications';
            InitValue = true;
        }
        field(5; "Loan Approver User ID"; Code[50])
        {
            Caption = 'Loan Approver User ID';
            TableRelation = User."User Name";
        }
        field(6; "Max Loans Per Employee"; Integer)
        {
            Caption = 'Max Loans Per Employee';
            InitValue = 3;
            MinValue = 1;
        }
        field(7; "Default Interest Rate"; Decimal)
        {
            Caption = 'Default Interest Rate (%)';
            InitValue = 0;
            DecimalPlaces = 2;
        }
        field(8; "Monthly Processing Day"; Integer)
        {
            Caption = 'Monthly Processing Day';
            InitValue = 1;
            MinValue = 1;
            MaxValue = 31;
        }
        field(9; "Auto Close Loans"; Boolean)
        {
            Caption = 'Auto Close Loans';
            InitValue = true;
        }
        field(10; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            Editable = false;
        }
        field(11; "Modified Date"; DateTime)
        {
            Caption = 'Modified Date';
            Editable = false;
        }
    }
    
    keys
    {
        key(PK; "Primary Key")
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
}