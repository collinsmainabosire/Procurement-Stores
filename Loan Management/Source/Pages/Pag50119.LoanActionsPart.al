namespace BCTRAINING.BCTRAINING;
using Microsoft.Foundation.Reporting;

page 50119 "Loan Actions Part"
{
    PageType = ListPart;
    SourceTable = "Report Selections";
    Caption = 'Actions';
    Editable = false;
    
    layout
    {
        area(Content)
        {
            group(ActionGroup)
            {
                ShowCaption = false;
                
                field(NewLoan; 'New Loan Application')
                {
                    ApplicationArea = All;
                    Editable = false;
                    
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Employee Loan Card");
                    end;
                }
                
                field(AllLoans; 'View All Loans')
                {
                    ApplicationArea = All;
                    Editable = false;
                    
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Employee Loan List");
                    end;
                }
                
                field(LoanTypes; 'Loan Types Setup')
                {
                    ApplicationArea = All;
                    Editable = false;
                    
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Loan Type List");
                    end;
                }
                
                field(LoanSetup; 'System Setup')
                {
                    ApplicationArea = All;
                    Editable = false;
                    
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Loan Setup Card");
                    end;
                }
                
                field(Schedules; 'Repayment Schedules')
                {
                    ApplicationArea = All;
                    Editable = false;
                    
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Loan Schedule List");
                    end;
                }
                
                field(Ledger; 'Audit Trail')
                {
                    ApplicationArea = All;
                    Editable = false;
                    
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Loan Ledger List");
                    end;
                }
            }
        }
    }
}