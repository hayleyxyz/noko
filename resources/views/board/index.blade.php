board.index

@foreach($posts as $post)
    <p>
        {{ $post->body }}
    </p>
@endforeach