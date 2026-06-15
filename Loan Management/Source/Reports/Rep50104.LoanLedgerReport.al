namespace BCTRAINING.BCTRAINING;

report 50104 "Loan Ledger Report"
{
    ApplicationArea = All;
    Caption = 'Loan Ledger';
    DefaultLayout = RDLC;
    RDLCLayout = './Reports/LoanLedger.rdl';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(LoanLedger; "Employee Loan Ledger Entry")
        {
            RequestFilterFields = "Loan No.", "Employee No.", "Posting Date", "Document Type";

            column(Entry_No; "Entry No.")
            {
                IncludeCaption = true;
            }
            column(Loan_No; "Loan No.")
            {
                IncludeCaption = true;
            }
            column(Employee_No; "Employee No.")
            {
                IncludeCaption = true;
            }
            column(Posting_Date; "Posting Date")
            {
                IncludeCaption = true;
            }
            column(Document_Type; "Document Type")
            {
                IncludeCaption = true;
            }
            column(Description; Description)
            {
                IncludeCaption = true;
            }
            column(Amount; Amount)
            {
                IncludeCaption = true;
            }
            column(Balance; Balance)
            {
                IncludeCaption = true;
            }
            column(Created_By; "Created By")
            {
                IncludeCaption = true;
            }
            column(Created_Date; "Created Date")
            {
                IncludeCaption = true;
            }

            column(TotalAmount; TotalAmount)
            {
            }

            trigger OnPreDataItem()
            begin
                SetCurrentKey("Loan No.", "Posting Date");
                TotalAmount := 0;
            end;

            trigger OnAfterGetRecord()
            begin
                TotalAmount += Amount;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Filters)
                {
                    Caption = 'Report Filters';

                    field(FromPostingDate; FromPostingDateVar)
                    {
                        Caption = 'From Posting Date';
                        ApplicationArea = All;
                        ToolTip = 'Start date for report';
                    }

                    field(ToPostingDate; ToPostingDateVar)
                    {
                        Caption = 'To Posting Date';
                        ApplicationArea = All;
                        ToolTip = 'End date for report';
                    }

                    field(DocumentTypeFilter; DocumentTypeFilterVar)
                    {
                        Caption = 'Document Type Filter';
                        ApplicationArea = All;
                        ToolTip = 'Leave blank for all types';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            FromPostingDateVar := CalcDate('<-1M>', Today);
            ToPostingDateVar := Today;
        end;
    }

    trigger OnPreReport()
    begin
        if FromPostingDateVar <> 0D then
            LoanLedger.SetFilter("Posting Date", '>=%1', FromPostingDateVar);

        if ToPostingDateVar <> 0D then
            LoanLedger.SetFilter("Posting Date", '<=%1', ToPostingDateVar);
    end;

    var
        LoanLedgers: Record "Employee Loan Ledger Entry";
        TotalAmount: Decimal;
        FromPostingDateVar: Date;
        ToPostingDateVar: Date;
        DocumentTypeFilterVar: Text;
}