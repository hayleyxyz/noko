<?php

use Illuminate\Database\Seeder;
use Noko\Models\Board;

class BoardTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        Board::create([
            'name' => 'a',
            'title' => 'anime/random',
        ]);
    }
}
