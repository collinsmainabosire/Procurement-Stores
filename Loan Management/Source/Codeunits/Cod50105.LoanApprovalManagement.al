namespace BCTRAINING.BCTRAINING;

codeunit 50105 "Loan Approval Management"
{
    /// <summary>
    /// Sends loan for approval workflow
    /// Updates status and creates approval request
    /// </summary>
    procedure SendForApproval(var LoanHeader: Record "Employee Loan Header"): Boolean
    var
        LoanSetup: Record "Employee Loan Setup";
        LoanType: Record "Employee Loan Type";
    begin
        // Get setup configuration
        LoanSetup.Get();
        
        // Check if approval workflow is enabled
        if not LoanSetup."Enable Approval Workflow" then begin
            // If no workflow, auto-approve
            ApproveLoan(LoanHeader."Loan No.", UserId, '');
            exit(true);
        end;
        
        // Get loan type to check if approval required
        if not LoanType.Get(LoanHeader."Loan Type") then
            exit(false);
        
        // If loan type doesn't require approval, auto-approve
        if not LoanType."Requires Approval" then begin
            ApproveLoan(LoanHeader."Loan No.", UserId, '');
            exit(true);
        end;
        
        // Update loan status to pending approval
        LoanHeader."Status" := "Loan Status"::"Pending Approval";
        LoanHeader."Approval Status" := "Loan Approval Status"::Pending;
        LoanHeader.Modify(true);
        
        // Send notification to approver
        SendApprovalNotification(LoanHeader);
        
        exit(true);
    end;
    
    /// <summary>
    /// Approves a loan
    /// Sets approved amount and updates status
    /// </summary>
    procedure ApproveLoan(
        LoanNo: Code[20]; 
        ApprovedBy: Code[50]; 
        Comments: Text[500]
    ): Boolean
    var
        LoanHeader: Record "Employee Loan Header";
    begin
        // Get the loan
        if not LoanHeader.Get(LoanNo) then begin
            Error('Loan %1 not found.', LoanNo);
            exit(false);
        end;
        
        // Set approved amount to requested amount
        // (In real system, this might be different)
        LoanHeader."Approved Amount" := LoanHeader."Requested Amount";
        
        // Calculate total with interest
        // Total = Approved Amount + (Approved Amount * Interest Rate / 100)
        LoanHeader."Total Amount" := LoanHeader."Requested Amount" +
            (LoanHeader."Requested Amount" * LoanHeader."Interest Rate" / 100);
        
        // Update approval details
        LoanHeader."Status" := "Loan Status"::Approved;
        LoanHeader."Approval Status" := "Loan Approval Status"::Approved;
        LoanHeader."Approved By" := ApprovedBy;
        LoanHeader."Approval Date" := Today;
        LoanHeader.Modify(true);
        
        // Send approval notification to employee
        SendApprovalApprovedNotification(LoanHeader);
        
        exit(true);
    end;
    
    /// <summary>
    /// Rejects a loan
    /// Sets status to rejected and stores reason
    /// </summary>
    procedure RejectLoan(
        LoanNo: Code[20]; 
        RejectedBy: Code[50]; 
        RejectionReason: Text[500]
    ): Boolean
    var
        LoanHeader: Record "Employee Loan Header";
    begin
        // Get the loan
        if not LoanHeader.Get(LoanNo) then begin
            Error('Loan %1 not found.', LoanNo);
            exit(false);
        end;
        
        // Can only reject loans in pending approval status
        if LoanHeader."Status" <> "Loan Status"::"Pending Approval" then begin
            Error('Can only reject loans in Pending Approval status.');
            exit(false);
        end;
        
        // Update rejection details
        LoanHeader."Status" := "Loan Status"::Rejected;
        LoanHeader."Approval Status" := "Loan Approval Status"::Rejected;
        LoanHeader."Rejection Reason" := RejectionReason;
        LoanHeader.Modify(true);
        
        // Send rejection notification to employee
        SendRejectionNotification(LoanHeader, RejectionReason);
        
        exit(true);
    end;
    
    /// <summary>
    /// Sends approval request notification to approver
    /// </summary>
    local procedure SendApprovalNotification(LoanHeader: Record "Employee Loan Header")
    var
        LoanNotificationMgmt: Codeunit "Loan Notification Management";
    begin
        LoanNotificationMgmt.SendApprovalEmail(LoanHeader);
    end;
    
    /// <summary>
    /// Sends approval confirmation to employee
    /// </summary>
    local procedure SendApprovalApprovedNotification(LoanHeader: Record "Employee Loan Header")
    var
        LoanNotificationMgmt: Codeunit "Loan Notification Management";
    begin
        LoanNotificationMgmt.SendApprovalConfirmation(LoanHeader);
    end;
    
    /// <summary>
    /// Sends rejection notification to employee
    /// </summary>
    local procedure SendRejectionNotification(
        LoanHeader: Record "Employee Loan Header"; 
        RejectionReason: Text[500]
    )
    var
        LoanNotificationMgmt: Codeunit "Loan Notification Management";
    begin
        LoanNotificationMgmt.SendRejectionEmail(LoanHeader, RejectionReason);
    end;
}