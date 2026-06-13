namespace BCTRAINING.BCTRAINING;

report 50100 "Loan Register"
{
    ApplicationArea = All;
    Caption = 'Loan Register';
    DefaultLayout = RDLC;
    RDLCLayout = './Reports/LoanRegister.rdl';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(LoanHeader; "Employee Loan Header")
        {
            RequestFilterFields = "Loan No.", "Employee No.", "Status", "Application Date";

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
            column(Requested_Amount; "Requested Amount")
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
            column(Application_Date; "Application Date")
            {
            }
            column(Approval_Date; "Approval Date")
            {
            }
            column(Term_Months; "Term Months")
            {
            }

            trigger OnPreDataItem()
            begin
                LoanHeader.SetCurrentKey("Loan No.");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Filters)
                {
                    Caption = 'Filters';

                    field(LoansFromDate; LoansFromDate)
                    {
                        Caption = 'From Application Date';
                        ApplicationArea = All;
                    }
                    field(LoansToDate; LoansToDate)
                    {
                        Caption = 'To Application Date';
                        ApplicationArea = All;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            LoansFromDate := CalcDate('<-1M>', Today);
            LoansToDate := Today;
        end;
    }

    var
        LoansFromDate: Date;
        LoansToDate: Date;
}