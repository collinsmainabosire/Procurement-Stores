namespace BCTRAINING.BCTRAINING;

page 50108 "Loans Type List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Employee Loan Type";
    Caption = 'Loan Types';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }
                field("Maximum Amount"; Rec."Maximum Amount")
                {
                    ApplicationArea = All;
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = All;
                }
                field("Maximum Term Months"; Rec."Maximum Term Months")
                {
                    ApplicationArea = All;
                }
                field("Requires Approval"; Rec."Requires Approval")
                {
                    ApplicationArea = All;
                }
                field("Active"; Rec."Active")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EditLoanType)
            {
                Caption = 'Edit';
                Image = Edit;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Page.Run(Page::"Loan Type Card", Rec);
                end;
            }
        }
    }
}