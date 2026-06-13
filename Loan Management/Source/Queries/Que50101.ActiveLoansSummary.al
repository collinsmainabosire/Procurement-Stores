namespace BCTRAINING.BCTRAINING;

query 50101 "Active Loans Summary"
{
    Caption = 'Active Loans Summary';
    QueryType = Normal;
    
    elements
    {
        dataitem(""; "")
        {
        }
    }
    
    trigger OnBeforeOpen()
    begin
    
    end;
}
