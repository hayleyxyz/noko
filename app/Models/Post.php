<?php
/**
 * Created by PhpStorm.
 * User: oscar
 * Date: 14/10/2015
 * Time: 22:42
 */

namespace Noko\Models;


use Illuminate\Database\Eloquent\Model;

class Post extends Model {

    public function scopeIsThread($query) {
        return $query->whereNull('parent_id');
    }

}