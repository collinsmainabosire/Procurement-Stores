namespace BCTRAINING.BCTRAINING;
using Microsoft.Foundation.NoSeries;

page 50120 "Loan Management Navigation"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    Caption = 'Loan Management Navigation';

    actions
    {
        area(Creation)
        {
            action(NewLoan)
            {
                ApplicationArea = All;
                Caption = 'New Loan';
                Image = DocumentNew;
                RunObject = page "Employees Loan Card";
                RunPageMode = Create;
            }
        }

        area(Processing)
        {
            group(Loans)
            {
                Caption = 'Loans';

                action(EmployeeLoans)
                {
                    ApplicationArea = All;
                    Caption = 'Employee Loans';
                    RunObject = page "Employees Loan List";
                }

                action(LoanTypes)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Types';
                    RunObject = page "Loans Type List";
                }

                action(LoanSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Setup';
                    RunObject = page "Loans Setup Card";
                }
            }

            group(Schedules)
            {
                Caption = 'Schedules';

                action(RepaymentSchedules)
                {
                    ApplicationArea = All;
                    Caption = 'Repayment Schedules';
                    RunObject = page "Loan Schedule List";
                }

                action(LoanLedgerEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Ledger Entries';
                    RunObject = page "Loan Ledger List";
                }
            }

            group(Administration)
            {
                Caption = 'Administration';

                action(NoSeries)
                {
                    ApplicationArea = All;
                    Caption = 'No. Series';
                    RunObject = page  "No. Series";
                }

                action(JobQueueEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Job Queue Entries';
                  //  RunObject = page "Job Queue Entries";
                }

                action(JobQueueLogEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Job Queue Log Entries';
                   // RunObject = page "Job Queue Log Entries";
                }
            }
        }

        area(Reporting)
        {
            action(LoanRegister)
            {
                ApplicationArea = All;
                Caption = 'Loan Register';
                RunObject = report "Loan Register";
            }

            action(OutstandingLoans)
            {
                ApplicationArea = All;
                Caption = 'Outstanding Loans';
                RunObject = report "Outstanding Loans";
            }

            action(RepaymentSchedule)
            {
                ApplicationArea = All;
                Caption = 'Repayment Schedule';
                RunObject = report "Repayment Schedule";
            }
        }
    }
}