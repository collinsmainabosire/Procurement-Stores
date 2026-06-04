namespace BCTRAINING.BCTRAINING;

using System.Automation;

/*pageextension 50101 "Student Approval Requests Ext" extends "Requests to Approve"

{
    actions
    {
        addlast(processing)
        {
            action(OpenStudentRecord)
            {
                ApplicationArea = All;
                Caption = 'Open Record';
                Image = Document;
                Visible = IsStudentTable;

                trigger OnAction()
                var
                    StudentRequest: Record "Student Approval test";
                    RecRef: RecordRef;
                begin
                    if RecRef.Get(Rec."Record ID to Approve") then begin
                        RecRef.SetTable(StudentRequest);
                        Page.Run(Page::"Approval Test", StudentRequest);
                        exit;
                    end;

                    if StudentRequest.Get(Rec."Document No.") then begin
                        Page.Run(Page::"Approval Test", StudentRequest);
                        exit;
                    end;

                    Error('Cannot open record. Student request %1 was not found.', Rec."Document No.");
                end;
            }
        }

    }

    var
        IsStudentTable: Boolean;
}
*/