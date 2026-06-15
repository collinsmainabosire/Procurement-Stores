namespace BCTRAINING.BCTRAINING;

query 50100 "Active Loans Query"
{
    QueryType = Normal;
    Caption = 'Active Loans';
    
    elements
    {
        dataitem(EmployeeLoanHeader; "Employee Loan Header")
        {
            filter(StatusFilter; Status)
            {
                Caption = 'Status';
            }
            
            filter(EmployeeFilter; "Employee No.")
            {
                Caption = 'Employee';
            }
            
            column(LoanNo; "Loan No.")
            {
                Caption = 'Loan No.';
            }
            column(EmployeeNo; "Employee No.")
            {
                Caption = 'Employee No.';
            }
            column(EmployeeName; "Employee Name")
            {
                Caption = 'Employee Name';
            }
            column(ApprovedAmount; "Approved Amount")
            {
                Caption = 'Approved Amount';
            }
            column(OutstandingBalance; "Outstanding Balance")
            {
                Caption = 'Outstanding Balance';
            }
            column(TotalPaid; "Total Paid")
            {
                Caption = 'Total Paid';
            }
        }
    }
}