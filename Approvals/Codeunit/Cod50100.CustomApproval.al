namespace BCTRAINING.BCTRAINING;

using System.Automation;
using System.Security.User;

codeunit 50100 "Custom Approval"
{
    // =========================================================================================
    // CODEUNIT: Custom Approval
    // PURPOSE : Handles the full approval lifecycle for the "Student Approval test" table.
    //
    // CANCEL FIX:
    //           When the sender cancels, two things must happen:
    //             1. All Open/Created approval entries for the document → Status = Cancelled
    //             2. The document Status → Open
    //           BC's workflow engine handles (1) only if the workflow response chain includes
    //           "Cancel the approval request". To make this reliable regardless of workflow
    //           configuration, RunWorkflowOnCancelApprovalRequest now explicitly cancels
    //           the entries itself after raising the workflow event.
    //
    // OPEN RECORD FIX:
    //           Page 654 calls Rec.ShowRecord() → PageManagement.PageRun(RecRef).
    //           OnBeforeRunWorkflowEntriesPage never fires from this path.
    //           The correct hook is OnBeforeShowRecord on table 454 "Approval Entry".
    // =========================================================================================

    var
        WorkflowManagement: Codeunit "Workflow Management";
        NoWorkflowEnabledErr: Label 'No approval workflow is enabled for this document type.';
        SendApprovalTxt: Label 'Approval request for student request is sent.';
        CancelApprovalTxt: Label 'Approval request for student request is cancelled.';
        NoDelegateErr: Label 'No delegate (Substitute) is configured for approver %1.';
        NoUserSetupErr: Label 'No User Setup found for approver %1.';
        NoOpenEntryErr: Label 'There is no open approval request for this document.';
        NoCommentErr: Label 'You must enter a rejection comment before rejecting. Please use the Reject action on the document page.';
        AlreadyOpenErr: Label 'This document is already open.';

    // =========================================================================================
    // SECTION 1: EVENT CODES
    // =========================================================================================

    procedure SendApprovalEventCode(): Code[128]
    begin
        exit('RUNWORKFLOWONSENDSTUDENTREQUEST');
    end;

    procedure CancelApprovalEventCode(): Code[128]
    begin
        exit('RUNWORKFLOWONCANCELSTUDENTREQUEST');
    end;

    // =========================================================================================
    // SECTION 2: WORKFLOW EVENT AND RESPONSE REGISTRATION
    // =========================================================================================

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling",
     'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure AddWorkflowEventsToLibrary()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        WorkflowEventHandling.AddEventToLibrary(
            SendApprovalEventCode(),
            Database::"Student Approval test",
            SendApprovalTxt, 0, false);

        WorkflowEventHandling.AddEventToLibrary(
            CancelApprovalEventCode(),
            Database::"Student Approval test",
            CancelApprovalTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling",
     'OnAddWorkflowResponsesToLibrary', '', false, false)]
    local procedure AddWorkflowResponsesToLibrary()
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        WorkflowResponseHandling.AddResponseToLibrary(
            WorkflowResponseHandling.ReleaseDocumentCode(),
            Database::"Student Approval test",
            'Release student request.', 'GROUP 0');

        WorkflowResponseHandling.AddResponseToLibrary(
            WorkflowResponseHandling.OpenDocumentCode(),
            Database::"Student Approval test",
            'Reopen student request.', 'GROUP 0');
    end;

    // =========================================================================================
    // SECTION 3: INTEGRATION EVENTS
    // =========================================================================================

    [IntegrationEvent(false, false)]
    procedure OnSendStudentApprovalTestForApproval(var Rec: Record "Student Approval test")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelStudentApprovalTestForApproval(var Rec: Record "Student Approval test")
    begin
    end;

    // =========================================================================================
    // SECTION 4: PUBLIC PAGE-FACING PROCEDURES
    // =========================================================================================

    procedure ApproveRequest(var Rec: Record "Student Approval test")
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        ApprovalEntry.SetRange("Table ID", Database::"Student Approval test");
        ApprovalEntry.SetRange("Document No.", Rec."Student No.");
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if not ApprovalEntry.FindFirst() then
            Error(NoOpenEntryErr);

        ApprovalsMgmt.ApproveApprovalRequests(ApprovalEntry);
    end;

    procedure RejectWithComment(var Rec: Record "Student Approval test")
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalCommentLine: Record "Approval Comment Line";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        RejectionPage: Page "Student Rejection Comment";
        CommentText: Text[250];
    begin
        ApprovalEntry.SetRange("Table ID", Database::"Student Approval test");
        ApprovalEntry.SetRange("Document No.", Rec."Student No.");
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if not ApprovalEntry.FindFirst() then
            Error(NoOpenEntryErr);

        RejectionPage.SetApprovalEntry(ApprovalEntry);
        if RejectionPage.RunModal() <> Action::OK then
            exit;

        CommentText := RejectionPage.GetComment();
        if CommentText = '' then
            Error(NoCommentErr);

        ApprovalCommentLine.Init();
        ApprovalCommentLine."Table ID" := ApprovalEntry."Table ID";
        ApprovalCommentLine."Document Type" := ApprovalEntry."Document Type";
        ApprovalCommentLine."Document No." := ApprovalEntry."Document No.";
        ApprovalCommentLine."Record ID to Approve" := ApprovalEntry."Record ID to Approve";
        ApprovalCommentLine."Workflow Step Instance ID" := ApprovalEntry."Workflow Step Instance ID";
        ApprovalCommentLine.Comment := CommentText;
        ApprovalCommentLine."User ID" := CopyStr(
            UserId(), 1, MaxStrLen(ApprovalCommentLine."User ID"));
        ApprovalCommentLine."Date and Time" := CurrentDateTime();
        ApprovalCommentLine.Insert(true);

        ApprovalsMgmt.RejectApprovalRequests(ApprovalEntry);
    end;

    procedure ReopenRequest(var Rec: Record "Student Approval test")
    begin
        if Rec.Status <> Rec.Status::Rejected then
            Error(AlreadyOpenErr);

        Rec.Status := Rec.Status::Open;
        Rec.Modify(true);

        Message('Document has been reopened and can be sent for approval again.');
    end;

    // =========================================================================================
    // SECTION 5: WORKFLOW EVENT SUBSCRIBERS — SEND AND CANCEL
    // =========================================================================================

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Approval", 'OnSendStudentApprovalTestForApproval', '', false, false)]
    local procedure RunWorkflowOnSendApproval(var Rec: Record "Student Approval test")
    begin
        if not WorkflowManagement.CanExecuteWorkflow(Rec, SendApprovalEventCode()) then
            Error(NoWorkflowEnabledErr);

        WorkflowManagement.HandleEvent(SendApprovalEventCode(), Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Approval", 'OnCancelStudentApprovalTestForApproval', '', false, false)]
    local procedure RunWorkflowOnCancelApprovalRequest(var Rec: Record "Student Approval test")
    // CANCEL FIX:
    // After raising the workflow event we explicitly cancel all Open or Created
    // approval entries for this document. This is necessary because BC's engine
    // only cancels entries if the workflow response chain includes the
    // "Cancel the approval request" response — which is easy to misconfigure.
    // Doing it explicitly here makes cancellation reliable regardless of the
    // workflow setup, and guarantees the approver sees Status = Cancelled.
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        if not WorkflowManagement.CanExecuteWorkflow(Rec, CancelApprovalEventCode()) then
            Error(NoWorkflowEnabledErr);

        WorkflowManagement.HandleEvent(CancelApprovalEventCode(), Rec);

        // Cancel all Open or Created entries for this document explicitly.
        // Status::Cancelled is what the approver will see on page 654 after this.
        ApprovalEntry.SetRange("Table ID", Database::"Student Approval test");
        ApprovalEntry.SetRange("Document No.", Rec."Student No.");
        ApprovalEntry.SetFilter(Status, '%1|%2',
            ApprovalEntry.Status::Open,
            ApprovalEntry.Status::Created);
        if ApprovalEntry.FindSet(true) then
            repeat
                ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
                ApprovalEntry.Modify(true);
            until ApprovalEntry.Next() = 0;

        // Reset document status to Open so the sender can edit and resubmit.
        Rec.Status := Rec.Status::Open;
        Rec.Modify(true);
    end;

    // =========================================================================================
    // SECTION 6: APPROVAL ENGINE CALLBACKS
    // =========================================================================================

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure SetPendingStatus(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number <> Database::"Student Approval test" then
            exit;

        RecRef.SetTable(StudentRequest);
        StudentRequest.Status := StudentRequest.Status::"Pending Approval";
        StudentRequest.Modify(true);

        Variant := StudentRequest;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure ReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number <> Database::"Student Approval test" then
            exit;

        RecRef.SetTable(StudentRequest);
        StudentRequest.Status := StudentRequest.Status::Approved;
        StudentRequest.Modify(true);

        RecRef.GetTable(StudentRequest);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number <> Database::"Student Approval test" then
            exit;

        RecRef.SetTable(StudentRequest);
        StudentRequest.Status := StudentRequest.Status::Open;
        StudentRequest.Modify(true);

        RecRef.GetTable(StudentRequest);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnRejectApprovalRequest', '', false, false)]
    local procedure RejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        StudentRequest: Record "Student Approval test";
        ApprovalCommentLine: Record "Approval Comment Line";
        RecRef: RecordRef;
    begin
        if ApprovalEntry."Table ID" <> Database::"Student Approval test" then
            exit;

        ApprovalCommentLine.SetRange("Table ID", ApprovalEntry."Table ID");
        ApprovalCommentLine.SetRange("Document No.", ApprovalEntry."Document No.");
        if ApprovalCommentLine.IsEmpty() then
            Error(NoCommentErr);

        if RecRef.Get(ApprovalEntry."Record ID to Approve") then
            if RecRef.Number = Database::"Student Approval test" then begin
                RecRef.SetTable(StudentRequest);
                StudentRequest.Status := StudentRequest.Status::Rejected;
                StudentRequest.Modify(true);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnDelegateApprovalRequest', '', false, false)]
    local procedure DelegateApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        UserSetup: Record "User Setup";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        if ApprovalEntry."Table ID" <> Database::"Student Approval test" then
            exit;

        if not UserSetup.Get(ApprovalEntry."Approver ID") then
            Error(NoUserSetupErr, ApprovalEntry."Approver ID");

        if UserSetup.Substitute = '' then
            Error(NoDelegateErr, ApprovalEntry."Approver ID");

        ApprovalsMgmt.DelegateApprovalRequests(ApprovalEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure PopulateApprovalEntry(
        var RecRef: RecordRef;
        var ApprovalEntryArgument: Record "Approval Entry";
        WorkflowStepInstance: Record "Workflow Step Instance")
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number <> Database::"Student Approval test" then
            exit;

        RecRef.SetTable(StudentRequest);

        // Re-fetch from DB to guarantee a committed, resolvable RecordId.
        // This keeps the "Open Record" button enabled on page 654.
        if not StudentRequest.Get(StudentRequest."Student No.") then
            exit;

        ApprovalEntryArgument."Table ID" := Database::"Student Approval test";
        ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
        ApprovalEntryArgument."Document No." := StudentRequest."Student No.";
        ApprovalEntryArgument."Record ID to Approve" := StudentRequest.RecordId;
    end;

    // =========================================================================================
    // SECTION 7: NOTIFICATION
    // =========================================================================================

    [EventSubscriber(ObjectType::Table, Database::"Approval Entry",
     'OnAfterInsertEvent', '', false, false)]
    local procedure NotifyApproverOnEntryInserted(var Rec: Record "Approval Entry"; RunTrigger: Boolean)
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowStepInstance: Record "Workflow Step Instance";
    begin
        if Rec."Table ID" <> Database::"Student Approval test" then
            exit;

        if Rec.Status <> Rec.Status::Open then
            exit;

        if not WorkflowStepInstance.Get(Rec."Workflow Step Instance ID") then
            exit;

        ApprovalsMgmt.CreateApprovalEntryNotification(Rec, WorkflowStepInstance);
    end;

    // =========================================================================================
    // SECTION 8: OPEN RECORD NAVIGATION
    //
    // Page 654 "Requests to Approve" calls Rec.ShowRecord() on table 454 "Approval Entry".
    // ShowRecord() calls PageManagement.PageRun(RecRef) — NOT RunWorkflowEntriesPage.
    // The correct hook is OnBeforeShowRecord on table 454 "Approval Entry".
    //
    // OnBeforeRunWorkflowEntriesPage is kept for other entry points such as
    // page 9085 "Approval Entries" and document page action buttons.
    // =========================================================================================

    [EventSubscriber(ObjectType::Table, Database::"Approval Entry",
     'OnBeforeShowRecord', '', false, false)]
    local procedure HandleShowRecord(var ApprovalEntry: Record "Approval Entry"; var IsHandled: Boolean)
    var
        StudentRequest: Record "Student Approval test";
        RecRef: RecordRef;
    begin
        if ApprovalEntry."Table ID" <> Database::"Student Approval test" then
            exit;

        IsHandled := true;

        if RecRef.Get(ApprovalEntry."Record ID to Approve") then begin
            RecRef.SetTable(StudentRequest);
            Page.Run(Page::"Approval Test", StudentRequest);
            exit;
        end;

        if ApprovalEntry."Document No." <> '' then
            if StudentRequest.Get(ApprovalEntry."Document No.") then begin
                Page.Run(Page::"Approval Test", StudentRequest);
                exit;
            end;

        Error('Cannot open student request. Record not found (Doc No.: %1).', ApprovalEntry."Document No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnBeforeRunWorkflowEntriesPage', '', false, false)]
    local procedure OpenStudentApprovalCard(RecordIDInput: RecordID; TableId: Integer; DocumentType: Enum "Approval Document Type"; DocumentNo: Code[20]; var IsHandled: Boolean)
    var
        StudentRequest: Record "Student Approval test";
        RecRef: RecordRef;
    begin
        if TableId <> Database::"Student Approval test" then
            exit;

        IsHandled := true;

        if RecRef.Get(RecordIDInput) then begin
            RecRef.SetTable(StudentRequest);
            Page.Run(Page::"Approval Test", StudentRequest);
            exit;
        end;

        if DocumentNo <> '' then
            if StudentRequest.Get(DocumentNo) then begin
                Page.Run(Page::"Approval Test", StudentRequest);
                exit;
            end;

        Error('Cannot open the student request. Record could not be found (Doc No.: %1).', DocumentNo);
    end;

}
