namespace BCTRAINING.BCTRAINING;

table 50122 "Loan Cue"
{
    Caption = 'Loan Cue';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Pending Approvals"; Integer)
        {
            Caption = 'Pending Approvals';
        }
        field(3; "Approved Not Disbursed"; Integer)
        {
            Caption = 'Approved - Not Disbursed';
        }
        field(4; "Active Loans"; Integer)
        {
            Caption = 'Active Loans';
        }
        field(5; "Outstanding Balance"; Decimal)
        {
            Caption = 'Outstanding Balance';
        }
        field(6; "Upcoming Payments"; Integer)
        {
            Caption = 'Upcoming Payments';
        }
        field(7; "Overdue Payments"; Integer)
        {
            Caption = 'Overdue Payments';
        }
        field(8; "Closed This Month"; Integer)
        {
            Caption = 'Closed This Month';
        }
        field(9; "Rejected Loans"; Integer)
        {
            Caption = 'Rejected Loans';
        }
        field(10; "Employees With Loans"; Integer)
        {
            Caption = 'Employees With Loans';
        }
        field(11; "Avg Outstanding Balance"; Decimal)
        {
            Caption = 'Avg Outstanding Balance';
        }
        field(12; "Max Active Loans"; Integer)
        {
            Caption = 'Max Active Loans';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}