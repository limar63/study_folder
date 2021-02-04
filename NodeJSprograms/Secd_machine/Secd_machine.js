//Using this global variable because too lazy to implement proper paramater inside printing function
var result = ''; 

function making_print_string(thingy) {
    //console.log('printing', thingy);
    //console.log('printing', typeof thingy);
    if (typeof thingy == 'number') {
        return '\u001b[33m' + thingy.toString() + '\u001b[0m';
    }
    else if (typeof thingy == 'string') {
        return '\u001b[32m' + thingy + '\u001b[0m';
    }
    else if (typeof thingy == 'symbol') {
        return '\u001b[36m' + thingy.toString().slice(7, thingy.toString().length - 1) + '\u001b[0m';
    }
    else if (Array.isArray(thingy)) {
        return '[ ' + thingy.map(making_print_string).join(', ') + ' ]';
    }
    else if (thingy instanceof Closures) {
        return making_print_string([thingy.expression, thingy.dictionary, thingy.blockdict, thingy.godict])
    }
    else if (typeof thingy == 'object') {
        return '\u001b[35m{ \u001b[0m' + Object.entries(thingy).map(dictarray => { return ' ' + making_print_string(dictarray[0]) + ' : ' + making_print_string(dictarray[1]) }) + '\u001b[35m }\u001b[0m' ;
    }
}

function making_print_lisp(thingy)
{
    //console.log('lisping', thingy);
    //console.log('lisping', typeof thingy);
    if (typeof thingy == 'number') {
        return '\u001b[33m' + thingy.toString() + '\u001b[0m';
    }
    else if (typeof thingy == 'string') {
        return '\u001b[32m' + thingy + '\u001b[0m';
    }
    else if (typeof thingy == 'symbol') {
        return '\u001b[36m' + thingy.toString().slice(7, thingy.toString().length - 1) + '\u001b[0m';
    }
    else if (Array.isArray(thingy)) {
        return '(' + thingy.map(making_print_lisp).join(' ') + ')';
    }
    else if (thingy instanceof Closures) {
        return making_print_lisp([thingy.expression, thingy.dictionary, thingy.blockdict, thingy.godict])
    }                                                                                                       //not sure if it's needed, machine_considering, there is no dictionaries in lisp
    /*else if (typeof thingy == 'object')
    {
        return '\u001b[35m{ \u001b[0m' + Object.entries(thingy).map(dictarray => { return making_print_lisp(dictarray[0]) + ' : ' + making_print_lisp(dictarray[1]) }) + '\u001b[35m }\u001b[0m' ;
    }*/
}

//Global dictionary
var global_d = {};


