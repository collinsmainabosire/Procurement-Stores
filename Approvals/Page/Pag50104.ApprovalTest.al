namespace BCTRAINING.BCTRAINING;

using System.Automation;

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

        area(FactBoxes)
        {
            part(ApprovalComments; "Approval Comments Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Table ID" = const(50102),
                              "Document No." = field("Student No.");
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
                    // Allow sending only when document is Open
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
                    // Only visible when document is pending
                    Enabled = Rec.Status = Rec.Status::"Pending Approval";

                    trigger OnAction()
                    var
                        CustomApproval: Codeunit "Custom Approval";
                    begin
                        CustomApproval.OnCancelStudentApprovalTestForApproval(Rec);
                    end;
                }
                action(Approvals)
                {
                    ApplicationArea = All;
                    Caption = 'Approvals';
                    ToolTip = 'View approval entries for this document.';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        ApprovalEntry: Record "Approval Entry";
                    begin
                        ApprovalEntry.SetRange("Table ID", Database::"Student Approval test");
                        ApprovalEntry.SetRange("Document No.", Rec."Student No.");
                        Page.RunModal(Page::"Approval Entries", ApprovalEntry);
                    end;
                }
            }
        }
    }
}