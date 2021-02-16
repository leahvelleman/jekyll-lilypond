# jekyll-lilypond


Render snippets of lilypond code by placing them within the `{% lilypond %}...{% endlilypond %}` block. 

For example, use this code to render a scale with alt-text for accessibility.

```
Here is some music.

{% lilypond alt:'A C-Major scale' %} c d e f g a b c {% endlilypond %}
```

TODO: The plugin generates a SVG image and includes it in the output page.

## Installation

The plugin requires TK what version of Lilypond TK what version of timidity. 

## Usage

### Writing music

Inside the block, write a Lilypond music expression, which can be simple 
```
{% lilypond alt: "Five notes of the A-minor scale" %}
  a b c d e 
{% endlilypond %}
```
or complex.
```
{% lilypond alt: "A deceptive cadence" %}
  TODO MORE COMPLICATED EXAMPLE
{% endlilypond %}
```

To generate an mp3 file as well as an image, use `mp3: true`.
```
{% lilypond alt: "SOMETHING", mp3: true %}
  TODO
{% endlilypond %}
```

(If you are an advanced Lilypond user and you need to write code other
than music expressions — for instance, if you want access to the `\paper`
or `\layout` blocks — use the `raw` attribute or write an input template.)


### Settings

Change settings using tag attributes, including the `alt` and `mp3` attributes we've already seen. 

These affect Lilypond's musical output. 

| Attribute | Purpose | Default |
|---|---|---|
|`mp3` | Whether to generate an mp3 | `false` |
|`tempo` | Tempo of mp3 if one is generated, in quarter notes per minute | `120` |
|`lyricfont` | Lyric font | Century Schoolbook |
|`lyricsize` | Lyric size, in Lilypond's internal units | `1` |
|`width` | Width of score | `nil`, which produces no line breaks |

These affect the appearance rendered HTML.

| Attribute | Purpose | Default |
|---|---|---|
|`alt` | Alt text | `"A piece of musical notation"` |
|`class` | Class attribute | `"jekyll-lilypond"` |
|`style` | Style attribute | empty |
|`caption` | Figure caption | empty |

In addition, you can determine how much structure Jekyll puts around the image tag. `template: basic`
produces only an image with the specified class, style, and alt-text. (Note that this prevents the `mp3` and `caption` 
attributes from working.) `template: regular` adds a `figure` element, a figure caption, and a button to play an mp3.


### Choosing a font

If you find that horizontal spacing is uneven in passages with lyrics, the solution is often to choose a narrower lyric font, so that long words don't
cause note spacing to "bulge" as much. Times is fairly narrow, and the free font Brill and the nonfree Minion Pro Condensed are both attractive options 
that are narrower still.

The font you choose must be installed locally. 

## Advanced usage

Behind the scenes, the plugin uses 



You can write your own layout. TO CHECK Put it in your site `_includes` directory, and specify it by filename. For instance, if your template file
is `_includes/extra_fancy.html`, your opening tag should be `{% lilypond template: extra_fancy %}`. In your template file, refer to the generated image, 
MIDI file, and mp3 as `{{ filename }}.png`, `{{ filename }}.midi`, and `{{ filename }}.mp3`.

Any attribute you pass to the tag is available for use in a template, not just the officially supported ones. For instance, if your opening tag is
`{% lilypond foo: bar %}` and your template contains `<img src="{{ filename }}.png"/> {{ foo }}`, it will produce an image element followed by the word "bar".

### Lilypond templates

If you are an advanced Lilypond user, you can also write an *input template* for the source file that is passed to Lilypond. 

As with regular templates, if you do this, any attribute you pass to the tag will become available to your input template. On the other hand,
most "official" attributes will stop working unless you reimplement them. For instance, mp3 generation depends on MIDI output, so `mp3: true` 
could result in a broken link unless you write your own `\midi` block in your input template. 

### Raw mode



* `raw` — TODO: Whether to discard the built-in Lilypond template, defaulting to `false`

If you do this, you're on your own: all attributes except `alt`, `class`, `style`, and `caption` will stop working, and
you will instead need to specify font, size, and so on using your own Lilypond code that you write. 


## Testing

`bundle exec rspec` runs tests. A minimal sample Jekyll site for tests to call on is in `spec/fixtures`, 
with the interesting details being the sample templates in `spec/fixtures/layouts`.
