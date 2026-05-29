namespace BCTRAINING.BCTRAINING;

page 50102 "Online User API"
{
    APIGroup = 'studentportal';
    APIPublisher = 'bcTraining';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'onlineUserAPI';
    DelayedInsert = true;
    EntityName = 'onlineuser';
    EntitySetName = 'onlineusers';
    PageType = API;
    SourceTable = "Online Users";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(userID; Rec."User ID")
                {
                    Caption = 'User ID';
                }
                field(fullName; Rec."Full Name")
                {
                    Caption = 'Full Name';
                }
                field(email; Rec.Email)
                {
                    Caption = 'Email';
                }
                field(password; Rec.Password)
                {
                    Caption = 'Password';
                }
                field(createdDate; Rec."Created Date")
                {
                    Caption = 'Created Date';
                }
            }
        }
    }
}
