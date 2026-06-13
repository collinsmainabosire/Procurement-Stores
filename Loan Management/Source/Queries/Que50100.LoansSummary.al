namespace BCTRAINING.BCTRAINING;

query 50100 "Loans Summary"
{
    QueryType = Normal;

    elements
    {
        dataitem(EmployeeLoanHeader; "Employee Loan Header")
        {
            column(Loan_No; "Loan No.")
            {
            }
            column(Employee_No; "Employee No.")
            {
            }
            column(Loan_Type; "Loan Type")
            {
            }
            column(Status; Status)
            {
            }
            column(Outstanding_Balance; "Outstanding Balance")
            {
            }
            column(Total_Paid; "Total Paid")
            {
            }
            column(Application_Date; "Application Date")
            {
            }
        }
    }
}