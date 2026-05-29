namespace BCTRAINING.BCTRAINING;

page 50100 "Online Users List"
{
    ApplicationArea = All;
    Caption = 'Online Users List';
    PageType = List;
    SourceTable = "Online Users";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("User ID"; Rec."User ID")
                {
                }

                field("Full Name"; Rec."Full Name")
                {
                }

                field(Email; Rec.Email)
                {
                }

                field(Password; Rec.Password)
                {
                }

                field("Created Date"; Rec."Created Date")
                {
                }
            }
        }
    }
}