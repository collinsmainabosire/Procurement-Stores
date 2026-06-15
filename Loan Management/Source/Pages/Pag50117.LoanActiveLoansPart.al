namespace BCTRAINING.BCTRAINING;

page 50117 "Loan Active Loans Part"
{
    PageType = ListPart;
    SourceTable = "Employee Loan Header";
    Caption = 'Active Loans';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(ActiveLoansList)
            {
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Loan number';
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Employee';
                }
                field("Outstanding Balance"; Rec."Outstanding Balance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount still owed';
                    Style = Attention;
                }
                field("Total Paid"; Rec."Total Paid")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount paid to date';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Status", Rec."Status"::Disbursed);
        Rec.SetCurrentKey("Loan No.");
    end;
}