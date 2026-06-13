namespace BCTRAINING.BCTRAINING;

page 50118 "Loan Activities"
{
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = "Loan Cue";
    Caption = 'Loan Activities';
    Editable = false;
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            cuegroup(PendingApprovals)
            {
                Caption = 'Pending Approvals';
                Visible = IsApprover;

                field(PendingApprovalsCount; Rec."Pending Approvals")
                {
                    ApplicationArea = All;
                    Caption = 'Pending Approvals';
                    ToolTip = 'Number of loans pending approval';

                    trigger OnDrillDown()
                    var
                        LoanHeader: Record "Employee Loan Header";
                    begin
                        LoanHeader.SetRange("Status", LoanHeader."Status"::"Pending Approval");
                        Page.Run(Page::"Employee Loan List", LoanHeader);
                    end;
                }

                field(ApprovedNotDisbursedCount; Rec."Approved Not Disbursed")
                {
                    ApplicationArea = All;
                    Caption = 'Approved - Not Disbursed';
                    ToolTip = 'Loans approved but not yet disbursed';

                    trigger OnDrillDown()
                    var
                        LoanHeader: Record "Employee Loan Header";
                    begin
                        LoanHeader.SetRange("Status", LoanHeader."Status"::Approved);
                        Page.Run(Page::"Employee Loan List", LoanHeader);
                    end;
                }
            }

            cuegroup(ActiveLoans)
            {
                Caption = 'Active Loans';

                field(ActiveLoansCount; Rec."Active Loans")
                {
                    ApplicationArea = All;
                    Caption = 'Active Loans';
                    ToolTip = 'Number of active loans';

                    trigger OnDrillDown()
                    var
                        LoanHeader: Record "Employee Loan Header";
                    begin
                        LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
                        Page.Run(Page::"Employee Loan List", LoanHeader);
                    end;
                }

                field(OutstandingBalanceAmount; Rec."Outstanding Balance")
                {
                    ApplicationArea = All;
                    Caption = 'Outstanding Balance';
                    ToolTip = 'Total outstanding balance across active loans';
                }

                field(UpcomingPaymentsCount; Rec."Upcoming Payments")
                {
                    ApplicationArea = All;
                    Caption = 'Upcoming Payments (30 Days)';
                    ToolTip = 'Payments due in the next 30 days';

                    trigger OnDrillDown()
                    var
                        LoanSchedule: Record "Employee Loan Schedule";
                    begin
                        LoanSchedule.SetRange("Payment Status", LoanSchedule."Payment Status"::Pending);
                        LoanSchedule.SetRange("Due Date", Today, CalcDate('<30D>', Today));
                        Page.Run(Page::"Loan Schedule List", LoanSchedule);
                    end;
                }

                field(OverduePaymentsCount; Rec."Overdue Payments")
                {
                    ApplicationArea = All;
                    Caption = 'Overdue Payments';
                    ToolTip = 'Number of overdue payments';
                    Style = Attention;

                    trigger OnDrillDown()
                    var
                        LoanSchedule: Record "Employee Loan Schedule";
                    begin
                        LoanSchedule.SetRange("Payment Status", LoanSchedule."Payment Status"::Pending);
                        LoanSchedule.SetFilter("Due Date", '<%1', Today);
                        Page.Run(Page::"Loan Schedule List", LoanSchedule);
                    end;
                }
            }

            cuegroup(ClosedLoans)
            {
                Caption = 'Closed Loans';

                field(ClosedLoansThisMonthCount; Rec."Closed This Month")
                {
                    ApplicationArea = All;
                    Caption = 'Closed This Month';
                    ToolTip = 'Number of loans closed this month';

                    trigger OnDrillDown()
                    var
                        LoanHeader: Record "Employee Loan Header";
                        MonthStart: Date;
                        MonthEnd: Date;
                    begin
                        MonthStart := CalcDate('<-CM>', Today);
                        MonthEnd := CalcDate('<CM>', Today);
                        LoanHeader.SetRange("Status", LoanHeader."Status"::Closed);
                        LoanHeader.SetRange("Closed Date", MonthStart, MonthEnd);
                        Page.Run(Page::"Employee Loan List", LoanHeader);
                    end;
                }

                field(RejectedLoansCount; Rec."Rejected Loans")
                {
                    ApplicationArea = All;
                    Caption = 'Rejected Loans';
                    ToolTip = 'Number of rejected loan applications';

                    trigger OnDrillDown()
                    var
                        LoanHeader: Record "Employee Loan Header";
                    begin
                        LoanHeader.SetRange("Status", LoanHeader."Status"::Rejected);
                        Page.Run(Page::"Employee Loan List", LoanHeader);
                    end;
                }
            }

            cuegroup(EmployeeStatistics)
            {
                Caption = 'Employee Statistics';
                Visible = IsAdmin or IsPayrollOfficer;

                field(EmployeesWithLoansCount; Rec."Employees With Loans")
                {
                    ApplicationArea = All;
                    Caption = 'Employees with Loans';
                    ToolTip = 'Employees with active loans';
                }

                field(AverageOutstandingBalance; Rec."Avg Outstanding Balance")
                {
                    ApplicationArea = All;
                    Caption = 'Avg Outstanding Balance';
                }

                field(MaxActiveLoans; Rec."Max Active Loans")
                {
                    ApplicationArea = All;
                    Caption = 'Max Active Loans (Employee)';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Manage)
            {
                Caption = 'Manage';

                action(NewLoan)
                {
                    ApplicationArea = All;
                    Caption = 'New Loan';
                    Image = DocumentNew;
                    RunObject = page "Employee Loan Card";
                    RunPageMode = Create;
                    ToolTip = 'Create a new loan application';
                }

                action(EmployeeLoans)
                {
                    ApplicationArea = All;
                    Caption = 'Employee Loans';
                    Image = List;
                    RunObject = page "Employee Loan List";
                    ToolTip = 'Open loan list';
                }

                action(LoanTypes)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Types';
                    Image = Setup;
                    RunObject = page "Loan Type List";
                    ToolTip = 'Maintain loan types';
                }
            }

            group(Process)
            {
                Caption = 'Process';

                action(DisburseLoans)
                {
                    ApplicationArea = All;
                    Caption = 'Disburse Loans';
                    Image = Payment;
                    RunObject = page "Employee Loan List";
                    ToolTip = 'Open approved loans for disbursement';
                }

                action(RepaymentSchedules)
                {
                    ApplicationArea = All;
                    Caption = 'Repayment Schedules';
                    Image = DocumentList;
                    RunObject = page "Loan Schedule List";
                    ToolTip = 'View repayment schedules';
                }

                action(ProcessMonthlyDeductions)
                {
                    ApplicationArea = All;
                    Caption = 'Process Monthly Deductions';
                    Image = Process;
                    ToolTip = 'Run monthly loan deduction processing';
                    Visible = IsAdmin or IsPayrollOfficer;

                    trigger OnAction()
                    var
                        LoanManagement: Codeunit "Loan Management";
                    begin
                        if Confirm('Process monthly loan deductions now?', false) then begin
                            LoanManagement.ProcessMonthlyDeductions();
                            Message('Monthly loan deductions processed.');
                            CalculateMetrics();
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }

            group(Reports)
            {
                Caption = 'Reports';

                action(LoanRegisterReport)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Register';
                    Image = Report;
                    RunObject = report "Loan Register";
                }

                action(OutstandingLoansReport)
                {
                    ApplicationArea = All;
                    Caption = 'Outstanding Loans';
                    Image = Report;
                    RunObject = report "Outstanding Loans";
                }

                action(RepaymentScheduleReport)
                {
                    ApplicationArea = All;
                    Caption = 'Repayment Schedule';
                    Image = Report;
                    RunObject = report "Repayment Schedule";
                }
            }

            group(Administration)
            {
                Caption = 'Administration';
                Visible = IsAdmin;

                action(LoanSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Setup';
                    Image = Setup;
                    RunObject = page "Loan Setup Card";
                }

                action(NumberSeries)
                {
                    ApplicationArea = All;
                    Caption = 'Number Series';
                    Image = NumberSetup;
                    RunObject = page "No. Series";
                }

                action(JobQueueEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Job Queue Entries';
                    Image = TaskList;
                    RunObject = page "Job Queue Entries";
                }

                action(JobQueueLogs)
                {
                    ApplicationArea = All;
                    Caption = 'Job Queue Logs';
                    Image = Log;
                    RunObject = page "Job Queue Log Entries";
                }

                action(AuditTrail)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Ledger Entries';
                    Image = Audit;
                    RunObject = page "Loan Ledger List";
                }
            }

            group(Links)
            {
                Caption = 'Quick Links';

                action(Employees)
                {
                    ApplicationArea = All;
                    Caption = 'Employees';
                    Image = People;
                    RunObject = page "Employee List";
                }

                action(ChartOfAccounts)
                {
                    ApplicationArea = All;
                    Caption = 'Chart of Accounts';
                    Image = General;
                    RunObject = page "Chart of Accounts";
                }
            }

            group(Help)
            {
                Caption = 'Help';

                action(UserGuide)
                {
                    ApplicationArea = All;
                    Caption = 'User Guide';
                    Image = Help;

                    trigger OnAction()
                    begin
                        Hyperlink('https://example.com/loan-management');
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        DetermineUserRole();
        EnsureCueRecord();
        CalculateMetrics();
    end;

    var
        IsAdmin: Boolean;
        IsApprover: Boolean;
        IsEmployee: Boolean;
        IsPayrollOfficer: Boolean;

    local procedure DetermineUserRole()
    begin
        // Temporary: show all tiles.
        // Replace later with permission-set / user-group logic if required.
        IsAdmin := true;
        IsApprover := true;
        IsPayrollOfficer := true;
        IsEmployee := true;
    end;

    local procedure EnsureCueRecord()
    begin
        if not Rec.Get('PRIMARY') then begin
            Rec.Init();
            Rec."Primary Key" := 'PRIMARY';
            Rec.Insert();
        end;
    end;

    local procedure CalculateMetrics()
    var
        LoanHeader: Record "Employee Loan Header";
        LoanSchedule: Record "Employee Loan Schedule";
        MonthStart: Date;
        MonthEnd: Date;
        Outstanding: Decimal;
    begin
        Rec."Pending Approvals" := CountLoansByStatus(LoanHeader."Status"::"Pending Approval");
        Rec."Approved Not Disbursed" := CountLoansByStatus(LoanHeader."Status"::Approved);
        Rec."Active Loans" := CountLoansByStatus(LoanHeader."Status"::Disbursed);
        Rec."Closed This Month" := CountClosedThisMonth();
        Rec."Rejected Loans" := CountLoansByStatus(LoanHeader."Status"::Rejected);

        Outstanding := 0;
        LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
        if LoanHeader.FindSet() then
            repeat
                Outstanding += LoanHeader."Outstanding Balance";
            until LoanHeader.Next() = 0;
        Rec."Outstanding Balance" := Outstanding;

        LoanSchedule.SetRange("Payment Status", LoanSchedule."Payment Status"::Pending);
        LoanSchedule.SetRange("Due Date", Today, CalcDate('<30D>', Today));
        Rec."Upcoming Payments" := LoanSchedule.Count();

        LoanSchedule.SetRange("Payment Status", LoanSchedule."Payment Status"::Pending);
        LoanSchedule.SetFilter("Due Date", '<%1', Today);
        Rec."Overdue Payments" := LoanSchedule.Count();

        CalculateEmployeeStatistics();

        if Rec."Employees With Loans" > 0 then
            Rec."Avg Outstanding Balance" := Rec."Outstanding Balance" / Rec."Employees With Loans"
        else
            Rec."Avg Outstanding Balance" := 0;

        Rec.Modify();
    end;

    local procedure CountLoansByStatus(Status: Enum "Loan Status"): Integer
    var
        LoanHeader: Record "Employee Loan Header";
    begin
        LoanHeader.SetRange("Status", Status);
        exit(LoanHeader.Count());
    end;

    local procedure CountClosedThisMonth(): Integer
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

    local procedure CalculateEmployeeStatistics()
    var
        LoanHeader: Record "Employee Loan Header";
        Counts: Dictionary of [Code[20], Integer];
        EmployeeNo: Code[20];
        CurrentCount: Integer;
        MaxCount: Integer;
    begin
        Rec."Employees With Loans" := 0;
        Rec."Max Active Loans" := 0;

        LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
        if not LoanHeader.FindSet() then
            exit;

        repeat
            EmployeeNo := LoanHeader."Employee No.";
            if not Counts.ContainsKey(EmployeeNo) then
                Counts.Add(EmployeeNo, 0);

            CurrentCount := Counts.Get(EmployeeNo) + 1;
            Counts.Set(EmployeeNo, CurrentCount);
        until LoanHeader.Next() = 0;

        Rec."Employees With Loans" := Counts.Count();

        foreach EmployeeNo in Counts.Keys do begin
            CurrentCount := Counts.Get(EmployeeNo);
            if CurrentCount > MaxCount then
                MaxCount := CurrentCount;
        end;

        Rec."Max Active Loans" := MaxCount;
    end;
}