namespace BCTRAINING.BCTRAINING;

page 50114 "Loan Management Role Centre"
{
    PageType = RoleCenter;
    ApplicationArea = All;
    Caption = 'Loan Management';

    layout
    {
        area(RoleCenter)
        {
            
        }
    }

    actions
    {
        area(Creation)
        {
            group(ApplicationActionsGroup)
            {
                Caption = 'Applications';

                action(NewLoanApplication)
                {
                    ApplicationArea = All;
                    Caption = 'New Loan Application';
                    Image = New;
                    Promoted = true;
                }
            }
        }

        area(Processing)
        {
            group(ApprovalActionsGroup)
            {
                Caption = 'Approvals';

                action(ReviewPendingApplications)
                {
                    ApplicationArea = All;
                    Caption = 'Review Pending Applications';
                    Image = ViewDetails;
                    
                }
            }

            group(DisbursementActionsGroup)
            {
                Caption = 'Disbursement';

                action(ViewApprovedLoans)
                {
                    ApplicationArea = All;
                    Caption = 'View Approved Loans';
                    Image = ViewDetails;

                }
            }

            group(PaymentProcessingGroup)
            {
                Caption = 'Payment Processing';

                action(ViewOverduePayments)
                {
                    ApplicationArea = All;
                    Caption = 'View Overdue Payments';
                    Image = Attention;
                }
            }

            group(SetupActionsGroup)
            {
                Caption = 'Setup';

                action(ManageLoanTypes)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Types';
                    Image = Setup;
                }

                action(LoanSystemSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Setup';
                    Image = Setup;
                }
            }
        }

        area(Reporting)
        {
            group(ReportActionsGroup)
            {
                Caption = 'Reports';

                action(LoanRegisterReport)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Register';
                    Image = Report;
                }
            }
        }
    }
}