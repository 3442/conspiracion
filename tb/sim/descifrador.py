FILE = 'image_processing/out_file'
SIZE = 640 * 480 * 4
START = 0x10000

loads = {START: FILE}
consts = {0x30050000: 1, 0x30060000: 0}
cycles = 10000000
mem_dumps = [range(START, START + SIZE)]

def final():
    words = []
    with open(FILE, 'rb') as file:
        while data := file.read(4):
            words.append(int.from_bytes(data, 'little') ^ 0x00ffffff)

    assert_mem(START, words)
