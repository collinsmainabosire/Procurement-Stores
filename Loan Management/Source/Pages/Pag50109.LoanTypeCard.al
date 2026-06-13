namespace BCTRAINING.BCTRAINING;

page 50109 "Loan Type Card"
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
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }
                field("Active"; Rec."Active")
                {
                    ApplicationArea = All;
                }
            }

            group(Terms)
            {
                Caption = 'Loan Terms';

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
            }

            group(System)
            {
                Caption = 'System Information';

                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Modified Date"; Rec."Modified Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}