
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

**异或非：**
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



举例：

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










