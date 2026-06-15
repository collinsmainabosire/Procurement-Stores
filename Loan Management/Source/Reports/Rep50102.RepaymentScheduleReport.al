namespace BCTRAINING.BCTRAINING;

report 50102 "Repayment Schedule Report"
{
    ApplicationArea = All;
    Caption = 'Repayment Schedule';
    DefaultLayout = RDLC;
    RDLCLayout = './Reports/RepaymentSchedule.rdl';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(LoanHeader; "Employee Loan Header")
        {
            RequestFilterFields = "Loan No.", "Employee No.", "Status";

            column(Loan_No; "Loan No.")
            {
                IncludeCaption = true;
            }
            column(Employee_No; "Employee No.")
            {
                IncludeCaption = true;
            }
            column(Employee_Name; "Employee Name")
            {
                IncludeCaption = true;
            }
            column(Loan_Type; "Loan Type")
            {
                IncludeCaption = true;
            }
            column(Approved_Amount; "Approved Amount")
            {
                IncludeCaption = true;
            }
            column(Interest_Rate; "Interest Rate")
            {
                IncludeCaption = true;
            }
            column(Total_Amount; "Total Amount")
            {
                IncludeCaption = true;
            }
            column(Term_Months; "Term Months")
            {
                IncludeCaption = true;
            }
            column(Disbursement_Date; "Disbursement Date")
            {
                IncludeCaption = true;
            }
            column(Outstanding_Balance; "Outstanding Balance")
            {
                IncludeCaption = true;
            }
            column(Status; Status)
            {
                IncludeCaption = true;
            }

            dataitem(LoanSchedule; "Employee Loan Schedule")
            {
                DataItemLink = "Loan No." = field("Loan No.");

                column(Installment_No; "Installment No.")
                {
                    IncludeCaption = true;
                }
                column(Due_Date; "Due Date")
                {
                    IncludeCaption = true;
                }
                column(Principal_Amount; "Principal Amount")
                {
                    IncludeCaption = true;
                }
                column(Interest_Amount; "Interest Amount")
                {
                    IncludeCaption = true;
                }
                column(Total_InstAmount; "Total Amount")
                {
                    IncludeCaption = true;
                }
                column(Paid_Amount; "Paid Amount")
                {
                    IncludeCaption = true;
                }
                column(Remaining_Balance; "Remaining Balance")
                {
                    IncludeCaption = true;
                }
                column(Payment_Status; "Payment Status")
                {
                    IncludeCaption = true;
                }
                column(Payment_Date; "Payment Date")
                {
                    IncludeCaption = true;
                }

                column(IsOverdue; IsOverdue())
                {
                }

                trigger OnPreDataItem()
                begin
                    // Sort by installment number
                    SetCurrentKey("Loan No.", "Installment No.");
                end;
            }
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

                    field(ShowPaidOnly; ShowPaidOnlyVar)
                    {
                        Caption = 'Show Paid Installments Only';
                        ApplicationArea = All;
                        ToolTip = 'Show only payments that have been made?';
                    }

                    field(ShowPendingOnly; ShowPendingOnlyVar)
                    {
                        Caption = 'Show Pending Installments Only';
                        ApplicationArea = All;
                        ToolTip = 'Show only payments that are pending?';
                    }
                }
            }
        }
    }

    local procedure IsOverdue(): Boolean
    begin
        // Check if payment is overdue (due date is in past and not paid)
        if (LoanSchedule."Due Date" < Today) and
           (LoanSchedule."Payment Status" = LoanSchedule."Payment Status"::Pending) then
            exit(true);

        exit(false);
    end;

    var
        LoanSchedules: Record "Employee Loan Schedule";
        ShowPaidOnlyVar: Boolean;
        ShowPendingOnlyVar: Boolean;
}