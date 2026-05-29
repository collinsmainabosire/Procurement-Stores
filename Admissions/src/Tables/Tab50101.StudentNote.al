table 50101 "Student Note"
{
    Caption = 'Student Note';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }

        field(2; Title; Text[100])
        {
            DataClassification = CustomerContent;
        }

        field(3; Description; Text[250])
        {
            DataClassification = CustomerContent;
        }

        field(4; "User Email"; Text[100])
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
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
