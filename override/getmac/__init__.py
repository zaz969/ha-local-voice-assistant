# Shims getmac to return a stable MAC no matter what is requested

def get_mac_address(*args, **kwargs):
    return "02:00:00:12:34:56"