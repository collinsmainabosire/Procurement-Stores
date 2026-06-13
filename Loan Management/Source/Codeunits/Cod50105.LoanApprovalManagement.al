namespace BCTRAINING.BCTRAINING;
using System.Automation;

codeunit 50105 "Loan Approval Management"
{
    trigger OnRun()
    begin
    end;

    /// <summary>
    /// Sends loan for approval
    /// </summary>
    procedure SendForApproval(var LoanHeader: Record "Employee Loan Header"): Boolean
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        LoanSetup: Record "Employee Loan Setup";
    begin
        LoanSetup.Get();

        if not LoanSetup."Enable Approval Workflow" then begin
            // Auto-approve if workflow disabled
            ApproveLoan(LoanHeader."Loan No.", UserId, '');
            exit(true);
        end;

        // Check if approval is required for this loan type
        if not IsApprovalRequired(LoanHeader."Loan Type") then begin
            ApproveLoan(LoanHeader."Loan No.", UserId, '');
            exit(true);
        end;

        // Update status
        LoanHeader."Status" := "Loan Status"::"Pending Approval";
        LoanHeader."Approval Status" := "Loan Approval Status"::"Pending";
        LoanHeader.Modify(true);

        // Send notification
        SendApprovalNotification(LoanHeader);

        exit(true);
    end;

    /// <summary>
    /// Approves a loan
    /// </summary>
    procedure ApproveLoan(LoanNo: Code[20]; ApprovedBy: Code[50]; Comments: Text[500]): Boolean
    var
        LoanHeader: Record "Employee Loan Header";
        LoanManagement: Codeunit "Loan Management";
    begin
        if not LoanHeader.Get(LoanNo) then begin
            Error('Loan %1 not found.', LoanNo);
            exit(false);
        end;

        // Set approved amounts
        LoanHeader."Approved Amount" := LoanHeader."Requested Amount";
        LoanHeader."Total Amount" := LoanHeader."Requested Amount" +
            (LoanHeader."Requested Amount" * LoanHeader."Interest Rate" / 100);

        // Update approval details
        LoanHeader."Status" := "Loan Status"::Approved;
        LoanHeader."Approval Status" := "Approval Status"::Approved;
        LoanHeader."Approved By" := ApprovedBy;
        LoanHeader."Approval Date" := Today;
        LoanHeader.Modify(true);

        // Send approval notification
        SendApprovalApprovedNotification(LoanHeader);

        exit(true);
    end;

    /// <summary>
    /// Rejects a loan
    /// </summary>
    procedure RejectLoan(LoanNo: Code[20]; RejectedBy: Code[50]; RejectionReason: Text[500]): Boolean
    var
        LoanHeader: Record "Employee Loan Header";
    begin
        if not LoanHeader.Get(LoanNo) then begin
            Error('Loan %1 not found.', LoanNo);
            exit(false);
        end;

        if LoanHeader."Status" <> "Loan Status"::"Pending Approval" then begin
            Error('Can only reject loans in Pending Approval status.');
            exit(false);
        end;

        // Update rejection details
        LoanHeader."Status" := "Loan Status"::Rejected;
        LoanHeader."Approval Status" := "Approval Status"::Rejected;
        LoanHeader."Rejection Reason" := RejectionReason;
        LoanHeader.Modify(true);

        // Send rejection notification
        SendRejectionNotification(LoanHeader, RejectionReason);

        exit(true);
    end;

    /// <summary>
    /// Checks if approval is required for loan type
    /// </summary>
    local procedure IsApprovalRequired(LoanTypeCode: Code[20]): Boolean
    var
        LoanType: Record "Employee Loan Type";
    begin
        if LoanType.Get(LoanTypeCode) then
            exit(LoanType."Requires Approval");

        exit(false);
    end;

    /// <summary>
    /// Sends approval notification
    /// </summary>
    local procedure SendApprovalNotification(LoanHeader: Record "Employee Loan Header")
    var
        NotificationMgmt: Codeunit "Loan Notification Management";
    begin
        NotificationMgmt.SendApprovalEmail(LoanHeader);
    end;

    /// <summary>
    /// Sends approval confirmation notification
    /// </summary>
    local procedure SendApprovalApprovedNotification(LoanHeader: Record "Employee Loan Header")
    var
        NotificationMgmt: Codeunit "Loan Notification Management";
    begin
        NotificationMgmt.SendApprovalConfirmation(LoanHeader);
    end;

    /// <summary>
    /// Sends rejection notification
    /// </summary>
    local procedure SendRejectionNotification(LoanHeader: Record "Employee Loan Header"; RejectionReason: Text[500])
    var
        NotificationMgmt: Codeunit "Loan Notification Management";
    begin
        NotificationMgmt.SendRejectionEmail(LoanHeader, RejectionReason);
    end;
}