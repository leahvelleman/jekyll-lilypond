\version "2.20.0"
\paper {
  indent = 0\mm
  short-indent = 0\mm
  {% if width %}
    paper-width = {{ width }}\in
    {% if height %}
      paper-height = {{ height }}\in
    {% else %}
      page-breaking = #ly:one-page-breaking
    {% endif %}
  {% else %}
    page-breaking = #ly:one-line-breaking
  {% endif %}
  left-margin = 4\mm
  right-margin = 4\mm
  top-margin = 4\mm
  bottom-margin = 4\mm
  oddHeaderMarkup = ##f
  evenHeaderMarkup = ##f
  oddFooterMarkup = ##f
  evenFooterMarkup = ##f
}
\score {
  { {{ content }} }
  \layout { 
    #(layout-set-staff-size 17)
    \context {
      \Lyrics
      {% if lyricfont %}
        \override LyricText #'font-name = #"{{ lyricfont }}"
      {% endif %}
      {% if lyricsize %}
        \override LyricText #'font-size = #{{ lyricsize }}
      {% endif %}
    }
  }
  \midi { 
    \tempo 4 = {{ tempo | default: "120" }}
  }
}
