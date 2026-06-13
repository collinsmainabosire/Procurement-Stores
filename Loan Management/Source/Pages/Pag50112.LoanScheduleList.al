namespace BCTRAINING.BCTRAINING;

page 50112 "Loan Schedule List"
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
                }
                field("Installment No."; Rec."Installment No.")
                {
                    ApplicationArea = All;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                }
                field("Principal Amount"; Rec."Principal Amount")
                {
                    ApplicationArea = All;
                }
                field("Interest Amount"; Rec."Interest Amount")
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
                field("Paid Amount"; Rec."Paid Amount")
                {
                    ApplicationArea = All;
                }
                field("Remaining Balance"; Rec."Remaining Balance")
                {
                    ApplicationArea = All;
                }
                field("Payment Status"; Rec."Payment Status")
                {
                    ApplicationArea = All;
                }
                field("Payment Date"; Rec."Payment Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}