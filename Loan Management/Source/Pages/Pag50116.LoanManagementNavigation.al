namespace BCTRAINING.BCTRAINING;

page 50116 "Loan Management Navigation"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Loan Management Navigation';

    layout
    {
        area(Content)
        {
            group(LoanManagement)
            {
                Caption = 'Loan Management';
            }

            group(Approvals)
            {
                Caption = 'Approvals';
            }

            group(Processing)
            {
                Caption = 'Processing';
            }

            group(Reporting)
            {
                Caption = 'Reports';
            }

            group(Administration)
            {
                Caption = 'Administration';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(LoanManagementGroup)
            {
                Caption = 'Loan Management';

                action(EmployeeLoans)
                {
                    Caption = 'Employee Loans';
                    Image = List;
                    //RunObject = page "Employee Loan List";
                }

                action(NewLoan)
                {
                    Caption = 'New Loan Application';
                    Image = New;
                   // RunObject = page "Employee Loan Card";
                }

                action(LoanTypes)
                {
                    Caption = 'Loan Types';
                    Image = Setup;
                   // RunObject = page "Loan Type List";
                }
            }

            group(ApprovalsGroup)
            {
                Caption = 'Approvals';

                action(PendingApprovals)
                {
                    Caption = 'Pending Approvals';
                    Image = Approvals;
                   // RunObject = page "Employee Loan List";
                }
            }

            group(ProcessingGroup)
            {
                Caption = 'Processing';

                action(DisburseLoans)
                {
                    Caption = 'Disburse Loans';
                    Image = Payment;
                    //RunObject = page "Employee Loan List";
                }

                action(RepaymentSchedules)
                {
                    Caption = 'Repayment Schedules';
                    Image = ViewDetails;
                    RunObject = page "Loan Schedule List";
                }
            }

            group(ReportsGroup)
            {
                Caption = 'Reports';

                action(LoanRegister)
                {
                    Caption = 'Loan Register';
                    Image = Report;
                    RunObject = report "Loan Register";
                }

                action(OutstandingLoans)
                {
                    Caption = 'Outstanding Loans';
                    Image = Report;
                    RunObject = report "Outstanding Loans";
                }

                action(RepaymentScheduleReport)
                {
                    Caption = 'Repayment Schedule';
                    Image = Report;
                    RunObject = report "Repayment Schedule";
                }
            }

            group(AdminGroup)
            {
                Caption = 'Administration';

                action(LoanSetup)
                {
                    Caption = 'Loan Setup';
                    Image = Setup;
                    //RunObject = page "Loan Setup Card";
                }

                action(JobQueue)
                {
                    Caption = 'Job Queue Entries';
                    Image = Job;
                    //RunObject = page "Job Queue Entries";
                }
            }
        }
    }
}