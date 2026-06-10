table 50107 "Security Log"
{
    Caption = 'Security Log';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "ID"; BigInteger)
        {
            AutoIncrement = true;
            Editable = false;
        }

        field(2; "Event Type"; Text[100])
        {
            // Failed Login, Password Changed, Account Locked, etc.
        }

        field(3; "User ID"; Code[50])
        {
        }

        field(4; "Details"; Text[500])
        {
        }

        field(5; "Timestamps"; DateTime)
        {
        }

        field(6; "IP Address"; Text[50])
        {
            // For future use when you add web API
        }
    }

    keys
    {
        key(PK; "ID")
        {
            Clustered = true;
        }

        key(User; "User ID", "Timestamps")
        {
        }
    }
}