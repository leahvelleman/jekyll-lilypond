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

The block expects its contents to be lilypond code, and it compiles that code to produce an image, which it 
inserts into the rendered page. TODO If you use the `mp3` attribute, it also generates an mp3 file and inserts
a link to it.

The contents of the block must be Lilypond music expressions. TODO The block inserts a version statement, a `\paper` and
`\layout` block, and other niceties, so that simple examples like this work without errors.
```
{% lilypond alt: "Five notes of the A-minor scale" %}
  a b c d e 
{% endlilypond %}
```
As do more complex music expressions.
```
{% lilypond alt: "A deceptive cadence" %}
  TODO MORE COMPLICATED EXAMPLE
{% endlilypond %}
```
TODO To write your own Lilypond file fromt scratch — for instance, if you want to write
your own `\header`, `\paper`, or `\layout` blocks — use the `raw` attribute. 

### Attributes

Use attributes in the Lilypond tag to affect the rendered image, the mp3
if one is generated, and the HTML that contains them. For instance, 
this code TODO DOES SOMETHING

TODO

These attributes are recognized by default.

* `alt` — TODO: The alt text for the image, defaulting to "A piece of musical notation" if not specified
* `class` — TODO: The class attribute for the image tag, defaulting to "jekyll-lilypond"
* `style` — TODO: The style attribute for the image tag, defaulting to empty
* `caption` — TODO:
* `mp3` — TODO: Whether to generate an mp3, defaulting to `false`
* `tempo` — TODO: Tempo of generated mp3, where a value of `120` means ♩=120
* `lyricfont` — TODO: The font to use for typesetting lyrics, defaulting to Lilypond's Century Schoolbook-like default
* `lyricsize` — TODO: The font size of lyrics, in Lilypond's idiosyncratic units: `2` is large, `1` is normal, `0` small, `-1` very small, and so on.
* `width` — TODO: The width of the score, in ????. The default value, `nil`, instructs Lilypond to typeset everything on one line, making it as wide as it needs to be.

It may be useful to choose a narrow lyric font, so that wordy passages don't have their spacing distorted. Times is fairly narrow, and the free font Brill and 
the nonfree Minion Pro Condensed are both attractive options that are narrower still.

### Templates

TK layouts

* `basic` — TODO: Only an `img` tag with the specified alt-text, class, and style. The `caption` attribute has no effect in this layout. 
* `regular` (default) — TODO: A `figure` tag containing the image and a caption if one is specified. If `mp3` is `true`, there is also a button to play the generated mp3.
* `fancy` — TODO: IUNNO WHATEVER GO NUTS

You can write your own layout. TO CHECK Put it in your site `_includes` directory, and specify it by filename. For instance, if your template file
is `_includes/extra_fancy.html`, your opening tag should be `{% lilypond template: extra_fancy %}`. In your template file, refer to the generated image, 
MIDI file, and mp3 as `{{ filename }}.png`, `{{ filename }}.midi`, and `{{ filename }}.mp3`.

Any attribute you pass to the tag is available for use in a template, not just the officially supported ones. For instance, if your opening tag is
`{% lilypond foo: bar %}` and your template contains `<img src="{{ filename }}.png"/> {{ foo }}`, it will produce an image element followed by the word "bar".

### Input templates

If you are an advanced Lilypond user, you can also write an *input template* for the source file that is passed to Lilypond. 

As with regular templates, if you do this, any attribute you pass to the tag will become available to your input template. On the other hand,
most "official" attributes will stop working unless you reimplement them. For instance, mp3 generation depends on MIDI output, so `mp3: true` 
could result in a broken link unless you write your own `\midi` block in your input template. 

## Testing

`bundle exec rspec` runs tests. A minimal sample Jekyll site for tests to call on is in `spec/fixtures`, 
with the interesting details being the sample templates in `spec/fixtures/layouts`.
