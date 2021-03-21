# jekyll-lilypond

<img src="files/rite.png" width="75%" style="margin: 1em auto !important;"/>

Automatically generate sheet music images by adding Lilypond blocks to your markdown files. Customize the images
and the HTML markup surrounding them using Liquid attributes — for instance, by using the `alt` attribute to
specify alt text.

For complete documentation, see [the plugin website](https://www.velleman.org/jekyll-lilypond).


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
expression. For details, see [this brief summary](https://lilypond.org/doc/v2.20/Documentation/learning/score-is-a-_0028single_0029-compound-musical-expression) in the Lilypond teaching manual or [Wikipedia's list of common music expression details](https://en.wikipedia.org/wiki/Help:Score#Syntax).
```
{% lilypond alt: "The beginning of the second movement" %}
  \new PianoStaff <<
    \new Staff { \time 2/4 \key ees \major
      \tempo "siempre staccato"
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

To make customizations that can't be make within a music expression — for instance, to change the width or height of the score or specify a custom font —
use attributes on the `{% lilypond %}` tag. For more information on attributes, see [the plugin documentation](http://127.0.0.1:4000/jekyll-lilypond#attributes).

## Approach

### Caching

Lilypond runs more slowly than Jekyll, and regenerating every score would create a noticeable lag. This would be especially painful in auto-regenerate mode,
which is normally very responsive. To solve this, I cache images. Each Lilypond source file, and each resulting image, has a filename derived from the MD5 hash
of the source code. The plugin only compiles a Lilypond source file when the corresponding image does not yet exist. 

To force the plugin to regenerate all of the score images for a site, which is sometimes useful for debugging, empty the `lilypond_files` directory. 

To keep upload size to a minimum, you can also empty the `lilypond_files` directory and regenerate the site before deploying. This removes "stale" images 
that are no longer in use.

### Templates

The plugin generates two kinds of code: Lilypond source files, which it uses to generate images, and HTML includes, which appear in the finished page
and contain the `img` element and surrounding markup. 

To generate both kinds of source code, it uses Liquid templates. Liquid is the native templating language of Jekyll. Just as Jekyll users can write their own
templates to create new page layouts, users of this plugin can write their own templates to add simple features and customizations.

In Lilypond source, using a template avoids the need to repeat boilerplate. For instance, the default Lilypond template begins like this:
```
\version "2.20.0"
\paper {
  indent = 0\mm
  short-indent = 0\mm
  bottom-margin = 4\mm
  oddHeaderMarkup = ##f
  evenHeaderMarkup = ##f
  oddFooterMarkup = ##f
  evenFooterMarkup = ##f
```
These settings produce clean output without extraneous marks, headers, footers, or whitespace, but it would be a hassle to retype them in every Lilypond block.
Later parts of the template include correct code for setting the page width, font, and so on, which saves the user from needing to remember the somewhat 
arbitrary syntax for doing those things.

In HTML includes, using templates makes it possible to customize markup. For instance, one built-in template inserts a bare image into the finished page,
another wraps it in a `figure` element and provides a caption, and so on. 

## Testing

`bundle exec rspec` runs tests. A minimal sample Jekyll site for tests to call on is in `spec/fixtures`, 
with the interesting details being the sample templates in `spec/fixtures/layouts`.
