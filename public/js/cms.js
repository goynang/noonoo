String.prototype.capitalize = function() {
	return this.charAt(0).toUpperCase() + this.slice(1);
};

String.prototype.hashCode = function() {
  var hash = 0, i, chr;
  if (this.length === 0) return hash;
  for (i = 0; i < this.length; i++) {
    chr   = this.charCodeAt(i);
    hash  = ((hash << 5) - hash) + chr;
    hash |= 0; // Convert to 32bit integer
  }
  return hash;
};

var cms = function() {
	
	// Private variables

	var $this = this, currentElement = null, clientID = null, pubSubClient = null;
	
	var saveSave = debounce(function() {
		console.log('Save!');
		savePage(serialisePage());
	}, 1000);
	
	// Private functions
	
	function setupEditors() {
		inlineEditor = new MediumEditor(
			'[data-editor="inline"]',
			{
				disableReturn: true,
				cleanPastedHTML: true,
				buttonLabels: 'fontawesome',
				toolbar: {
					buttons: ['bold', 'italic', 'anchor', 'strikethrough']
				}
			}
		);
		
		blockEditor = new MediumEditor(
			'[data-editor="block"]',
			{
				cleanPastedHTML: true,
				buttonLabels: 'fontawesome',
				toolbar: {
					buttons: ['justifyLeft', 'justifyCenter', 'bold', 'italic', 'anchor', 'strikethrough']
				}
			}
		);
	}
	
	function toggleCMS() {
		$('html').toggleClass('cms');
	}
	
	function revealCMS() {
		$('#cms_ui').delay(500).fadeIn(1000);
	}
	
	function initPubSub() {
		pubSubClient = new Faye.Client('/pubsub');
		var channelName = (location.pathname === '/') ? '/ROOT' : location.pathname;
		var subscription = pubSubClient.subscribe('/changes' + channelName, function(message) {
			var viewport = document.getElementById('viewport');
			var incoming = document.createElement('div');
			incoming.id = 'viewport';
			incoming.innerHTML = message.html;
			if ($this.clientID != message.clientID) {
				morphdom(viewport, incoming);
				setupEditors();
			}
		});
	}
	
	function showPageZones() {
		$('body').addClass('showing-page-zones');
		$('.page-zone').addClass('shown');
	}
	
	function hidePageZones() {
		$('body').removeClass('showing-page-zones');
		$('.page-zone').removeClass('shown');
	}
	
	function showTemplateZones() {
		$('body').addClass('showing-template-zones');
		$('.template-zone').addClass('shown');
	}
	
	function hideTemplateZones() {
		$('body').removeClass('showing-template-zones');
		$('.template-zone').removeClass('shown');
	}
	
	function showComponents() {
		$('.component').addClass('shown');
	}
	
	function hideComponents() {
		$('.component').removeClass('shown');
	}
	
	function toggleComponents() {
		$('.component').toggleClass('shown');
	}
	
	function showGuides() {
		showPageZones();
		showTemplateZones();
		showComponents();
	}
	
	function hideGuides() {
		hidePageZones();
		hideTemplateZones();
		hideComponents();
	}
	
	function openPanel(panel) {
		panel.parents('.panels').find('div.active.panel').removeClass('active');
		panel.addClass('active');
	}
	
	function pageChanged() {
		saveSave.apply();
	}
	
	function renderPage() {
		console.log('renderPage');
		// $.get(location.pathname, function(data) {
			// $('#viewport').replaceWith(data);
			// refresh();
		// });
	}
	
	function debounce(func, wait, immediate) {
		var timeout;
		return function() {
			var context = this, args = arguments;
			var later = function() {
				timeout = null;
				if (!immediate) func.apply(context, args);
			};
			var callNow = immediate && !timeout;
			clearTimeout(timeout);
			timeout = setTimeout(later, wait);
			if (callNow) func.apply(context, args);
		};
	}
	
	function loadStyles() {
		// FontAwesome for icons etc.
		$('<link>').appendTo('head').attr({type : 'text/css', rel : 'stylesheet'}).attr('href', '//netdna.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css');
		// Main CMS UI styles...
		$('<link>').appendTo('head').attr({type : 'text/css', rel : 'stylesheet'}).attr('href', '/css/cms.css');
		// Styles used by editor (context pop-ups etc.)...
		$('<link>').appendTo('head').attr({type : 'text/css', rel : 'stylesheet'}).attr('href', '/vendor/medium-editor.min.css');
	}
	
	function registerCMSEventListeners() {
		
		// Toggle CMS panels
		$('#cms_ui .toggle').on('click', function() {
			$('html').toggleClass('cms');
		});
		
		// Preview on device
		$('#cms_preview_device').on('change', function() {
			previewAs($(this).val());
		});
		
		// Set correct tab in toolbar
		$('#cms_ui h2').on('click', function() {
			openPanel( $(this).parents('.panel') );
		});
		
		// Allow new components to be dragged onto page (into zones)
		$('.cms_components li').draggable({
			helper: 'clone',
			opacity: 0.33,
			connectToSortable: '.page-zone, .template-zone',
			tolerance: 'pointer',
			snap: true,
			start: showGuides,
			stop: hideGuides
		});
		
		// Hide/show content zones
		$('#cms_show_page_zones').on('click', function() {
			if ($(this).is(':checked')) {
				showPageZones();
			} else {
				hidePageZones();
			}
		});
		
		// Hide/show template zones
		$('#cms_show_template_zones').on('click', function() {
			if ($(this).is(':checked')) {
				showTemplateZones();
			} else {
				hideTemplateZones();
			}
		});
		
		// Hide/show components zones
		$('#cms_show_components').on('click', function() {
			if ($(this).is(':checked')) {
				showComponents();
			} else {
				hideComponents();
			}
		});
		
		// Set number of columns for page
		$('#cms_this_page_columns li').on('click', function() {
			var columns = $(this).attr('data-columns');
			
			$('body').removeClass( "columns-1 columns-2 columns-3 columns-4" ).addClass( "columns-" + columns );
			$('#cms_this_page_columns li').removeClass('active');
			$('#cms_this_page_columns [data-columns='+columns+']').addClass('active');
			
			var page = {};
			page.columns = columns;
			pageChanged();
		});
		
		// Handle inspector based changes
		$('#cms_inspector').on('blur', 'input', function() {
			var n = 'data-prop-' + $(this).attr('name');
			var v = $(this).val();
			currentElement.find('['+n+']').attr(n, v);
			// TODO: XHR rerender component?
			pageChanged();
			renderPage();
		});
		
		// Handle page info changes
		$('#cms_this_page').on('blur', 'input, textarea', function() {
			pageChanged();	
		});
	}
	
	function registerComponentEventListeners() {

		$('#viewport').on('input', '.component', function(){
			pageChanged();
		});
		
		$('#viewport').on('click', '.component', function(){
			inspect($(this));
		});

		$('#viewport').on('click', function(){
			resetInspector();
		});

		// Allow components to be sorted
		$('.page-zone, .template-zone').sortable({
			placeholder: 'block-placeholder',
			handle: '.handle',
			connectWith: '.page-zone, .template-zone',
			tolerance: 'pointer',
			update: function (event, ui) {
				if (ui.item.attr('data-component') !== undefined) {
					$.get('?component=' + ui.item.attr('data-component'), function(data) {
						ui.item.replaceWith(data);
						setupComponentResize(ui.item);
						setupEditors();
						pageChanged();
					});
				}
			},
			start: showGuides,
			stop: hideGuides
		});
		
		// Allow components to be resized
		$('.component').each(setupComponentResize);
		
		// Style up editable components on hover (add drag handles etc.)
		$('#viewport').on('mouseenter', '.component',function() {
			$(this).find('.actions').show();
		}).on('mouseleave', '.component', function() {
			$(this).find('.actions').hide();
		}).on('click', '.component .remove', function() {
			$(this).parents('.component').remove();
			pageChanged();
		});
	}
	
	function init() {
		$this.clientID = ('' + Date.now()).hashCode();
		loadStyles();
		setupEditors();
		registerCMSEventListeners();
		registerComponentEventListeners();
		initPubSub();
		revealCMS();
	}
	
	function setupComponentResize(index, element) {
		$element = $(element);
		var zone = $element.parents('.page-zone, .template-zone');
		var gutterWidth = 20; // Must match CSS
		var containerWidth = zone.width();
		var columnWidth = (containerWidth / 12);
		$element.resizable({
			containment: "parent",
			autoHide: true,
			handles: "e",
			grid: [columnWidth, 1],
			start: function(e, ui) {
				columnWidth = (zone.width() / 12);
				ui.element.resizable( "option", "grid", [columnWidth, 1] );
				var widthIndicator = $('<div class="width"></div>');
				ui.element.append(widthIndicator);
				zone.addClass('resizing');
				ui.element.addClass('current');
			},
			resize: function(e, ui) {
				var columns = 1.0 * ui.element.width() / columnWidth;
				columns = Math.round(columns * 10) / 10; // convert to int
				ui.element.find('.width').text(columns + '/12');
			},
			stop: function(e, ui) {
				zone.removeClass('resizing');
				ui.element.removeClass('current');
				var columns = 1.0 * ui.element.width() / columnWidth;
				columns = Math.round(columns * 10) / 10; // convert to int
				ui.element.removeClass('span1 span2 span3 span4 span5 span6 span7 span8 span9 span10 span11 span12');
				ui.element.removeAttr('style');
				ui.element.addClass('span' + columns);
				ui.element.find('.width').remove();
				pageChanged();
			}
		});
	}
	
	function serialisePage() {
		var page = {};
		var cleanName;
		page.path = window.location.pathname;
		page.title = $('#cms_this_page_title').val();
		page.label = $('#cms_this_page_label').val();
		page.zones = {};
		page.layout_attributes = {};
		page.layout_attributes.zones = {};
		$('.template-zone, .page-zone').each(function(zone_index, zoneElement) {
			var zone = [];
			$(zoneElement).find('.component').each(function(component_index, componentElement) {
				var component = {};
				component.name = $(componentElement).attr('itemtype');
				component.klass = $(componentElement).attr('class').replace(/ui-.*?|resizable(-autohide)?|/g, '').replace(/ {2,}/, ' ').trim();
				// Find itemprops
				$(componentElement).find('[itemprop]').each(function(i, e) {
					component[$(e).attr('itemprop')] = $.trim($(e).html());
				});
				// Find data-props
				$(componentElement).find('.content').find('*').each(function() {
					$.each(this.attributes, function() {
						if(this.specified && this.name.indexOf('data-prop-') === 0) {
							cleanName = this.name.replace('data-prop-','');
							component[cleanName] = this.value;
						}
					});
				});

				zone.push(component);
			});
			if ($(zoneElement).hasClass('template-zone')) {
				page.layout_attributes.zones[$(zoneElement).attr('id')] = zone;
			} else {
				page.zones[$(zoneElement).attr('id')] = zone;
			}
		});
		return page;
	}
	
	// public interface
	
	this.inspect = function(element) {
		currentElement = element;
		$.get( '/@/inspect/' + element.attr('itemtype')).done(function(data) {
			var $inspector = $('#cms_inspector div');
			if (data !== '') {
				$inspector.replaceWith(data);
			} else {
				resetInspector();
			}
		});
	};
	
	this.resetInspector = function() {
		var $inspector = $('#cms_inspector div');
		$inspector.replaceWith('<div class="empty">Click an element on your page to see its details here</div>');
	};
	
	this.savePage = function(page) {
		$.post( page.path, { 'page' : JSON.stringify(page), '_method' : 'patch' }, "json" ).done(function( data ) {
			var channelName = (page.path === '/') ? '/ROOT' : page.path;
			var message = {};
			message.html = $('#viewport').html();
			message.clientID = $this.clientID;
			pubSubClient.publish('/changes' + channelName, message);
		});
	};
	
	this.previewAs = function(what) {
		$('#metaviewport').attr('content', 'width=480');
		$('html').removeClass('native').removeClass('phone').removeClass('tablet').removeClass('laptop').removeClass('desktop');
		$('html').addClass(what);
	};
	
	this.refresh = function() {
		init();
	};

	// Initialisation
	
	init(); 
}();