

page 50116 "Loan Approvals Part"
{
    PageType = ListPart;
    SourceTable = "Employee Loan Header";
    Caption = 'Pending Approvals';
    Editable = false;
    
    layout
    {
        area(Content)
        {
            repeater(ApprovalsList)
            {
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Loan number';
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Employee requesting the loan';
                }
                field("Requested Amount"; Rec."Requested Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount requested';
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date application submitted';
                }
            }
        }
    }
    
    trigger OnOpenPage()
    begin
        // Only show pending approvals
        Rec.SetRange("Status", Rec."Status"::"Pending Approval");
        Rec.SetCurrentKey("Application Date");
    end;
}