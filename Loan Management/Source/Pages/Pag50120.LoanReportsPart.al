namespace BCTRAINING.BCTRAINING;
using Microsoft.Foundation.Reporting;

page 50120 "Loan Reports Part"
{
    PageType = ListPart;
    SourceTable = "Report Selections";
    Caption = 'Reports';
    Editable = false;

    layout
    {
        area(Content)
        {
            group(ReportGroup)
            {
                ShowCaption = false;

                field(RegisterReport; 'Loan Register')
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Report.Run(Report::"Loan Register");
                    end;
                }

                field(OutstandingReport; 'Outstanding Loans')
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Report.Run(Report::"Outstanding Loans");
                    end;
                }

                field(ScheduleReport; 'Repayment Schedule')
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Report.Run(Report::"Repayment Schedule Report");
                    end;
                }

                field(SummaryReport; 'Loan Summary')
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Report.Run(Report::"Employee Loan Summary");
                    end;
                }

                field(LedgerReport; 'Transaction Ledger')
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Report.Run(Report::"Loan Ledger Report");
                    end;
                }
            }
        }
    }
}