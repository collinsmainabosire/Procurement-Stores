namespace BCTRAINING.BCTRAINING;
using Microsoft.HumanResources.Employee;
using System.Email;

codeunit 50106 "Loan Notification Management"
{
    Permissions = tabledata "Email Item" = im;

    trigger OnRun()
    begin
    end;

    /// <summary>
    /// Sends approval notification email
    /// </summary>
    procedure SendApprovalEmail(LoanHeader: Record "Employee Loan Header")
    var
        EmailItem: Record "Email Item";
        LoanSetup: Record "Employee Loan Setup";
        EmailBody: Text;
        Subject: Text;
    begin
        LoanSetup.Get();

        if not LoanSetup."Send Notifications" then
            exit;

        Subject := StrSubstNo('Loan Application %1 - Pending Approval', LoanHeader."Loan No.");
        EmailBody := GetApprovalEmailBody(LoanHeader);

        SendEmail(LoanSetup."Loan Approver User ID", Subject, EmailBody);
    end;

    /// <summary>
    /// Sends approval confirmation notification
    /// </summary>
    procedure SendApprovalConfirmation(LoanHeader: Record "Employee Loan Header")
    var
        Employee: Record Employee;
        EmailBody: Text;
        Subject: Text;
        EmployeeEmail: Text;
    begin
        if not Employee.Get(LoanHeader."Employee No.") then
            exit;

        if Employee."E-Mail" = '' then
            exit;

        Subject := StrSubstNo('Your Loan Application %1 Has Been Approved', LoanHeader."Loan No.");
        EmailBody := GetApprovalConfirmationBody(LoanHeader);
        EmployeeEmail := Employee."E-Mail";

        SendEmail(EmployeeEmail, Subject, EmailBody);
    end;

    /// <summary>
    /// Sends rejection notification email
    /// </summary>
    procedure SendRejectionEmail(LoanHeader: Record "Employee Loan Header"; RejectionReason: Text[500])
    var
        Employee: Record Employee;
        EmailBody: Text;
        Subject: Text;
        EmployeeEmail: Text;
    begin
        if not Employee.Get(LoanHeader."Employee No.") then
            exit;

        if Employee."E-Mail" = '' then
            exit;

        Subject := StrSubstNo('Your Loan Application %1 Has Been Rejected', LoanHeader."Loan No.");
        EmailBody := GetRejectionEmailBody(LoanHeader, RejectionReason);
        EmployeeEmail := Employee."E-Mail";

        SendEmail(EmployeeEmail, Subject, EmailBody);
    end;

    /// <summary>
    /// Sends loan closure notification
    /// </summary>
    procedure SendClosureEmail(LoanNo: Code[20])
    var
        LoanHeader: Record "Employee Loan Header";
        Employee: Record Employee;
        EmailBody: Text;
        Subject: Text;
        EmployeeEmail: Text;
    begin
        if not LoanHeader.Get(LoanNo) then
            exit;

        if not Employee.Get(LoanHeader."Employee No.") then
            exit;

        if Employee."E-Mail" = '' then
            exit;

        Subject := StrSubstNo('Your Loan %1 Has Been Fully Repaid', LoanNo);
        EmailBody := GetClosureEmailBody(LoanHeader);
        EmployeeEmail := Employee."E-Mail";

        SendEmail(EmployeeEmail, Subject, EmailBody);
    end;

    /// <summary>
    /// Gets approval email body
    /// </summary>
    local procedure GetApprovalEmailBody(LoanHeader: Record "Employee Loan Header"): Text
    var
        EmailBody: Text;
    begin
        EmailBody := StrSubstNo(
            'Dear Loan Approver,\n\n' +
            'A new loan application requires your approval.\n\n' +
            'Loan No.: %1\n' +
            'Employee: %2\n' +
            'Loan Type: %3\n' +
            'Amount: %4\n' +
            'Term: %5 months\n' +
            'Purpose: %6\n' +
            'Application Date: %7\n\n' +
            'Please review and approve or reject the application.\n\n' +
            'Regards,\nSystem',
            LoanHeader."Loan No.", LoanHeader."Employee Name", LoanHeader."Loan Type",
            Format(LoanHeader."Requested Amount", 0, '<Sign>'),
            LoanHeader."Term Months", LoanHeader."Purpose", Format(LoanHeader."Application Date"));

        exit(EmailBody);
    end;

    /// <summary>
    /// Gets approval confirmation email body
    /// </summary>
    local procedure GetApprovalConfirmationBody(LoanHeader: Record "Employee Loan Header"): Text
    var
        EmailBody: Text;
    begin
        EmailBody := StrSubstNo(
            'Dear %1,\n\n' +
            'We are pleased to inform you that your loan application has been approved.\n\n' +
            'Loan Details:\n' +
            'Loan No.: %2\n' +
            'Approved Amount: %3\n' +
            'Term: %4 months\n' +
            'Interest Rate: %5%\n' +
            'Total Amount: %6\n' +
            'Approved By: %7\n' +
            'Approval Date: %8\n\n' +
            'Your loan will be disbursed shortly. You will receive further communication regarding the disbursement date.\n\n' +
            'Regards,\nHuman Resources Department',
            LoanHeader."Employee Name", LoanHeader."Loan No.",
            Format(LoanHeader."Approved Amount", 0, '<Sign>'),
            LoanHeader."Term Months",
            Format(LoanHeader."Interest Rate", 0, '<Sign>'),
            Format(LoanHeader."Total Amount", 0, '<Sign>'),
            LoanHeader."Approved By", Format(LoanHeader."Approval Date"));

        exit(EmailBody);
    end;

    /// <summary>
    /// Gets rejection email body
    /// </summary>
    local procedure GetRejectionEmailBody(LoanHeader: Record "Employee Loan Header"; RejectionReason: Text[500]): Text
    var
        EmailBody: Text;
    begin
        EmailBody := StrSubstNo(
            'Dear %1,\n\n' +
            'We regret to inform you that your loan application has been rejected.\n\n' +
            'Loan Details:\n' +
            'Loan No.: %2\n' +
            'Amount Applied: %3\n' +
            'Term: %4 months\n\n' +
            'Reason for Rejection:\n%5\n\n' +
            'If you have any questions, please contact the Human Resources Department.\n\n' +
            'Regards,\nHuman Resources Department',
            LoanHeader."Employee Name", LoanHeader."Loan No.",
            Format(LoanHeader."Requested Amount", 0, '<Sign>'),
            LoanHeader."Term Months", RejectionReason);

        exit(EmailBody);
    end;

    /// <summary>
    /// Gets closure email body
    /// </summary>
    local procedure GetClosureEmailBody(LoanHeader: Record "Employee Loan Header"): Text
    var
        EmailBody: Text;
    begin
        EmailBody := StrSubstNo(
            'Dear %1,\n\n' +
            'Congratulations! Your loan has been fully repaid and closed.\n\n' +
            'Loan Details:\n' +
            'Loan No.: %2\n' +
            'Original Amount: %3\n' +
            'Total Amount Paid: %4\n' +
            'Closure Date: %5\n\n' +
            'Thank you for on-time repayments.\n\n' +
            'Regards,\nPayroll Department',
            LoanHeader."Employee Name", LoanHeader."Loan No.",
            Format(LoanHeader."Approved Amount", 0, '<Sign>'),
            Format(LoanHeader."Total Paid", 0, '<Sign>'),
            Format(LoanHeader."Closed Date"));

        exit(EmailBody);
    end;

    /// <summary>
    /// Generic email sending procedure
    /// </summary>
    local procedure SendEmail(RecipientEmail: Text; Subject: Text; Body: Text)
    var
        Email: Codeunit  Email;
        EmailMessage: Codeunit "Email Message";
    begin
        EmailMessage.Create(RecipientEmail, Subject, Body);
        Email.Send(EmailMessage);
    end;
}