namespace BCTRAINING.BCTRAINING;

page 50105 "Loan Type List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Employee Loan Type";
    Caption = 'Loan Types';
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique code for this loan type';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Description of the loan type';
                }
                field("Maximum Amount"; Rec."Maximum Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum loan amount allowed';
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Interest rate percentage';
                }
                field("Maximum Term Months"; Rec."Maximum Term Months")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum repayment term in months';
                }
                field("Requires Approval"; Rec."Requires Approval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Whether this loan type requires approval';
                }
                field("Active"; Rec."Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Is this loan type currently active?';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewLoanType)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = New;
                Promoted = true;
                PromotedCategory = New;
                ToolTip = 'Create a new loan type';

                trigger OnAction()
                begin
                    Page.Run(Page::"Loan Type Card");
                end;
            }

            action(EditLoanType)
            {
                ApplicationArea = All;
                Caption = 'Edit';
                Image = Edit;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Edit selected loan type';
                Enabled = (Rec."Code" <> '');

                trigger OnAction()
                begin
                    Page.Run(Page::"Loan Type Card", Rec);
                end;
            }
        }
    }
}