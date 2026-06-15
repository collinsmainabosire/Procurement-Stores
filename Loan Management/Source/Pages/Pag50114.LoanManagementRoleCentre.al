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
            // Dashboard summary
            group(Dashboard)
            {
                ShowCaption = false;
                part(DashboardPart; "Loan Dashboard Part")
                {
                    ApplicationArea = All;
                }
            }
            
            // Key metrics and activities
            group(Activities)
            {
                Caption = 'Activities';
                
                part(ApprovalsPart; "Loan Approvals Part")
                {
                    ApplicationArea = All;
                }
                
                part(ActiveLoansPart; "Loan Active Loans Part")
                {
                    ApplicationArea = All;
                }
                
                part(OverduePaymentsPart; "Loan Overdue Payments Part")
                {
                    ApplicationArea = All;
                }
            }
            
            // Quick access to main functions
            group(MainFunctions)
            {
                Caption = 'Main Functions';
                
                part(ActionsPart; "Loan Actions Part")
                {
                    ApplicationArea = All;
                }
            }
            
            // Reports
            group(Reports)
            {
                Caption = 'Reports';
                
                part(ReportsPart; "Loan Reports Part")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
