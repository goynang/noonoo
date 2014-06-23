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
	
	function showZones() {
		$('.zone').addClass('shown');
	}
	
	function hideZones() {
		$('.zone').removeClass('shown');
	}
	
	function showComponents() {
		$('.component').addClass('shown');
	}
	
	function hideComponents() {
		$('.component').removeClass('shown');
	}
	
	function showGuides() {
		showZones();
		showComponents();
	}
	
	function hideGuides() {
		hideZones();
		hideComponents();
	}
	
	function openPanel(panel) {
		panel.parents('form').find('.active').removeClass('active');
		panel.addClass('active');
	}
	
	function openInspector() {
		openPanel( $('#cms_inspector') );
	}
	
	function pageChanged() {
		needsSave = true;
		$('#cms_save_page').removeAttr('disabled');
	}
	
	function registerEventListeners() {
		// Save page upon change to component content via input (i.e. typing)
		$('.component').on('input', function() {
			pageChanged();
		});
		
		// Set correct tab in toolbar
		$('#cms_ui legend span').on('click', function() {
			openPanel( $(this).parent().parent() );
		});
		
		// Inspect components
		$('.component').on('click', function() {
			$this.inspect($(this));
		});
		
		// Allow new components to be dragged onto page (into zones)
		$('.cms_components li').draggable({
			helper: 'clone',
			opacity: 0.33,
			connectToSortable: '.zone',
			tolerance: 'pointer',
			snap: true,
			start: showGuides,
			stop: hideGuides
		});
    
		// Allow components to be sorted
		$('.zone').sortable({
			placeholder: 'block-placeholder',
			handle: '.handle',
			connectWith: '.zone',
			tolerance: 'pointer',
			update: function (event, ui) {
				if (ui.item.attr('data-component') !== undefined) {
					$.get('/components/' + ui.item.attr('data-component'), function(data) {
						ui.item.replaceWith(data);
						$this.refresh();
						pageChanged();
					});
				}
			},
			start: showGuides,
			stop: hideGuides
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
		$('#cms_show_zones').on('click', function() {
			if ($(this).is(':checked')) {
				showZones();
			} else {
				hideZones();
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
		
		// Handle save request
		$('#cms_save_page').on('click', $this.savePage);
		pageChanged();
	}
	
	function init() {
		setupEditors();
		registerEventListeners();
		$('#cms_save_page').attr('disabled','disabled');
	}
	
    // public interface
	
	this.inspect = function(element) {
		currentElement = element;
		openInspector();
		var $fieldPrototype = $('<p><label></label><input type="text" name="" value=""></p>');
		var $fields = $('<div></div>');
		var $inspector = $('#cms_inspector div');
		// TODO: this doesn't really deal with multiple elements properly
		element.find('[data-inspectable=true]').each(function() {
			$.each(this.attributes, function() {
				if(this.specified && this.name != 'data-inspectable') {
					$fieldPrototype.find('label').text(this.name);
					$fieldPrototype.find('input').attr('name', this.name);
					$fieldPrototype.find('input').attr('value', this.value);
					$fields.append($fieldPrototype.clone());
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
			page.content = {};
			$('.zone').each(function(zone_index, zoneElement) {
				var zone = [];
				$(zoneElement).find('.component').each(function(component_index, componentElement) {
					var component = {};
					component.name = $(componentElement).attr('itemtype');
					$(componentElement).find('[itemprop]').each(function(i, e) {
						component[$(e).attr('itemprop')] = $.trim($(e).html());
					});
					zone.push(component);
				});
				page.content[$(zoneElement).attr('id')] = zone;
			});
			$.post( page.path, { 'page' : JSON.stringify(page) }, "json" ).done(function( data ) {
				needsSave = false;
				$('#cms_save_page').attr('disabled','disabled');
			});
		}
	};
	
	this.refresh = function() {
		init();
	};

	// Initialisation
	
	init();	
}();