import sys
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError
req = Request(sys.argv[1])
try:
	response = urlopen(req)
except HTTPError as e:
	sys.exit(10)
except URLError as e:
	sys.exit(10)
else:
    sys.exit(0)
