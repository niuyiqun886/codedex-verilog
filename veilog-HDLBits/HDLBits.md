
```verilog
module top_module(
	input a,
	input b,
	input c,
	output w,
	output x,
	output y,
	output z);
	
	assign w = a;
	assign x = b;
	assign y = b;
	assign z = c;
endmdule
```


其中可以化简：如果确定每个信号的宽度，则使用连接运算符等效更简单。

```verilog
module top_module(
	input a,b,c,
	output w,x,y,z);
	
	assign {w,x,y,z} = {a,b,b,c};
endmdule
```


**非门：**
1. 按位非 ~（bitwise NOT）  
	对操作数的每一个 bit 分别取反，结果的位宽和操作数相同。比如对一个 4 位信号 `a = 4'b1010`，`~a` 的结果是 `4'b0101`——每一位都翻转。
2. 逻辑非 !（logical NOT）  
	把整个操作数当作一个"真/假"来判断，结果永远是 1 位。只要操作数中有任何一位是 1（即非零），就当作"真"，`!` 的结果为 0；如果操作数全为 0（即"假"），`!` 的结果为 1。比如 `a = 4'b1010`（非零），`!a` 的结果是 `1'b0`。

**与门：**
1. 按位与 &（bitwise AND）  
	把两个操作数对应位置的 bit 一一配对做与运算，结果位宽等于较宽的那个操作数。比如 `a = 4'b1100`、`b = 4'b1010`，那么 `a & b` 得到 `4'b1000`——第 3 位两边都是 1 所以留 1，其余位至少有一边是 0 所以为 0。
2. 逻辑与 &&（logical AND）  
	把两个操作数各自整体判断成"真/假"（非零为真，全零为假），然后做与运算，结果永远是 1 位。同样是 `a = 4'b1100`、`b = 4'b1010`，两者都非零，所以都算"真"，`a && b` 的结果是 `1'b1`。

**或非门：** 不要混着用符号
1. 按位或非 ~ |（bitwise NOR）  
2. 逻辑或非 ！ ||（logical NOR）

**异或：**
按位异或"^"，不存在逻辑异或。

**声明wires：**

`声明了一个名为`w`的 8 位向量` 
格式：

```

```verilog
wire [7:0] w;         // 8-bit wire
reg  [4:1] x;         // 4-bit reg
output reg [0:0] y;   // 1-bit reg that is also an output port (this is still a vector)
input wire [3:-2] z;  // 6-bit wire input (negative ranges are allowed)
output [3:0] a;       // 4-bit output wire. Type is 'wire' unless specified otherwise.
wire [0:7] b;         // 8-bit wire where b[0] is the most-significant bit.
```

这个语句需要在输入输出的外面

```verilog
`default_nettype none
module top_module(
    input a, b，
    output out  
	);
    wire and_out1;    //在外面声明

    assign and_out1 = a && b;
    assign out = ! and_out1;

endmodule
```



