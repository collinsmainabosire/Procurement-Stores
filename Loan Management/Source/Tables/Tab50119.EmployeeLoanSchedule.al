table 50119 "Employee Loan Schedule"
{
    DataClassification = ToBeClassified;
    Caption = 'Employee Loan Schedule';
    
    fields
    {
        field(1; "Loan No."; Code[20])
        {
            Caption = 'Loan No.';
            TableRelation = "Employee Loan Header";
            NotBlank = true;
        }
        field(2; "Installment No."; Integer)
        {
            Caption = 'Installment No.';
            NotBlank = true;
        }
        field(3; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(4; "Principal Amount"; Decimal)
        {
            Caption = 'Principal Amount';
            DecimalPlaces = 2;
        }
        field(5; "Interest Amount"; Decimal)
        {
            Caption = 'Interest Amount';
            DecimalPlaces = 2;
        }
        field(6; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DecimalPlaces = 2;
        }
        field(7; "Remaining Balance"; Decimal)
        {
            Caption = 'Remaining Balance';
            DecimalPlaces = 2;
        }
        field(8; "Paid Amount"; Decimal)
        {
            Caption = 'Paid Amount';
            Editable = false;
            DecimalPlaces = 2;
        }
        field(9; "Payment Status"; Enum "Payment Status")
        {
            Caption = 'Payment Status';
            Editable = false;
            InitValue = Pending;
        }
        field(10; "Payment Date"; Date)
        {
            Caption = 'Payment Date';
            Editable = false;
        }
        field(11; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            Editable = false;
        }
    }
    
    keys
    {
        key(PK; "Loan No.", "Installment No.")
        {
            Clustered = true;
        }
        key(SK1; "Due Date")
        {
        }
        key(SK2; "Payment Status")
        {
        }
    }
    
    trigger OnInsert()
    begin
        "Created Date" := CurrentDateTime;
    end;
}