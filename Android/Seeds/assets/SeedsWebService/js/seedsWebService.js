var path;

var confirmDelete = function(p) {
	path = p;
	$.prompt("ȷ��ɾ�����ļ���", {
		buttons : {
			"ȷ��" : true,
			"ȡ��" : false
		},
		callback : deleteCallback
	});
	return false;
}

function deleteCallback(e, v, m, f) {
	if (v != undefined && v == true) {
		var loc = window.location.pathname + path;
		$.post(loc, {}, function(data) {
			$.prompt(data, {
				buttons : {
					"ȷ��" : true
				},
				callback : deletedCallback
			});
		});
	}
	return false;
}

function deletedCallback(e, v, m, f) {
	window.location.reload();
}