举例：题目链接：[矢量门](https://hdlbits.01xz.net/wiki/Vectorgates)

b放高位，a放低位：

![](assets/49dc34a5-1b19-48f5-8fac-ea6d3a5c334c.png)


```verilog
module top_module( 
    input [2:0] a,
    input [2:0] b,
    output [2:0] out_or_bitwise,
    output out_or_logical,
    output [5:0] out_not
);
    assign out_or_bitwise[2:0] = a[2:0] | b[2:0];
    assign out_or_logical = a[2:0] || b[2:0];
    assign out_not[5:3] = ~ b[2:0],
    assign out_not[2:0] = ~ a[2:0];

endmodule
```

可以简化：位宽已经对应了，可以改为 a|b；a||b这样子。


**连接运算符：** {a,b,c}用于将向量的较小部分连接起来，从而创建更大的向量。

```verilog
{3'b111, 3'b000} => 6'b111000 
{1'b1, 1'b0, 3'b101} => 5'b10101 
{4'ha, 4'd10} => 8'b10101010 // 4'ha 和 4'd10 的二进制表示均为 4'b1010
```

多次复制的简介方式：

```verilog
assign a = {b,b,b,b,b,b}; //这样更繁琐
{num{vector}}             //此操作将向量复制_num__次_。num_必须_为常量。两组大括号都是必需的。
{5{1'b1}} // 5'b11111（或 5'd31 或 5'h1f）
{2{a,b,c}} // 与 {a,b,c,a,b,c} 相同
```


要注意：这里的assign中需要在24{in[7]}外面再加一个大的{}，才行。

```verilog
module top_module (
    input [7:0] in,
    output [31:0] out );
	
    assign out[31:0] = {{24{in[7]}},in[7:0]};

endmodule
```



题目链接：[模块](https://hdlbits.01xz.net/wiki/Module)

![](assets/841be368-938d-458a-82ab-ce3f6b80a635.png)


模块层级结构是通过将一个模块实例化到另一个模块中而创建的：
注意这里的方式：.in1(a) 是大的在里面小的在外面。
```verilog
module top_module (
	input a,
	input b,
	output out
);

	// Create an instance of "mod_a" named "inst1", and connect ports by name:
	mod_a inst1 ( 
		.in1(a), 	// Port"in1"connects to wire "a"
		.in2(b),	// Port "in2" connects to wire "b"
		.out(out)	// Port "out" connects to wire "out" 
				// (Note: mod_a's port "out" is not related to top_module's wire "out". 
				// It is simply coincidence that they have the same name)
	);

/*
	// Create an instance of "mod_a" named "inst2", and connect ports by position:
	mod_a inst2 ( a, b, out );	// The three wires are connected to ports in1, in2, and out, respectively.
*/
	
endmodule
```


题目链接：[按名称连接端口](https://hdlbits.01xz.net/wiki/Module_name)
举例：只有位置信息，并没给端口的名字。

![](assets/2cfcb7f5-f8e1-41fa-a3ea-edc203fa832a.png)


```verilog
module top_module ( 
    input a, 
    input b, 
    input c,
    input d,
    output out1,
    output out2
);
    //mod_a instant1(.out({out1,out2}), .in({a,b,c,d}));
    //mod_a inst1(.out(out1), .out(out2), .in(a), .in(b), .in(c), .in(d));
    mod_a instant1 ( out1, out2, a, b, c, d );
endmodule
```

>[!warning] 问题
>1.隐藏的两行的问题就是，没有给mod_a中任何一个端口起名字，只给出了端口的位置，所以只能按照位置信息来写。
>2.同一个端口名.out和.in重复使用了多次，Verilog不允许在一次实例化中重复连接同名端口。


这个图就是按照名字来连接的：

![](assets/e0b9d0f0-55de-40fe-8611-9cfea7019d0b.png)


```verilog
module top_module ( 
    input a, 
    input b, 
    input c,
    input d,
    output out1,
    output out2
);
    mod_a inst1(.in1(a), .in2(b), .in3(c), .in4(d), .out1(out1), .out2(out2));
endmodule

```




题目链接：[三个模块](https://hdlbits.01xz.net/wiki/Module_shift)
内部模块连接的写法：

![](assets/db8db3af-b089-4a70-910d-d39c36f71bbf.png)

```verilog
module top_module ( input clk, input d, output q );

    wire out1,out2;
    my_dff inst1(.clk(clk), .d(d), .q(out1));
    my_dff inst2(.clk(clk), .d(out1), .q(out2));
    my_dff inst3(.clk(clk), .d(out2), .q(q));
    
    //也可以这么写，直接按顺序
	//wire a, b;
	//my_dff d1 ( clk, d, a );
	//my_dff d2 ( clk, a, b );
	//my_dff d3 ( clk, b, q );
endmodule
```






题目链接：[模块和向量](https://hdlbits.01xz.net/wiki/Module_shift8)

数据选择器的写法：使用always @( * )  begin

```verilog
module top_module ( 
    input clk, 
    input [7:0] d, 
    input [1:0] sel, 
    output [7:0] q 
);
    wire [7:0] a;
    wire [7:0] b;
    wire [7:0] c;
    my_dff8 inst1(clk, d[7:0], a[7:0]);
    my_dff8 inst2(clk, a[7:0], b[7:0]);
    my_dff8 inst3(clk, b[7:0], c[7:0]);
    
    always @(*) 
    begin
        case (sel)
            2'b00: q[7:0] = d[7:0];
            2'b01: q[7:0] = a[7:0];            
            2'b10: q[7:0] = b[7:0];
            2'b11: q[7:0] = c[7:0];
        endcase
    end
endmodule

```

也可以简化：位数已经对齐了，就不用写了。

```verilog
module top_module (
    input clk,
    input [7:0] d,
    input [1:0] sel,
    output reg [7:0] q      // 注意加 reg
);
    wire [7:0] a, b, c;
    my_dff8 inst1(clk, d, a);
    my_dff8 inst2(clk, a, b);
    my_dff8 inst3(clk, b, c);

    always @(*) 
    begin
        case (sel)
            2'b00: q = d;   // 延迟 0 拍
            2'b01: q = a;   // 延迟 1 拍
            2'b10: q = b;   // 延迟 2 拍
            2'b11: q = c;   // 延迟 3 拍
        endcase
    end
endmodule
```



题目链接： [加法器](https://hdlbits.01xz.net/wiki/Module_fadd)
已经给了一个：(这里有加法器的写法) 
module add16 ( input[15:0] **a**, input[15:0] **b**, input **cin**, output[15:0] **sum**, output **cout** );
需要写add1和add16.

![](assets/916f4f6d-de2d-41af-b2e4-df146835f3a0.png)


```verilog
module top_module (
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum
);//
	wire x;
    add16 inst1(a[15:0], b[15:0], 0, sum[15:0], x);
    add16 inst2(a[31:16], b[31:16], x, sum[31:16]);
    
endmodule

module add1 ( input a, input b, input cin,   output sum, output cout );

// Full adder module here  加法器的写法
	assign sum = a ^ b ^ cin;
	assign cout = a&b | a&cin | b&cin;
endmodule
```



[Module addsub](https://hdlbits.01xz.net/wiki/Module_addsub)

![](assets/aa913d92-5763-4b97-97be-5eb3e5bbc4e8.png)

异或也可以这么写：

![](assets/bc769cd3-21dc-4111-b657-b25c68d13f5b.png)


```verilog
module top_module(
    input [31:0] a,
    input [31:0] b,
    input sub,
    output [31:0] sum
);
    wire x;
    //wire [31:0] sub_b_out; 
    //assign sub_b_out[31:0] = {32{sub}} ^ b[31:0];
    
    reg [31:0] sub_b_out;
	always @(*) begin
    	case (sub)
        	1'b0: sub_b_out = b;
        	1'b1: sub_b_out = ~b;
    	endcase
	end
    
    add16 inst1(a[15:0], sub_b_out[15:0], sub, sum[15:0], x);
    add16 inst2(a[31:16], sub_b_out[31:16], x, sum[31:16]);
    
endmodule

```

>[!question] 
>1.异或门的写法，可以是用'^'，也可以是用一个数据选择器。
>2.`sub` 是 1 位，`b` 是 32 位。Verilog 在做 `sub ^ b[31:0]` 时会把 `sub` **零扩展**成 32 位（变成 `{31'b0, sub}`），结果只有最低位被取反，高 31 位原样通过。所以减法时只翻转了 b[0]，完全不对。


