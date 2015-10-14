<?php

Route::group([ 'prefix' => '{board}' ], function() {

    Route::get('/', [ 'as' => 'index', 'uses' => 'BoardController@index' ]);

});