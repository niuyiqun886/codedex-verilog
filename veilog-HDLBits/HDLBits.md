
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

**声明wires**

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
