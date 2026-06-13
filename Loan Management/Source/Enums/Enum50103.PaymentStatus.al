namespace BCTRAINING.BCTRAINING;

enum 50103 "Payment Status"
{
    Extensible = true;

    value(0; "Pending")
    {
        Caption = 'Pending';
    }
    value(1; "Partial")
    {
        Caption = 'Partial';
    }
    value(2; "Paid")
    {
        Caption = 'Paid';
    }
}