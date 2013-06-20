
angular.module('boxen-web', [])
	.filter('moment', function() {
	    return function(dateString) {
	    	if(dateString)
	        	return moment(dateString).fromNow();
	    };
	})
	.filter('outdated', function() {
	    return function(array) {
	    	return _.filter(array, function(m){ return !m.updated})
	    };
	});

angular.module('boxen-web')
	.controller('BoxenModules', ['$scope', '$http', '$q', function($scope, $http, $q){

		// Private
		var checkAllModules = function(){
			// Only check old checked
			var to_check = _.filter($scope.modules, function(m){ return !m.last_check || moment().diff(moment(m.last_check), 'days') > 1});

			var check_next = function(){
				if(to_check.length > 0)
					$scope.checkModule(to_check[0].name).then(function(){
						to_check.shift();
							check_next();
					});
			}

			check_next();
		}

	    $http({method: 'GET', url: '/api/modules'}).
	  		success(function(data, status, headers, config) {
	  			$scope.modules = data;

	  			checkAllModules();
	  		});

		// Scope
		//
		$scope.checkModule = function(name){
			var deferred = $q.defer();

			$http({method: 'GET', url: '/api/modules/' + name}).
		  		success(function(data, status, headers, config) {
		  			var to_update = _.find($scope.modules, function(m){ return m.name === data.name});
		  			to_update.updated = data.updated;
		  			to_update.last_check = data.last_check;
		  			to_update.last_version = data.last_version;

		  			deferred.resolve();
		  		});

		  	return deferred.promise;
		}

		$scope.checkDiff = function(name){

			$http({method: 'GET', url: '/api/modules/' + name + "/changes"}).
		  		success(function(data, status, headers, config) {

		  			var to_check = _.find($scope.modules, function(m){ return m.name === data.name});
		  			to_check.changes = data.changes;

		  		});

		}
	}]);

