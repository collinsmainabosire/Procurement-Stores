table 50100 "Online Users"
{
    Caption = 'Online Users';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }

        field(2; "Full Name"; Text[100])
        {
            DataClassification = CustomerContent;
        }

        field(3; Email; Text[100])
        {
            DataClassification = CustomerContent;
        }

        field(4; Password; Text[100])
        {
            DataClassification = CustomerContent;
        }

        field(5; "Created Date"; DateTime)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "User ID")
        {
            Clustered = true;
        }
    }
}