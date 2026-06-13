namespace BCTRAINING.BCTRAINING;

page 50113 "Loans Setup Card"
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
                }
                field("Enable Approval Workflow"; Rec."Enable Approval Workflow")
                {
                    ApplicationArea = All;
                }
                field("Send Notifications"; Rec."Send Notifications")
                {
                    ApplicationArea = All;
                }
                field("Loan Approver User ID"; Rec."Loan Approver User ID")
                {
                    ApplicationArea = All;
                }
            }

            group(Limits)
            {
                Caption = 'Employee Limits';

                field("Max Loans Per Employee"; Rec."Max Loans Per Employee")
                {
                    ApplicationArea = All;
                }
                field("Default Interest Rate"; Rec."Default Interest Rate")
                {
                    ApplicationArea = All;
                }
            }

            group(Processing)
            {
                Caption = 'Processing Settings';

                field("Monthly Processing Day"; Rec."Monthly Processing Day")
                {
                    ApplicationArea = All;
                }
                field("Auto Close Loans"; Rec."Auto Close Loans")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Primary Key", 'PRIMARY');
        if not Rec.FindFirst() then begin
            Rec."Primary Key" := 'PRIMARY';
            Rec.Insert();
        end;
    end;
}