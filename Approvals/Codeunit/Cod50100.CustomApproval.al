codeunit 50100 "Custom Approval"
{
    var
        WorkflowManagement: Codeunit "Workflow Management";
        NoWorkflowEnabledErr: Label 'No approval workflow is enabled for this document type.';
        SendApprovalTxt: Label 'Approval request for student request is sent.';
        CancelApprovalTxt: Label 'Approval request for student request is cancelled.';
        RejectCommentErr: Label 'You must enter a rejection comment before rejecting.';
        NoDelegateErr: Label 'No delegate (Substitute) is configured for approver %1. Please set a Substitute in User Setup.';
        NoUserSetupErr: Label 'No User Setup found for approver %1.';

    procedure SendApprovalEventCode(): Code[128]
    begin
        exit('RUNWORKFLOWONSENDSTUDENTREQUEST');
    end;

    procedure CancelApprovalEventCode(): Code[128]
    begin
        exit('RUNWORKFLOWONCANCELSTUDENTREQUEST');
    end;

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

    [IntegrationEvent(false, false)]
    procedure OnSendStudentApprovalTestForApproval(var Rec: Record "Student Approval test")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelStudentApprovalTestForApproval(var Rec: Record "Student Approval test")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Approval",
     'OnSendStudentApprovalTestForApproval', '', false, false)]
    local procedure RunWorkflowOnSendApproval(var Rec: Record "Student Approval test")
    begin
        if not WorkflowManagement.CanExecuteWorkflow(Rec, SendApprovalEventCode()) then
            Error(NoWorkflowEnabledErr);

        WorkflowManagement.HandleEvent(SendApprovalEventCode(), Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Approval",
     'OnCancelStudentApprovalTestForApproval', '', false, false)]
    local procedure RunWorkflowOnCancelApprovalRequest(var Rec: Record "Student Approval test")
    begin
        if not WorkflowManagement.CanExecuteWorkflow(Rec, CancelApprovalEventCode()) then
            Error(NoWorkflowEnabledErr);

        WorkflowManagement.HandleEvent(CancelApprovalEventCode(), Rec);

        Rec.Status := Rec.Status::Open;
        Rec.Modify(true);
    end;

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

        if not FreshEntry.Get(ApprovalEntry."Entry No.") then
            exit;

        FreshEntry."Last Date-Time Modified" := CurrentDateTime();
        FreshEntry."Last Modified By User ID" := CopyStr(
            UserId(), 1, MaxStrLen(FreshEntry."Last Modified By User ID"));
        FreshEntry.Modify(true);

        ApprovalCommentLine.Init();
        ApprovalCommentLine."Table ID" := FreshEntry."Table ID";
        // FIX: Use 0 integer value to avoid "can't be evaluated into type Integer" error.
        // "Document Type" is an Option field; passing the enum symbol "::" " "" resolves
        // to blank text which BC cannot cast to Integer internally. Use FromInteger(0) instead.
        ApprovalCommentLine."Document Type" := 0;
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

        // Check same-level peers still pending
        PendingEntries.SetRange("Table ID", FreshEntry."Table ID");
        PendingEntries.SetRange("Document No.", FreshEntry."Document No.");
        PendingEntries.SetRange("Sequence No.", FreshEntry."Sequence No.");
        PendingEntries.SetFilter(
            Status, '%1|%2',
            PendingEntries.Status::Open,
            PendingEntries.Status::Created);

        if not PendingEntries.IsEmpty() then begin
            if RecRef.Get(FreshEntry."Record ID to Approve") then
                if RecRef.Number = Database::"Student Approval test" then begin
                    RecRef.SetTable(StudentRequest);
                    StudentRequest.Status := StudentRequest.Status::"Pending Approval";
                    StudentRequest.Modify(true);
                end;
            exit;
        end;

        // Check next level exists
        PendingEntries.Reset();
        PendingEntries.SetRange("Table ID", FreshEntry."Table ID");
        PendingEntries.SetRange("Document No.", FreshEntry."Document No.");
        PendingEntries.SetFilter("Sequence No.", '>%1', FreshEntry."Sequence No.");
        PendingEntries.SetFilter(
            Status, '%1|%2',
            PendingEntries.Status::Open,
            PendingEntries.Status::Created);

        if not PendingEntries.IsEmpty() then begin
            if RecRef.Get(FreshEntry."Record ID to Approve") then
                if RecRef.Number = Database::"Student Approval test" then begin
                    RecRef.SetTable(StudentRequest);
                    StudentRequest.Status := StudentRequest.Status::"Pending Approval";
                    StudentRequest.Modify(true);
                end;
            exit;
        end;

        // Full chain complete — workflow fires OnReleaseDocument
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.",
     'OnRejectApprovalRequest', '', false, false)]
    local procedure RejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        ApprovalCommentLine: Record "Approval Comment Line";
        FreshEntry: Record "Approval Entry";
        StudentRequest: Record "Student Approval test";
        RecRef: RecordRef;
        CommentText: Text[250];
    begin
        if ApprovalEntry."Table ID" <> Database::"Student Approval test" then
            exit;

        if not FreshEntry.Get(ApprovalEntry."Entry No.") then
            exit;

        if not GetRejectionComment(FreshEntry, CommentText) then
            Error(RejectCommentErr);

        ApprovalCommentLine.Init();
        ApprovalCommentLine."Table ID" := FreshEntry."Table ID";
        // FIX: same Document Type fix applied here
        ApprovalCommentLine."Document Type" := 0;
        ApprovalCommentLine."Document No." := FreshEntry."Document No.";
        ApprovalCommentLine."Record ID to Approve" := FreshEntry."Record ID to Approve";
        ApprovalCommentLine."Workflow Step Instance ID" := FreshEntry."Workflow Step Instance ID";
        ApprovalCommentLine.Comment := CommentText;
        ApprovalCommentLine."User ID" := CopyStr(
            UserId(), 1, MaxStrLen(ApprovalCommentLine."User ID"));
        ApprovalCommentLine."Date and Time" := CurrentDateTime();
        ApprovalCommentLine.Insert(true);

        if RecRef.Get(FreshEntry."Record ID to Approve") then
            if RecRef.Number = Database::"Student Approval test" then begin
                RecRef.SetTable(StudentRequest);
                StudentRequest.Status := StudentRequest.Status::Rejected;
                StudentRequest.Modify(true);
            end;
    end;

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

        // FIX: This is the primary cause of "can't be evaluated into type Integer".
        // "::" " "" is a blank Option string that BC's internal approval engine tries
        // to cast to Integer and fails. Use FromInteger(0) which is the safe, explicit way
        // to set the first Option value (" ") on an Option/Enum field.
        ApprovalEntryArgument."Document Type" := 0;
        ApprovalEntryArgument."Document No." := StudentRequest."Student No.";
        ApprovalEntryArgument."Record ID to Approve" := StudentRequest.RecordId;
    end;

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