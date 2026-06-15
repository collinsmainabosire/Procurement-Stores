table 50122 "Loan Report Selection"
{
    DataClassification = ToBeClassified;
    Caption = 'Loan Report Selection';

    fields
    {
        field(1; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            NotBlank = true;
        }
        field(2; "Report Name"; Text[100])
        {
            Caption = 'Report Name';
        }
        field(3; "Description"; Text[250])
        {
            Caption = 'Description';
        }
        field(4; "Active"; Boolean)
        {
            Caption = 'Active';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Report ID")
        {
            Clustered = true;
        }
    }
}