;;extends

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



