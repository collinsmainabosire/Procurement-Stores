namespace BCTRAINING.BCTRAINING;

page 50110 "Employee Loan Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Employee Loan Header";
    Caption = 'Employee Loan';
    
    layout
    {
        area(Content)
        {
            group(Header)
            {
                Caption = 'Loan Information';
                
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique loan number. Auto-generated.';
                    Editable = false;
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
                    Editable = (Rec."Status" = Rec."Status"::Open);
                }
            }
            
            group(Employee)
            {
                Caption = 'Employee Details';
                
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Employee requesting the loan';
                    Editable = (Rec."Status" = Rec."Status"::Open);
                    ShowMandatory = true;
                    
                    trigger OnValidate()
                    begin
                        // This will run validation in table
                        // Table will populate Employee Name
                        CurrPage.Update(false);
                    end;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Employee name. Auto-populated.';
                    Editable = false;
                }
            }
            
            group(LoanDetails)
            {
                Caption = 'Loan Terms';
                
                field("Loan Type"; Rec."Loan Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Type of loan (Personal, Emergency, etc)';
                    Editable = (Rec."Status" = Rec."Status"::Open);
                    ShowMandatory = true;
                    
                    trigger OnValidate()
                    begin
                        // Table validates and populates limits
                        CurrPage.Update(false);
                    end;
                }
                field("Requested Amount"; Rec."Requested Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount employee is requesting';
                    Editable = (Rec."Status" = Rec."Status"::Open);
                    
                    trigger OnValidate()
                    begin
                        // Table will validate against Maximum Amount
                        CurrPage.Update(false);
                    end;
                }
                field("Maximum Amount"; Rec."Maximum Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum allowed for this loan type';
                    Editable = false;
                }
                field("Approved Amount"; Rec."Approved Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount approved by manager';
                    Editable = false;
                }
                field("Term Months"; Rec."Term Months")
                {
                    ApplicationArea = All;
                    ToolTip = 'Repayment period in months';
                    Editable = (Rec."Status" = Rec."Status"::Open);
                    
                    trigger OnValidate()
                    begin
                        // Table will validate against Maximum Term
                        CurrPage.Update(false);
                    end;
                }
                field("Maximum Term Months"; Rec."Maximum Term Months")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum term allowed for this loan type';
                    Editable = false;
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Interest rate percentage';
                    Editable = false;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Total including interest';
                    Editable = false;
                }
                field("Purpose"; Rec."Purpose")
                {
                    ApplicationArea = All;
                    ToolTip = 'Reason for the loan';
                    Editable = (Rec."Status" = Rec."Status"::Open);
                    MultiLine = true;
                }
            }
            
            group(Approval)
            {
                Caption = 'Approval Status';
                
                field("Approval Status"; Rec."Approval Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Approval workflow status';
                    Editable = false;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Who approved this loan';
                    Editable = false;
                }
                field("Approval Date"; Rec."Approval Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date of approval';
                    Editable = false;
                }
                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Why the loan was rejected';
                    Editable = false;
                    MultiLine = true;
                }
            }
            
            group(Disbursement)
            {
                Caption = 'Disbursement';
                
                field("Disbursement Date"; Rec."Disbursement Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date loan was disbursed to employee';
                    Editable = false;
                }
                field("Disbursed Amount"; Rec."Disbursed Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount disbursed';
                    Editable = false;
                }
            }
            
            group(Balance)
            {
                Caption = 'Balance Information';
                
                field("Outstanding Balance"; Rec."Outstanding Balance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount still owed';
                    Editable = false;
                    StyleExpr = BalanceStyle;
                }
                field("Total Paid"; Rec."Total Paid")
                {
                    ApplicationArea = All;
                    ToolTip = 'Total amount paid so far';
                    Editable = false;
                }
            }
            
            group(Closure)
            {
                Caption = 'Closure';
                
                field("Closed Date"; Rec."Closed Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date loan was fully repaid';
                    Editable = false;
                }
            }
            
            group(AuditTrail)
            {
                Caption = 'Audit Trail';
                
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Who created this loan record';
                    Editable = false;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'When this loan was created';
                    Editable = false;
                }
                field("Last Modified By"; Rec."Last Modified By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Who last modified this loan';
                    Editable = false;
                }
                field("Last Modified Date"; Rec."Last Modified Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'When it was last modified';
                    Editable = false;
                }
            }
        }
        
        area(FactBoxes)
        {
            part(RepaymentSchedulePart; "Loan Schedule List")
            {
                ApplicationArea = All;
                SubPageLink = "Loan No." = field("Loan No.");
                Caption = 'Repayment Schedule';
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(SendForApproval)
            {
                ApplicationArea = All;
                Caption = 'Send for Approval';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Submit this loan for approval';
                Visible = (Rec."Status" = Rec."Status"::Open);
                
                trigger OnAction()
                var
                    LoanApprovalMgmt: Codeunit "Loan Approval Management";
                begin
                    if LoanApprovalMgmt.SendForApproval(Rec) then begin
                        Message('Loan sent for approval');
                        CurrPage.Update(false);
                    end;
                end;
            }
            
            action(ApproveLoan)
            {
                ApplicationArea = All;
                Caption = 'Approve';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Approve this loan application';
                Visible = (Rec."Status" = Rec."Status"::"Pending Approval");
                
                trigger OnAction()
                var
                    LoanApprovalMgmt: Codeunit "Loan Approval Management";
                begin
                    if LoanApprovalMgmt.ApproveLoan(Rec."Loan No.", UserId, '') then begin
                        Message('Loan approved successfully');
                        Rec.Get(Rec."Loan No.");
                        CurrPage.Update(false);
                    end;
                end;
            }
            
            action(RejectLoan)
            {
                ApplicationArea = All;
                Caption = 'Reject';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Reject this loan application';
                Visible = (Rec."Status" = Rec."Status"::"Pending Approval");
                
                trigger OnAction()
                var
                    LoanApprovalMgmt: Codeunit "Loan Approval Management";
                    RejectionReason: Text[500];
                begin
                    if Confirm('Are you sure you want to reject this loan?', false) then begin
                        RejectionReason := 'Rejected by approver';
                        if LoanApprovalMgmt.RejectLoan(Rec."Loan No.", UserId, RejectionReason) then begin
                            Message('Loan rejected');
                            Rec.Get(Rec."Loan No.");
                            CurrPage.Update(false);
                        end;
                    end;
                end;
            }
            
            action(DisburseAmount)
            {
                ApplicationArea = All;
                Caption = 'Disburse Loan';
                Image = Payment;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Disburse the approved loan amount';
                Visible = (Rec."Status" = Rec."Status"::Approved);
                
                trigger OnAction()
                var
                    LoanMgmt: Codeunit "Loan Management";
                begin
                    if Confirm('Are you sure you want to disburse this loan?', false) then begin
                        if LoanMgmt.DisburseLoan(Rec."Loan No.", Today) then begin
                            Message('Loan disbursed successfully');
                            Rec.Get(Rec."Loan No.");
                            CurrPage.Update(false);
                        end;
                    end;
                end;
            }
            
            action(ViewSchedule)
            {
                ApplicationArea = All;
                Caption = 'View Repayment Schedule';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View detailed repayment schedule';
                Visible = (Rec."Status" = Rec."Status"::Disbursed);
                
                trigger OnAction()
                var
                    LoanSchedule: Record "Employee Loan Schedule";
                begin
                    LoanSchedule.SetRange("Loan No.", Rec."Loan No.");
                    Page.Run(Page::"Loan Schedule List", LoanSchedule);
                end;
            }
        }
    }
    
    trigger OnAfterGetRecord()
    begin
        UpdateStyles();
    end;
    
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // Set defaults for new record
        Rec."Application Date" := Today;
    end;
    
    var
        StatusStyle: Text;
        BalanceStyle: Text;
    
    local procedure UpdateStyles()
    begin
        // Color the status
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
        
        // Color the balance
        if Rec."Outstanding Balance" > 0 then
            BalanceStyle := 'Attention'
        else
            BalanceStyle := 'Favorable';
    end;
}
