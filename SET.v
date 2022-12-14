module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output reg busy;
output reg valid;
output reg [7:0] candidate;


reg [3:0] x,y;

wire [3:0] x1_d,x2_d,x3_d;//difference//x對圓心x的差值
wire [3:0] y1_d,y2_d,y3_d;//difference//y對圓心y的差值
wire [7:0] r1_s,r2_s,r3_s; //square//圓半徑平方
wire [7:0] dis1,dis2,dis3;//xy到圓心距離

assign x1_d = (x >= central[23:20] ? x - central[23:20] : central[23:20] - x);//x1
assign y1_d = (y >= central[19:16] ? y - central[19:16] : central[19:16] - y);//y1
assign x2_d = (x >= central[15:12] ? x - central[15:12] : central[15:12] - x);//x2
assign y2_d = (y >= central[11:8] ? y - central[11:8] : central[11:8] - y);//y2
assign x3_d = (x >= central[7:4] ? x - central[7:4] : central[7:4] - x);//x3
assign y3_d = (y >= central[3:0] ? y - central[3:0] : central[3:0] - y);//y3
assign r1_s = radius[11:8] * radius[11:8];
assign r2_s = radius[7:4] * radius[7:4];
assign r3_s = radius[3:0] * radius[3:0];
assign dis1 = x1_d * x1_d + y1_d * y1_d;
assign dis2 = x2_d * x2_d + y2_d * y2_d;
assign dis3 = x3_d * x3_d + y3_d * y3_d;

always @(posedge clk or posedge rst) begin //busy
	if(rst)
		busy <= 0;
	else if(x == 8 && y == 8)
		busy <= 0;	
	else if(en == 0)
		busy <= 1;
end

always @(posedge clk or posedge rst) begin //valid
	if(rst)
		valid <= 0;
	else if(y == 8 && x == 7)
		valid <= 1;
	else
		valid <= 0;
end

always @(*) begin //candidate
	if(rst)
		candidate = 0;
	else if(busy == 0)
		candidate = 0;
	else begin
	case(mode)
		2'b00:begin
			if(r1_s >= dis1)
				candidate = candidate + 1;
		end
		2'b01:begin
			if(r1_s >= dis1 && r2_s >= dis2)
				candidate = candidate + 1;
		end
		2'b10:begin
			if((r1_s >= dis1 && r2_s < dis2) || (r2_s >= dis2 && r1_s < dis1))
				candidate = candidate + 1;
		end
		2'b11:begin
			if((r1_s >= dis1 && r2_s >= dis2 && r3_s < dis3) || (r1_s >= dis1 && r2_s < dis2 && r3_s >= dis3) || (r1_s < dis1 && r2_s >= dis2 && r3_s >= dis3))begin
				candidate = candidate + 1;
			end
		end
	endcase
	end
end

always @(posedge clk) begin //xy
	if(en)begin
		x <= 1;
		y <= 1;
	end
	else if(x == 8 && y == 8)begin
		x <= 1;
		y <= 1;
	end
	else if(x == 8) begin
		x <= 1;
		y <= y + 1;
	end
	else if(busy == 1)
		x <= x + 1;
end

endmodule

