namespace BCTRAINING.BCTRAINING;
using Microsoft.HumanResources.Employee;
using System.Email;

codeunit 50106 "Loan Notification Management"
{
    Permissions = tabledata "Email Item" = im;

    /// <summary>
    /// Sends approval notification email to approver
    /// </summary>
    procedure SendApprovalEmail(LoanHeader: Record "Employee Loan Header")
    var
        LoanSetup: Record "Employee Loan Setup";
        Subject: Text;
        EmailBody: Text;
    begin
        // Get setup to check if notifications enabled
        LoanSetup.Get();

        if not LoanSetup."Send Notifications" then
            exit; // Exit silently if disabled

        // Build email subject
        Subject := StrSubstNo('Loan Application %1 - Pending Approval', LoanHeader."Loan No.");

        // Build email body
        EmailBody := GetApprovalEmailBody(LoanHeader);

        // Send to approver
        SendEmail(LoanSetup."Loan Approver User ID", Subject, EmailBody);
    end;

    /// <summary>
    /// Sends approval confirmation to employee
    /// </summary>
    procedure SendApprovalConfirmation(LoanHeader: Record "Employee Loan Header")
    var
        Employee: Record Employee;
        Subject: Text;
        EmailBody: Text;
    begin
        // Get employee email
        if not Employee.Get(LoanHeader."Employee No.") then
            exit;

        if Employee."E-Mail" = '' then
            exit; // Can't send if no email

        // Build subject
        Subject := StrSubstNo('Your Loan Application %1 Has Been Approved',
            LoanHeader."Loan No.");

        // Build body
        EmailBody := GetApprovalConfirmationBody(LoanHeader);

        // Send to employee
        SendEmail(Employee."E-Mail", Subject, EmailBody);
    end;

    /// <summary>
    /// Sends rejection notification to employee
    /// </summary>
    procedure SendRejectionEmail(
        LoanHeader: Record "Employee Loan Header";
        RejectionReason: Text[500]
    )
    var
        Employee: Record Employee;
        Subject: Text;
        EmailBody: Text;
    begin
        // Get employee email
        if not Employee.Get(LoanHeader."Employee No.") then
            exit;

        if Employee."E-Mail" = '' then
            exit;

        // Build subject
        Subject := StrSubstNo('Your Loan Application %1 Has Been Rejected',
            LoanHeader."Loan No.");

        // Build body
        EmailBody := GetRejectionEmailBody(LoanHeader, RejectionReason);

        // Send to employee
        SendEmail(Employee."E-Mail", Subject, EmailBody);
    end;

    /// <summary>
    /// Sends closure notification to employee
    /// Confirms loan fully repaid
    /// </summary>
    procedure SendClosureEmail(LoanNo: Code[20])
    var
        LoanHeader: Record "Employee Loan Header";
        Employee: Record Employee;
        Subject: Text;
        EmailBody: Text;
    begin
        // Get the loan
        if not LoanHeader.Get(LoanNo) then
            exit;

        // Get employee email
        if not Employee.Get(LoanHeader."Employee No.") then
            exit;

        if Employee."E-Mail" = '' then
            exit;

        // Build subject
        Subject := StrSubstNo('Your Loan %1 Has Been Fully Repaid', LoanNo);

        // Build body
        EmailBody := GetClosureEmailBody(LoanHeader);

        // Send to employee
        SendEmail(Employee."E-Mail", Subject, EmailBody);
    end;

    /// <summary>
    /// Builds approval request email body
    /// </summary>
    local procedure GetApprovalEmailBody(LoanHeader: Record "Employee Loan Header"): Text
    var
        EmailBody: Text;
    begin
        // StrSubstNo = String Substitution with Numbers
        // %1, %2, %3, etc. are placeholders
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
            LoanHeader."Loan No.",
            LoanHeader."Employee Name",
            LoanHeader."Loan Type",
            Format(LoanHeader."Requested Amount", 0, '<Sign>'),
            LoanHeader."Term Months",
            LoanHeader."Purpose",
            Format(LoanHeader."Application Date")
        );

        exit(EmailBody);
    end;

    /// <summary>
    /// Builds approval confirmation email body
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
            'Your loan will be disbursed shortly.\n\n' +
            'Regards,\nHR Department',
            LoanHeader."Employee Name",
            LoanHeader."Loan No.",
            Format(LoanHeader."Approved Amount", 0, '<Sign>'),
            LoanHeader."Term Months",
            Format(LoanHeader."Interest Rate", 0, '<Sign>'),
            Format(LoanHeader."Total Amount", 0, '<Sign>'),
            LoanHeader."Approved By",
            Format(LoanHeader."Approval Date")
        );

        exit(EmailBody);
    end;

    /// <summary>
    /// Builds rejection email body
    /// </summary>
    local procedure GetRejectionEmailBody(
        LoanHeader: Record "Employee Loan Header";
        RejectionReason: Text[500]
    ): Text
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
            'If you have any questions, please contact HR.\n\n' +
            'Regards,\nHR Department',
            LoanHeader."Employee Name",
            LoanHeader."Loan No.",
            Format(LoanHeader."Requested Amount", 0, '<Sign>'),
            LoanHeader."Term Months",
            RejectionReason
        );

        exit(EmailBody);
    end;

    /// <summary>
    /// Builds loan closure email body
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
            LoanHeader."Employee Name",
            LoanHeader."Loan No.",
            Format(LoanHeader."Approved Amount", 0, '<Sign>'),
            Format(LoanHeader."Total Paid", 0, '<Sign>'),
            Format(LoanHeader."Closed Date")
        );

        exit(EmailBody);
    end;

    /// <summary>
    /// Generic email sending procedure
    /// Handles actual email transmission
    /// </summary>
    local procedure SendEmail(RecipientEmail: Text; Subject: Text; Body: Text)
    var
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
    begin
        // Create email message
        EmailMessage.Create(RecipientEmail, Subject, Body);

        // Send using system email
        Email.Send(EmailMessage);
    end;
}