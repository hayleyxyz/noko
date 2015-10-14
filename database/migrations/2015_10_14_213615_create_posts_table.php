<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreatePostsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('posts', function(Blueprint $table) {
            $table->increments('id');
            $table->unsignedInteger('board_id');
            $table->foreign('board_id')->references('id')->on('boards');
            $table->unsignedInteger('board_post_index');
            $table->unique([ 'board_id', 'board_post_index' ]);
            $table->unsignedInteger('parent_id')->nullable();
            $table->foreign('parent_id')->references('id')->on('posts');
            $table->string('subject')->nullable();
            $table->string('email')->nullable();
            $table->string('name')->nullable();
            $table->string('tripcode')->nullable();
            $table->string('capcode')->nullable();
            $table->text('body');
            $table->timestamp('bumped_at');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::drop('posts');
    }
}
