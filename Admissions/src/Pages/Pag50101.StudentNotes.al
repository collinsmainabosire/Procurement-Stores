namespace BCTRAINING.BCTRAINING;

page 50101 "Student Notes"
{
    ApplicationArea = All;
    Caption = 'Student Notes';
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "Student Note";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }

                field(Title; Rec.Title)
                {
                }

                field(Description; Rec.Description)
                {
                }

                field("User Email"; Rec."User Email")
                {
                }

                field("Created Date"; Rec."Created Date")
                {
                }
            }
        }
    }
}