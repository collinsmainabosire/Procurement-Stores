namespace BCTRAINING.BCTRAINING;

page 50117 "Loan Management Role Centre"
{
    PageType = RoleCenter;
    ApplicationArea = All;
    Caption = 'Loan Management';

    layout
    {
        area(RoleCenter)
        {
            group(Navigation)
            {
                Caption = 'Navigation';

                part(NavigationPart; "Loan Management Navigation")
                {
                    ApplicationArea = All;
                }
            }

            group(HeaderGroup)
            {
                ShowCaption = false;

               /* part(HeartbeatPart; "Loan Management Heartbeat")
                {
                    ApplicationArea = All;
                }*/
            }

            group(Activities)
            {
                Caption = 'Activities';
                Visible = IsAdmin or IsApprover or IsPayrollOfficer;

                cuegroup(PendingApprovals)
                {
                    Caption = 'Pending Approvals';
                    Visible = IsApprover;

                    field(PendingApprovalsCount; PendingApprovalsCount)
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

                    field(ApprovedNotDisbursedCount; ApprovedNotDisbursedCount)
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

                    field(ActiveLoansCount; ActiveLoansCount)
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

                    field(OutstandingBalanceAmount; OutstandingBalanceAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Outstanding Balance';
                        ToolTip = 'Total outstanding balance across all active loans';
                    }

                    field(UpcomingPaymentsCount; UpcomingPaymentsCount)
                    {
                        ApplicationArea = All;
                        Caption = 'Upcoming Payments (30 Days)';
                        ToolTip = 'Number of payments due in next 30 days';

                        trigger OnDrillDown()
                        var
                            LoanSchedule: Record "Employee Loan Schedule";
                        begin
                            LoanSchedule.SetRange("Payment Status", LoanSchedule."Payment Status"::Pending);
                            LoanSchedule.SetRange("Due Date", Today, CalcDate('<30D>', Today));
                            Page.Run(Page::"Loan Schedule List", LoanSchedule);
                        end;
                    }

                    field(OverduePaymentsCount; OverduePaymentsCount)
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

                    field(ClosedLoansThisMonthCount; ClosedLoansThisMonthCount)
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

                    field(RejectedLoansCount; RejectedLoansCount)
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

                    field(EmployeesWithLoansCount; EmployeesWithLoansCount)
                    {
                        ApplicationArea = All;
                        Caption = 'Employees with Loans';
                        ToolTip = 'Number of employees with active loans';

                        trigger OnDrillDown()
                        var
                            LoanHeader: Record "Employee Loan Header";
                        begin
                            LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
                            Page.Run(Page::"Employee Loan List", LoanHeader);
                        end;
                    }

                    field(AverageOutstandingBalance; AverageOutstandingBalance)
                    {
                        ApplicationArea = All;
                        Caption = 'Avg Outstanding Balance';
                        ToolTip = 'Average outstanding balance per employee';
                    }

                    field(MaxActiveLoans; MaxActiveLoans)
                    {
                        ApplicationArea = All;
                        Caption = 'Max Active Loans (Employee)';
                        ToolTip = 'Maximum active loans for a single employee';
                    }
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
                    ToolTip = 'View complete loan register';
                }

                action(OutstandingLoansReport)
                {
                    ApplicationArea = All;
                    Caption = 'Outstanding Loans';
                    Image = Report;
                    RunObject = report "Outstanding Loans";
                    ToolTip = 'View outstanding loans report';
                }

                action(RepaymentScheduleReport)
                {
                    ApplicationArea = All;
                    Caption = 'Repayment Schedule';
                    Image = Report;
                    RunObject = report "Repayment Schedule";
                    ToolTip = 'View repayment schedules';
                }

                action(EmployeeLoanSummaryReport)
                {
                    ApplicationArea = All;
                    Caption = 'Employee Loan Summary';
                    Image = Report;
                    RunObject = report "Employee Loan Summary";
                    ToolTip = 'View employee loan summary';
                }

                action(LoanLedgerReport)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Ledger';
                    Image = Report;
                    RunObject = report "Loan Ledger Report";
                    ToolTip = 'View loan ledger entries';
                }
            }

            group(Maintenance)
            {
                Caption = 'Maintenance';
                Visible = IsAdmin;

                action(LoanTypesSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Types';
                    Image = Setup;
                    RunObject = page "Loan Type List";
                    ToolTip = 'Configure loan types';
                }

                action(LoanSetupAction)
                {
                    ApplicationArea = All;
                    Caption = 'Loan Setup';
                    Image = Setup;
                    RunObject = page "Loan Setup Card";
                    ToolTip = 'Configure loan management settings';
                }

                action(NumberSeriesSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Number Series';
                    Image = Setup;
                    RunObject = page "No. Series";
                    ToolTip = 'Setup number series for loans';
                }

                separator(MaintenanceSeparator1)
                {
                }

                action(JobQueueEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Job Queue Entries';
                    Image = TaskList;
                    RunObject = page "Job Queue Entries";
                    ToolTip = 'View and manage job queue entries';
                }

                action(JobQueueLogs)
                {
                    ApplicationArea = All;
                    Caption = 'Job Queue Logs';
                    Image = Log;
                    RunObject = page "Job Queue Log Entries";
                    ToolTip = 'View job queue execution logs';
                }
            }

            group(ManagementTools)
            {
                Caption = 'Management Tools';
                Visible = IsAdmin;

                action(ExportLoans)
                {
                    ApplicationArea = All;
                    Caption = 'Export Loans to Excel';
                    Image = Export;
                    ToolTip = 'Export all loans to Excel';

                    trigger OnAction()
                    var
                        LoanHeader: Record "Employee Loan Header";
                    begin
                        LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
                        Page.Run(Page::"Employee Loan List", LoanHeader);
                    end;
                }

                action(ProcessMonthlyDeductions)
                {
                    ApplicationArea = All;
                    Caption = 'Process Monthly Deductions';
                    Image = Process;
                    ToolTip = 'Manually trigger monthly loan deductions';
                    Visible = IsPayrollOfficer or IsAdmin;

                    trigger OnAction()
                    var
                        LoanManagement: Codeunit "Loan Management";
                        ConfirmDialog: Dialog;
                    begin
                        if Confirm('Are you sure you want to process monthly loan deductions?', false) then begin
                            if LoanManagement.ProcessMonthlyDeductions() then
                                Message('Monthly deductions processed successfully.')
                            else
                                Message('An error occurred during processing. Please check the logs.');
                        end;
                    end;
                }

                action(AuditTrail)
                {
                    ApplicationArea = All;
                    Caption = 'Audit Trail';
                    Image = Audit;
                    ToolTip = 'View loan audit trail';

                    trigger OnAction()
                    var
                        LoanLedger: Record "Employee Loan Ledger Entry";
                    begin
                        Page.Run(Page::"Loan Ledger List", LoanLedger);
                    end;
                }
            }

            group(MyLoans)
            {
                Caption = 'My Loans';
                Visible = IsEmployee;

                action(MyLoanApplications)
                {
                    ApplicationArea = All;
                    Caption = 'My Loan Applications';
                    Image = DocumentList;
                    RunObject = page "Employee Loan List";
                    ToolTip = 'View your loan applications';
                }

                action(ApplyForLoan)
                {
                    ApplicationArea = All;
                    Caption = 'Apply for Loan';
                    Image = DocumentNew;
                    ToolTip = 'Submit a new loan application';

                    trigger OnAction()
                    var
                        LoanHeader: Record "Employee Loan Header";
                        LoanCardPage: Page "Employee Loan Card";
                    begin
                        LoanHeader.Init();
                        LoanCardPage.SetRecord(LoanHeader);
                        LoanCardPage.Run();
                    end;
                }

                action(MyRepaymentSchedule)
                {
                    ApplicationArea = All;
                    Caption = 'My Repayment Schedule';
                    Image = DocumentList;
                    ToolTip = 'View your repayment schedule';

                    trigger OnAction()
                    var
                        LoanSchedule: Record "Employee Loan Schedule";
                        EmployeeNo: Code[20];
                    begin
                        EmployeeNo := GetCurrentEmployeeNo();
                        LoanSchedule.SetRange("Loan No.", GetEmployeeLoanNo(EmployeeNo));
                        Page.Run(Page::"Loan Schedule List", LoanSchedule);
                    end;
                }
            }

            group(QuickLinks)
            {
                Caption = 'Quick Links';

                action(Employees)
                {
                    ApplicationArea = All;
                    Caption = 'Employees';
                    Image = People;
                    RunObject = page "Employee List";
                    ToolTip = 'View employees';
                }

                action(Departments)
                {
                    ApplicationArea = All;
                    Caption = 'Departments';
                    Image = Departments;
                    ToolTip = 'View departments';
                }

                action(GeneralLedger)
                {
                    ApplicationArea = All;
                    Caption = 'General Ledger';
                    Image = General;
                    RunObject = page "General Ledger";
                    ToolTip = 'View general ledger';
                }
            }

            group(HelpAndSupport)
            {
                Caption = 'Help & Support';

                action(Documentation)
                {
                    ApplicationArea = All;
                    Caption = 'User Guide';
                    Image = Help;
                    ToolTip = 'Open user guide';

                    trigger OnAction()
                    begin
                        Hyperlink('https://your-documentation-url.com/loan-management');
                    end;
                }

                action(SupportTicket)
                {
                    ApplicationArea = All;
                    Caption = 'Submit Support Ticket';
                    Image = Email;
                    ToolTip = 'Submit a support request';

                    trigger OnAction()
                    begin
                        Hyperlink('mailto:support@yourdomain.com?subject=Loan%20Management%20Support');
                    end;
                }

                action(FAQs)
                {
                    ApplicationArea = All;
                    Caption = 'Frequently Asked Questions';
                    Image = ContactCard;
                    ToolTip = 'View FAQs';

                    trigger OnAction()
                    begin
                        Hyperlink('https://your-documentation-url.com/loan-management/faqs');
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        DetermineUserRole();
        RefreshData();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        RefreshData();
    end;

    var
        IsAdmin: Boolean;
        IsApprover: Boolean;
        IsEmployee: Boolean;
        IsPayrollOfficer: Boolean;
        PendingApprovalsCount: Integer;
        ApprovedNotDisbursedCount: Integer;
        ActiveLoansCount: Integer;
        OutstandingBalanceAmount: Decimal;
        UpcomingPaymentsCount: Integer;
        OverduePaymentsCount: Integer;
        ClosedLoansThisMonthCount: Integer;
        RejectedLoansCount: Integer;
        EmployeesWithLoansCount: Integer;
        AverageOutstandingBalance: Decimal;
        MaxActiveLoans: Integer;

    local procedure DetermineUserRole()
    begin
        // Determine user role based on permissions
        IsAdmin := HasPermission(ObjectType::Table, 50103, Permission::Read);
        IsApprover := HasPermission(ObjectType::Table, 50101, Permission::Read);
        IsPayrollOfficer := CheckIfPayrollOfficer();
        IsEmployee := true; // All users are employees
    end;

    local procedure CheckIfPayrollOfficer(): Boolean
    var
        UserPermissions: Record "User Permission";
    begin
        // Check if user has payroll-related permissions
        exit(HasPermission(ObjectType::Table, Database::Employee, Permission::Read));
    end;

    local procedure RefreshData()
    begin
        CalculateMetrics();
    end;

    local procedure CalculateMetrics()
    var
        LoanHeader: Record "Employee Loan Header";
        LoanSchedule: Record "Employee Loan Schedule";
        EmployeeNo: Text;
        MonthStart: Date;
        MonthEnd: Date;
    begin
        // Clear previous values
        PendingApprovalsCount := 0;
        ApprovedNotDisbursedCount := 0;
        ActiveLoansCount := 0;
        OutstandingBalanceAmount := 0;
        UpcomingPaymentsCount := 0;
        OverduePaymentsCount := 0;
        ClosedLoansThisMonthCount := 0;
        RejectedLoansCount := 0;
        EmployeesWithLoansCount := 0;
        AverageOutstandingBalance := 0;
        MaxActiveLoans := 0;

        // Pending Approvals
        LoanHeader.SetRange("Status", LoanHeader."Status"::"Pending Approval");
        PendingApprovalsCount := LoanHeader.Count();

        // Approved Not Disbursed
        LoanHeader.SetRange("Status", LoanHeader."Status"::Approved);
        ApprovedNotDisbursedCount := LoanHeader.Count();

        // Active Loans
        LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
        ActiveLoansCount := LoanHeader.Count();
        if LoanHeader.FindSet() then
            repeat
                OutstandingBalanceAmount += LoanHeader."Outstanding Balance";
            until LoanHeader.Next() = 0;

        // Upcoming Payments
        LoanSchedule.SetRange("Payment Status", LoanSchedule."Payment Status"::Pending);
        LoanSchedule.SetRange("Due Date", Today, CalcDate('<30D>', Today));
        UpcomingPaymentsCount := LoanSchedule.Count();

        // Overdue Payments
        LoanSchedule.SetRange("Payment Status", LoanSchedule."Payment Status"::Pending);
        LoanSchedule.SetFilter("Due Date", '<%1', Today);
        OverduePaymentsCount := LoanSchedule.Count();

        // Closed This Month
        MonthStart := CalcDate('<-CM>', Today);
        MonthEnd := CalcDate('<CM>', Today);
        LoanHeader.SetRange("Status", LoanHeader."Status"::Closed);
        LoanHeader.SetRange("Closed Date", MonthStart, MonthEnd);
        ClosedLoansThisMonthCount := LoanHeader.Count();

        // Rejected Loans
        LoanHeader.SetRange("Status", LoanHeader."Status"::Rejected);
        RejectedLoansCount := LoanHeader.Count();

        // Calculate employee statistics
        LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
        EmployeesWithLoansCount := GetDistinctEmployeeCount();

        if EmployeesWithLoansCount > 0 then
            AverageOutstandingBalance := OutstandingBalanceAmount / EmployeesWithLoansCount;
    end;

    local procedure GetDistinctEmployeeCount(): Integer
    var
        LoanHeader: Record "Employee Loan Header";
        EmployeeNos: list of [Code[20]];
    begin
        LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
        if LoanHeader.FindSet() then
            repeat
                if not EmployeeNos.Contains(LoanHeader."Employee No.") then
                    EmployeeNos.Add(LoanHeader."Employee No.");
            until LoanHeader.Next() = 0;

        exit(EmployeeNos.Count());
    end;

    local procedure GetCurrentEmployeeNo(): Code[20]
    var
        User: Record User;
    begin
        User.SetRange("User Name", UserId);
        if User.FindFirst() then
            exit(User."Employee ID");
        exit('');
    end;

    local procedure GetEmployeeLoanNo(EmployeeNo: Code[20]): Code[20]
    var
        LoanHeader: Record "Employee Loan Header";
    begin
        LoanHeader.SetRange("Employee No.", EmployeeNo);
        if LoanHeader.FindFirst() then
            exit(LoanHeader."Loan No.");
        exit('');
    end;
}