display/7i $pc
display /x $rax
display /x $rbx
display /x $rdx
display /x $rbp



info file
#b *add_head
#b *cut_head
b *print_node
run

define print_list
  set $var1 = ((long) list_head)
  set $currentvalue = * $var1
  set $currentlink = * ($var1 + 8)
  set $count = 0
  while $currentlink > 0
    printf "%d[%d|%x] -> ", $count, $currentvalue, $currentlink
    set $var1 = $var1 - 16
    set $currentvalue = * $var1
    set $currentlink = * ($var1 + 8)
    set $count = $count + 1
  end
  printf "[empty|node]\n"
end

define assert_list_value
  set $var1 = ((long) list_head)
  set $var2 = $arg1
  set $currentvalue = * $var1
  set $currentlink = * ($var1 + 8)
  set $check = 1
  while $var2 >= 0
    if $currentvalue != $arg0[$var2]
      set $check = 0
    end
    set $var2 = $var2 - 1
    set $var1 = $var1 - 16
    set $currentvalue = * $var1
    set $currentlink = * ($var1 + 8)
  end
  if $check == 1
    print "Value test passed"
  else
    print "Value test failed"
  end
end

define assert_list_length
  set $var1 = ((long) list_head)
  set $currentlink = * ($var1 + 8)
  set $count = 0
  while $currentlink > 0
    set $var1 = $var1 - 16
    set $currentlink = * ($var1 + 8)
    set $count = $count + 1
  end
  if $count == $arg0
    print "Length test passed"
  else
    print "Length test failed"
end

print "testing"
print_list
print $count
