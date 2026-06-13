namespace BCTRAINING.BCTRAINING;

codeunit 50104 "Role Centre Initialization"
{
    SingleInstance = true;

    trigger OnRun()
    begin
        InitializeRoleCentre();
    end;

    procedure InitializeRoleCentre()
    var
        LoanSetup: Record "Employee Loan Setup";
    begin
        // Initialize default setup if not exists
        if not LoanSetup.Get() then begin
            LoanSetup.Init();
            LoanSetup."Primary Key" := 'PRIMARY';
            LoanSetup."Loan Number Series" := 'LOAN';
            LoanSetup."Enable Approval Workflow" := true;
            LoanSetup."Send Notifications" := true;
            LoanSetup."Max Loans Per Employee" := 3;
            LoanSetup."Monthly Processing Day" := 1;
            LoanSetup."Auto Close Loans" := true;
            LoanSetup.Insert();
        end;
    end;

    procedure GetUserRoleType(): Text
    var
        UserRole: Text;
    begin
        if IsAdmin() then
            UserRole := 'Administrator'
        else if IsApprover() then
            UserRole := 'Approver'
        else if IsPayrollOfficer() then
            UserRole := 'Payroll Officer'
        else
            UserRole := 'Employee';

        exit(UserRole);
    end;

    procedure IsAdmin(): Boolean
    begin
        // Check if user has admin permissions
        exit(HasPermission(ObjectType::Table, 50103, Permission::Read));
    end;

    procedure IsApprover(): Boolean
    begin
        // Check if user has approval permissions
        exit(HasPermission(ObjectType::Table, 50101, Permission::Modify));
    end;

    procedure IsPayrollOfficer(): Boolean
    begin
        // Check if user is in payroll role
        exit(HasPermission(ObjectType::Codeunit, 50100, Permission::Execute));
    end;

    procedure GetDashboardSummary(var PendingCount: Integer; var ActiveCount: Integer; var OverdueCount: Integer)
    var
        LoanHeader: Record "Employee Loan Header";
        LoanSchedule: Record "Employee Loan Schedule";
    begin
        // Get pending approvals
        LoanHeader.SetRange("Status", LoanHeader."Status"::"Pending Approval");
        PendingCount := LoanHeader.Count();

        // Get active loans
        LoanHeader.SetRange("Status", LoanHeader."Status"::Disbursed);
        ActiveCount := LoanHeader.Count();

        // Get overdue payments
        LoanSchedule.SetRange("Payment Status", LoanSchedule."Payment Status"::Pending);
        LoanSchedule.SetFilter("Due Date", '<%1', Today);
        OverdueCount := LoanSchedule.Count();
    end;
}