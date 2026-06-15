namespace BCTRAINING.BCTRAINING;


page 50115 "Loan Dashboard Part"
{
    PageType = CardPart;
    SourceTable = "Employee Loan Header";
    Caption = 'Loan Management Dashboard';
    Editable = false;
    
    layout
    {
        area(Content)
        {
            cuegroup(Dashboard)
            {
                Caption = 'Dashboard';
                Visible = true;
                
                // Key metric 1: Total active loans
                field(ActiveLoansCount; GetActiveLoansCount())
                {
                    ApplicationArea = All;
                    Caption = 'Active Loans';
                    ToolTip = 'Number of loans currently disbursed';
                    
                    trigger OnDrillDown()
                    var
                        LoanHeader: Record "Employee Loan Header";
                    begin
                        LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
                        Page.Run(Page::"Employee Loan List", LoanHeader);
                    end;
                }
                
                // Key metric 2: Total outstanding balance
                field(OutstandingBalance; GetOutstandingBalance())
                {
                    ApplicationArea = All;
                    Caption = 'Outstanding Balance';
                    ToolTip = 'Total amount still owed across all loans';
                }
                
                // Key metric 3: Pending approvals
                field(PendingApprovalsCount; GetPendingApprovalsCount())
                {
                    ApplicationArea = All;
                    Caption = 'Pending Approvals';
                    ToolTip = 'Loans waiting for approval';
                    Style = Attention;
                    
                    trigger OnDrillDown()
                    var
                        LoanHeader: Record "Employee Loan Header";
                    begin
                        LoanHeader.SetRange("Status", LoanHeader."Status"::"Pending Approval");
                        Page.Run(Page::"Employee Loan List", LoanHeader);
                    end;
                }
                
                // Key metric 4: Overdue payments
                field(OverduePaymentsCount; GetOverduePaymentsCount())
                {
                    ApplicationArea = All;
                    Caption = 'Overdue Payments';
                    ToolTip = 'Payments past due date';
                    Style = Unfavorable;
                    
                    trigger OnDrillDown()
                    var
                        LoanSchedule: Record "Employee Loan Schedule";
                    begin
                        LoanSchedule.SetRange("Payment Status", LoanSchedule."Payment Status"::Pending);
                        LoanSchedule.SetFilter("Due Date", '<%1', Today);
                        Page.Run(Page::"Loan Schedule List", LoanSchedule);
                    end;
                }
                
                // Key metric 5: Loans closed this month
                field(ClosedLoansMonth; GetClosedLoansThisMonth())
                {
                    ApplicationArea = All;
                    Caption = 'Closed This Month';
                    ToolTip = 'Loans fully repaid this month';
                    Style = Favorable;
                }
                
                // Key metric 6: Upcoming payments (30 days)
                field(UpcomingPayments; GetUpcomingPaymentsCount())
                {
                    ApplicationArea = All;
                    Caption = 'Upcoming Payments';
                    ToolTip = 'Payments due in next 30 days';
                }
            }
        }
    }
    
    // HELPER FUNCTIONS
    
    local procedure GetActiveLoansCount(): Integer
    var
        LoanHeader: Record "Employee Loan Header";
    begin
        LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
        exit(LoanHeader.Count());
    end;
    
    local procedure GetOutstandingBalance(): Decimal
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
    
    local procedure GetClosedLoansThisMonth(): Integer
    var
        LoanHeader: Record "Employee Loan Header";
        MonthStart: Date;
        MonthEnd: Date;
    begin
        MonthStart := CalcDate('<-CM>', Today);
        MonthEnd := CalcDate('<CM>', Today);
        LoanHeader.SetRange("Status", LoanHeader."Status"::Closed);
        LoanHeader.SetRange("Closed Date", MonthStart, MonthEnd);
        exit(LoanHeader.Count());
    end;
    
    local procedure GetUpcomingPaymentsCount(): Integer
    var
        LoanSchedule: Record "Employee Loan Schedule";
    begin
        LoanSchedule.SetRange("Payment Status", LoanSchedule."Payment Status"::Pending);
        LoanSchedule.SetRange("Due Date", Today, CalcDate('<30D>', Today));
        exit(LoanSchedule.Count());
    end;
}
