function making_print_string(thingy)
{
    if (typeof thingy == 'number')
    {
        return '\u001b[33m' + thingy.toString() + '\u001b[0m';
    }
    else if (typeof thingy == 'string')  
    {
        return '\u001b[32m' + thingy + '\u001b[0m';
    }
    else if (typeof thingy == 'symbol')
    {
        return '\u001b[36m' + thingy.toString().slice(7, thingy.toString().length - 1) + '\u001b[0m';
    }
    else if (Array.isArray(thingy))
    {
        return '[ ' + thingy.map(making_print_string).join(', ') + ' ]';
    }
    else if (typeof thingy == 'object')
    {
        return '{ ' + Object.entries(thingy).map(making_print_string).join(', ') + ' }' ;
    }
}

function foo(par)
{
    console.log(par);
}
console.log(making_print_string([[[[[[[[22, 33]]]]]]]]))







if (control[0] == lambding)                                                                    //We got a lambding symbol as a current element, which means, we need to take a variable name and value from stack and put them inside global dictionary
{
    control.shift();                                                                                //Getting rid of lambding symbol from control
    var clos_exp_val = stack[0];                                                                    //If control: [Lambda_applying] stack: [[10, 5], ['LAMBDA', [x, y], ['+', 'x', 'y']]] - clos_exp_val = [10, 5]
    var clos_expr_vars = stack[1].expression[1].slice();                                            //If control: [Lambda_applying] stack: [[10, 5], ['LAMBDA', [x, y], ['+', 'x', 'y']]] - clos_expr_vars = ['y', 'x']
    var clos_expr_eval = stack[1].expression[2].slice();                                            //If control: [Lambda_applying] stack: [[10, 5], ['LAMBDA', [x, y], ['+', 'x', 'y']]] - clos_expr_eval = ['+', 'x', 'y']
    local_d.unshift(stack[1].dictionary);                                                           //Unshifting dictionary to local_d stack from closure dictionary
    stack.shift();                                                                                  //Getting rid of variable values list and closure from stack
    stack.shift();
    if (control[0] == local_mark)                                                                   //Check if local_mark symbol is next after lambding symbol. If it is - we can't add local_mark symbol, to make tail recursion being possible
    {
        local_d.shift();                                                                            //We also need to delete highest dictionary, because, we need to create additional ones in case of tail recursion
    }
    else                                                                                            //No local mark, so, it's not tail recursion, which means, we need to add local_mark symbol
    {
        control.unshift(local_mark);
    }
    control.unshift(clos_expr_eval);                                                                //Putting eval part of the lambda to control to be evalled
    control.unshift(lvar_list_define);                                                              //Putting lvar_list_define to assign lists of var names and values, which will be put inside the stack 
    stack.unshift(clos_expr_vars);                                                                  //Putting variable names list from lambda expression to a highest element of the stack
    stack.unshift(clos_exp_val);                                                                    //Putting variable value list from lambda expression to a highest element of the stack
}