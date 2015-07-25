(function () {
	function loadScript(url, callback) {
		var script = document.createElement("script");
		script.type = "text/javascript";
		if (script.readyState) { //IE
			script.onreadystatechange = function () {
				if (script.readyState == "loaded" || script.readyState == "complete") {
					script.onreadystatechange = null;
					callback();
				}
			};
		} else { //Others
			script.onload = function () {
				callback();
			};
		}
		script.src = url;
		document.getElementsByTagName("head")[0].appendChild(script);
	}
	loadScript("//code.jquery.com/jquery-1.11.0.min.js", function() {
		loadScript("/vendor/jquery-ui-1.10.4.custom.min.js", function() {
			loadScript("/vendor/medium-editor.min.js", function() {
				loadScript("/js/cms.js", function() {});
			});
		});
	});
})();