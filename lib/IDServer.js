

function IDServerAPI(url) {

    var _url = url;


    this.kbase_ids_to_external_ids = function(ids)
    {
	var resp = json_call_ajax_sync("IDServerAPI.kbase_ids_to_external_ids", [ids]);
//	var resp = json_call_sync("IDServerAPI.kbase_ids_to_external_ids", [ids]);
        return resp[0];
    }

    this.kbase_ids_to_external_ids_async = function(ids, _callback, _error_callback)
    {
	json_call_ajax_async("IDServerAPI.kbase_ids_to_external_ids", [ids], 1, _callback, _error_callback)
    }

    this.external_ids_to_kbase_ids = function(external_db, ext_ids)
    {
	var resp = json_call_ajax_sync("IDServerAPI.external_ids_to_kbase_ids", [external_db, ext_ids]);
//	var resp = json_call_sync("IDServerAPI.external_ids_to_kbase_ids", [external_db, ext_ids]);
        return resp[0];
    }

    this.external_ids_to_kbase_ids_async = function(external_db, ext_ids, _callback, _error_callback)
    {
	json_call_ajax_async("IDServerAPI.external_ids_to_kbase_ids", [external_db, ext_ids], 1, _callback, _error_callback)
    }

    this.register_ids = function(prefix, db_name, ids)
    {
	var resp = json_call_ajax_sync("IDServerAPI.register_ids", [prefix, db_name, ids]);
//	var resp = json_call_sync("IDServerAPI.register_ids", [prefix, db_name, ids]);
        return resp[0];
    }

    this.register_ids_async = function(prefix, db_name, ids, _callback, _error_callback)
    {
	json_call_ajax_async("IDServerAPI.register_ids", [prefix, db_name, ids], 1, _callback, _error_callback)
    }

    this.allocate_id_range = function(kbase_id_prefix, count)
    {
	var resp = json_call_ajax_sync("IDServerAPI.allocate_id_range", [kbase_id_prefix, count]);
//	var resp = json_call_sync("IDServerAPI.allocate_id_range", [kbase_id_prefix, count]);
        return resp[0];
    }

    this.allocate_id_range_async = function(kbase_id_prefix, count, _callback, _error_callback)
    {
	json_call_ajax_async("IDServerAPI.allocate_id_range", [kbase_id_prefix, count], 1, _callback, _error_callback)
    }

    this.register_allocated_ids = function(prefix, db_name, assignments)
    {
	var resp = json_call_ajax_sync("IDServerAPI.register_allocated_ids", [prefix, db_name, assignments]);
//	var resp = json_call_sync("IDServerAPI.register_allocated_ids", [prefix, db_name, assignments]);
        return resp;
    }

    this.register_allocated_ids_async = function(prefix, db_name, assignments, _callback, _error_callback)
    {
	json_call_ajax_async("IDServerAPI.register_allocated_ids", [prefix, db_name, assignments], 0, _callback, _error_callback)
    }

    this.kbase_ids_with_prefix = function(prefix)
    {
	var resp = json_call_ajax_sync("IDServerAPI.kbase_ids_with_prefix", [prefix]);
//	var resp = json_call_sync("IDServerAPI.kbase_ids_with_prefix", [prefix]);
        return resp[0];
    }

    this.kbase_ids_with_prefix_async = function(prefix, _callback, _error_callback)
    {
	json_call_ajax_async("IDServerAPI.kbase_ids_with_prefix", [prefix], 1, _callback, _error_callback)
    }

    function _json_call_prepare(url, method, params, async_flag)
    {
	var rpc = { 'params' : params,
		    'method' : method,
		    'version': "1.1",
	};
	
	var body = JSON.stringify(rpc);
	
	var http = new XMLHttpRequest();
	
	http.open("POST", url, async_flag);
	
	//Send the proper header information along with the request
	http.setRequestHeader("Content-type", "application/json");
	//http.setRequestHeader("Content-length", body.length);
	//http.setRequestHeader("Connection", "close");
	return [http, body];
    }

    /*
     * JSON call using jQuery method.
     */

    function json_call_ajax_sync(method, params)
    {
        var rpc = { 'params' : params,
                    'method' : method,
                    'version': "1.1",
        };
        
        var body = JSON.stringify(rpc);
        var resp_txt;
	var code;
        
        var x = jQuery.ajax({       "async": false,
                                    dataType: "text",
                                    url: _url,
                                    success: function (data, status, xhr) { resp_txt = data; code = xhr.status },
				    error: function(xhr, textStatus, errorThrown) { resp_txt = xhr.responseText, code = xhr.status },
                                    data: body,
                                    processData: false,
                                    type: 'POST',
				    });

        var result;

        if (resp_txt)
        {
	    var resp = JSON.parse(resp_txt);
	    
	    if (code >= 500)
	    {
		throw resp.error;
	    }
	    else
	    {
		return resp.result;
	    }
        }
	else
	{
	    return null;
	}
    }

    function json_call_ajax_async(method, params, num_rets, callback, error_callback)
    {
        var rpc = { 'params' : params,
                    'method' : method,
                    'version': "1.1",
        };
        
        var body = JSON.stringify(rpc);
        var resp_txt;
	var code;
        
        var x = jQuery.ajax({       "async": true,
                                    dataType: "text",
                                    url: _url,
                                    success: function (data, status, xhr)
				{
				    resp = JSON.parse(data);
				    var result = resp["result"];
				    if (num_rets == 1)
				    {
					callback(result[0]);
				    }
				    else
				    {
					callback(result);
				    }
				    
				},
				    error: function(xhr, textStatus, errorThrown)
				{
				    if (xhr.responseText)
				    {
					resp = JSON.parse(xhr.responseText);
					if (error_callback)
					{
					    error_callback(resp.error);
					}
					else
					{
					    throw resp.error;
					}
				    }
				},
                                    data: body,
                                    processData: false,
                                    type: 'POST',
				    });

    }

    function json_call_async(method, params, num_rets, callback)
    {
	var tup = _json_call_prepare(_url, method, params, true);
	var http = tup[0];
	var body = tup[1];
	
	http.onreadystatechange = function() {
	    if (http.readyState == 4 && http.status == 200) {
		var resp_txt = http.responseText;
		var resp = JSON.parse(resp_txt);
		var result = resp["result"];
		if (num_rets == 1)
		{
		    callback(result[0]);
		}
		else
		{
		    callback(result);
		}
	    }
	}
	
	http.send(body);
	
    }
    
    function json_call_sync(method, params)
    {
	var tup = _json_call_prepare(url, method, params, false);
	var http = tup[0];
	var body = tup[1];
	
	http.send(body);
	
	var resp_txt = http.responseText;
	
	var resp = JSON.parse(resp_txt);
	var result = resp["result"];
	    
	return result;
    }
}

