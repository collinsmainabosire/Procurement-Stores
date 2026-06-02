namespace BCTRAINING.BCTRAINING;

using System.Automation;
using System.Security.User;

codeunit 50100 "Custom Approval"
{
    // =========================================================================================
    // CODEUNIT: Custom Approval
    // PURPOSE : Handles the full approval lifecycle for the "Student Approval test" table.
    //           This includes sending, cancelling, approving, rejecting, and delegating
    //           approval requests. It also registers the custom workflow events and responses
    //           into BC's workflow engine so they appear in the Workflow setup pages.
    //
    // PATTERN : The page (50104) calls only PUBLIC procedures in this codeunit.
    //           All business logic lives here — the page actions are single-line delegates.
    //           Event subscribers handle BC's internal workflow callbacks automatically.
    //
    // BC270   : RunModal() cannot be called inside a workflow transaction. All dialogs
    //           (e.g. rejection comment prompt) must be opened BEFORE the workflow engine
    //           is invoked. This codeunit is structured to respect that constraint.
    //
    // REJECTION COMMENT ENFORCEMENT:
    //           To prevent rejection without a comment from ANY entry point
    //           (including the built-in Approval Entries page), the
    //           OnRejectApprovalRequest subscriber itself checks for an existing
    //           comment before allowing the rejection to proceed. The page action
    //           RejectWithComment saves the comment first, then calls reject.
    //           If someone bypasses the page and rejects directly, the subscriber
    //           blocks it with an error because no comment exists yet.
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
    // These string codes uniquely identify the custom workflow events in BC's workflow engine.
    // They must match exactly what is registered in AddWorkflowEventsToLibrary below.
    // =========================================================================================

    procedure SendApprovalEventCode(): Code[128]
    // Returns the unique event code that BC uses to identify the
    // "Send for Approval" workflow event for the Student Approval test table.
    begin
        exit('RUNWORKFLOWONSENDSTUDENTREQUEST');
    end;

    procedure CancelApprovalEventCode(): Code[128]
    // Returns the unique event code that BC uses to identify the
    // "Cancel Approval" workflow event for the Student Approval test table.
    begin
        exit('RUNWORKFLOWONCANCELSTUDENTREQUEST');
    end;

    // =========================================================================================
    // SECTION 2: WORKFLOW EVENT AND RESPONSE REGISTRATION
    // These subscribers fire when BC loads its workflow library (e.g. when opening the
    // Workflow setup page). They add our custom events and responses to BC's list so they
    // can be selected when building a workflow in the UI.
    // =========================================================================================

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling",
     'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure AddWorkflowEventsToLibrary()
    // Registers our two custom events into BC's workflow event library.
    // After this runs, the events appear in the "When Event" dropdown
    // on the Workflow setup page.
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
    // Registers the Release and Open responses for our custom table into BC's
    // workflow response library. These responses appear in the "Then Response"
    // dropdown on the Workflow setup page and tell BC what to do when an
    // approval is approved (Release) or cancelled/rejected (Open).
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
    // These are the public integration event declarations that act as the trigger points
    // for our workflow. The page calls these procedures. The subscribers below listen
    // to them and execute the actual workflow logic.
    // Using integration events decouples the page from the workflow engine entirely.
    // =========================================================================================

    [IntegrationEvent(false, false)]
    procedure OnSendStudentApprovalTestForApproval(var Rec: Record "Student Approval test")
    // Integration event raised when the user clicks Send for Approval on the page.
    // The subscriber RunWorkflowOnSendApproval (below) listens to this event
    // and passes it into BC's workflow engine via WorkflowManagement.HandleEvent.
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelStudentApprovalTestForApproval(var Rec: Record "Student Approval test")
    // Integration event raised when the user clicks Cancel Approval on the page.
    // The subscriber RunWorkflowOnCancelApprovalRequest (below) listens to this
    // event and passes it into BC's workflow engine.
    begin
    end;

    // =========================================================================================
    // SECTION 4: PUBLIC PAGE-FACING PROCEDURES
    // These procedures are called directly from page 50104 action triggers.
    // Keeping all logic here means the page actions are clean single-line calls.
    // =========================================================================================

    procedure ApproveRequest(var Rec: Record "Student Approval test")
    // Called from the Approve action on page 50104.
    // Finds the open approval entry for this document and calls BC's built-in
    // ApproveApprovalRequests. BC then fires OnReleaseDocument which our
    // subscriber (ReleaseDocument below) handles by setting Status to Approved.
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        // Find the approval entry that is currently waiting for approval
        ApprovalEntry.SetRange("Table ID", Database::"Student Approval test");
        ApprovalEntry.SetRange("Document No.", Rec."Student No.");
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if not ApprovalEntry.FindFirst() then
            Error(NoOpenEntryErr);

        // Hand off to BC's built-in approval engine.
        // BC will mark the entry Approved and fire OnReleaseDocument
        // once all approvers in the chain have approved.
        ApprovalsMgmt.ApproveApprovalRequests(ApprovalEntry);
    end;

    procedure RejectWithComment(var Rec: Record "Student Approval test")
    // Called from the Reject action on page 50104.
    // IMPORTANT: The rejection comment dialog (RunModal) is opened HERE,
    // BEFORE ApprovalsMgmt.RejectApprovalRequests is called. This is required
    // in BC270 because RunModal cannot be called inside a workflow transaction.
    // The comment is saved to Approval Comment Line BEFORE rejection is triggered.
    // The OnRejectApprovalRequest subscriber then checks that the comment exists
    // before allowing the status to change — this makes the comment mandatory
    // from ALL entry points including the built-in Approval Entries page.
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalCommentLine: Record "Approval Comment Line";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        RejectionPage: Page "Student Rejection Comment";
        CommentText: Text[250];
    begin
        // Step 1 — find the open approval entry for this document
        ApprovalEntry.SetRange("Table ID", Database::"Student Approval test");
        ApprovalEntry.SetRange("Document No.", Rec."Student No.");
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if not ApprovalEntry.FindFirst() then
            Error(NoOpenEntryErr);

        // Step 2 — open the rejection comment dialog.
        // This runs OUTSIDE the workflow transaction so RunModal is safe here.
        // If the user cancels the dialog we exit without rejecting.
        RejectionPage.SetApprovalEntry(ApprovalEntry);
        if RejectionPage.RunModal() <> Action::OK then
            exit;

        // Step 3 — validate that the approver actually typed a comment
        CommentText := RejectionPage.GetComment();
        if CommentText = '' then
            Error(NoCommentErr);

        // Step 4 — persist the rejection comment to Approval Comment Line
        // BEFORE calling reject. The subscriber OnRejectApprovalRequest checks
        // for this comment and will error if it does not exist — making the
        // comment mandatory even if someone bypasses this page action.
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

        // Step 5 — now trigger the rejection through BC's approval engine.
        // This fires OnRejectApprovalRequest (subscriber below) which verifies
        // the comment exists and then sets the document Status to Rejected.
        ApprovalsMgmt.RejectApprovalRequests(ApprovalEntry);
    end;

    procedure ReopenRequest(var Rec: Record "Student Approval test")
    // Called from the Reopen action on page 50104.
    // Allows a rejected document to be reset to Open status so it can
    // be corrected and sent for approval again.
    // Only documents with status Rejected can be reopened.
    begin
        if Rec.Status <> Rec.Status::Rejected then
            Error(AlreadyOpenErr);

        // Reset the document status to Open so the sender can
        // make corrections and send for approval again.
        Rec.Status := Rec.Status::Open;
        Rec.Modify(true);

        Message('Document has been reopened and can be sent for approval again.');
    end;

    // =========================================================================================
    // SECTION 5: WORKFLOW EVENT SUBSCRIBERS — SEND AND CANCEL
    // These subscribers listen to the integration events declared in Section 3.
    // They validate that a workflow is enabled and pass the event into BC's engine.
    // =========================================================================================

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Approval",
     'OnSendStudentApprovalTestForApproval', '', false, false)]
    local procedure RunWorkflowOnSendApproval(var Rec: Record "Student Approval test")
    // Listens to OnSendStudentApprovalTestForApproval.
    // Validates that an enabled workflow exists for this event, then passes
    // the event to BC's WorkflowManagement engine which processes the
    // workflow steps configured in the Workflow setup page.
    begin
        if not WorkflowManagement.CanExecuteWorkflow(Rec, SendApprovalEventCode()) then
            Error(NoWorkflowEnabledErr);

        WorkflowManagement.HandleEvent(SendApprovalEventCode(), Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Approval",
     'OnCancelStudentApprovalTestForApproval', '', false, false)]
    local procedure RunWorkflowOnCancelApprovalRequest(var Rec: Record "Student Approval test")
    // Listens to OnCancelStudentApprovalTestForApproval.
    // Passes the cancel event into BC's workflow engine, then explicitly
    // resets the document status to Open. The explicit reset is needed because
    // BC does not always fire OnOpenDocument for custom tables on cancel.
    begin
        if not WorkflowManagement.CanExecuteWorkflow(Rec, CancelApprovalEventCode()) then
            Error(NoWorkflowEnabledErr);

        WorkflowManagement.HandleEvent(CancelApprovalEventCode(), Rec);

        // Force status back to Open after cancellation regardless of
        // whether the workflow response fires OnOpenDocument or not.
        Rec.Status := Rec.Status::Open;
        Rec.Modify(true);
    end;

    // =========================================================================================
    // SECTION 6: APPROVAL ENGINE CALLBACKS
    // These subscribers are called by BC's internal approval engine during the lifecycle.
    // They handle status transitions on the Student Approval test record.
    // =========================================================================================

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnSetStatusToPendingApproval', '', false, false)]
    local procedure SetPendingStatus(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    // Called by BC's approval engine when the workflow response
    // "Set Status to Pending Approval" executes after a document is sent.
    // We set our custom Status field to Pending Approval and signal to BC
    // that we have handled it by setting IsHandled to true.
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number <> Database::"Student Approval test" then
            exit;

        RecRef.SetTable(StudentRequest);
        StudentRequest.Status := StudentRequest.Status::"Pending Approval";
        StudentRequest.Modify(true);

        // Return the updated record back through the Variant parameter
        // so BC's engine has the latest version of the record.
        Variant := StudentRequest;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling",
     'OnReleaseDocument', '', false, false)]
    local procedure ReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    // Called by BC's workflow engine when the workflow response
    // "Release the document" executes — this happens when the final
    // approver in the chain approves the request.
    // We set our custom Status field to Approved.
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number <> Database::"Student Approval test" then
            exit;

        RecRef.SetTable(StudentRequest);
        StudentRequest.Status := StudentRequest.Status::Approved;
        StudentRequest.Modify(true);

        // Sync the RecRef back so BC's engine has the updated record.
        RecRef.GetTable(StudentRequest);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling",
     'OnOpenDocument', '', false, false)]
    local procedure OpenDocument(RecRef: RecordRef; var Handled: Boolean)
    // Called by BC's workflow engine when the workflow response
    // "Open the document" executes — this happens on the cancel and
    // reject paths when the workflow is configured with that response.
    // We set our custom Status field back to Open.
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number <> Database::"Student Approval test" then
            exit;

        RecRef.SetTable(StudentRequest);
        StudentRequest.Status := StudentRequest.Status::Open;
        StudentRequest.Modify(true);

        // Sync the RecRef back so BC's engine has the updated record.
        RecRef.GetTable(StudentRequest);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnRejectApprovalRequest', '', false, false)]
    local procedure RejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    // Called by BC's approval engine when RejectApprovalRequests is invoked
    // from ANY entry point — including the built-in Approval Entries page.
    //
    // MANDATORY COMMENT ENFORCEMENT:
    // Before setting the status to Rejected, we check that a comment already
    // exists in Approval Comment Line for this document. If no comment exists
    // we throw an error and the rejection is blocked. This means:
    //   - Via page 50104 Reject action: comment is saved first by
    //     RejectWithComment (Section 4), so this check passes.
    //   - Via built-in Approval Entries page Reject button: no comment has
    //     been saved so this check fails and the rejection is blocked.
    // This enforces the mandatory comment rule from all entry points.
    //
    // DO NOT open any dialog here. This event fires inside BC's workflow
    // transaction in BC270 and RunModal inside a transaction causes the
    // "transaction is stopped" error.
    var
        StudentRequest: Record "Student Approval test";
        ApprovalCommentLine: Record "Approval Comment Line";
        RecRef: RecordRef;
    begin
        if ApprovalEntry."Table ID" <> Database::"Student Approval test" then
            exit;

        // Check that a comment exists before allowing rejection.
        // RejectWithComment saves the comment before calling this.
        // If someone rejects without going through RejectWithComment,
        // no comment will exist and this error blocks the rejection.
        ApprovalCommentLine.SetRange("Table ID", ApprovalEntry."Table ID");
        ApprovalCommentLine.SetRange("Document No.", ApprovalEntry."Document No.");
        if ApprovalCommentLine.IsEmpty() then
            Error(NoCommentErr);

        // Comment exists — safe to proceed with rejection.
        // Set the document status to Rejected.
        if RecRef.Get(ApprovalEntry."Record ID to Approve") then
            if RecRef.Number = Database::"Student Approval test" then begin
                RecRef.SetTable(StudentRequest);
                StudentRequest.Status := StudentRequest.Status::Rejected;
                StudentRequest.Modify(true);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnDelegateApprovalRequest', '', false, false)]
    local procedure DelegateApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    // Called by BC's approval engine when the approver delegates their request.
    // We validate that the approver has a substitute configured in User Setup
    // before allowing the delegation to proceed.
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure PopulateApprovalEntry(
        var RecRef: RecordRef;
        var ApprovalEntryArgument: Record "Approval Entry";
        WorkflowStepInstance: Record "Workflow Step Instance")
    // Called by BC's approval engine when it is about to create an Approval Entry
    // for our document. We must populate the key fields here so BC can correctly
    // identify, store, and retrieve the approval entry for our custom table.
    //
    // "Table ID" is mandatory in BC270. Without it BC cannot resolve the record
    // reference and throws: "The value "" can't be evaluated into type Integer."
    //
    // "Document Type" must be set using the enum symbol "::" " "" (blank/space).
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number <> Database::"Student Approval test" then
            exit;

        RecRef.SetTable(StudentRequest);

        ApprovalEntryArgument."Table ID" := Database::"Student Approval test";
        ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
        ApprovalEntryArgument."Document No." := StudentRequest."Student No.";
        ApprovalEntryArgument."Record ID to Approve" := StudentRequest.RecordId;
    end;

    // =========================================================================================
    // SECTION 7: NOTIFICATION
    // Sends a BC notification to the approver when a new approval entry is created.
    // =========================================================================================

    [EventSubscriber(ObjectType::Table, Database::"Approval Entry",
     'OnAfterInsertEvent', '', false, false)]
    local procedure NotifyApproverOnEntryInserted(
        var Rec: Record "Approval Entry"; RunTrigger: Boolean)
    // Fires whenever an Approval Entry record is inserted.
    // We filter to our custom table and only entries with status Open
    // (i.e. newly created entries waiting for approval).
    // Creates a BC notification that appears in the approver's
    // notification bell in the BC client.
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowStepInstance: Record "Workflow Step Instance";
    begin
        if Rec."Table ID" <> Database::"Student Approval test" then
            exit;

        // Only notify for entries that are actively waiting for approval
        if Rec.Status <> Rec.Status::Open then
            exit;

        // The WorkflowStepInstance is needed by CreateApprovalEntryNotification
        // to build the correct notification link back to the document
        if not WorkflowStepInstance.Get(Rec."Workflow Step Instance ID") then
            exit;

        ApprovalsMgmt.CreateApprovalEntryNotification(Rec, WorkflowStepInstance);
    end;
}