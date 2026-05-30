codeunit 50100 "Custom Approval"
{
    // =========================
    // VARIABLES
    // =========================
    var
        WorkflowManagement: Codeunit "Workflow Management";
        NoWorkflowEnabledErr: Label 'No approval workflow is enabled for this document type.';
        SendApprovalTxt: Label 'Approval request for student request is sent.';
        CancelApprovalTxt: Label 'Approval request for student request is cancelled.';
        RejectCommentErr: Label 'You must enter a rejection comment before rejecting.';
        NoDelegateErr: Label 'No delegate (Substitute) is configured for approver %1. Please set a Substitute in User Setup.';
        NoUserSetupErr: Label 'No User Setup found for approver %1.';

    // =========================
    // EVENT CODE FUNCTIONS
    // =========================
    procedure SendApprovalEventCode(): Code[128]
    begin
        exit('RUNWORKFLOWONSENDSTUDENTREQUEST');
    end;

    procedure CancelApprovalEventCode(): Code[128]
    begin
        exit('RUNWORKFLOWONCANCELSTUDENTREQUEST');
    end;

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
            SendApprovalEventCode(),
            Database::"Student Approval test",
            SendApprovalTxt,
            0,
            false);

        WorkflowEventHandling.AddEventToLibrary(
            CancelApprovalEventCode(),
            Database::"Student Approval test",
            CancelApprovalTxt,
            0,
            false);
    end;

    // =========================
    // REGISTER WORKFLOW RESPONSES
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling",
     'OnAddWorkflowResponsesToLibrary', '', false, false)]
    local procedure AddWorkflowResponsesToLibrary()
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        WorkflowResponseHandling.AddResponseToLibrary(
            WorkflowResponseHandling.ReleaseDocumentCode(),
            Database::"Student Approval test",
            'Release student request.',
            'GROUP 0');

        WorkflowResponseHandling.AddResponseToLibrary(
            WorkflowResponseHandling.OpenDocumentCode(),
            Database::"Student Approval test",
            'Reopen student request.',
            'GROUP 0');
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
        if not WorkflowManagement.CanExecuteWorkflow(Rec, SendApprovalEventCode()) then
            Error(NoWorkflowEnabledErr);

        WorkflowManagement.HandleEvent(SendApprovalEventCode(), Rec);
    end;

    // =========================
    // CANCEL APPROVAL
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Approval",
     'OnCancelStudentApprovalTestForApproval', '', false, false)]
    local procedure RunWorkflowOnCancelApprovalRequest(var Rec: Record "Student Approval test")
    begin
        if not WorkflowManagement.CanExecuteWorkflow(Rec, CancelApprovalEventCode()) then
            Error(NoWorkflowEnabledErr);

        WorkflowManagement.HandleEvent(CancelApprovalEventCode(), Rec);
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
        if RecRef.Number <> Database::"Student Approval test" then
            exit;

        RecRef.SetTable(StudentRequest);
        StudentRequest.Status := StudentRequest.Status::"Pending Approval";
        StudentRequest.Modify(true);

        Variant := StudentRequest;
        IsHandled := true;
    end;

    // =========================
    // RELEASE — APPROVED
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling",
     'OnReleaseDocument', '', false, false)]
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

    // =========================
    // OPEN DOCUMENT — CANCEL / REOPEN
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling",
     'OnOpenDocument', '', false, false)]
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

    // =========================
    // MULTI-LEVEL APPROVAL — APPROVE
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnApproveApprovalRequest', '', false, false)]
    local procedure ApproveApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        StudentRequest: Record "Student Approval test";
        ApprovalCommentLine: Record "Approval Comment Line";
        PendingEntries: Record "Approval Entry";
        RecRef: RecordRef;
        ApprovedByMsg: Label 'Approved by %1 (Level %2) on %3.';
    begin
        if ApprovalEntry."Table ID" <> Database::"Student Approval test" then
            exit;

        // ── Step 1: Stamp approver and timestamp ──────────────────────────
        ApprovalEntry."Last Date-Time Modified" := CurrentDateTime();
        ApprovalEntry."Last Modified By User ID" := CopyStr(
            UserId(), 1, MaxStrLen(ApprovalEntry."Last Modified By User ID"));
        ApprovalEntry.Modify(true);

        // ── Step 2: Write approval comment showing who approved ───────────
        ApprovalCommentLine.Init();
        ApprovalCommentLine."Table ID" := ApprovalEntry."Table ID";
        ApprovalCommentLine."Document Type" := ApprovalEntry."Document Type";
        ApprovalCommentLine."Document No." := ApprovalEntry."Document No.";
        ApprovalCommentLine."Record ID to Approve" := ApprovalEntry."Record ID to Approve";
        ApprovalCommentLine."Workflow Step Instance ID" := ApprovalEntry."Workflow Step Instance ID";
        ApprovalCommentLine.Comment := CopyStr(
            StrSubstNo(
                ApprovedByMsg,
                ApprovalEntry."Approver ID",
                ApprovalEntry."Sequence No.",
                Format(Today(), 0, '<Day,2>/<Month,2>/<Year4>')),
            1, MaxStrLen(ApprovalCommentLine.Comment));
        ApprovalCommentLine."User ID" := CopyStr(
            UserId(), 1, MaxStrLen(ApprovalCommentLine."User ID"));
        ApprovalCommentLine."Date and Time" := CurrentDateTime();
        ApprovalCommentLine.Insert(true);

        // ── Step 3: Check if peers on the same level are still pending ────
        PendingEntries.SetRange("Table ID", ApprovalEntry."Table ID");
        PendingEntries.SetRange("Document No.", ApprovalEntry."Document No.");
        PendingEntries.SetRange("Sequence No.", ApprovalEntry."Sequence No.");
        PendingEntries.SetFilter(
            Status, '%1|%2',
            PendingEntries.Status::Open,
            PendingEntries.Status::Created);

        if not PendingEntries.IsEmpty() then begin
            RecRef.Get(ApprovalEntry."Record ID to Approve");
            if RecRef.Number = Database::"Student Approval test" then begin
                RecRef.SetTable(StudentRequest);
                StudentRequest.Status := StudentRequest.Status::"Pending Approval";
                StudentRequest.Modify(true);
            end;
            exit;
        end;

        // ── Step 4: Check if a next level exists ──────────────────────────
        PendingEntries.Reset();
        PendingEntries.SetRange("Table ID", ApprovalEntry."Table ID");
        PendingEntries.SetRange("Document No.", ApprovalEntry."Document No.");
        PendingEntries.SetFilter("Sequence No.", '>%1', ApprovalEntry."Sequence No.");
        PendingEntries.SetFilter(
            Status, '%1|%2',
            PendingEntries.Status::Open,
            PendingEntries.Status::Created);

        if not PendingEntries.IsEmpty() then begin
            RecRef.Get(ApprovalEntry."Record ID to Approve");
            if RecRef.Number = Database::"Student Approval test" then begin
                RecRef.SetTable(StudentRequest);
                StudentRequest.Status := StudentRequest.Status::"Pending Approval";
                StudentRequest.Modify(true);
            end;
            exit;
        end;

        // ── Step 5: Full chain complete — workflow fires OnReleaseDocument
    end;

    // =========================
    // REJECT WITH MANDATORY COMMENT
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnRejectApprovalRequest', '', false, false)]
    local procedure RejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        StudentRequest: Record "Student Approval test";
        ApprovalCommentLine: Record "Approval Comment Line";
        RecRef: RecordRef;
        CommentText: Text[250];
    begin
        if ApprovalEntry."Table ID" <> Database::"Student Approval test" then
            exit;

        // ── Step 1: Force approver to enter a comment ─────────────────────
        if not GetRejectionComment(ApprovalEntry, CommentText) then
            Error(RejectCommentErr);

        // ── Step 2: Persist the rejection comment ─────────────────────────
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

        // ── Step 3: Set record status to Rejected ─────────────────────────
        RecRef.Get(ApprovalEntry."Record ID to Approve");
        if RecRef.Number = Database::"Student Approval test" then begin
            RecRef.SetTable(StudentRequest);
            StudentRequest.Status := StudentRequest.Status::Rejected;
            StudentRequest.Modify(true);
        end;
    end;

    // =========================
    // DELEGATE
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnDelegateApprovalRequest', '', false, false)]
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
        if RecRef.Number <> Database::"Student Approval test" then
            exit;

        RecRef.SetTable(StudentRequest);

        ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
        ApprovalEntryArgument."Document No." := StudentRequest."Student No.";
        ApprovalEntryArgument."Record ID to Approve" := StudentRequest.RecordId;
    end;

    // =========================
    // NOTIFY APPROVERS — BC 270 CORRECT APPROACH
    // ─────────────────────────────────────────────
    // In BC 270, the correct way to trigger notifications is to call
    // ApprovalsMgmt.CreateApprovalEntryNotification() which is a
    // public procedure on Codeunit 1535 confirmed in the BC 270 docs.
    // We subscribe to OnAfterInsertEvent on Table "Approval Entry"
    // which is a guaranteed table trigger event available in ALL
    // BC versions — no codeunit integration event needed.
    // =========================
    [EventSubscriber(ObjectType::Table, Database::"Approval Entry",
     'OnAfterInsertEvent', '', false, false)]
    local procedure NotifyApproverOnEntryInserted(var Rec: Record "Approval Entry"; RunTrigger: Boolean)
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowStepInstance: Record "Workflow Step Instance";
    begin
        // Only handle Student Approval test entries
        if Rec."Table ID" <> Database::"Student Approval test" then
            exit;

        // Only notify on Open entries — Created are placeholders
        if Rec.Status <> Rec.Status::Open then
            exit;

        // WorkflowStepInstance is needed by CreateApprovalEntryNotification.
        // Get it from the entry's Workflow Step Instance ID.
        if not WorkflowStepInstance.Get(Rec."Workflow Step Instance ID") then
            exit;

        // CreateApprovalEntryNotification is a confirmed public procedure
        // on Codeunit "Approvals Mgmt." in BC 270. It handles both
        // email and activity notification based on Notification Setup.
        ApprovalsMgmt.CreateApprovalEntryNotification(Rec, WorkflowStepInstance);
    end;

    // =========================
    // REJECTION COMMENT DIALOG HELPER
    // Returns FALSE if user cancels or submits empty comment.
    // =========================
    local procedure GetRejectionComment(
        ApprovalEntry: Record "Approval Entry";
        var CommentText: Text[250]): Boolean
    var
        RejectionPage: Page "Student Rejection Comment";
    begin
        RejectionPage.SetApprovalEntry(ApprovalEntry);

        if RejectionPage.RunModal() <> Action::OK then
            exit(false);

        CommentText := RejectionPage.GetComment();
        exit(CommentText <> '');
    end;
}