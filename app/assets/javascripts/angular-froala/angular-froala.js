'use strict';

angular.module('froala', []).
	value('froalaConfig', {
		key: '6Ud1QBRVCDLPAZMBQ==',
    inlineMode: false,
    heightMin: 200,
    toolbarButtons: [ 'bold', 'italic', 'underline', 'paragraphFormat', 'insertTable', 'formatOL', 'formatUL','align', 'outdent', 'indent', 'insertLink', 'undo', 'redo', 'clearFormatting', 'image', 'insertVideo', 'html' ],
		toolbarButtonsSM: ['bold', 'italic', 'underline', 'paragraphFormat'],
	  toolbarButtonsXS: ['bold', 'italic', 'underline'],
	  toolbarButtonsMD: ['bold', 'italic', 'underline', 'paragraphFormat', 'insertTable', 'formatOL', 'formatUL','align', 'outdent', 'indent', 'insertLink', 'undo', 'redo', 'clearFormatting', 'image', 'insertVideo', 'html'],
    placeholderText: 'Enter text here...'
	}).
	directive('froala', ['froalaConfig', '$timeout', function(froalaConfig, $timeout) {
		froalaConfig = froalaConfig || {};
		var froalaEvents = ['afterPaste','afterRemoveImage','afterSave','afterUploadPastedImage','align','badLink','beforeDeleteImage','beforeImageUpload','beforePaste','beforeRemoveImage','beforeSave','blur','bold','cellDeleted','cellHorizontalSplit','cellInsertedAfter','cellInsertedBefore','cellVerticalSplit','cellsMerged','columnDeleted','columnInsertedAfter','columnInsertedBefore','contentChanged','fileError','focus','formatBlock','htmlHide','htmlShow','imageAltSet','imageDeleteError','imageDeleteSuccess','imageError','imageFloatedLeft','imageFloatedNone','imageFloatedRight','imageInserted','imageLinkInserted','imageLinkRemoved','imageLoaded','imageReplaced','imagesLoadError','imagesLoaded','indent','initialized','italic','linkInserted','linkRemoved','onPaste','orderedListInserted','outdent','redo','rowDeleted','rowInsertedAbove','rowInsertedBelow','saveError','selectAll','strikeThrough','subscript','superscript','tableDeleted','tableInserted','underline','undo','unorderedListInserted','videoError','videoFloatedLeft','videoFloatedNone','videoFloatedRight','videoInserted','videoRemoved'];
		var generatedIds = 0;
		var slugToEventName = function(slug){
			if(slug.search('froalaEvent') >= 0){
				slug = slug.replace('froalaEvent', '');
				return slug.charAt(0).toLowerCase() + slug.slice(1);
			}else{
				//not presented as a froala event
				return false;
			}
		}
		var eventNameToSlug = function(eventName){
			var slug = 'froalaEvent' + eventName.charAt(0).toUpperCase() + eventName.slice(1);
			return slug;
		}

		var scope = {
			froala : '='
		};

		for (var i = 0; i < froalaEvents.length; i++) {
		   scope[froalaEvents[i]] = '=' + eventNameToSlug(froalaEvents[i]);
		}

		return {
			restrict: 'A',
			require: 'ngModel',
			scope: scope,
			link: function(scope, element, attrs, ngModel) {
				if(!(element instanceof jQuery)){
					throw "Froala requires jQuery, are you loading it before Angular?";
				}

				var defaultOptions = {};
				var contentChangedCallback;
				var options = angular.extend({}, froalaConfig, scope.froala);
				if(options.contentChangedCallback){
					contentChangedCallback = options.contentChangedCallback;
					delete options.contentChangedCallback;
				}

				// generate an ID if not present
        if (!attrs.id) {
          attrs.$set('id', 'froala-' + generatedIds++);
        }

				var updateView = function () {
					var returnedHtml = element.froalaEditor('html.get');
					var theHTML;
					if(angular.isArray(returnedHtml) && angular.isString(returnedHtml[0])){
						theHTML = returnedHtml[0];
					}else if(angular.isString(returnedHtml)){
						theHTML = returnedHtml;
					}else{
						console.error('We received an unexpected format for the html');
						return;
					}

					ngModel.$setViewValue(theHTML);
					if (!scope.$root.$$phase) {
						scope.$apply();
					}
				};

				options.contentChangedCallback = function () {
					if(contentChangedCallback)
						contentChangedCallback();
					updateView();
				};

				ngModel.$render = function(){
					element.froalaEditor('html.set', ngModel.$viewValue || '', true);
				};

				var froala = element.froalaEditor(options).data('froala.editor');

				froala.$el.on('blur keyup change', function(e){
					updateView();
				});

				var registerEventAndCallback = function(eventName, callback){
			  	if(eventName && callback){
			  		var el;
			  		var realEventName;

			  		if(froalaEvents.indexOf(eventName) > -1){
			  			el = element;
			  			realEventName = 'froalaEditor.' + eventName;
			  		}else{
			  			el = froala.$element;
			  			realEventName = eventName;
			  		}

			  		el.on(realEventName, callback);
			  	}
				}

				//register passed events
				for (var key in attrs) {
				  if (attrs.hasOwnProperty(key)) {
				  	var eventName = slugToEventName(key); //returns false if not an event
				  	if(eventName){
				  		registerEventAndCallback(eventName, scope[eventName]);
				  	}
				  }
				}

				for(var key in options.events){
					if (options.events.hasOwnProperty(key)) {
						registerEventAndCallback(key, options.events[key]);
					}
				}

				// the froala instance to the options object to make methods available in parent scope
				if(scope.froala){
					scope.froala.froala = angular.bind(element, $(attrs.id).froalaEditor);
				}

				scope.$watch('froala', function(n, o){
					for (var key in n) {
						if (n.hasOwnProperty(key)) {
							if(n[key] != o[key]){
								element.froalaEditor('option', key, n[key]);
							}
						}
					}
				}, true);

				scope.$on('$destroy', function(){
					froala['destroy']();
				});
			}
		};
 }]);
