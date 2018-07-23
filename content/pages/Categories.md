+++
date = "2018-06-11T21:48:51-07:00"
title = ""
draft = true
+++

<div class="blog-sidebar">
    {{ if default true .Site.Params.sidebar.showRecent }}
        {{ partial "recent" . }}
    {{ end }}
    {{ if default true .Site.Params.sidebar.showTaxonomy }}
        {{ partial "taxonomies" . }}
    {{ end }}
</div>
