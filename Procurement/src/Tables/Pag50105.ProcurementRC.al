namespace BCTRAINING.BCTRAINING;

page 50105 "Procurement RC"
{
    ApplicationArea = All;
    Caption = 'Procurement Role Centre';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
        }
    }

    actions
    {
        area(embedding)
        {
            action("Students Approval Requests")
            {
                Caption = 'Students Approval Requests';
                Image = Workflow;
                RunObject = Page "Approval Test";
                ApplicationArea = All;
            }

        }
        area(processing)
        {
            group("Procurement Management")
            {
                Caption = 'Procurement Management';
                Image = Job;


            }
            group("Common Requisitions")
            {
                Caption = 'Common Requisitions';

                action("Stores Requisitions")
                {
                    Caption = 'Stores Requisitions';
                    ApplicationArea = All;

                }
                action("Imprest Requisitions")
                {
                    Caption = 'Imprest Requisitions';
                    ApplicationArea = All;
                }
                action("Transport Requisition")
                {
                    Caption = 'Transport Requisition';
                    ApplicationArea = All;
                }
            }
        }
    }
}
