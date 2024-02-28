module SuffBalance (output reg balanceExist ,input [10:0]withdraw , accountBalance);
       
  initial begin
    if (accountBalance - withdraw >= 11'b0)
      balanceExist=1'b1;
    else balanceExist=1'b0;
  end
        
endmodule

module ATM(
input clk,
input exit,
input [3:0] password,
input [1:0] menuOptions,
input lang,
input [10:0] depValue,
input [10:0] withValue,
input card,
output reg error,
output reg balanceExist
);

reg [10:0] accountBalance;
reg option;
parameter [3:0] IDLE = 4'b0000;
parameter [3:0] LANG = 4'b0001;
parameter [3:0] PIN = 4'b0010;
parameter [3:0] MENU = 4'b0011;
parameter [3:0] WITHDRAW = 4'b0100;
parameter [3:0] DEPOSIT = 4'b0101;
parameter [3:0] BALANCE = 4'b0110;
parameter [3:0] PRINT = 4'b1000;
parameter [3:0] EXIT = 4'b1001;
reg [3:0] curr_state = IDLE;
reg [3:0] accountPass = 4'b1001; //Assumption
reg [1:0] trials = 2'b00; //Allowd times for invalid password

initial
  begin
	accountBalance = 11'd5000;
    $display("Welcome to ATM");
  end
  
  SuffBalance be(balanceExist,withValue,accountBalance);


always @ (card or exit or menuOptions or password)
begin
	case(curr_state)
        IDLE: begin
            case(card)
            1'b0: curr_state = IDLE;
            1'b1: begin
                curr_state = LANG;
                $display("Logged In");
            end
            default: curr_state = IDLE;
            endcase
        end
        LANG: begin
            $display("Choose Language - (1) English / (2) Arabic");
            case(lang)
            1'b0: curr_state = LANG;
            1'b1: curr_state = PIN;
            default: curr_state = LANG;
            endcase
        end
        PIN: begin
            case(password)
            accountPass: curr_state = MENU;
            default: begin
                $display("Invalid Password");
                trials = trials + 2'b1;
                if(trials == 2'b11) begin
                    curr_state = IDLE;
                    trials = 2'b00;
                end
                else 
                begin 
                    curr_state = PIN;
                    error=1'b1;
                end
            end
            endcase
        end
        MENU: begin
            $display("Choose Operation - (0) Deposit / (1) Balance / (2) Withdraw / (3) Exit");
            case(menuOptions)
            2'b00: curr_state = DEPOSIT;
            2'b01: curr_state = BALANCE;
            2'b10: curr_state = WITHDRAW;
            2'b11: curr_state = EXIT;
            default: curr_state = MENU;
            endcase
        end
        DEPOSIT: begin
            if(depValue == 11'b0 || depValue == 11'bX || depValue == 11'bZ) curr_state = DEPOSIT;
            else 
                begin
                    accountBalance = accountBalance + depValue; //insha2allah hatzbot
                    option = 1'b0;
                    curr_state = PRINT;
                end
        end
        BALANCE: begin
            $display("Balance is %d", accountBalance);
            curr_state = MENU;

        end

        WITHDRAW: begin
            $display("Enter amount to be withdrawn");
            if(balanceExist)
            begin 
            accountBalance= accountBalance-withValue;
            option=1'b1;
            curr_state = PRINT;
            end
            else 
            begin
              $display("Balance isn't enough for withdrawing");
            error=1'b1;
            end
        end

        PRINT: begin
            case(option)
            1'b0:
            $display("Balance after withdrawl is: %d",accountBalance);
            1'b1:
            $display("Balance after depositing is: %d",accountBalance);
            default: curr_state = IDLE;
            endcase

            curr_state=MENU;
        end
        EXIT: curr_state=IDLE;
    endcase
end

endmodule

