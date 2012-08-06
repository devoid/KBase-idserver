try:
    import json
except ImportError:
    import sys
    sys.path.append('simplejson-2.3.3')
    import simplejson as json
    
import urllib



class IDServerAPI:

    def __init__(self, url):
        if url != None:
            self.url = url

    def kbase_ids_to_external_ids(self, ids):

        arg_hash = { 'method': 'IDServerAPI.kbase_ids_to_external_ids',
                     'params': [ids],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        resp_str = urllib.urlopen(self.url, body).read()
        resp = json.loads(resp_str)

        if 'result' in resp:
            return resp['result'][0]
        else:
            return None

    def external_ids_to_kbase_ids(self, external_db, ext_ids):

        arg_hash = { 'method': 'IDServerAPI.external_ids_to_kbase_ids',
                     'params': [external_db, ext_ids],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        resp_str = urllib.urlopen(self.url, body).read()
        resp = json.loads(resp_str)

        if 'result' in resp:
            return resp['result'][0]
        else:
            return None

    def register_ids(self, prefix, db_name, ids):

        arg_hash = { 'method': 'IDServerAPI.register_ids',
                     'params': [prefix, db_name, ids],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        resp_str = urllib.urlopen(self.url, body).read()
        resp = json.loads(resp_str)

        if 'result' in resp:
            return resp['result'][0]
        else:
            return None

    def allocate_id_range(self, kbase_id_prefix, count):

        arg_hash = { 'method': 'IDServerAPI.allocate_id_range',
                     'params': [kbase_id_prefix, count],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        resp_str = urllib.urlopen(self.url, body).read()
        resp = json.loads(resp_str)

        if 'result' in resp:
            return resp['result'][0]
        else:
            return None

    def register_allocated_ids(self, prefix, db_name, assignments):

        arg_hash = { 'method': 'IDServerAPI.register_allocated_ids',
                     'params': [prefix, db_name, assignments],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        resp_str = urllib.urlopen(self.url, body).read()
        resp = json.loads(resp_str)

        if 'result' in resp:
            return resp['result']
        else:
            return None

    def kbase_ids_with_prefix(self, prefix):

        arg_hash = { 'method': 'IDServerAPI.kbase_ids_with_prefix',
                     'params': [prefix],
                     'version': '1.1'
                     }

        body = json.dumps(arg_hash)
        resp_str = urllib.urlopen(self.url, body).read()
        resp = json.loads(resp_str)

        if 'result' in resp:
            return resp['result'][0]
        else:
            return None




        
