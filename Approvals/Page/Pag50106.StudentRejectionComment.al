namespace BCTRAINING.BCTRAINING;

using System.Automation;

page 50106 "Student Rejection Comment"
{
    PageType = StandardDialog;
    Caption = 'Rejection Comment';

    layout
    {
        area(Content)
        {
            field(Comment; CommentText)
            {
                ApplicationArea = All;
                Caption = 'Comment';
                MultiLine = true;
                ToolTip = 'Enter a reason for rejecting this request.';
            }
        }
    }

    var
        CommentText: Text[250];
        ApprovalEntry: Record "Approval Entry";

    procedure SetApprovalEntry(Entry: Record "Approval Entry")
    begin
        ApprovalEntry := Entry;
    end;

    procedure GetComment(): Text[250]
    begin
        exit(CommentText);
    end;
}
