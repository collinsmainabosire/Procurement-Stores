namespace BCTRAINING.BCTRAINING;

report 50101 "Outstanding Loans"
{
    ApplicationArea = All;
    Caption = 'Outstanding Loans';
    DefaultLayout = RDLC;
    RDLCLayout = './Reports/OutstandingLoans.rdl';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(LoanHeader; "Employee Loan Header")
        {
            RequestFilterFields = "Employee No.", "Loan Type";

            column(Loan_No; "Loan No.")
            {
            }
            column(Employee_No; "Employee No.")
            {
            }
            column(Employee_Name; "Employee Name")
            {
            }
            column(Loan_Type; "Loan Type")
            {
            }
            column(Approved_Amount; "Approved Amount")
            {
            }
            column(Outstanding_Balance; "Outstanding Balance")
            {
            }
            column(Total_Paid; "Total Paid")
            {
            }
            column(Status; Status)
            {
            }
            column(Term_Months; "Term Months")
            {
            }
            column(Disbursement_Date; "Disbursement Date")
            {
            }

            trigger OnPreDataItem()
            begin
                SetRange(Status, Status::Disbursed);
                SetFilter("Outstanding Balance", '>0');
                SetCurrentKey("Employee No.");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
    }
}