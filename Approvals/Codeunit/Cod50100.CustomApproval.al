codeunit 50100 "Custom Approval"
{
    var
        WorkflowManagement: Codeunit "Workflow Management";

        NoWorkflowEnabledErr: Label 'No approval workflow for this document.';

        SendApprovalEventCode: Label 'RUNWORKFLOWONSENDSTUDENTREQUEST';
        CancelApprovalEventCode: Label 'RUNWORKFLOWONCANCELSTUDENTREQUEST';

        SendApprovalTxt: Label 'Approval request for student request is sent';
        CancelApprovalTxt: Label 'Approval request for student request is cancelled';

    // =========================
    // REGISTER WORKFLOW EVENTS
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling",
     'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure AddWorkflowEventsToLibrary()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        WorkflowEventHandling.AddEventToLibrary(
            SendApprovalEventCode,
            Database::"Student Approval test",
            SendApprovalTxt,
            0,
            false);

        WorkflowEventHandling.AddEventToLibrary(
            CancelApprovalEventCode,
            Database::"Student Approval test",
            CancelApprovalTxt,
            0,
            false);
    end;

    // =========================
    // INTEGRATION EVENTS
    // =========================
    [IntegrationEvent(false, false)]
    procedure OnSendStudentApprovalTestForApproval(var Rec: Record "Student Approval test")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelStudentApprovalTestForApproval(var Rec: Record "Student Approval test")
    begin
    end;

    // =========================
    // SEND FOR APPROVAL
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Approval",
     'OnSendStudentApprovalTestForApproval', '', false, false)]
    local procedure RunWorkflowOnSendApproval(var Rec: Record "Student Approval test")
    begin
        if not WorkflowManagement.CanExecuteWorkflow(Rec, SendApprovalEventCode) then
            Error(NoWorkflowEnabledErr);

        WorkflowManagement.HandleEvent(SendApprovalEventCode, Rec);
    end;

    // =========================
    // CANCEL APPROVAL
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Approval",
     'OnCancelStudentApprovalTestForApproval', '', false, false)]
    local procedure RunWorkflowOnCancelApprovalRequest(var Rec: Record "Student Approval test")
    begin
        if not WorkflowManagement.CanExecuteWorkflow(Rec, CancelApprovalEventCode) then
            Error(NoWorkflowEnabledErr);

        WorkflowManagement.HandleEvent(CancelApprovalEventCode, Rec);

        // SAFE: reopen manually (DO NOT rely on workflow response OpenDocument)
        Rec.Status := Rec.Status::Open;
        Rec.Modify(true);
    end;

    // =========================
    // PENDING APPROVAL STATUS
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnSetStatusToPendingApproval', '', false, false)]
    local procedure SetPendingStatus(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number = Database::"Student Approval test" then begin
            RecRef.SetTable(StudentRequest);

            StudentRequest.Status := StudentRequest.Status::"Pending Approval";
            StudentRequest.Modify(true);

            Variant := StudentRequest;
            IsHandled := true;
        end;
    end;

    // =========================
    // RELEASE (APPROVED)
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling",
     'OnReleaseDocument', '', false, false)]
    local procedure ReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number = Database::"Student Approval test" then begin
            RecRef.SetTable(StudentRequest);

            StudentRequest.Status := StudentRequest.Status::Approved;
            StudentRequest.Modify(true);

            Handled := true;
        end;
    end;

    // =========================
    // REJECT
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnRejectApprovalRequest', '', false, false)]
    local procedure RejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        StudentRequest: Record "Student Approval test";
    begin
        if ApprovalEntry."Table ID" = Database::"Student Approval test" then begin
            if StudentRequest.Get(ApprovalEntry."Document No.") then begin
                StudentRequest.Status := StudentRequest.Status::Rejected;
                StudentRequest.Modify(true);
            end;
        end;
    end;

    // =========================
    // APPROVAL ENTRY SETUP
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure PopulateApprovalEntry(
        var RecRef: RecordRef;
        var ApprovalEntryArgument: Record "Approval Entry";
        WorkflowStepInstance: Record "Workflow Step Instance")
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number = Database::"Student Approval test" then begin
            RecRef.SetTable(StudentRequest);

            ApprovalEntryArgument."Document No." := StudentRequest."Student No.";
        end;
    end;
}