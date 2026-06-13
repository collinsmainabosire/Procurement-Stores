namespace BCTRAINING.BCTRAINING;

page 50115 "Loan Schedule FactBox"
{
    PageType = CardPart;
    SourceTable = "Employee Loan Schedule";
    Caption = 'Schedule';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Installment No."; Rec."Installment No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Paid Amount"; Rec."Paid Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Payment Status"; Rec."Payment Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}