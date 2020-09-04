def compare(f):
    return lambda x, y: f(x, y)

more_than = compare(lambda x, y: x > y)

print(more_than(5, 6))