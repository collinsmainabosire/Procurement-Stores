table 50112 "Interview Score"
{
    Caption = 'Interview Score';
    DataClassification = ToBeClassified;
    // LINE TABLE for Interview
    // Multiple score categories per interview
    // Example: Technical (85), Communication (90), Leadership (80)

    fields
    {
        field(1; "Interview ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Interview"."Interview ID";

            trigger OnValidate()
            begin
                if "Interview ID" <> '' then begin
                    Interview.Get("Interview ID");
                end;
            end;
        }

        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(3; "Score Category"; Text[50])
        {
            DataClassification = ToBeClassified;
            // Technical Skills, Communication, Problem Solving, etc.

            trigger OnValidate()
            begin
                if "Score Category" = '' then
                    Error('Score category is required');
            end;
        }

        field(4; "Weight %"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 100;
            InitValue = 100;
            // How much this category counts toward total
        }

        field(5; "Score Value"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 100;

            trigger OnValidate()
            begin
                if ("Score Value" > 100) or ("Score Value" < 0) then
                    Error('Score must be between 0 and 100');
            end;
        }

        field(6; "Comments"; Text[500])
        {
            DataClassification = ToBeClassified;
            // Interviewer comments on this score
        }

        field(7; "Weighted Score"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            DecimalPlaces = 2;

            trigger OnCalc()
            begin
                "Weighted Score" := ("Score Value" * "Weight %") / 100;
            end;
        }

        field(8; "Grade"; Text[10])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            // A, B, C, D, F based on score
        }

        field(9; "Created Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Interview ID", "Line No.")
        {
            Clustered = true;
        }

        key(Category; "Score Category")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Line No." = 0 then
            "Line No." := GetNextLineNo();

        "Created Date" := CurrentDateTime;
        CalculateGrade();
    end;

    trigger OnModify()
    begin
        CalculateGrade();
    end;

    local procedure GetNextLineNo(): Integer
    var
        InterviewScore: Record "Interview Score";
    begin
        InterviewScore.SetRange("Interview ID", "Interview ID");
        if InterviewScore.FindLast() then
            exit(InterviewScore."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure CalculateGrade()
    begin
        case true of
            "Score Value" >= 90:
                "Grade" := 'A';
            "Score Value" >= 80:
                "Grade" := 'B';
            "Score Value" >= 70:
                "Grade" := 'C';
            "Score Value" >= 60:
                "Grade" := 'D';
            else
                "Grade" := 'F';
        end;
    end;

    var
        Interview: Record "Interview";
}