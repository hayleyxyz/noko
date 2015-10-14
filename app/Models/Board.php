<?php
/**
 * Created by PhpStorm.
 * User: oscar
 * Date: 14/10/2015
 * Time: 22:02
 */

namespace Noko\Models;


use Illuminate\Database\Eloquent\Model;

class Board extends Model {

    public function posts() {
        return $this->hasMany(Post::class);
    }

}