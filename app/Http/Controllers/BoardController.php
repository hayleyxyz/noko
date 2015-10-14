<?php
/**
 * Created by PhpStorm.
 * User: oscar
 * Date: 14/10/2015
 * Time: 22:07
 */

namespace Noko\Http\Controllers;


use Noko\Models\Board;

class BoardController extends Controller {

    public function index() {
        /** @var Board $board */
        $board = app('board');

        $posts = $board->posts()
            ->isThread()
            ->paginate();

        return view('board.index')
            ->with('posts', $posts);
    }

}