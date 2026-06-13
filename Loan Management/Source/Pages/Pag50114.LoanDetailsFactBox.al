namespace BCTRAINING.BCTRAINING;

page 50114 "Loan Details FactBox"
{
    PageType = CardPart;
    SourceTable = "Employee Loan Header";
    Caption = 'Loan Details';

    layout
    {
        area(Content)
        {
            group(Details)
            {
                field("Approved Amount"; Rec."Approved Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Outstanding Balance"; Rec."Outstanding Balance")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Paid"; Rec."Total Paid")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}