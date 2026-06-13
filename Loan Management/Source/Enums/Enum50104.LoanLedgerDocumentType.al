namespace BCTRAINING.BCTRAINING;

enum 50104 "Loan Ledger Document Type"
{
    Extensible = true;

    value(0; "Disbursement")
    {
        Caption = 'Disbursement';
    }
    value(1; "Payment")
    {
        Caption = 'Payment';
    }
    value(2; "Reversal")
    {
        Caption = 'Reversal';
    }
    value(3; "Interest")
    {
        Caption = 'Interest';
    }
}