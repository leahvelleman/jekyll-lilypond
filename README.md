# jekyll-lilypond


Render snippets of lilypond code by placing them within the `{% lilypond %}...{% endlilypond %}` block. 

For example, use this code to render a scale with alt-text for accessibility.

```
Here is some music.

{% lilypond alt:'A C-Major scale' %} c d e f g a b c {% endlilypond %}
```

The plugin generates a PNG image and includes it in the output page.

## Installation

The plugin requires Lilypond and ImageMagick. To use it in a Jekyll site,
add 

```ruby
gem 'jekyll-lilypond'
```

to your Gemfile and

```yaml
plugins:
  - jekyll-lilypond
```

to your `_config.yml`.

## Quick start

Inside the block, write a Lilypond music expression.
```
{% lilypond alt: "Five notes of the A-minor scale" %}
  a b c d e 
{% endlilypond %}
```
The expression can include multiple staves, expressive marks, time and key signature changes, and any of the other notation Lilypond supports within a music
expression
```
{% lilypond %}
  \new PianoStaff <<
    \new Staff { \time 2/4 \key ees \major
      \tempo "siempre stacatto"
      <g bes des' ees'>
      8 8 8 8 8 8 8 8 8 8_> 8 8_> 8 8 8 8
    }
    \new Staff { \clef bass \time 2/4 \key ees \major
      <fes,, aes,, ces, fes, >
      8 8 8 8 8 8 8 8 8 8_> 8 8_> 8 8 8 8
    }
  >>
{% endlilypond %}
```


### Settings

Change settings using tag attributes, including the `alt` attribute we've already seen. 

These attributes affect Lilypond's musical output. 

| Attribute | Purpose | Default |
|---|---|---|
|`lyricfont` | Lyric font | Century Schoolbook |
|`lyricsize` | Lyric size, in Lilypond's internal units | `1` |
|`width` | Width of score | `nil` |
|`height` | Height of score | `nil` |

The default width of `nil` produces a score of unlimited width, with no linebreaks. 

These affect the HTML elements inserted into your finished document. 

| Attribute | Purpose | Default |
|---|---|---|
|`alt` | Alt text | `"A piece of musical notation"` |
|`class` | Class attribute | `"jekyll-lilypond"` |
|`style` | Style attribute | empty |
|`caption` | Figure caption | empty |

Finally, you can control whether the plugin inserts a `figure` element or just a bare `img` element. The default is an `img`. Specify `include_template: figure`
for a `figure`. The `caption` attribute only has an effect on `figure` elements.

### Choosing a font

If you find that horizontal spacing is uneven in passages with lyrics, the solution is often to choose a narrower lyric font, so that long words don't
cause note spacing to "bulge" as much. Times is fairly narrow, and the free font Brill and the nonfree Minion Pro Condensed are both attractive options 
that are narrower still.

The font you choose must be installed locally. 

## Testing

`bundle exec rspec` runs tests. A minimal sample Jekyll site for tests to call on is in `spec/fixtures`, 
with the interesting details being the sample templates in `spec/fixtures/layouts`.
