String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
};

var cms = function() {
	
	// Private variables

    var $this = this, currentElement = null, needsSave = false;
	
	// Private functions
	
	function setupEditors() {
		inlineEditor = new MediumEditor(
			'[data-editor="inline"]',
			{
				disableReturn: true,
				cleanPastedHTML: true,
				buttonLabels: 'fontawesome',
				buttons: ['bold', 'italic', 'anchor', 'strikethrough'],
			}
		);
		
		inlineEditor = new MediumEditor(
			'[data-editor="block"]',
			{
				cleanPastedHTML: true,
				buttonLabels: 'fontawesome',
				buttons: ['bold', 'italic', 'anchor', 'strikethrough'],
			}
		);
		
		blockEditor = new MediumEditor(
			'[data-editor="full"]',
			{
				cleanPastedHTML: true,
				buttonLabels: 'fontawesome',
				buttons: ['header1', 'header2', 'orderedlist', 'unorderedlist', 'bold', 'italic', 'anchor', 'strikethrough'],
				firstHeader: 'h2',
				secondHeader: 'h3'
			}
		);
	}
	
	function toggleCMS() {
		$('html').toggleClass('cms');
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
		panel.parents('.panels').find('.active').removeClass('active');
		panel.addClass('active');
	}
	
	function pageChanged() {
		needsSave = true;
		savePage();
	}
	
	function registerEventListeners() {
		
		// Toggle CMS panels
		$('#cms_ui .toggle').on('click', function() {
			$('html').toggleClass('cms');
		});
		
		$(document).keypress(function(e) {
			// console.log(e.which);
			// press 'e'
			if(e.which == 101) {
				toggleCMS();
			}
			// press c
			if(e.which == 99) {
				toggleComponents();
			}
		});
		
		$('#cms_preview_device').on('change', function() {
			previewAs($(this).val());
		});
		
		// Save page upon change to component content via input (i.e. typing)
		$('.component').on('input', function() {
			pageChanged();
		});
		
		// Set correct tab in toolbar
		$('#cms_ui h2').on('click', function() {
			openPanel( $(this).parents('.panel') );
		});
		
		// Inspect components
		$('.component').on('click', function() {
			$this.inspect($(this));
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
						$this.refresh();
						pageChanged();
					});
				}
			},
			start: showGuides,
			stop: hideGuides
		});
		
		// Allow componets to be resized
		$('.component').each(function() {
			var zone = $(this).parents('.page-zone, .template-zone');
			$(this).resizable({
				containment: "parent",
				autoHide: true,
				handles: "e",
				grid: [zone.width() / 12, 1],
				start: function(e, ui) {
					var widthIndicator = $('<div class="width"></div>');
					ui.element.append(widthIndicator);
					zone.addClass('resizing');
				},
				resize: function(e, ui) {
					var columns = (ui.element.width() / zone.width()) * 12;
					columns = columns | 0; // convert to int
					ui.element.find('.width').text(columns + '/12');
				},
				stop: function(e, ui) {
					zone.removeClass('resizing');
					var columns = (ui.element.width() / zone.width()) * 12;
					columns = columns | 0; // convert to int
					ui.element.removeClass('span1 span2 span3 span4 span5 span6 span7 span8 span9 span10 span11 span12');
					ui.element.removeAttr('style');
					ui.element.addClass('span' + columns);
					ui.element.find('.width').remove();
					pageChanged();
				}
			});
		});
		
		// Style up editable components on hover (add drag handles etc.)
		$('.component').on('mouseenter', function() {
			$(this).find('.actions').show();
		}).on('mouseleave', function() {
			$(this).find('.actions').hide();
		});
		
		$('.component').on('click', '.remove', function() {
			$(this).parents('.component').remove();
			pageChanged();
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
		
		// Handle inspector based changes
		$('#cms_inspector').on('blur', 'input', function() {
			var n = $(this).attr('name');
			var v = $(this).val();
			currentElement.find('[data-inspectable=true]').attr(n, v);
		});
	}
	
	function init() {
		setupEditors();
		registerEventListeners();
	}
	
    // public interface
	
	this.inspect = function(element) {
		currentElement = element;
		var $fieldPrototype = $('<p><label></label><input type="text" name="" value=""></p>');
		var $fields = $('<div></div>');
		var $inspector = $('#cms_inspector div');
		var swap = false;
		$('#cms_inspector legend span').text(element.attr('itemtype').capitalize());
		// TODO: this doesn't really deal with multiple elements properly
		element.find('[data-inspectable=true]').each(function() {
			$.each(this.attributes, function() {
				if(this.specified && this.name != 'data-inspectable') {
					$fieldPrototype.find('label').text(this.name);
					$fieldPrototype.find('input').attr('name', this.name);
					$fieldPrototype.find('input').attr('value', this.value);
					$fields.append($fieldPrototype.clone());
					swap = true;
				}
			});
		});
		$inspector.replaceWith($fields);
	};
	
	this.savePage = function() {
		if (needsSave) {
			var page = {};
			page.path = window.location.pathname;
			page.title = document.title;
			page.zones = {};
			page.layout_attributes = {};
			page.layout_attributes.zones = {};
			$('.template-zone, .page-zone').each(function(zone_index, zoneElement) {
				var zone = [];
				$(zoneElement).find('.component').each(function(component_index, componentElement) {
					var component = {};
					component.name = $(componentElement).attr('itemtype');
					component.klass = $(componentElement).attr('class');
					$(componentElement).find('[itemprop]').each(function(i, e) {
						component[$(e).attr('itemprop')] = $.trim($(e).html());
					});
					zone.push(component);
				});
				if ($(zoneElement).hasClass('template-zone')) {
					page.layout_attributes.zones[$(zoneElement).attr('id')] = zone;
				} else {
					page.zones[$(zoneElement).attr('id')] = zone;
				}
			});
			// console.log(JSON.stringify(page));
			$.post( page.path, { 'page' : JSON.stringify(page) }, "json" ).done(function( data ) {
				needsSave = false;
			});
		}
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