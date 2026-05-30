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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
  'OnApproveApprovalRequest', '', false, false)]
    local procedure ApproveApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        StudentRequest: Record "Student Approval test";
        ApprovalCommentLine: Record "Approval Comment Line";
        PendingEntries: Record "Approval Entry";
        FreshEntry: Record "Approval Entry";
        RecRef: RecordRef;
        ApprovedByMsg: Label 'Approved by %1 (Level %2) on %3.';
    begin
        if ApprovalEntry."Table ID" <> Database::"Student Approval test" then
            exit;

        // ── Re-read the entry fresh from DB using the single PK field ─────────
        if not FreshEntry.Get(ApprovalEntry."Entry No.") then
            exit;

        // ── Step 1: Stamp approver and timestamp ──────────────────────────────
        FreshEntry."Last Date-Time Modified" := CurrentDateTime();
        FreshEntry."Last Modified By User ID" := CopyStr(
            UserId(), 1, MaxStrLen(FreshEntry."Last Modified By User ID"));
        FreshEntry.Modify(true);

        // ── Step 2: Write approval comment ────────────────────────────────────
        ApprovalCommentLine.Init();
        ApprovalCommentLine."Table ID" := FreshEntry."Table ID";
        ApprovalCommentLine."Document Type" := FreshEntry."Document Type";
        ApprovalCommentLine."Document No." := FreshEntry."Document No.";
        ApprovalCommentLine."Record ID to Approve" := FreshEntry."Record ID to Approve";
        ApprovalCommentLine."Workflow Step Instance ID" := FreshEntry."Workflow Step Instance ID";
        ApprovalCommentLine.Comment := CopyStr(
            StrSubstNo(
                ApprovedByMsg,
                FreshEntry."Approver ID",
                FreshEntry."Sequence No.",
                Format(Today(), 0, '<Day,2>/<Month,2>/<Year4>')),
            1, MaxStrLen(ApprovalCommentLine.Comment));
        ApprovalCommentLine."User ID" := CopyStr(
            UserId(), 1, MaxStrLen(ApprovalCommentLine."User ID"));
        ApprovalCommentLine."Date and Time" := CurrentDateTime();
        ApprovalCommentLine.Insert(true);

        // ── Step 3: Check same-level peers still pending ──────────────────────
        PendingEntries.SetRange("Table ID", FreshEntry."Table ID");
        PendingEntries.SetRange("Document No.", FreshEntry."Document No.");
        PendingEntries.SetRange("Sequence No.", FreshEntry."Sequence No.");
        PendingEntries.SetFilter(
            Status, '%1|%2',
            PendingEntries.Status::Open,
            PendingEntries.Status::Created);

        if not PendingEntries.IsEmpty() then begin
            RecRef.Get(FreshEntry."Record ID to Approve");
            if RecRef.Number = Database::"Student Approval test" then begin
                RecRef.SetTable(StudentRequest);
                StudentRequest.Status := StudentRequest.Status::"Pending Approval";
                StudentRequest.Modify(true);
            end;
            exit;
        end;

        // ── Step 4: Check if next level exists ────────────────────────────────
        PendingEntries.Reset();
        PendingEntries.SetRange("Table ID", FreshEntry."Table ID");
        PendingEntries.SetRange("Document No.", FreshEntry."Document No.");
        PendingEntries.SetFilter("Sequence No.", '>%1', FreshEntry."Sequence No.");
        PendingEntries.SetFilter(
            Status, '%1|%2',
            PendingEntries.Status::Open,
            PendingEntries.Status::Created);

        if not PendingEntries.IsEmpty() then begin
            RecRef.Get(FreshEntry."Record ID to Approve");
            if RecRef.Number = Database::"Student Approval test" then begin
                RecRef.SetTable(StudentRequest);
                StudentRequest.Status := StudentRequest.Status::"Pending Approval";
                StudentRequest.Modify(true);
            end;
            exit;
        end;

        // ── Step 5: Full chain complete — workflow fires OnReleaseDocument ─────
    end;

    // =========================
    // REJECT — COMMENT + STATUS
    // OnRejectApprovalRequest fires AFTER BC sets the entry to Rejected.
    // We show the comment dialog first. If the user cancels or enters
    // nothing we throw an Error() which rolls back the entire rejection
    // transaction — BC's own status update is also rolled back because
    // we are still inside the same database transaction.
    // =========================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnRejectApprovalRequest', '', false, false)]
    local procedure RejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        StudentRequest: Record "Student Approval test";
        ApprovalCommentLine: Record "Approval Comment Line";
        SameLevelEntries: Record "Approval Entry";
        RecRef: RecordRef;
        CommentText: Text[250];
        RejectedByMsg: Label 'Rejected by %1 (Level %2) on %3.';
    begin
        if ApprovalEntry."Table ID" <> Database::"Student Approval test" then
            exit;

        // ── Step 1: Force rejection comment BEFORE any writes ─────────────
        // If the user cancels the dialog or leaves comment blank,
        // Error() fires here which rolls back the whole transaction
        // including BC's own Rejected status update on the entry.
        if not GetRejectionComment(ApprovalEntry, CommentText) then
            Error(RejectCommentErr);

        // ── Step 2: Stamp the rejection on the approval entry ─────────────
        ApprovalEntry."Last Date-Time Modified" := CurrentDateTime();
        ApprovalEntry."Last Modified By User ID" := CopyStr(
            UserId(), 1, MaxStrLen(ApprovalEntry."Last Modified By User ID"));
        ApprovalEntry.Modify(true);

        // ── Step 3: Persist rejection comment to Approval Comment Line ────
        ApprovalCommentLine.Init();
        ApprovalCommentLine."Table ID" := ApprovalEntry."Table ID";
        ApprovalCommentLine."Document Type" := ApprovalEntry."Document Type";
        ApprovalCommentLine."Document No." := ApprovalEntry."Document No.";
        ApprovalCommentLine."Record ID to Approve" := ApprovalEntry."Record ID to Approve";
        ApprovalCommentLine."Workflow Step Instance ID" := ApprovalEntry."Workflow Step Instance ID";
        ApprovalCommentLine.Comment := CopyStr(
            StrSubstNo(
                RejectedByMsg,
                ApprovalEntry."Approver ID",
                ApprovalEntry."Sequence No.",
                Format(Today(), 0, '<Day,2>/<Month,2>/<Year4>'))
            + ' — ' + CommentText,
            1, MaxStrLen(ApprovalCommentLine.Comment));
        ApprovalCommentLine."User ID" := CopyStr(
            UserId(), 1, MaxStrLen(ApprovalCommentLine."User ID"));
        ApprovalCommentLine."Date and Time" := CurrentDateTime();
        ApprovalCommentLine.Insert(true);

        // ── Step 4: Cancel ALL other Open/Created entries on same level ───
        SameLevelEntries.SetRange("Table ID", ApprovalEntry."Table ID");
        SameLevelEntries.SetRange("Document No.", ApprovalEntry."Document No.");
        SameLevelEntries.SetRange("Sequence No.", ApprovalEntry."Sequence No.");
        SameLevelEntries.SetFilter(
            Status, '%1|%2',
            SameLevelEntries.Status::Open,
            SameLevelEntries.Status::Created);

        if SameLevelEntries.FindSet(true) then
            repeat
                SameLevelEntries.Status := SameLevelEntries.Status::Canceled;
                SameLevelEntries."Last Date-Time Modified" := CurrentDateTime();
                SameLevelEntries."Last Modified By User ID" := CopyStr(
                    UserId(), 1, MaxStrLen(SameLevelEntries."Last Modified By User ID"));
                SameLevelEntries.Modify(true);
            until SameLevelEntries.Next() = 0;

        // ── Step 5: Cancel ALL entries on ALL higher levels ───────────────
        SameLevelEntries.Reset();
        SameLevelEntries.SetRange("Table ID", ApprovalEntry."Table ID");
        SameLevelEntries.SetRange("Document No.", ApprovalEntry."Document No.");
        SameLevelEntries.SetFilter("Sequence No.", '>%1', ApprovalEntry."Sequence No.");
        SameLevelEntries.SetFilter(
            Status, '%1|%2',
            SameLevelEntries.Status::Open,
            SameLevelEntries.Status::Created);

        if SameLevelEntries.FindSet(true) then
            repeat
                SameLevelEntries.Status := SameLevelEntries.Status::Canceled;
                SameLevelEntries."Last Date-Time Modified" := CurrentDateTime();
                SameLevelEntries."Last Modified By User ID" := CopyStr(
                    UserId(), 1, MaxStrLen(SameLevelEntries."Last Modified By User ID"));
                SameLevelEntries.Modify(true);
            until SameLevelEntries.Next() = 0;

        // ── Step 6: Set document status to Rejected ───────────────────────
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
    // NOTIFY APPROVERS
    // =========================
    [EventSubscriber(ObjectType::Table, Database::"Approval Entry",
     'OnAfterInsertEvent', '', false, false)]
    local procedure NotifyApproverOnEntryInserted(
        var Rec: Record "Approval Entry"; RunTrigger: Boolean)
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

    // =========================
    // REJECTION COMMENT DIALOG HELPER
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