//Creating a Closures class for lambda to use. Closure contains expression field and the state of the local dictionary upon creating the lambda
class Closures 
{
    constructor(expression, dictionary, blockdict, godict) {                                                                    //constructor, obviously, taking two parameters
        this.expression = expression;                                                                       //will contatin the lambda expression
        this.dictionary = dictionary;                                                                       //will contain latest local dictionary copy
        this.blockdict = blockdict;
        this.godict = godict;
    }
}
//var count = 0;
//Function, where all main action going. It looks like cycle, but it's an implicit recursion
function main_cycle(expression)
{
    let apply_list = Symbol('APPLY-LIST');                                                                  //Symbol which applies a procedure to a 3+ arguments, throwing them all in the list
    let machine_cons = Symbol('MACHINE-CONS');                                                              //Symbol which adds an element to a list
    let select = Symbol('SELECT');                                                                          //Symbol from IF procedure, which will make a decision between if/else, depedning on true/false result
    let local_mark = Symbol('LOCAL-END');                                                                   //Symbol, which means, that local scope got to it's end and local dictionary should be thrown away from a local dictionary stack
    let lvar_define = Symbol('LVAR-DEF');                                                                   //Symbol, which starts the proccess of putting a variable with it's value to a local dictionary 
    let lvar_list_define = Symbol('LVAR-LIST-DEF');                                                         //Symbol, which starts the proccess of putting a list of variables with their values to a local dictionary
    let gvar_def = Symbol('GVAR-DEF');                                                                      //Symbol, which starts the proccess of putting a variable/function variable with it's value to a global dictionary
    let catch_def = Symbol('CATCH-DEF');
    let catch_end = Symbol('CATCH-END');
    let lambda_end = Symbol('LAMBDA-END');                                                               //Symbol, which starts the proccess of applying the lambda
    let pop = Symbol('POP');
    let let_ast_body = Symbol('LET*-BODY');
    let throwing = Symbol('THROWING');  
    let block_def = Symbol('BLOCK-DEF'); 
    let block_end = Symbol('BLOCK-END');
    let tagbody_end = Symbol('TAGBODY-END');
    let returning = Symbol('RETURNING');
    let local_d = [];                                                                                     //Stack that will contain all local dictionaries as elements
    let catch_env = [];  
    let block_env = [];
    let go_env = [];
    let control = [expression];                                                                             //Putting parsed expression inside the control list
    let stack = [];                                                                                         //Stack for holding elements temporaly
    making_print_string(expression);                                                                        //Making expression into readable format
    //console.log('Starting expression is', result);                                                          //Displaying that expression
    result = '';                                                                                            //Clearing result global variable                                                                                        //Count for infinite loop prevention on debugging 
    //let count = 0
    while (control.length > 0) {                                                                            //We are going through a cycle until control stack is not empty. We are evalling first element inside the control stack and after that pushing it away from control
        //console.log('going')
        let operations = ['+', '-', '*', '/', '<', '>', '<=', '>=', '='];                                   //List of operations to distinguish them from variables
        if ((typeof control[0] == 'number') || (operations.includes(control[0]))) {                         //Checking if current element is a number or from operation list, which means, they are self-evalling and should be put inside the stack as they are
            //console.log('found number');
            stack = [control[0]].concat(stack);
            control = control.slice(1);                                                                     //Puting element inside the stack, while, simultaneously, getting rid of it from control stack
        }
        else if (typeof control[0] == 'string') {                                                           //Checking if current element is a string object
            //console.log('found string');
            if ((local_d.length > 0) && (control[0] in local_d[0])) {                                       //Checking if latest local dictionary isn't empty and contains current element as a variable name
                stack = [local_d[0][control[0]]].concat(stack);
                control = control.slice(1);                                                                 //Putting variable value inside the stack, while, simultaniously, getting rid of variable name from control stack
            }
            else if (control[0] in global_d) {                                                              //Checking if global dictionary has current element as variable name, since, we didn't find it in local dictionary or in a list of procedure
                stack = [global_d[control[0]]].concat(stack);
                control = control.slice(1);                                                                 //Putting variable value inside the stack, while, simultaniously, getting rid of variable name from control stack
            }
            else {                                                                                          //We didn't find a variable with that name anywhere 
                stack = [control[0]].concat(stack);
                control = control.slice(1);
            }
        }
        else if (Array.isArray(control[0])) {                                                               //Checking if the current element in the stack is array 
            //console.log('found array');
            if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'LIST')) {            //Checking if inside that element there is a LIST keyword. It's edited to UpperCase to avoid issues with the way keyword is written.
                //console.log('found list');
                if (control[0].length >= 2) {                                                               //Check if it has 2 or more elements (not a single LIST keyword inside array)
                    let object_to_remove = control[0][1];                                                   //We are moving first element after LIST keyword to a first element of the control stack to be evalled, while, keeping 'LIST' and rest of it's elements inside that array. Also, machine_cons Symbol is added to merge evalled arguments of the list with the list itself inside stack
                    let temp_list = [['LIST'].concat(control[0].slice(2)), machine_cons];
                    control = [object_to_remove].concat(temp_list, control.slice(1));                       //For example, control: [['LIST', 5, 10, 15, 20]] -> control: [5, ['LIST', 10, 15, 20], machine_cons]
                }
                else {                                                                                      //LIST keyword is a single element inside array, which means, all elements of the list were put out of the list construction and were evalled. 
                    control = control.slice(1);                                                             //We are getting rid of LIST keyword in control and putting empty list inside stack, so, all the evalled elements would merge with that empty list by evalling machine_cons symbols
                    stack = [[]].concat(stack);  
                }        
            }
            else if  ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'BEGIN')) {
                //console.log('found begin');
                if (control[0].length > 2) {
                    let object_to_remove = control[0][1];                                                   
                    let temp_list = [['BEGIN'].concat(control[0].slice(2))];
                    control = [object_to_remove, pop].concat(temp_list, control.slice(1));
                }
                else if (control[0].length == 2) {
                    control[0] = control[0][1].slice();
                }
            }
            else if  ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'TAG_BEGIN')) {
                //console.log('found tagbegin');
                if (control[0].length > 1) {
                    let object_to_remove = control[0][1];                                                   
                    let temp_list = [['TAG_BEGIN'].concat(control[0].slice(2))];
                    if (typeof object_to_remove != 'string') {
                        control = [object_to_remove, pop].concat(temp_list, control.slice(1));
                    }
                    else {
                        control = temp_list.concat(control.slice(1));
                    }   
                }
                else if (control[0].length == 1) {
                    control = control.slice(1);
                    stack = ['nil'].concat(stack);
                }
            }
            else if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'CATCH')) {
                //console.log('found catch');
                control = [control[0][1], catch_def, ['BEGIN'].concat(control[0].slice(2))].concat(catch_end).concat(control.slice(1))
                let copy = {};                                                                          
                Object.assign(copy, catch_env[0]);
                catch_env = [copy].concat(catch_env);
            } 
            else if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'THROW')) {
                //console.log('found throw');
                control = [['BEGIN'].concat(control[0].slice(2)), control[0][1], throwing].concat(control.slice(1));
            }
            else if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'TAGBODY')) {
                //console.log('found tagbody');
                control = [['TAG_BEGIN'].concat(control[0].slice(1))].concat(tagbody_end).concat(control.slice(1));
                let copy = {};                                                                          
                Object.assign(copy, go_env[0]);
                go_env = [copy].concat(go_env);
                for (i = 1; i < control[0].length; i++) { 
                    if (typeof control[0][i] == 'string') {
                        if (typeof control[0][i + 1] == 'string') {
                            console.log('Exception: Can\'t have to labels in a row');
                            break;
                        }
                        else {
                            go_env[0][control[0][i]] = control[0].slice(i + 1);
                            i++;
                        }
                    }
                }
            } 
            else if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'GO')) {
                //console.log('found go');
                control = [['TAG_BEGIN'].concat(go_env[0][control[0][1]])].concat(control.slice(3));
            }
            else if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'BLOCK')) {
                //console.log('found block');
                stack = [control[0][1]].concat(stack);
                control = [block_def, ['BEGIN'].concat(control[0].slice(2))].concat(block_end).concat(control.slice(1));
                let copy = {};                                                                          
                Object.assign(copy, block_env[0]);
                block_env = [copy].concat(block_env);
            } 
            else if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'RETURN-FROM')) {
                //console.log('found return-from');
                stack = [control[0][1]].concat(stack);
                control = [['BEGIN'].concat(control[0].slice(2)), returning].concat(control.slice(1));
            }
            /*else if (control[0][0] in global_d)                                                           //We found that the element inside the current aray is a key in a global dictionary = we found a function call
            {
                var name = control[0][0];                                                                   //We are putting expression from closure and making it look like with previously defined function (define (foo x y) (+ x y)) control: [foo, 5, 10] => control: [['LAMBDA', ['x', 'y'], ['+', 'x', 'y']], ['LIST', 5, 10], Lambda_applying]
                var clos_exp = global_d[name].expression.slice();
                control = [clos_exp, ['LIST'].concat(control[0].slice(1)), lambding].concat(control.slice(1));  //Should've put lambding inside closure, but too lazy to fix it, since, not much will change
                
            }*/        
            else if ((typeof control[0][0][0] == 'string') && (control[0][0][0].toUpperCase() == 'LAMBDA')) { //We found that the element inside the current array is an array, and inside that array first element is Lambda keyword I's edited to UpperCase to avoid issues with the way keyword is written.
                //console.log('found labmda');    
                control = [control[0][0], ['LIST'].concat(control[0].slice(1))].concat(apply_list, control.slice(1));  //Example control: [[['LAMBDA', ['x', 'y'], ['+', 'x', 'y']] 5 10]] => [['LAMBDA', ['x', 'y'], ['+', 'x', 'y']], ['LIST', 5, 10], Lambda_applying]
            }
            else if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'LET*')) {
                //console.log('found let*');
                let copy = {};                                                                              //Making a shallow copy of the current highest local dictionary and putting it's copy on top of the local_d stack, to inherit variables from a higher local scope, if there are any variables
                Object.assign(copy, local_d[0]);
                local_d = [copy].concat(local_d);
                stack = [control[0][1]].concat(stack);
                control = [let_ast_body, control[0][2], local_mark].concat(control.slice(1));
                
            }                
            else if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'LET')) {        //We found out that inside the current array there is a 'LET' keyword, which means, it's a local scope with variable evalled parallel from each other
                //console.log('found let');
                if (control[0].length != 3) {
                    console.log('Exception: Wrong Let format');
                    break;
                }
                let temp = control[0][1];                                                                   //Making variables to contain all variable names and their values 'control[0][1]' is a [[var1, value1], [var2, value2] ...]
                let temp_var_list = [];                                                                     //List with variable names 
                let temp_value_list = [];                                                                   //List with variable values
                for (let i = 0; i < temp.length; i += 1)                                                    //Filling these two lists from the top with elements
                {
                    temp_var_list = temp_var_list.concat(temp[i][0]);
                    temp_value_list = temp_value_list.concat(temp[i][1]);
                }
                //Example control: [['LET', [['x', 10], ['y', 20]], ['+', 'x', 'y']]] => control: [['LIST', 10, 20], LVAR_LIST_DEF, ['+', 'x', 'y'], LOCAL_END]
                control = [['LIST'].concat(temp_value_list)].concat([lvar_list_define, control[0][2], local_mark]).concat(control.slice(1));
                stack = [temp_var_list].concat(stack);                                                      //We need to reverse the list of variables because of the nature of the stack shenanigans
                let copy = {};                                                                              //Making a shallow copy of the current highest local dictionary and putting it's copy on top of the local_d stack, to inherit variables from a higher local scope, if there are any variables
                Object.assign(copy, local_d[0]);
                local_d = [copy].concat(local_d);
            }
                                                                                                            //We found out that inside the current array there is a 'LAMBDA' keyword, which means, we need to create a closure and put it on a stack
            else if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'LAMBDA')) {     //((lambda (x y) (+ x y)) 10 20) (lambda, (x, y, z)(+, x, y, z))
                //console.log('found lambda');
                if (control[0].length != 3) {
                    console.log('Exception: Wrong lambda format');
                    break;
                }
                let dict_copy = {};                                                                         //When creating a closure, we need to make a copy of the current state of the local dictionary to avoid dynamic scope
                Object.assign(dict_copy, local_d[0]);
                let block_copy = {};
                Object.assign(block_copy, block_env[0]);
                let go_copy = {};
                Object.assign(go_copy, go_env[0]);
                var closure = new Closures(control[0], dict_copy, block_copy, go_copy);                     //Creating a closure object by using current control[0] element and the copy of the latest local dictionary. By creating it, we are deleting control[0] from control because of .shift()
                control = control.slice(1);
                stack = [closure].concat(stack);
            }
            else if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'DEFINE')) {     //We found out that inside the current array there is a 'Define' keyword, which means, we are defining a global variable/function
                //console.log('found define');
                if (typeof control[0][1] == 'string') {                                                     //Second element inside the array is string, which means, it's a variable assignment
                    stack = [control[0][1]].concat(stack);                                                  //Example control: [['DEFINE', 'x', 5]] stack: [] => control: [5, GVAR_DEF] stack: ['x']
                    control = [control[0][2], gvar_def].concat(control.slice(1));
                }
                else {                                                                                      //Second element inside the array is an array, which means, it's a function assignment
                    stack = [control[0][1][0]].concat(stack);                                               //Example control: [['DEFINE', ['Zdarova', 'a', 'b'], ['+', 'a' 'b']]] stack: []=> control: [['LAMBDA', ['a', 'b'], ['+', 'a', 'b']], GVAR_DEF] stack: ['Zdarova']
                    control = [['LAMBDA', control[0][1].slice(1), control[0][2]]].concat(gvar_def, control.slice(1));
                }
            }
            /*    else                                                                                      //We didn't find any keywords inside the list with length of 3 elements, so, we assume there is a procedure inside and we need to apply it to other 2 arguments inside
                {
                    let temp_list = control.shift().concat(apply2);                                         //Example control: [['+', 2, 2]] => control: ['+', 2, 2, APPLY2]
                    control = temp_list.concat(control); 
                }
            }*/                                                           
            else if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'QUOTE')) {      //We found out that inside the current array there is a 'QUOTE' keyword, which means, we need to a list out of element without evalling it's content
                //console.log('found quote');
                if (control[0].length != 2) {
                    console.log('Exception: Wrong quote format');
                    break;
                }
                stack = [control[0][1]].concat(stack);                                                      //Example control: [['QUOTE', ['+', 2, 2]]] stack: [] => control: [] stack: [['+', 2, 2]]
                control = control.slice(1);
            }
            else if ((typeof control[0][0] == 'string') && (control[0][0].toUpperCase() == 'IF')) {         //We found out that inside the current array there is a 'IF' keyword
                //console.log('found if');
                let x = control[0].slice(1, 2).concat(select).concat(control[0].slice(2));                  //Example: control: [['IF', ['<', 2, 1], 10, 5]] => control: [['<', 2, 1], 'SELECT', 10, 5]
                control = x.concat(control.slice(1));
            }
            else                                                                                            //Nothing on top has worked so, we assume, it's a list of 3 or more elements with procedure on the firt postition, which should be applied to all other arguments. We need to form a list of these arguments
            {                                                                                               //Example control: [['+', 0, 1, 2, 3, 4, 5]] => control: ['+', ['LIST', 0, 1, 2, 3, 4, 5], APPLY-LIST]
                //console.log('apply-listing');
                control = [control[0][0], ['LIST'].concat(control[0].slice(1)), apply_list].concat(control.slice(1));
            }
        
        }
        else if (control[0] == select) {                                                                     //We got a select symbol as a current element, which is a part of 'IF' procedure
            //console.log('found select');
            let check = stack[0];                                                                           //Getting latest element from stack, which supposed to be either '#t' or '#f'
            stack = stack.slice(1);
            if (check == '#t') {                                                                             //Checking if we should use true part or else part of the IF
                control = [control[1]].concat(control.slice(3));                                            //Example control: ['SELECT', 10, 5] stack: ['#t] => control: [10] stack: []
            }
            else { 
                control = [control[2]].concat(control.slice(3));                                            //Example control: ['SELECT', 10, 5] stack: ['#f] => control: [5] stack: []
            }
        }
        else if (control[0] == apply_list) {                                                                 //We got a apply_list symbol as a current element, which means, we need to apply a procedure to the list of arguments
            //console.log('found apply-list');
            if (stack[1] instanceof Closures) {                                                                   //We got a lambding symbol as a current element, which means, we need to take a variable name and value from stack and put them inside global dictionary
                control = control.slice(1);                                                                                //Getting rid of lambding symbol from control
                let clos_exp_val = stack[0];                                                                    //If control: [Lambda_applying] stack: [[10, 5], ['LAMBDA', [x, y], ['+', 'x', 'y']]] - clos_exp_val = [10, 5]
                let clos_expr_vars = stack[1].expression[1].slice();                                            //If control: [Lambda_applying] stack: [[10, 5], ['LAMBDA', [x, y], ['+', 'x', 'y']]] - clos_expr_vars = ['y', 'x']
                let clos_expr_eval = stack[1].expression[2].slice();                                            //If control: [Lambda_applying] stack: [[10, 5], ['LAMBDA', [x, y], ['+', 'x', 'y']]] - clos_expr_eval = ['+', 'x', 'y']
                local_d = [stack[1].dictionary].concat(local_d);                                                //Putting dictionary to local_d stack from closure dictionary                                                         
                block_env = [stack[1].blockdict].concat(block_env);
                go_env = [stack[1].godict].concat(go_env);
                stack = stack.slice(1);                                                                                  //Getting rid of variable values list and closure from stack
                stack = stack.slice(1);
                if (control[0] == local_mark) {                                                                  //Check if local_mark symbol is next after lambding symbol. If it is - we can't add local_mark symbol, to make tail recursion being possible
                    local_d = local_d.slice(1);                                                                            //We also need to delete highest dictionary, because, we need to create additional ones in case of tail recursion
                }
                else {                                                                                           //No local mark, so, it's not tail recursion, which means, we need to add local_mark symbol
                    control = [lambda_end].concat(control);
                }
                control = [clos_expr_eval].concat(control);                                                                //Putting eval part of the lambda to control to be evalled
                control = [lvar_list_define].concat(control);                                                             //Putting lvar_list_define to assign lists of var names and values, which will be put inside the stack 
                stack = [clos_expr_vars].concat(stack);                                                                  //Putting variable names list from lambda expression to a highest element of the stack
                stack = [clos_exp_val].concat(stack);                                                                    //Putting variable value list from lambda expression to a highest element of the stack
            }
            else {
                let procedure = stack[1];                                                                       //Variable for a procedure
                let arguments = stack[0];                                                                       //Variable for a list of values
                if (procedure == '+') {                                                                          //Checking, if procedure is a '+'
                                                                                                                //Applying a reduce method to get a summ of all elements inside the array
                    arguments = arguments.reduce((accumulator, currentElement) => accumulator + currentElement);//reduce is a lambda function, that works for all elements of the list, accumulator usually 
                                                                                                                //the first element and current element is going through second, third etc elements and applying it like lambda says
                }
                else if (procedure == '-')                                                                      //Checking, if procedure is a '-'
                {                                                                                                //Applying a reduce method to substract a list of all elements except the first one from the first element. We need to reverse the array back, because, making an array via a stack method reversed it.
                    if (arguments.length == 1){
                        arguments = -1 * arguments[0];
                    }
                    else{
                        arguments = arguments.reduce((accumulator, currentElement) => accumulator - currentElement); //We need to reverse here, because we need accumulator to be a first element, and in stack order is inverted
                    }
                }
                else if (procedure == '*') {                                                                     //Checking, if procedure is a '*'
                    arguments = arguments.reduce((accumulator, currentElement) => accumulator * currentElement);//Applying a reduce method to multiply all elements inside the array
                }
                else if (procedure == '/') {                                                                     //Checking, if procedure is a '/'
                    if (arguments.slice(0, -1).includes(0)) {                                                    //Check to avoid dividing by zero
                        console.log('EXCEPTION: You can\'t divide with zero');                                  //Exception text
                        break;                                                                                  //Breaking the main cycle
                    }
                    else                                                                                        //Not trying to divide by 0
                    {                                                                                           //Applying a reduce method to divide first element from the list to all other elements from the list
                        arguments = arguments.reduce((accumulator, currentElement) => accumulator / currentElement);
                    }
                }    
                else if (procedure == '=') {                                                                      //Checking, if procedure is a '='
                    let check = '#t';                                                                           //We assume the result is true, unless, we find a reason to make it false
                    while ((arguments.length > 1) && (check == '#t')) {                                           //We are going through a cycle until we run out of elements, or, getting a false result
                        if (arguments[arguments.length - 1] == arguments[arguments.length - 2]) {                //Checking, if last element is equal to the next after the last (because, list is reversed)
                            arguments[arguments.length - 2] = arguments[arguments.length - 1];                  //It is, so, we swap last and pre-last element with each other to preserve last one
                            arguments = arguments.slice(0, -1);                                                 //Getting rid of pre-last element, which, after previous line of code, being a last element of the list
                        }
                        else {                                                                                   //We found an element, this is not equal to the last one 
                            check = '#f';                                                                       //Changing the check variable to false value
                        }
                    }
                    arguments = [check].slice();                                                                //Putting true or false in place of list of arguments
                }
                else if (procedure == '<') {                                                                     //Checking, if procedure is a '<'
                    let check = '#t';                                                                           //We assume the result is true, unless, we find a reason to make it false
                    while ((arguments.length > 1) && (check == '#t')) {                                          //We are going through a cycle until we run out of elements, or, getting a false result
                        if (arguments[arguments.length - 1] < arguments[arguments.length - 2]) {                 //Checking, if last element is smaller than the next after the last (because, list is reversed)
                            arguments[arguments.length - 2] = arguments[arguments.length - 1];                  //It is, so, we swap last and pre-last element with each other to preserve last one
                            arguments = arguments.slice(0, -1);                                                                    //Getting rid of pre-last element, which, after previous line of code, being a last element of the list
                        }
                        else {                                                                                   //We found an element, this is not bigger than the last one
                            check = '#f';                                                                       //Changing the check variable to false value
                        }
                    }
                    arguments = check;                                                                //Putting true or false in place of list of arguments
                }
                else if (procedure == '>') {                                                                     //Checking, if procedure is a '>'
                    let check = '#t';                                                                           //We assume the result is true, unless, we find a reason to make it false
                    while ((arguments.length > 1) && (check == '#t')) {                                          //We are going through a cycle until we run out of elements, or, getting a false result
                        if (arguments[arguments.length - 1] > arguments[arguments.length - 2]) {                 //Checking, if last element is bigger than the next after the last (because, list is reversed)
                            arguments[arguments.length - 2] = arguments[arguments.length - 1];                  //It is, so, we swap last and pre-last element with each other to preserve last one
                            arguments = arguments.slice(0, -1);                                                                    //Getting rid of pre-last element, which, after previous line of code, being a last element of the list
                        }
                        else {                                                                                   //We found an element, this is not smaller than the last one
                            check = '#f';                                                                       //Changing the check variable to false value
                        }
                    }
                    arguments = check;                                                                       //Putting true or false in place of list of arguments
                }
                else if (procedure == '<=') {                                                                    //Checking, if procedure is a '<='
                    let check = '#t';                                                                           //We assume the result is true, unless, we find a reason to make it false
                    while ((arguments.length > 1) && (check == '#t')) {                                          //We are going through a cycle until we run out of elements, or, getting a false result
                        if (arguments[arguments.length - 1] <= arguments[arguments.length - 2]) {                //Checking, if last element is smaller or equal to the next after the last (because, list is reversed)
                            arguments[arguments.length - 2] = arguments[arguments.length - 1];                  //It is, so, we swap last and pre-last element with each other to preserve last one
                            arguments = arguments.slice(0, -1);                                                                    //Getting rid of pre-last element, which, after previous line of code, being a last element of the list
                        }
                        else {                                                                                   //We found an element, this is not bigger or equal to the last one  
                            check = '#f';                                                                       //Changing the check variable to false value
                        }
                    }
                    arguments = check;                                                                        //Putting true or false in place of list of arguments
    
                }
                else if (procedure == '>=') {                                                                    //Checking, if procedure is a '>='
                    let check = '#t';                                                                           //We assume the result is true, unless, we find a reason to make it false
                    while ((arguments.length > 1) && (check == '#t')) {                                          //We are going through a cycle until we run out of elements, or, getting a false result
                        if (arguments[arguments.length - 1] >= arguments[arguments.length - 2]) {                //Checking, if last element is bigger or equal to the next after the last (because, list is reversed)
                            arguments[arguments.length - 2] = arguments[arguments.length - 1];                  //It is, so, we swap last and pre-last element with each other to preserve last one
                            arguments = arguments.slice(0, -1);                                                                    //Getting rid of pre-last element, which, after previous line of code, being a last element of the list
                        }
                        else {                                                                                   //We found an element, this is not smaller or equal to the last one
                            check = '#f';                                                                       //Changing the check variable to false value
                        }
                    }
                    arguments = check;                                                                        //Putting true or false in place of list of arguments
                }
                else if (procedure == 'car') {
                    //console.log('GOT IT')
                    arguments = arguments[0][0];
                }
                else if (procedure == 'cdr') {
                    arguments = arguments[0].slice(1);
                }
                else if (procedure == 'cons') {
                    arguments = [arguments[0]].concat(arguments[1]);
                }
                stack = stack.slice(1);                                                                                  //Clearing control from APPLY-LIST, getting rid of the highest element of stack and changing the value of new highest element, inside the stack, to an arguments variable
                stack[0] = arguments;
                control = control.slice(1); 
            }    
        }
            
        else if (control[0] == machine_cons) {                                                                       //We got a machine_cons symbol as a current element, which means, we have a list as the highest element inside stack and we need to put next element in stack after that list, inside the list
            //console.log('found machine cons');
            let x = stack[0];                                                                          //Setting y as an argument, x as list, while, simultaneously, getting rid of them from stack
            stack = stack.slice(1);
            let y = stack[0];
            stack = stack.slice(1);
            x = [y].concat(x);
            stack = [x].concat(stack);                                                                               //Putting the argument inside the list and returning list back as a highest element of stack Probably could avoid shifting list from the stack in the first place, but, too lazy to change it
            control = control.slice(1);                                                                                //Getting rid of machine_cons symbol from control stack
        }
        else if (control[0] == local_mark) {                                                                 //We got a local_mark symbol as a current element, which means, we need to push the latest dictionary out of local_d stack
            //console.log('found local_mark');
            local_d = local_d.slice(1);                                                                                //Getting rid of both local_mark from control stack and from highest dictionary from local_d
            control = control.slice(1);
        }
        else if (control[0] == lvar_list_define) {                                                           //We got a lvar_list_define symbol as a current element, which means, we need to take list of variables and list of names from stack, and put them together as variables inside highest local dictionary
            control = control.slice(1);                                                                                //Getting rid of lvar_list_define symbol from control stack
            while (stack[0].length > 0) {                                                                    //Checking, if value dictionary isn't empty. We could check either one of these, no difference, since, they both supposed to have equal amount of elements
                local_d[0][stack[1][0]] = stack[0][0];                                            //Shifting a variable name from a list of variables, using it as key. Also, shifting a variable value from a list of values and using it as a key value.
                stack[1] = stack[1].slice(1);
                stack[0] = stack[0].slice(1);
            }
            stack = stack.slice(2);                                                                         //Getting rid of 2 empty lists from stack through slicing
        }
        else if (control[0] == lvar_define) {                                                                //We got a lvar_define symbol as a current element, which means, we need to take a variable name and value from stack and put them inside highest local dictionary
            //console.log('found lvar_define');
            control = control.slice(1);                                                                                //Getting rid of lvar_define symbol
            let var_value = stack[0];                                                                  //Setting variables var_value as a variable value and var_name as a variable name while, simultaneously, getting rid of them by using shift()
            stack = stack.slice(1);
            let var_name = stack[0];
            stack = stack.slice(1);
            local_d[0][var_name] = var_value;                                                               //Using var_name variable as key and using var_value variable as a value for that key.
        }
        else if (control[0] == let_ast_body)          //We found out that inside the current array there is a 'LET*' keyword, which means, it's a local scope with variable evalled one after another
        {
            //console.log('found let* body');
            if (stack[0].length != 0) {
                stack = [stack[0][0][0]].concat(stack);
                control = [stack[1][0][1], lvar_define, let_ast_body].concat(control.slice(1));
                stack = [stack[0], stack[1].slice(1)].concat(stack.slice(2));
            }
            else {
                control = control.slice(1);
                stack = stack.slice(1);
            }
            // control = control[0][1].concat([control[0][2], local_mark]).concat(control.slice(1));       //Example control: [['LET*', [['x', 10], ['y', 'x']], ['+', 'x', 'y']]] => control: [['x', 10], ['y', 'x'] ['+', 'x', 'y'], LOCAL_END] ps - this expression wouldn't work with let because of "['y', 'x']""
        }
        else if (control[0] == catch_def) {
            //console.log('found catchdef');
            control = control.slice(1);                                                                                
            let var_name = stack[0];
            stack = stack.slice(1);
            let stack_copy = []
            Object.assign(stack_copy, stack)
            let global_copy = []
            Object.assign(global_copy, global_d)
            let local_copy = []
            Object.assign(local_copy, local_d)
            catch_env[0][var_name] = [[].concat(control.slice(1)), stack_copy, local_copy, catch_env.slice(1)];                                                           
        }
        else if (control[0] == catch_end) {
            //console.log('found catch_end');
            control = control.slice(1);
            catch_env = catch_env.slice(1)                                                                                                                                      
        }
        else if (control[0] == lambda_end) {
            //console.log('found lambda_end');
            control = control.slice(1);
            local_d = local_d.slice(1);
            go_env = go_env.slice(1);
            block_env = block_env.slice(1);                                                                                                                                      
        }
        else if (control[0] == throwing) {
            //console.log('found throwing');
            let label = stack[0];
            stack = stack.slice(1);
            let value = stack[0];
            stack = stack.slice(1);
            control = catch_env[0][label][0];
            stack =  [value].concat(catch_env[0][label][1]);
            local_d = catch_env[0][label][2];
            catch_env = catch_env[0][label][3];                                                    
        }
        else if (control[0] == block_def) {
            //console.log('found block_def');
            control = control.slice(1);                                                                                
            let var_name = stack[0];
            stack = stack.slice(1);
            let stack_copy = [];
            Object.assign(stack_copy, stack);
            let global_copy = [];
            Object.assign(global_copy, global_d);
            let local_copy = [];
            Object.assign(local_copy, local_d);
            block_env[0][var_name] = [[].concat(control.slice(1)), stack_copy, local_copy, block_env.slice(1)];                                                           
        }
        else if (control[0] == block_end) {
            //console.log('found block_end');
            control = control.slice(1);
            block_env = block_env.slice(1);                                                                                                                                
        }
        else if (control[0] == tagbody_end) {
            //console.log('found tagbody_end');
            control = control.slice(1); 
            go_env = go_env.slice(1);       
                                                                                                                            
        }
        else if (control[0] == returning) {                                                                   
            //console.log('found returning');
            let value = stack[0];
            stack = stack.slice(1);
            let label = stack[0];
            stack = stack.slice(1);
            control = block_env[0][label][0];
            stack =  [value].concat(block_env[0][label][1]);
            local_d = block_env[0][label][2];
            block_env = block_env[0][label][3];                                                    
        }
        else if (control[0] == gvar_def) {                                                                   //We got a gvar_def symbol as a current element, which means, we need to take a variable name and value from stack and put them inside global dictionary
            //console.log('found gvar_def');
            control = control.slice(1);                                                                                //Getting rid of gvar_def symbol
            let var_value = stack[0];                                                                  //Setting variables var_value as a variable value and var_name as a variable name while, simultaneously, getting rid of them by using shift()
            stack = stack.slice(1);
            let var_name = stack[0];
            stack = stack.slice(1);
            global_d[var_name] = var_value;                                                                 //Using var_name variable as key and using var_value variable as a value for that key.
            stack.unshift('defined variable "' + var_name.toString() + '"');                                //Saying which variable was defined
        }
        
        /*else if (control.length > 20) //exit in case of overflowing control stack
        {
            break;
        }*/
        else if (control[0] == pop){
            //console.log('found pop');
            stack = stack.slice(1);
            control = control.slice(1); 
        }
        /*
        else if (count > 30) {                                                                                   //elif to prevent infinite loop when testing
            break;
        }*/
        else {
            if (control[0] == block_end) {
                console.log('got block')
            }
            else {
                console.log('didn\'t get block', control[0])
            }
            console.log('I got some weird shit');
            console.log('control is', control);
            console.log('stack is', stack);
            console.log('local_d is', local_d);
            console.log('global_d is', global_d);
            console.log('catch_env is', catch_env);
            console.log('block env is', block_env);
            console.log('goenv is', go_env)
            console.log('control is', making_print_lisp(control));
            console.log('stack is', making_print_string(stack));
            console.log('global_d is', making_print_string(global_d));
            console.log('local_d is', making_print_string(local_d));
            console.log('catch_env is', making_print_string(catch_env));
            console.log('block_env is', making_print_string(block_env));
            console.log('go_env is', making_print_string(go_env));
            break;
        }
        console.log('control is', making_print_lisp(control));
        console.log('stack is', making_print_string(stack));
        /*if (stack.length > 1) {
            console.log('TYPE IS', typeof stack[1])
            console.log('element IS', stack[1])
        }*/
        console.log('global_d is', making_print_string(global_d));
        console.log('local_d is', making_print_string(local_d));
        console.log('catch_env is', making_print_string(catch_env));
        console.log('block_env is', making_print_string(block_env));
        console.log('go_env is', making_print_string(go_env));
        //count = count + 1;
    }
    return stack[0];                                                                                        //Returning first element
}

