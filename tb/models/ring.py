def _shift_out(val, n):
    rhs = val & ((1 << n) - 1)
    lhs = val >> n
    return (lhs, rhs)

def _shift_in(val, n, req=0):
    return req << n | (val & ((1 << n) - 1))

def _out(*, ttl, read, inval, reply, tag, index, data):
    req = _shift_in(read, 1, ttl)
    req = _shift_in(inval, 1, req)
    req = _shift_in(reply, 1, req)
    req = _shift_in(tag, 13, req)
    req = _shift_in(index, 12, req)
    req = _shift_in(data, 128, req)
    return req.to_bytes(20, 'big')

class RingSegmentModel:
    def __init__(self):
        self.queue = []

    def recv(self, req):
        req = int.from_bytes(req, 'big')
        req, data = _shift_out(req, 128)
        req, index = _shift_out(req, 12)
        req, tag = _shift_out(req, 13)
        req, reply = _shift_out(req, 1)
        req, inval = _shift_out(req, 1)
        ttl, read = _shift_out(req, 1)

        if ttl > 0:
            req = _out(ttl=(ttl - 1), read=read, inval=inval, reply=reply,
                       tag=tag, index=index, data=data)

            # Recvs de bus tienen prioridad
            self.queue.insert(0, req)

    def send(self, *, ty, tag, index, data):
        read = 0
        inval = 0

        match ty:
            case 'read':
                read = 1
            case 'inval':
                inval = 1
            case 'read-inval':
                read = inval = 1

        #FIXME: Bug en VPI
        data = 0

        req = _out(ttl=3, read=read, inval=inval, reply=0, tag=tag, index=index, data=data)
        self.queue.append(req)
