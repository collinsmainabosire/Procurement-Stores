namespace BCTRAINING.BCTRAINING;

report 50102 "Repayment Schedule"
{
    ApplicationArea = All;
    Caption = 'Repayment Schedule';
    DefaultLayout = RDLC;
    RDLCLayout = './Reports/RepaymentSchedule.rdl';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(LoanSchedule; "Employee Loan Schedule")
        {
            RequestFilterFields = "Loan No.";

            column(Loan_No; "Loan No.")
            {
            }
            column(Installment_No; "Installment No.")
            {
            }
            column(Due_Date; "Due Date")
            {
            }
            column(Principal_Amount; "Principal Amount")
            {
            }
            column(Interest_Amount; "Interest Amount")
            {
            }
            column(Total_Amount; "Total Amount")
            {
            }
            column(Paid_Amount; "Paid Amount")
            {
            }
            column(Remaining_Balance; "Remaining Balance")
            {
            }
            column(Payment_Status; "Payment Status")
            {
            }
            column(Payment_Date; "Payment Date")
            {
            }

            trigger OnPreDataItem()
            begin
                LoanSchedule.SetCurrentKey("Loan No.", "Installment No.");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
    }
}