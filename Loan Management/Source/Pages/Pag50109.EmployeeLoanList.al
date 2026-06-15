namespace BCTRAINING.BCTRAINING;

page 50109 "Employee Loan List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Employee Loan Header";
    Caption = 'Employee Loans';
    Editable = false;
    
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique loan number';
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Employee who borrowed the loan';
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the employee';
                }
                field("Loan Type"; Rec."Loan Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Type of loan';
                }
                field("Requested Amount"; Rec."Requested Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount requested by employee';
                }
                field("Approved Amount"; Rec."Approved Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount approved by manager';
                }
                field("Outstanding Balance"; Rec."Outstanding Balance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Remaining amount to be paid';
                    StyleExpr = OutstandingBalanceStyle;
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Current status of the loan';
                    StyleExpr = StatusStyle;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date loan was requested';
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(OpenLoan)
            {
                ApplicationArea = All;
                Caption = 'Open';
                Image = Open;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Open loan details';
                Enabled = (Rec."Loan No." <> '');
                
                trigger OnAction()
                begin
                    Page.Run(Page::"Employee Loan Card", Rec);
                end;
            }
            
            action(NewLoan)
            {
                ApplicationArea = All;
                Caption = 'New Loan';
                Image = New;
                Promoted = true;
                PromotedCategory = New;
                ToolTip = 'Create a new loan application';
                
                trigger OnAction()
                begin
                    Page.Run(Page::"Employee Loan Card");
                end;
            }
            
            action(SendForApproval)
            {
                ApplicationArea = All;
                Caption = 'Send for Approval';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Submit loan for approval';
                Enabled = (Rec."Status" = Rec."Status"::Open);
                
                trigger OnAction()
                var
                    LoanApprovalMgmt: Codeunit "Loan Approval Management";
                begin
                    // Call codeunit to handle approval
                    if LoanApprovalMgmt.SendForApproval(Rec) then begin
                        Message('Loan sent for approval');
                        CurrPage.Update(false);
                    end;
                end;
            }
            
            action(RefreshBalance)
            {
                ApplicationArea = All;
                Caption = 'Refresh Balance';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Recalculate outstanding balance';
                
                trigger OnAction()
                var
                    LoanMgmt: Codeunit "Loan Management";
                begin
                    // Call codeunit to calculate balance
                    Rec."Outstanding Balance" := LoanMgmt.CalculateBalance(Rec."Loan No.");
                    Rec.Modify();
                    CurrPage.Update(false);
                end;
            }
        }
    }
    
    trigger OnAfterGetRecord()
    begin
        // Set styling based on status
        UpdateStyles();
    end;
    
    var
        OutstandingBalanceStyle: Text;
        StatusStyle: Text;
    
    local procedure UpdateStyles()
    begin
        // Color code the outstanding balance
        if Rec."Outstanding Balance" > 0 then
            OutstandingBalanceStyle := 'Attention'
        else
            OutstandingBalanceStyle := 'Favorable';
        
        // Color code the status
        case Rec."Status" of
            Rec."Status"::Open:
                StatusStyle := 'None';
            Rec."Status"::"Pending Approval":
                StatusStyle := 'Attention';
            Rec."Status"::Approved:
                StatusStyle := 'Favorable';
            Rec."Status"::Rejected:
                StatusStyle := 'Unfavorable';
            Rec."Status"::Disbursed:
                StatusStyle := 'Strong';
            Rec."Status"::Closed:
                StatusStyle := 'Favorable';
        end;
    end;
}