//Shenanigans to read stuff from keyboard in node.js
const readline = require('readline');

//tokenizing an expression, making every single
function tokenize(line) {
    //console.log('tokenizing');
    let word_holder = '';                                                                                   //Used to differ between 1 element formed by many letters and elements formed by 1 letter. After adding word_hodler to the list, it's set to '' value again
    let tokens = [];                                                                                        //resulting list
    for (let i = 0; i < line.length; i++) {                                                                  //Going through the expression line
        if ((line[i] == '(') || (line[i] == ')')) {                                                          //Check if it's a non spacebar separator
            if (word_holder == '') {                                                                          //If none in word_holder we can just add parentheses to the resulting list
                tokens.push(line[i]);
            }
            else {                                                                                           //Else we need to add word holder characters before adding the separator
                tokens.push(word_holder);                                                                   //Adding what word_holder contains
                word_holder = '';                                                                           //Clearing word_holder
                tokens.push(line[i]);                                                                       //Adding parentheses to a token list
            }
        }
        else if (line[i] == ' ') {                                                                           //If we get a spacebar as a current character    
            if (word_holder != '') {                                                                         //If word_holder is not empty we need to add word_holder to the stack, since we got to the separator
                tokens.push(word_holder);                                                                   //Adding what word_holder contains
                word_holder = '';                                                                           //Clearing word_holder
            }
        }
        else                                                                                                //not a separator so we just fill the word_holder
            word_holder += line[i];                                                                         //Adding another character to word_holder list
    }
    if (word_holder != '') {                                                                                 //We check that after getting to the end of the expression line word_holder is empty. If not - it should be added to the resulting list
        tokens.push(word_holder);                                                                           //Adding what word_holder contains
    }
    return tokens                                                                                           //returning resulting list
}
function parse(tokenized_array) {                                                                            //Parsing the list of tokenized elements via stack method. Elements, closed by parentheses, will become nested lists    
    //console.log('parsing');
    let stack = [];                                                                                         //Creating the resulting stack
    for (let i = 0; i < tokenized_array.length; i++) {                                                        //Going through tokenized array that we got from previous function
        if (tokenized_array[i] != ')') {                                                                     //If we get an element that is not closing parentheses
            if (isNaN(parseInt(tokenized_array[i]))) {                                                       //If it's a digit character
                stack.push(tokenized_array[i]);                                                             //We push it to stack, either it's a '(' or other characters, that is not a ')'
            }
            else {
                stack.push(parseInt(tokenized_array[i]));                                                   //We push it to a stack as a digit, not a string, by parsing it to int
                
            }
        }
        else {                                                                                               //We got the ')'
            let placeholder_stack = [];                                                                     //Used to form a nested stack inside a stack, but we need to reverse it, because we make a stack by popping old one, and as a result, reversing elements
            while ((stack.length > 0) && (stack[stack.length - 1] != '(')) {                                 //Until we get to the closest opening '(', which means, that we got properly formed '(something)' construction, or until we run off the elements without getting to '(', which means, expression is wrong.
                placeholder_stack.push(stack.pop());                                                        //Appending top element from stack and putting it in a placeholder
            }
            if (stack.length > 0) {                                                                          //We check to avoid popping the empty list, which will result in crash
                stack.pop();                                                                                //Popping top element to get rid of '('
            }
            else {                                                                                           //Stack is empty and '(' was not found
                console.log("Exception: Missing opening skobochka");                                        //Raising a custom exception
            }
            stack.push(placeholder_stack.reverse());                                                        //Appending a placeholder stack as a nested stack, while reversing it
        }
    }
                                                                                                            //Since in the end, we will get a resulting list inside a list/selfevalling element (because we get a list as an element because parentheses surround it, or self-evalling element which needs to be returned without list), so we need to pull the only element outside the list
    return stack.pop()                                                                                      //Print(stack)
}
//Function for repl
function My_repl() {
    rl.question("Enter your expression: ", (answer) => {                                                     //Getting user input here, making it cyclical through recursion
        let expression_array = parse(tokenize(answer));
        console.log(making_print_lisp(main_cycle(expression_array)));
        My_repl();
    })
}

//More node.js reading input stuff
const rl = readline.createInterface({
    input:  process.stdin,
    output: process.stdout
  });

//Launching repl function
My_repl();
