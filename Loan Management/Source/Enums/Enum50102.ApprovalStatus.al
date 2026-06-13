namespace BCTRAINING.BCTRAINING;

enum 50102 "Loan Approval Status"
{
    Extensible = true;

    value(0; "Not Submitted")
    {
        Caption = 'Not Submitted';
    }
    value(1; "Pending")
    {
        Caption = 'Pending';
    }
    value(2; "Approved")
    {
        Caption = 'Approved';
    }
    value(3; "Rejected")
    {
        Caption = 'Rejected';
    }
}