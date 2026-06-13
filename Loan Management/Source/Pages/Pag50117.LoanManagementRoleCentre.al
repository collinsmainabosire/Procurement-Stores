namespace BCTRAINING.BCTRAINING;

page 50117 "Loan Management Role Centre"
{
    PageType = RoleCenter;
    ApplicationArea = All;
    Caption = 'Loan Management';

    layout
    {
        area(RoleCenter)
        {
            group(ActivitiesGroup)
            {
                Caption = 'Activities';
                ShowCaption = false;

                part(Activities; "Loan Activities")
                {
                    ApplicationArea = All;
                }
            }

            group(NavigationGroup)
            {
                Caption = 'Navigation';

                part(Navigation; "Loan Management Navigation")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}