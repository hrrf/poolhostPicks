import sys, getopt, requests, io

POOLHOST_LOGIN_URI = 'https://poolhost.com/login'
POOLHOST_HAM_SELECT = 'https://poolhost.com/home/poolselect/41149/0'
POOLHOST_ALLPICKS_URI = 'https://poolhost.com/profootball/exportallpicks/5'

def get_args(argv):
    usage = 'poolhost.py -u username -p password'
    username, password = '', ''

    try:
        opts, args = getopt.getopt(argv, "hu:p:", ['username=','password='])
    except getopt.GetoptError:
        print(usage)
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print(usage)
            sys.exit(1)
        elif opt in ('-u', '--username'):
            username = arg
        elif opt in ('-p', '--password'):
            password = arg

    if not username:
        print("Error:  no username specified.")
        print(usage)
        sys.exit(2)
    if not password:
        print("Error:  no password specified.")
        print(usage)
        sys.exit(2)

    return username, password

def login(username, password):
    request_data = {
        'UserName':username,
        'Password':password,
        'RememberMe':'false',
        'ph-pool-id': 41149
    }

    s = requests.Session()
    s.post(POOLHOST_LOGIN_URI, data=request_data)

    # Some weird cookie or header exchange has to happen when accessing
    # this intermediate page
    s.get(POOLHOST_HAM_SELECT)

    response = s.get(POOLHOST_ALLPICKS_URI, stream=True)

    with open('output.xls', 'wb') as f:
        f.write(response.content)

if __name__ == '__main__':
    username, password = get_args(sys.argv[1:])
    login(username, password)

