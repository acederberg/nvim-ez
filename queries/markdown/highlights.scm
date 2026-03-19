;;extends

; Quarto in Quarto
(
  (
   fenced_code_block
    (info_string (language) @_lang)
    (#eq? @_lang "quarto")
  )
  @fenced_code_block.quarto
)


; Python in Quarto
(
  (
   fenced_code_block
    (info_string (language) @_lang)
    (#eq? @_lang "python")
    (code_fence_content) 
  )
  @fenced_code_block.python
)

; Default in Quarto
(
  (
    fenced_code_block
    (info_string (language) @_lang)
    (#eq? @_lang "default")
    (code_fence_content)
  )
  @fenced_code_block.default
)

; HTML in Quarto
(
  (
    fenced_code_block
    (info_string (language) @_lang)
    (#eq? @_lang "=html")
  )
  @fenced_code_block.html
)

(
  (
    fenced_code_block
    (info_string (language) @_lang)
    (#eq? @_lang "html")
  )
  @fenced_code_block.html
)

; Mermaid in Quarto
(
  (
    fenced_code_block
    (info_string (language) @_lang)
    (#eq? @_lang "mermaid")
  )
  @fenced_code_block.mermaid
)


(
  (
    (paragraph) @_
    (#match? @_ "^:::+ *(\\{ *.* *\\})?$")
  )
  @fence.start
)

(
  (
    (paragraph) @_
    (#match? @_ "^:::+ *$")
  )
  @fence.stop
)

