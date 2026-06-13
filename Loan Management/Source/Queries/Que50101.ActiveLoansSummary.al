namespace BCTRAINING.BCTRAINING;

query 50101 "Active Loans Summary"
{
    QueryType = Normal;

    elements
    {
        dataitem(EmployeeLoanHeader; "Employee Loan Header")
        {
            filter(StatusFilter; Status)
            {
            }

            column(Employee_No; "Employee No.")
            {
            }
            column(Outstanding_Balance; "Outstanding Balance")
            {
                Method = Sum;
            }
           /* column(Loan_Count; "Loan No.")
            {
                Method = Count;
            }*/
        }
    }
}