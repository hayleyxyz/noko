<?php

namespace Noko\Providers;

use Illuminate\Routing\Route;
use Illuminate\Support\ServiceProvider;
use Noko\Models\Board;

class BoardServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap the application services.
     *
     * @return void
     */
    public function boot()
    {
        app()->bind('board', function() {
            /** @var Route $route */
            $route = app('router')->current();

            if($route->hasParameter('board')) {
                $boardName = $route->parameter('board');
                $board = Board::where('name', '=', $boardName)->firstOrFail();
                return $board;
            }
        });
    }

    /**
     * Register the application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }
}
