def int_to_hex_string(value, bits):
    return "{0:0{1}X}".format(value & ((1<<bits) - 1), bits//4)

f = open('weights.csv')
z_ = []
for x in f.readlines():
    y = x.strip().split(',')
    #print int_to_hex_string(int(y[0]), 8)
    y = [int_to_hex_string(int(z), 8) for z in y]
    print ''.join(y)
