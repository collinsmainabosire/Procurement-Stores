namespace BCTRAINING.BCTRAINING;

page 50118 "Loan Overdue Payments Part"
{
    PageType = ListPart;
    SourceTable = "Employee Loan Schedule";
    Caption = 'Overdue Payments';
    Editable = false;
    
    layout
    {
        area(Content)
        {
            repeater(OverdueList)
            {
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Loan number';
                }
                field("Installment No."; Rec."Installment No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Installment number';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'When payment was due';
                    Style = Unfavorable;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount due';
                }
                field("Days Overdue"; GetDaysOverdue(Rec."Due Date"))
                {
                    ApplicationArea = All;
                    ToolTip = 'How many days overdue';
                    Style = Unfavorable;
                }
            }
        }
    }
    
    trigger OnOpenPage()
    begin
        // Only show pending, overdue installments
        Rec.SetRange("Payment Status", Rec."Payment Status"::Pending);
        Rec.SetFilter("Due Date", '<%1', Today);
        Rec.SetCurrentKey("Due Date");
    end;
    
    local procedure GetDaysOverdue(DueDate: Date): Integer
    begin
        if DueDate < Today then
            exit(Today - DueDate);
        exit(0);
    end;
}
