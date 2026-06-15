namespace BCTRAINING.BCTRAINING;

page 50113 "Loan Ledger List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "Employee Loan Ledger Entry";
    Caption = 'Loan Ledger';
    Editable = false;
    
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique entry number';
                }
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Loan number';
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Employee number';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date of transaction';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Type of transaction (Disbursement, Payment, etc)';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Description of transaction';
                }
                field("Amount"; Rec."Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Transaction amount';
                }
                field("Balance"; Rec."Balance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Balance after transaction';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Who created this entry';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'When entry was created';
                }
            }
        }
    }
}