table 50102 "Student Approval test"
{
    Caption = 'Student Approval test';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Student No."; Code[20])
        {
            Caption = 'Student No.';
        }
        field(2; "Student Name"; Text[100])
        {
            Caption = 'Student Name';
        }
        field(3; Status; Enum "Custom Status")
        {
            Caption = 'Status';
        }
    }
    keys
    {
        key(PK; "Student No.")
        {
            Clustered = true;
        }
    }
}
