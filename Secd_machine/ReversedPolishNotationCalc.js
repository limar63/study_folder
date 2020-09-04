const readline = require('readline');
 
function recursion_register()
{
    rl.question("Enter your expression: ", (answer) =>
    {  
        var expression_array = tokenize(answer);
        console.log(expression_array)
        if (typeof expression_array[expression_array.length - 1] == 'number' || expression_array[expression_array.length - 1] == ')')
        {
            var value = calculate(to_polish(expression_array));    
        }
        else
        {
            var value = calculate(expression_array);
        }
        if (value[1] == false)
        {
            console.log('Exception:', value[0])
        }
        else
        {
            console.log('Result is:', value[0])    
        }
        recursion_register();
    })
}
 
 
// [42,5,'+']
 
function tokenize(line)
{
    var word_holder = ''
    var tokens = []
    var separators = ['(', ')', '+', '-', '/', '*', 'neg']
    for (var i = 0; i < line.length; i++)
    {
        if (separators.includes(line[i]))
        {
            if (word_holder == '')
            {
                tokens.push(line[i]);
            }
            else
            {
                tokens.push(parseInt(word_holder));
                word_holder = '';
                tokens.push(line[i]);
            }
        }
        else if (line[i] == ' ')
        {
            if (word_holder != '')
            {
                tokens.push(parseInt(word_holder));
                word_holder = '';
            }
        }
        else
        {
            word_holder += line[i];
        }
    }
    if (word_holder != '')
        {
            tokens.push(parseInt(word_holder));
        } 
    return tokens
}
 
function to_polish(array)
{
    var high_priority = ['/', '*']
    var low_priority = ['+', '-']
    var stack = [];
    var result = [];
    console.log('array is', array)
    for (var i = 0; i < array.length; i++)
    {
        if (typeof array[i] ==  'number')
        {
            console.log('pushing number to result')
            result.push(array[i]);
        }
        else if (/*array[i] == 'neg' || */array[i] == '(')
        {
            console.log('pushing opening parentheses to stack')
            stack.push(array[i]);
        }
        else if (array[i] ==  ')')
        {
            console.log('encountered closing parentheses')
            var top_stack_element;
            do {
                top_stack_element = stack.pop()
                if (top_stack_element != '(')
                {
                    console.log('Adding element inside pars', top_stack_element)
                    result.push(top_stack_element)
                }
            }
            while (top_stack_element != '(')
        }
        else if (low_priority.includes(array[i]))
        {
            console.log('encountered LP function')
            if (low_priority.includes(stack[stack.length - 1]) || high_priority.includes(stack[stack.length - 1]))
            {
                result.push(stack.pop())
                stack.push(array[i])
            }
            else
            {
                stack.push(array[i])    
            }
        }
        else if (high_priority.includes(array[i]))
        {
            console.log('encountered HP')
            if (high_priority.includes(stack[stack.length - 1]))
            {
                result.push(stack.pop())
                stack.push(array[i])
            }
            else
            {
                stack.push(array[i])    
            }
        }
        console.log('step number', i)
        console.log('current result is', result)
        console.log('current stack is', stack)
    }
    console.log('STACK IS ', stack)
    if (stack.length != 0)
    {
        for (var j = 0; j < stack.length; j++)
        {
            result.push(stack[stack.length - j - 1])    
        }
    }
    console.log('Final result is', result)
    return result  
}

function calculate(array)
{
    var stack = [];
    for (var i = 0; i < array.length; i++)
    {
        if (typeof array[i] ==  'number')
        {
            stack.push(array[i]);
        }
        else if (array[i] == '+')
        {
            if (stack.length < 2)
            {
                return ['Missing stack elements for + function ', false]  //semipredicate [value, true/false]
            }
            stack.push(stack.pop() + stack.pop());
        }
        else if (array[i] == '-')
        {
            if (stack.length < 2)
            {
                return ['Missing stack elements for - function ', false]    
            }
            var x = stack.pop()
            var y = stack.pop()
            stack.push(y - x);
        }
        else if (array[i] == '*')
        {
            if (stack.length < 2)
            {
                return ['Missing stack elements for * function ', false]    
            }
            stack.push(stack.pop() * stack.pop());
        }
        else if (array[i] == '/')
        {
            if (stack.length < 2)
            {
                return ['Missing stack elements for / function ', false]    
            }
            else if (stack[stack.length - 1] == 0)
            {
                return ["You can't divide by zero ", false]      
            }
            var x = stack.pop()
            var y = stack.pop()
            stack.push(y / x);
        }
        else if (array[i] == 'neg')
        {
            if (typeof array[i - 1] !=  'number')
            {
                return ['Only a number can be set to be negative', false]    
            }
            else
            {
                stack.push(stack.pop() * -1);
            }
        }
    }
    return [stack[0], true]
}
 
const rl = readline.createInterface({
  input:  process.stdin,
  output: process.stdout
});
 
recursion_register()
 
 
 
//Поработать с unix файлами
 
// EAFP vs LBYL Погуглить
//Алгоритм перевода инфиксной записи в ОПН