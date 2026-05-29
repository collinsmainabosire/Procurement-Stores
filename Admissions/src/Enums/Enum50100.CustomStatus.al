namespace BCTRAINING.BCTRAINING;

enum 50100 "Custom Status"
{
    Extensible = true;

    value(0; Open)
    {
        Caption = 'Open';
    }

    value(1; "Pending Approval")
    {
        Caption = 'Pending Approval';
    }

    value(2; Approved)
    {
        Caption = 'Approved';
    }

    value(3; Rejected)
    {
        Caption = 'Rejected';
    }

}
