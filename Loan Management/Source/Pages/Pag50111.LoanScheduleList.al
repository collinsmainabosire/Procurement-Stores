namespace BCTRAINING.BCTRAINING;

page 50111 "Loan Schedule List"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Employee Loan Schedule";
    Caption = 'Loan Schedule';
    Editable = false;
    
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Loan number';
                }
                field("Installment No."; Rec."Installment No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Installment sequence number';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'When this payment is due';
                }
                field("Principal Amount"; Rec."Principal Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Principal portion of payment';
                }
                field("Interest Amount"; Rec."Interest Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Interest portion of payment';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Total payment due';
                }
                field("Paid Amount"; Rec."Paid Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount already paid';
                }
                field("Remaining Balance"; Rec."Remaining Balance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Balance remaining after this payment';
                }
                field("Payment Status"; Rec."Payment Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Status of this installment';
                    StyleExpr = PaymentStatusStyle;
                }
                field("Payment Date"; Rec."Payment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date payment was made';
                }
            }
        }
    }
    
    trigger OnAfterGetRecord()
    begin
        UpdateStyles();
    end;
    
    var
        PaymentStatusStyle: Text;
    
    local procedure UpdateStyles()
    begin
        // Color code payment status
        case Rec."Payment Status" of
            Rec."Payment Status"::Pending:
                PaymentStatusStyle := 'Attention';
            Rec."Payment Status"::Partial:
                PaymentStatusStyle := 'Warning';
            Rec."Payment Status"::Paid:
                PaymentStatusStyle := 'Favorable';
        end;
    end;
}