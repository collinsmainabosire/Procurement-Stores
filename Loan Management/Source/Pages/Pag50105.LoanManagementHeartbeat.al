namespace BCTRAINING.BCTRAINING;

page 50105 "Loan Management Heartbeat"
{
    PageType = CardPart;
    SourceTable = "Employee Loan Header";
    Caption = 'Dashboard';

    layout
    {
        area(Content)
        {
            group(DashboardGroup)
            {
                ShowCaption = false;

                field(DashboardTitle; 'Loan Management Dashboard')
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Strong;
                }

                group(KeyMetrics)
                {
                    ShowCaption = false;

                    grid(MetricsGrid)
                    {
                        GridLayout = Columns;

                        field(TotalLoansMetric; 'Total Loans')
                        {
                            ApplicationArea = All;
                            Editable = false;
                        }
                        field(TotalLoansValue; GetTotalLoansCount())
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Style = Strong;
                        }

                        field(ActiveLoansMetric; 'Active Loans')
                        {
                            ApplicationArea = All;
                            Editable = false;
                        }
                        field(ActiveLoansValue; GetActiveLoansCount())
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Style = Strong;
                        }

                        field(TotalOutstandingMetric; 'Total Outstanding')
                        {
                            ApplicationArea = All;
                            Editable = false;
                        }
                        field(TotalOutstandingValue; GetTotalOutstandingBalance())
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Style = Strong;
                        }

                        field(PendingApprovalsMetric; 'Pending Approvals')
                        {
                            ApplicationArea = All;
                            Editable = false;
                        }
                        field(PendingApprovalsValue; GetPendingApprovalsCount())
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Style = Attention;
                        }

                        field(OverduePaymentsMetric; 'Overdue Payments')
                        {
                            ApplicationArea = All;
                            Editable = false;
                        }
                        field(OverduePaymentsValue; GetOverduePaymentsCount())
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Style = Attention;
                        }

                        field(TotalCollectedMetric; 'Total Collected')
                        {
                            ApplicationArea = All;
                            Editable = false;
                        }
                        field(TotalCollectedValue; GetTotalCollectedAmount())
                        {
                            ApplicationArea = All;
                            Editable = false;
                            Style = Strong;
                        }
                    }
                }
            }
        }
    }

    var
        HeartbeatData: Record "Employee Loan Header";

    local procedure GetTotalLoansCount(): Integer
    var
        LoanHeader: Record "Employee Loan Header";
    begin
        exit(LoanHeader.Count());
    end;

    local procedure GetActiveLoansCount(): Integer
    var
        LoanHeader: Record "Employee Loan Header";
    begin
        LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
        exit(LoanHeader.Count());
    end;

    local procedure GetTotalOutstandingBalance(): Decimal
    var
        LoanHeader: Record "Employee Loan Header";
        TotalBalance: Decimal;
    begin
        LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
        if LoanHeader.FindSet() then
            repeat
                TotalBalance += LoanHeader."Outstanding Balance";
            until LoanHeader.Next() = 0;
        exit(TotalBalance);
    end;

    local procedure GetPendingApprovalsCount(): Integer
    var
        LoanHeader: Record "Employee Loan Header";
    begin
        LoanHeader.SetRange("Status", LoanHeader."Status"::"Pending Approval");
        exit(LoanHeader.Count());
    end;

    local procedure GetOverduePaymentsCount(): Integer
    var
        LoanSchedule: Record "Employee Loan Schedule";
    begin
        LoanSchedule.SetRange("Payment Status", LoanSchedule."Payment Status"::Pending);
        LoanSchedule.SetFilter("Due Date", '<%1', Today);
        exit(LoanSchedule.Count());
    end;

    local procedure GetTotalCollectedAmount(): Decimal
    var
        LoanHeader: Record "Employee Loan Header";
        TotalCollected: Decimal;
    begin
        LoanHeader.SetRange("Status", LoanHeader."Status"::Closed);
        if LoanHeader.FindSet() then
            repeat
                TotalCollected += LoanHeader."Total Paid";
            until LoanHeader.Next() = 0;
        exit(TotalCollected);
    end;
}