; extends

; Jinja Template expressions
; String containing {{ }}
(
 (double_quote_scalar) @injection.content
 (#match? @injection.content "\\{\\{.*\\}\\}")
 (#set! injection.language "jinja")
)

(
 (single_quote_scalar) @injection.content
 (#match? @injection.content "\\{\\{.*\\}\\}")
 (#set! injection.language "jinja")
)

(
 (block_scalar) @injection.content
 (#match? @injection.content "\\{\\{.*\\}\\}")
 (#set! injection.language "jinja")
)


; Special fields in ansible `YAML`.
; NOTE(acederberg): Not that helpful since this is not pure jinja, rather
;                   these should be treated as jinja render expressions.
;                   Instead, I will use after/yaml to hightlight these.



; Inline dockerfiles
(
 (block_mapping_pair
   key: (flow_node
          (plain_scalar
            (string_scalar) @key))
   value: (block_node
            (block_scalar) @injection.content
      )
    )
 (#eq? @key "dockerfile_inline")
 (#set! injection.language "dockerfile")
)


