
namespace BCTRAINING.BCTRAINING;

table 50123 "Loan User Profile"
{
    DataClassification = ToBeClassified;
    Caption = 'Loan User Profile';
    
    fields
    {
        field(1; "Profile ID"; Code[30])
        {
            Caption = 'Profile ID';
        }
        field(2; "Role Centre ID"; Integer)
        {
            Caption = 'Role Centre ID';
            InitValue = 50117;
        }
        field(3; "Description"; Text[100])
        {
            Caption = 'Description';
        }
    }
    
    keys
    {
        key(PK; "Profile ID")
        {
            Clustered = true;
        }
    }
}