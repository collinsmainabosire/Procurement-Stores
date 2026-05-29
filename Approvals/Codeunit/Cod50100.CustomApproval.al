namespace BCTRAINING.BCTRAINING;

using System.Automation;

codeunit 50100 "Custom Approval"
{
    //variables that will be used later in the codeunit
    var
        WorkflowManagement: Codeunit "Workflow Management";

        NoWorkflowEnabledErr: Label 'No approval workflow for this document.';

        SendApprovalEventCode: Label 'RUNWORKFLOWONSENDSTUDENTREQUEST';

        CancelApprovalEventCode: Label 'RUNWORKFLOWONCANCELSTUDENTREQUEST';

        SendApprovalTxt: Label 'Approval request for student request is sent';

        CancelApprovalTxt: Label 'Approval request for student request is cancelled';
    //Registering workflow events
    //Registers custom events inside Workflow Setup page.
    //Without this code, the events will not be visible in the workflow setup page and user will not be able to link the events to the workflow.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure AddWorkflowEventsToLibrary()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        //Registering sending approval event to the library
        WorkflowEventHandling.AddEventToLibrary(SendApprovalEventCode, Database::"Student Approval test", SendApprovalTxt, 0, false);
        //Registering cancel approval event to the library
        WorkflowEventHandling.AddEventToLibrary(CancelApprovalEventCode, Database::"Student Approval test", CancelApprovalTxt, 0, false);
    end;

    //Creating integration points for workflow in the codeunit
    //This is the procedure that will be called from the page when user clicks on send for approval action. 
    //The workflow system will trigger the workflow based on the event registered above.
    [IntegrationEvent(false, false)]
    //This is a These are publishers that will be called from the page when user clicks on send for approval/cancel approval action.
    procedure OnSendStudentApprovalTestForApproval(var Rec: Record "Student Approval test")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelStudentApprovalTestForApproval(var Rec: Record "Student Approval test")
    begin
    end;
    //Handling Sent for approval event
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Approval", 'OnSendStudentApprovalTestForApproval', '', false, false)]
    local procedure RunWorkflowOnSendApproval(var Rec: Record "Student Approval test")
    begin
        if not WorkflowManagement.CanExecuteWorkflow(Rec, SendApprovalEventCode)
           then
            Error(NoWorkflowEnabledErr);
        //This checkes if the workflow can be executed for the record. If not, it will show an error message to the user.
        WorkflowManagement.HandleEvent(SendApprovalEventCode, Rec);
    end;
    //Handling Pending approval event, it changes the status of the document to pending approval and triggers the workflow.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure RunWorkflowOnCancelApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number = Database::"Student Approval test" then begin

            RecRef.SetTable(StudentRequest);

            StudentRequest.Status := StudentRequest.Status::"Pending Approval";

            StudentRequest.Modify();

            Variant := StudentRequest;

            IsHandled := true;
        end;
    end;
    //Handling approved/rejected event, it changes the status of the document to approved/rejected based on the action taken by the approver and triggers the workflow.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure ReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number = Database::"Student Approval test" then begin

            RecRef.SetTable(StudentRequest);

            StudentRequest.Status :=
                StudentRequest.Status::Approved;

            StudentRequest.Modify(true);

            Handled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]
    local procedure RejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        StudentRequest: Record "Student Approval test";
    begin
        if ApprovalEntry."Table ID" =
          Database::"Student Approval test"
      then begin

            if StudentRequest.Get(
                ApprovalEntry."Document No.")
            then begin

                StudentRequest.Status :=
                    StudentRequest.Status::Rejected;

                StudentRequest.Modify(true);
            end;
        end;
    end;
    //Populating approval entires
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure PopulateApprovalEntry(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        StudentRequest: Record "Student Approval test";
    begin
        if RecRef.Number =
             Database::"Student Approval test"
         then begin

            RecRef.SetTable(StudentRequest);

            ApprovalEntryArgument."Document No." := StudentRequest."Student No.";
        end;

    end;
    //Adding workflow response predecessors to the library
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin

        case ResponseFunctionName of

            WorkflowResponseHandling.CreateApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode(), SendApprovalEventCode);

            WorkflowResponseHandling.CancelAllApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode(), CancelApprovalEventCode);
        end;
    end;
}
