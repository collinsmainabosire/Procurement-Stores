namespace BCTRAINING.BCTRAINING;

page 50108 "Loan Type Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Employee Loan Type";
    Caption = 'Loan Type';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Unique code for this loan type. Required.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Describe this loan type';
                }
                field("Active"; Rec."Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Check to activate this loan type';
                }
            }

            group(Terms)
            {
                Caption = 'Loan Terms';

                field("Maximum Amount"; Rec."Maximum Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum amount that can be borrowed';
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Annual interest rate percentage';
                }
                field("Maximum Term Months"; Rec."Maximum Term Months")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum repayment period in months';
                }
                field("Requires Approval"; Rec."Requires Approval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Does this loan type need manager approval?';
                }
            }

            group(System)
            {
                Caption = 'System Information';

                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Date this loan type was created';
                }
                field("Modified Date"; Rec."Modified Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Date this loan type was last modified';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SaveAndClose)
            {
                ApplicationArea = All;
                Caption = 'Save & Close';
                Image = Save;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Save and close this page';

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    CurrPage.Close();
                end;
            }
        }
    }
}