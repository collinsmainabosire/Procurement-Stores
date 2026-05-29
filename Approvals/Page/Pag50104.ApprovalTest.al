namespace BCTRAINING.BCTRAINING;

page 50104 "Approval Test"
{
    ApplicationArea = All;
    Caption = 'Approval Test';
    PageType = Card;
    SourceTable = "Student Approval test";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Student No."; Rec."Student No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the student number.';
                }

                field("Student Name"; Rec."Student Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the student name.';
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the approval status.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Approval)
            {
                Caption = 'Approval';

                action(SendForApproval)
                {
                    ApplicationArea = All;
                    Caption = 'Send for Approval';
                    ToolTip = 'Sends the document for approval.';
                    Image = SendApprovalRequest;

                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    Enabled = Rec.Status = Rec.Status::Open;

                    trigger OnAction()
                    var
                        CustomApproval: Codeunit "Custom Approval";
                    begin
                        CustomApproval.OnSendStudentApprovalTestForApproval(Rec);
                    end;
                }

                action(CancelApproval)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Approval';
                    ToolTip = 'Cancels the approval request.';
                    Image = CancelApprovalRequest;

                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    Enabled = Rec.Status = Rec.Status::"Pending Approval";

                    trigger OnAction()
                    var
                        CustomApproval: Codeunit "Custom Approval";
                    begin
                        CustomApproval.OnCancelStudentApprovalTestForApproval(Rec);
                    end;
                }
            }
        }
    }
}