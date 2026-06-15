namespace BCTRAINING.BCTRAINING;

page 50112 "Loan Setup Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Employee Loan Setup";
    Caption = 'Loan Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;
    
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';
                
                field("Loan Number Series"; Rec."Loan Number Series")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Number series for loan numbers';
                }
                field("Enable Approval Workflow"; Rec."Enable Approval Workflow")
                {
                    ApplicationArea = All;
                    ToolTip = 'Require approval before loan can be disbursed?';
                }
                field("Send Notifications"; Rec."Send Notifications")
                {
                    ApplicationArea = All;
                    ToolTip = 'Send email notifications for loan events?';
                }
                field("Loan Approver User ID"; Rec."Loan Approver User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'User who will approve loans';
                }
            }
            
            group(Limits)
            {
                Caption = 'Employee Limits';
                
                field("Max Loans Per Employee"; Rec."Max Loans Per Employee")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum active loans per employee';
                }
                field("Default Interest Rate"; Rec."Default Interest Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Default interest rate if not specified in loan type';
                }
            }
            
            group(Processing)
            {
                Caption = 'Automatic Processing';
                
                field("Monthly Processing Day"; Rec."Monthly Processing Day")
                {
                    ApplicationArea = All;
                    ToolTip = 'Day of month to process loan payments (1-31)';
                }
                field("Auto Close Loans"; Rec."Auto Close Loans")
                {
                    ApplicationArea = All;
                    ToolTip = 'Automatically close fully repaid loans?';
                }
            }
        }
    }
    
    trigger OnOpenPage()
    begin
        // For SingleInstance table, always get the one record
        if not Rec.Get() then begin
            Rec.Insert();
        end;
    end;
}